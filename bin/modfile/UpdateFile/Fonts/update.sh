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
        "$work_dir/build/baserom/images/system_ext/media/theme" \
        "$work_dir/build/baserom/images/system/system/media/theme" \
        "$work_dir/build/baserom/images/system/media/theme"; do
        if [ -d "$p" ]; then
            printf '%s\n' "$p"
            return 0
        fi
    done
    return 1
}

theme_runtime_root_for_target() {
    local target="$1"
    case "$target" in
        "$work_dir/build/baserom/images/product/media/theme")
            printf '%s\n' "/product/media/theme"
            ;;
        "$work_dir/build/baserom/images/system_ext/media/theme")
            printf '%s\n' "/system_ext/media/theme"
            ;;
        "$work_dir/build/baserom/images/system/system/media/theme"|"$work_dir/build/baserom/images/system/media/theme")
            printf '%s\n' "/system/media/theme"
            ;;
        *)
            return 1
            ;;
    esac
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

    local theme_runtime_root
    theme_runtime_root=$(theme_runtime_root_for_target "$theme_target") || {
        mods "Font $title theme: ERROR (unknown theme target)"
        return 1
    }

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

    # HyperOS/MIUI ThemeManager does not treat a variable theme font as only
    # Roboto-Regular.ttf. When a font advertises a fontWeightList it fans the
    # same source font out to the Xiaomi runtime aliases below and, crucially,
    # creates MI_Theme_VF.ttf. Settings/FontSettings uses MI_Theme_VF.ttf to
    # detect a variable theme font and to keep weight changes smooth.
    #
    # Keep the stock ROM font XML/configs untouched. These aliases live only
    # inside the MTZ and are populated from the selected SF Pro/Roboto VF.
    local runtime_fonts=(
        MI_Theme_VF.ttf
        Roboto-Regular.ttf
        Roboto-Italic.ttf
        Roboto-Bold.ttf
        Roboto-BoldItalic.ttf
        Roboto-Light.ttf
        Roboto-LightItalic.ttf
        Roboto-Medium.ttf
        Roboto-MediumItalic.ttf
        Roboto-Black.ttf
        Roboto-BlackItalic.ttf
        Roboto-Thin.ttf
        Roboto-ThinItalic.ttf
        Miui-Regular.ttf
        Miui-Bold.ttf
        MiuiEx-Regular.ttf
        MiuiEx-Bold.ttf
        MiuiEx-Light.ttf
    )

    local runtime_font
    for runtime_font in "${runtime_fonts[@]}"; do
        cp -f "$font_file" "$tmp/fonts/$runtime_font" || {
            rm -rf "$tmp"
            mods "Font $title theme: ERROR"
            return 1
        }
    done

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

    python3 - "$theme_target" "$theme_id" "$title" "$author" "$local_id" "$theme_runtime_root" <<'PY'
import json
import os
import sys

theme, theme_id, title, author, local_id, theme_runtime_root = sys.argv[1:7]
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

# Always point metadata at the partition that actually contains the MTZ in
# the unpacked ROM. On this HyperOS base /system/media is represented by a
# symlink-like entry during extraction, so trying to mkdir/copy through it fails.
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

    for runtime_font in "${runtime_fonts[@]}"; do
        if ! unzip -Z1 "$theme_target/$theme_id.mtz" 2>/dev/null \
            | grep -qx "fonts/$runtime_font"; then
            mods "Font $title theme: ERROR (missing $runtime_font)"
            return 1
        fi
    done

    # MI_Theme_VF.ttf is the key marker used by Xiaomi's variable-font path.
    if ! unzip -Z1 "$theme_target/$theme_id.mtz" 2>/dev/null \
        | grep -qx "fonts/MI_Theme_VF.ttf"; then
        mods "Font $title theme: ERROR (MI_Theme_VF.ttf missing)"
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

    # The MTZ already lives in the real partition selected above. Do not
    # mirror it through /system/media: that path may be a symlink represented as
    # a regular entry by the image extractor and mkdir would fail.
    if [ ! -s "$theme_target/$theme_id.mtz" ]; then
        mods "Font $title theme: ERROR (runtime MTZ missing)"
        return 1
    fi

    chmod 0644 "$theme_target/$theme_id.mtz" 2>/dev/null || true
    mods "Font $title runtime: OK ($theme_runtime_root/$theme_id.mtz)"
    mods "Font $title theme: OK (MTZ + metadata + runtime path verified)"
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

font_failed=0

case "$rom_os" in
    OS1|OS2|OS3|OS4)
        install_font_theme "$SF_FONT" "SF-Pro" "SF Pro" "Apple" "10010" || font_failed=1

        ROBOTO_FONT=$(prepare_roboto_variable || true)
        if [ -n "$ROBOTO_FONT" ]; then
            install_font_theme "$ROBOTO_FONT" "Roboto" "Roboto" "Google" "10011" || font_failed=1
        else
            mods "Font Roboto theme: ERROR"
            font_failed=1
        fi
        ;;
    *)
        mods "Font SF Pro theme: SKIP"
        mods "Font Roboto theme: SKIP"
        ;;
esac

install_ios_emoji || font_failed=1

if [ "$font_failed" -ne 0 ]; then
    error "Fonts integration failed"
    exit 1
fi
