work_dir=$(pwd)
source "$work_dir/functions.sh"

rom_os=$(cat "$work_dir/bin/ddevice/rom_os.txt" 2>/dev/null)

FONT_SOURCE="$work_dir/bin/modfile/UpdateFile/Fonts/HyperOS"
SF_FONT="$FONT_SOURCE/SF-Pro.ttf"
IOS_EMOJI_FONT="$FONT_SOURCE/NotoColorEmoji.ttf"

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

prepare_roboto_variable() {
    local local_font="$FONT_SOURCE/Roboto-VF.ttf"

    if [ -s "$local_font" ]; then
        printf '%s\n' "$local_font"
        return 0
    fi

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

# Follow the runtime paths declared by the stock font metadata instead of
# hard-coding /system/media/theme. Some HyperOS builds keep the theme tree on
# another partition; a wrong contentPath makes the selector silently fall back
# to the stock MiSans/MiLatin font.
stock_download = data.get("downloadPath")
stock_meta = data.get("metaPath")

if isinstance(stock_download, str) and stock_download.startswith("/") and stock_download.endswith(".mtz"):
    theme_runtime_root = os.path.dirname(stock_download)
else:
    norm = theme.replace("\\", "/")
    if "/images/product/media/theme" in norm:
        theme_runtime_root = "/product/media/theme"
    else:
        theme_runtime_root = "/system/media/theme"

if isinstance(stock_meta, str) and stock_meta.startswith("/") and "/.data/meta/fonts/" in stock_meta:
    font_meta_root = os.path.dirname(stock_meta)
else:
    font_meta_root = f"{theme_runtime_root}/.data/meta/fonts"

data["localId"] = local_id
data["onlineId"] = None
data["productId"] = None
data["downloadPath"] = f"{theme_runtime_root}/{theme_id}.mtz"
data["metaPath"] = f"{font_meta_root}/{theme_id}.mrm"
data["contentPath"] = f"{theme_runtime_root}/{theme_id}.mtz"
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

    if [ "$rc" -ne 0 ] || \
       [ ! -s "$theme_target/$theme_id.mtz" ] || \
       [ ! -s "$theme_target/.data/meta/fonts/$theme_id.mrm" ]; then
        mods "Font $title theme: ERROR"
        return 1
    fi

    if ! unzip -Z1 "$theme_target/$theme_id.mtz" 2>/dev/null \
        | grep -Eq '^fonts/[^/]+[.](ttf|otf)$'; then
        mods "Font $title theme: ERROR (font payload missing)"
        return 1
    fi

    if ! python3 - "$theme_target/.data/meta/fonts/$theme_id.mrm" "$theme_id" "$title" <<'PYVERIFY'
import json
import sys

path, theme_id, title = sys.argv[1:4]
with open(path, "r", encoding="utf-8-sig") as fh:
    data = json.load(fh)

ok = (
    data.get("title") == title
    and bool(str(data.get("localId", "")))
    and str(data.get("downloadPath", "")).endswith(f"/{theme_id}.mtz")
    and str(data.get("contentPath", "")).endswith(f"/{theme_id}.mtz")
    and str(data.get("metaPath", "")).endswith(f"/{theme_id}.mrm")
)
raise SystemExit(0 if ok else 1)
PYVERIFY
    then
        mods "Font $title theme: ERROR (metadata verification failed)"
        return 1
    fi

    mods "Font $title theme: OK (MTZ + metadata verified)"
    return 0

}

install_ios_emoji() {
    [ -s "$IOS_EMOJI_FONT" ] || {
        mods "Emoji iOS: SKIP"
        return 0
    }

    local target
    local count=0
    local failed=0

    while IFS= read -r -d '' target; do
        if cp -f "$IOS_EMOJI_FONT" "$target" >/dev/null 2>&1; then
            count=$((count + 1))
        else
            failed=1
        fi
    done < <(find "$work_dir/build/baserom/images" -type f -name "NotoColorEmoji.ttf" -print0 2>/dev/null)

    if [ "$failed" -eq 0 ] && [ "$count" -gt 0 ]; then
        mods "Emoji iOS: OK"
        return 0
    fi

    mods "Emoji iOS: ERROR"
    return 1
}

case "$rom_os" in
    OS1|OS2|OS3|OS4)
        install_font_theme "$SF_FONT" "SF-Pro" "SF Pro" "Apple" "10010"

        ROBOTO_FONT=$(prepare_roboto_variable || true)
        if [ -n "$ROBOTO_FONT" ]; then
            install_font_theme "$ROBOTO_FONT" "Roboto" "Roboto" "Google" "10011"
        else
            mods "Font Roboto theme: ERROR"
        fi
        ;;
    *)
        mods "Font SF Pro theme: SKIP"
        mods "Font Roboto theme: SKIP"
        ;;
esac

install_ios_emoji
