work_dir=$(pwd)
source "$work_dir/functions.sh"

rom_os=$(cat "$work_dir/bin/ddevice/rom_os.txt" 2>/dev/null)

FONT_SOURCE="$work_dir/bin/modfile/UpdateFile/Fonts/HyperOS"
SF_FONT="$FONT_SOURCE/SF-Pro.ttf"

mods "Fonts: keep original ROM fonts"

find_theme_target() {
    local p
    for p in \
        "$work_dir/build/baserom/images/product/media/theme" \
        "$work_dir/build/baserom/images/system/system/media/theme" \
        "$work_dir/build/baserom/images/system/media/theme"; do
        if [ -d "$p" ]; then
            printf '%s\n' "$p"
            return 0
        fi
    done
    return 1
}

find_roboto_font() {
    local f
    for f in \
        "$work_dir/build/baserom/images/system/system/fonts/RobotoVF.ttf" \
        "$work_dir/build/baserom/images/product/fonts/RobotoVF.ttf" \
        "$work_dir/build/baserom/images/system/system/fonts/Roboto-Regular.ttf" \
        "$work_dir/build/baserom/images/product/fonts/Roboto-Regular.ttf"; do
        if [ -s "$f" ]; then
            printf '%s\n' "$f"
            return 0
        fi
    done
    return 1
}

install_font_theme() {
    local font_file="$1"
    local theme_id="$2"
    local title="$3"
    local author="$4"
    local local_id="$5"

    [ -s "$font_file" ] || {
        mods "Font $title theme: SKIP"
        return 0
    }

    local theme_target
    theme_target=$(find_theme_target) || {
        mods "Font $title theme: ERROR"
        return 1
    }

    local ui_version=16
    [[ "$rom_os" == "OS4" ]] && ui_version=17

    local tmp
    tmp=$(mktemp -d) || {
        mods "Font $title theme: ERROR"
        return 1
    }

    mkdir -p "$tmp/fonts" "$tmp/preview" "$theme_target/.data/meta/fonts" || {
        rm -rf "$tmp"
        mods "Font $title theme: ERROR"
        return 1
    }

    cp -f "$font_file" "$tmp/fonts/Current-Font.ttf" || {
        rm -rf "$tmp"
        mods "Font $title theme: ERROR"
        return 1
    }

    cat > "$tmp/description.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<theme>
  <version>1.0</version>
  <uiVersion>$ui_version</uiVersion>
  <author>$author</author>
  <designer>$author</designer>
  <title>$title</title>
  <fontWeight>100,150,200,250,300,350,400,450,500,550,600,650,700,800,900</fontWeight>
  <description>$title Variable font</description>
</theme>
EOF

    printf '%s' 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Y9ZQmcAAAAASUVORK5CYII=' \
        | base64 -d > "$tmp/preview/preview_fonts_0.png" 2>/dev/null || true

    (
        cd "$tmp" || exit 1
        zip -qr "$theme_target/$theme_id.mtz" description.xml fonts preview
    ) || {
        rm -rf "$tmp"
        mods "Font $title theme: ERROR"
        return 1
    }

    python3 - "$theme_target" "$theme_id" "$title" "$author" "$local_id" <<'PY'
import json
import os
import sys

theme, theme_id, title, author, local_id = sys.argv[1:6]
src = os.path.join(theme, ".data", "meta", "fonts", "default.mrm")
dst = os.path.join(theme, ".data", "meta", "fonts", f"{theme_id}.mrm")

try:
    with open(src, "r", encoding="utf-8-sig") as fh:
        data = json.load(fh)
except Exception:
    data = {
        "platform": 8,
        "status": 1,
        "buildInThumbnails": [],
        "buildInPreviews": [],
        "titles": {},
        "authors": {},
        "designers": {},
        "parentResources": [],
        "subResources": [],
        "extraMeta": {}
    }

data["localId"] = local_id
data["onlineId"] = None
data["productId"] = None
data["downloadPath"] = f"/system/media/theme/{theme_id}.mtz"
data["metaPath"] = f"/system/media/theme/.data/meta/fonts/{theme_id}.mrm"
data["contentPath"] = f"/system/media/theme/{theme_id}.mtz"
data["status"] = 1
data["hash"] = "0"
data["size"] = 0
data["updatedTime"] = 0
data["title"] = title
data["description"] = f"{title} Variable font"
data["author"] = author
data["designer"] = author
data["version"] = "1.0"

for key, value in (("titles", title), ("authors", author), ("designers", author)):
    obj = data.get(key)
    if not isinstance(obj, dict):
        obj = {}
    for locale in list(obj.keys()):
        obj[locale] = value
    obj.update({"en_US": value, "vi_VN": value, "zh_CN": value})
    data[key] = obj

os.makedirs(os.path.dirname(dst), exist_ok=True)
with open(dst, "w", encoding="utf-8") as fh:
    json.dump(data, fh, ensure_ascii=False, indent=4)
    fh.write("\n")
PY

    local rc=$?
    rm -rf "$tmp"

    if [ "$rc" -eq 0 ] && \
       [ -s "$theme_target/$theme_id.mtz" ] && \
       [ -s "$theme_target/.data/meta/fonts/$theme_id.mrm" ]; then
        mods "Font $title theme: OK"
        return 0
    fi

    mods "Font $title theme: ERROR"
    return 1
}

case "$rom_os" in
    OS1|OS2|OS3|OS4)
        install_font_theme "$SF_FONT" "SF-Pro" "SF Pro" "Apple" "10010"

        ROBOTO_FONT=$(find_roboto_font || true)
        if [ -n "$ROBOTO_FONT" ]; then
            install_font_theme "$ROBOTO_FONT" "Roboto" "Roboto" "Google" "10011"
        else
            mods "Font Roboto theme: SKIP"
        fi
        ;;
    *)
        mods "Font SF Pro theme: SKIP"
        mods "Font Roboto theme: SKIP"
        ;;
esac
