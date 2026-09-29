work_dir=$(pwd)
source "$work_dir/functions.sh"

rom_os=$(cat "$work_dir/bin/ddevice/rom_os.txt" 2>/dev/null)
androidVer=$(cat "$work_dir/bin/ddevice/androidver.txt" 2>/dev/null)

FONT_SOURCE="$work_dir/bin/modfile/UpdateFile/Fonts/HyperOS"
SF_FONT="$FONT_SOURCE/SF-Pro.ttf"

mods "Fonts: keep original ROM fonts"

find_theme_target() {
    local p
    for p in         "$work_dir/build/baserom/images/product/media/theme"         "$work_dir/build/baserom/images/system/system/media/theme"         "$work_dir/build/baserom/images/system/media/theme"; do
        if [ -d "$p" ]; then
            printf '%s\n' "$p"
            return 0
        fi
    done
    return 1
}

install_sfpro_theme() {
    # MiSans/Roboto của ROM tuyệt đối không bị sửa.
    if [ ! -s "$SF_FONT" ]; then
        mods "Font SF Pro theme: SKIP"
        return 0
    fi

    local theme_target
    theme_target=$(find_theme_target) || {
        mods "Font SF Pro theme: ERROR"
        return 1
    }

    local ui_version=16
    [[ "$rom_os" == "OS4" ]] && ui_version=17

    local tmp
    tmp=$(mktemp -d) || {
        mods "Font SF Pro theme: ERROR"
        return 1
    }

    mkdir -p "$tmp/fonts" "$tmp/preview" "$theme_target/.data/meta/fonts" || {
        rm -rf "$tmp"
        mods "Font SF Pro theme: ERROR"
        return 1
    }

    cp -f "$SF_FONT" "$tmp/fonts/Current-Font.ttf" || {
        rm -rf "$tmp"
        mods "Font SF Pro theme: ERROR"
        return 1
    }

    cat > "$tmp/description.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<theme>
  <version>1.0</version>
  <uiVersion>$ui_version</uiVersion>
  <author>Apple</author>
  <designer>Apple</designer>
  <title>SF Pro</title>
  <fontWeight>100,150,200,250,300,350,400,450,500,550,600,650,700,800,900</fontWeight>
  <description>SF Pro Variable font</description>
</theme>
EOF

    # Preview tối thiểu hợp lệ; giao diện Themes vẫn có thể dùng preview mặc định.
    printf '%s' 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Y9ZQmcAAAAASUVORK5CYII='         | base64 -d > "$tmp/preview/preview_fonts_0.png" 2>/dev/null || true

    (
        cd "$tmp" || exit 1
        zip -qr "$theme_target/SF-Pro.mtz" description.xml fonts preview
    ) || {
        rm -rf "$tmp"
        mods "Font SF Pro theme: ERROR"
        return 1
    }

    python3 - "$theme_target" <<'PY'
import json
import os
import sys

theme = sys.argv[1]
src = os.path.join(theme, ".data", "meta", "fonts", "default.mrm")
dst = os.path.join(theme, ".data", "meta", "fonts", "SF-Pro.mrm")

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

data["localId"] = "10010"
data["onlineId"] = None
data["productId"] = None
data["downloadPath"] = "/system/media/theme/SF-Pro.mtz"
data["metaPath"] = "/system/media/theme/.data/meta/fonts/SF-Pro.mrm"
data["contentPath"] = "/system/media/theme/SF-Pro.mtz"
data["status"] = 1
data["hash"] = "0"
data["size"] = 0
data["updatedTime"] = 0
data["title"] = "SF Pro"
data["description"] = "SF Pro Variable font"
data["author"] = "Apple"
data["designer"] = "Apple"
data["version"] = "1.0"

titles = data.get("titles")
if not isinstance(titles, dict):
    titles = {}
for locale in list(titles.keys()):
    titles[locale] = "SF Pro"
titles.update({"en_US": "SF Pro", "vi_VN": "SF Pro", "zh_CN": "SF Pro"})
data["titles"] = titles

authors = data.get("authors")
if not isinstance(authors, dict):
    authors = {}
for locale in list(authors.keys()):
    authors[locale] = "Apple"
authors.update({"en_US": "Apple", "vi_VN": "Apple", "zh_CN": "Apple"})
data["authors"] = authors

designers = data.get("designers")
if not isinstance(designers, dict):
    designers = {}
for locale in list(designers.keys()):
    designers[locale] = "Apple"
designers.update({"en_US": "Apple", "vi_VN": "Apple", "zh_CN": "Apple"})
data["designers"] = designers

os.makedirs(os.path.dirname(dst), exist_ok=True)
with open(dst, "w", encoding="utf-8") as fh:
    json.dump(data, fh, ensure_ascii=False, indent=4)
    fh.write("\n")
PY

    local rc=$?
    rm -rf "$tmp"

    if [ "$rc" -eq 0 ] && [ -s "$theme_target/SF-Pro.mtz" ] && [ -s "$theme_target/.data/meta/fonts/SF-Pro.mrm" ]; then
        mods "Font SF Pro theme: OK"
        return 0
    fi

    mods "Font SF Pro theme: ERROR"
    return 1
}

case "$rom_os" in
    OS1|OS2|OS3|OS4)
        install_sfpro_theme
        ;;
    *)
        mods "Font SF Pro theme: SKIP"
        ;;
esac
