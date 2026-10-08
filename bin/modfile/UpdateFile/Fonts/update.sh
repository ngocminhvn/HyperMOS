#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

rom_os=$(tr -d ' \r\n' < "$work_dir/bin/ddevice/rom_os.txt")
FONT_SOURCE="$work_dir/bin/modfile/UpdateFile/Fonts/HyperOS"
SF_FONT="$FONT_SOURCE/SF-Pro.ttf"
ROBOTO_FONT="$FONT_SOURCE/Roboto-VF.ttf"
IOS_EMOJI_FONT="$FONT_SOURCE/NotoColorEmoji.ttf"
FONT_UTILS="$work_dir/bin/modfile/UpdateFile/Fonts/font_utils.py"
FONT_PREPARED_DIR="$work_dir/build/.prepared_theme_fonts"
SF_PREPARED_FONT="$FONT_PREPARED_DIR/SF-Pro.ttf"

mods "Fonts: stock MiSans + native Xiaomi font resources for SF Pro/Roboto"

THEME_TARGET=""
THEME_RUNTIME=""
select_theme_root() {
    local p
    if [ -d "$work_dir/build/baserom/images/product/media/theme" ]; then
        THEME_TARGET="$work_dir/build/baserom/images/product/media/theme"
        THEME_RUNTIME="/product/media/theme"
        return 0
    fi
    for p in \
        "$work_dir/build/baserom/images/system/system/media/theme" \
        "$work_dir/build/baserom/images/system/media/theme" \
        "$work_dir/build/baserom/images/system_ext/media/theme"; do
        [ -d "$p" ] || continue
        THEME_TARGET="$p"
        case "$p" in
            *system_ext/media/theme) THEME_RUNTIME="/system_ext/media/theme" ;;
            *) THEME_RUNTIME="/system/media/theme" ;;
        esac
        return 0
    done
    return 1
}

cleanup_legacy_generated_fonts() {
    local root
    for root in \
        "$work_dir/build/baserom/images/product/media/theme" \
        "$work_dir/build/baserom/images/system_ext/media/theme" \
        "$work_dir/build/baserom/images/system/system/media/theme" \
        "$work_dir/build/baserom/images/system/media/theme"; do
        [ -d "$root" ] || continue
        rm -f \
            "$root/SF-Pro.mtz" "$root/Roboto.mtz" \
            "$root/.data/meta/fonts/SF-Pro.mrm" \
            "$root/.data/meta/fonts/Roboto.mrm"
    done
}

write_preview_png() {
    local title="$1" font_file="$2" out="$3"
    python3 "$FONT_UTILS" preview "$title" "$font_file" "$out" || {
        error "Unable to render native dark-mode font preview for $title"
        return 1
    }
}

install_xiaomi_font_resource() {
    local font_file="$1"
    local font_id="$2"
    local theme_id="$3"
    local title="$4"
    local author="$5"
    local weights="$6"

    [ -s "$font_file" ] || {
        error "Font $title payload missing or empty: $font_file"
        return 1
    }

    local content_fonts="$THEME_TARGET/.data/content/fonts"
    local content_theme="$THEME_TARGET/.data/content/theme"
    local meta_fonts="$THEME_TARGET/.data/meta/fonts"
    local meta_theme="$THEME_TARGET/.data/meta/theme"
    local preview_dir="$THEME_TARGET/.data/preview/theme/$theme_id"
    mkdir -p "$content_fonts" "$content_theme" "$meta_fonts" "$meta_theme" "$preview_dir"

    local font_mrc="$content_fonts/$font_id.mrc"
    local theme_mrc="$content_theme/$theme_id.mrc"
    local font_mrm="$meta_fonts/$font_id.mrm"
    local theme_mrm="$meta_theme/$theme_id.mrm"

    # Xiaomi ThemeManager stores font payloads as raw font bytes with the .mrc
    # extension. Do not wrap the font in MTZ/ZIP and do not mirror it elsewhere.
    cp -f "$font_file" "$font_mrc"
    : > "$theme_mrc"
    chmod 0644 "$font_mrc" "$theme_mrc"

    write_preview_png "$title" "$font_file" "$preview_dir/preview_fonts_small_0.png" || return 1
    cp -f "$preview_dir/preview_fonts_small_0.png" "$preview_dir/preview_fonts_0.png"
    cp -f "$preview_dir/preview_fonts_small_0.png" "$preview_dir/en_US_fonts_small_0.png"
    cp -f "$preview_dir/preview_fonts_small_0.png" "$preview_dir/en_US_fonts_0.png"
    chmod 0644 "$preview_dir"/*.png

    local font_sha1 font_size
    font_sha1=$(sha1sum "$font_mrc" | awk '{print $1}')
    font_size=$(stat -c '%s' "$font_mrc")

    python3 - \
        "$THEME_TARGET" "$THEME_RUNTIME" "$font_id" "$theme_id" \
        "$title" "$author" "$weights" "$font_sha1" "$font_size" <<'PY'
import copy
import json
import os
import sys

(root, runtime, font_id, theme_id, title, author, weights, font_sha1, font_size) = sys.argv[1:10]
font_size = int(font_size)
# Native Xiaomi ThemeManager expects a plural fontWeights list. A singular
# fontWeight string is not recognized as ten independently selectable steps.
weight_values = [value.strip() for value in weights.split(",")]
if len(weight_values) != 10 or any(not value.isdecimal() for value in weight_values):
    raise ValueError(f"Invalid Xiaomi ten-step variable font weight map: {weights!r}")

font_default = os.path.join(root, ".data", "meta", "fonts", "default.mrm")
theme_default = os.path.join(root, ".data", "meta", "theme", "default.mrm")
font_out = os.path.join(root, ".data", "meta", "fonts", f"{font_id}.mrm")
theme_out = os.path.join(root, ".data", "meta", "theme", f"{theme_id}.mrm")

def load_template(path, fallback):
    try:
        with open(path, "r", encoding="utf-8-sig") as fh:
            value = json.load(fh)
        return value if isinstance(value, dict) else copy.deepcopy(fallback)
    except Exception:
        return copy.deepcopy(fallback)

base = {
    "platform": 8,
    "status": 1,
    "titles": {},
    "authors": {},
    "designers": {},
    "descriptions": {},
    "parentResources": [],
    "subResources": [],
    "extraMeta": {},
}

font = load_template(font_default, base)
theme = load_template(theme_default, base)

font_meta_path = f"{runtime}/.data/meta/fonts/{font_id}.mrm"
font_content_path = f"{runtime}/.data/content/fonts/{font_id}.mrc"
theme_meta_path = f"{runtime}/.data/meta/theme/{theme_id}.mrm"
theme_content_path = f"{runtime}/.data/content/theme/{theme_id}.mrc"

for obj in (font, theme):
    obj["onlineId"] = None
    obj["productId"] = None
    obj["assemblyId"] = None
    obj["updatedTime"] = 0
    obj["version"] = "1.0"
    obj["status"] = 1
    obj["title"] = title
    obj["description"] = f"{title} Variable font"
    obj["author"] = author
    obj["designer"] = author
    obj["titles"] = {"fallback": title, "en_US": title, "vi_VN": title, "zh_CN": title}
    obj["authors"] = {"fallback": author, "en_US": author, "vi_VN": author, "zh_CN": author}
    obj["designers"] = {"fallback": author, "en_US": author, "vi_VN": author, "zh_CN": author}
    obj["descriptions"] = {"fallback": f"{title} Variable font"}
    preview_root = f"{runtime}/.data/preview/theme/{theme_id}"
    preview_small = f"{preview_root}/preview_fonts_small_0.png"
    preview_large = f"{preview_root}/preview_fonts_0.png"
    preview_small_en = f"{preview_root}/en_US_fonts_small_0.png"
    preview_large_en = f"{preview_root}/en_US_fonts_0.png"

    # Override both legacy buildIn* paths inherited from Xiaomi's default MRM
    # and localized builtIn* paths. Leaving the stock default preview paths here
    # makes ThemeManager show unrelated color/placeholder artwork for custom fonts.
    obj["buildInThumbnails"] = [preview_small]
    obj["buildInPreviews"] = [preview_large]
    obj["builtInThumbnails"] = {
        "fallback": [preview_small],
        "en_US": [preview_small_en],
        "vi_VN": [preview_small],
        "zh_CN": [preview_small],
    }
    obj["builtInPreviews"] = {
        "fallback": [preview_large],
        "en_US": [preview_large_en],
        "vi_VN": [preview_large],
        "zh_CN": [preview_large],
    }
    obj["thumbnails"] = []
    obj["previews"] = []
    obj.pop("fontWeight", None)
    obj["fontWeights"] = weight_values

font["localId"] = font_id
font["hash"] = font_sha1
font["size"] = font_size
font["metaPath"] = font_meta_path
font["contentPath"] = font_content_path
font.pop("downloadPath", None)
font.pop("onlinePath", None)
font["parentResources"] = [{
    "localId": theme_id,
    "resourceCode": "theme",
    "extraMeta": {},
    "metaPath": theme_meta_path,
    "contentPath": theme_content_path,
}]
font["subResources"] = []

theme["localId"] = theme_id
theme["hash"] = "0"
theme["size"] = 0
theme["metaPath"] = theme_meta_path
theme["contentPath"] = theme_content_path
theme.pop("downloadPath", None)
theme.pop("onlinePath", None)
theme["parentResources"] = []
theme["subResources"] = [{
    "localId": font_id,
    "resourceCode": "fonts",
    "extraMeta": {},
    "metaPath": font_meta_path,
    "contentPath": font_content_path,
}]

for path, data in ((font_out, font), (theme_out, theme)):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(data, fh, ensure_ascii=False, indent=2)
        fh.write("\n")
PY

    chmod 0644 "$font_mrm" "$theme_mrm"

    cmp -s "$font_file" "$font_mrc" || {
        error "Font $title resource payload differs from source font"
        return 1
    }

    if ! python3 - "$font_mrm" "$theme_mrm" "$font_id" "$theme_id" "$THEME_RUNTIME" "$weights" <<'PY'
import json
import sys

font_path, theme_path, font_id, theme_id, runtime, weights = sys.argv[1:7]
expected_weights = [value.strip() for value in weights.split(",")]
with open(font_path, "r", encoding="utf-8-sig") as fh:
    font = json.load(fh)
with open(theme_path, "r", encoding="utf-8-sig") as fh:
    theme = json.load(fh)

font_meta = f"{runtime}/.data/meta/fonts/{font_id}.mrm"
font_content = f"{runtime}/.data/content/fonts/{font_id}.mrc"
theme_meta = f"{runtime}/.data/meta/theme/{theme_id}.mrm"
theme_content = f"{runtime}/.data/content/theme/{theme_id}.mrc"

ok = (
    font.get("localId") == font_id
    and font.get("metaPath") == font_meta
    and font.get("contentPath") == font_content
    and font.get("fontWeights") == expected_weights
    and theme.get("fontWeights") == expected_weights
    and "fontWeight" not in font
    and "fontWeight" not in theme
    and isinstance(font.get("parentResources"), list)
    and len(font["parentResources"]) == 1
    and font["parentResources"][0].get("localId") == theme_id
    and font["parentResources"][0].get("resourceCode") == "theme"
    and font["parentResources"][0].get("metaPath") == theme_meta
    and font["parentResources"][0].get("contentPath") == theme_content
    and theme.get("localId") == theme_id
    and theme.get("metaPath") == theme_meta
    and theme.get("contentPath") == theme_content
    and isinstance(theme.get("subResources"), list)
    and len(theme["subResources"]) == 1
    and theme["subResources"][0].get("localId") == font_id
    and theme["subResources"][0].get("resourceCode") == "fonts"
    and theme["subResources"][0].get("metaPath") == font_meta
    and theme["subResources"][0].get("contentPath") == font_content
)
raise SystemExit(0 if ok else 1)
PY
    then
        error "Font $title ThemeManager resource graph verification failed"
        return 1
    fi

    local count
    count=$(find "$work_dir/build/baserom/images" -type f \
        \( -name "$font_id.mrm" -o -name "$font_id.mrc" -o -name "$theme_id.mrm" -o -name "$theme_id.mrc" \) \
        | wc -l | tr -d ' ')
    if [ "$count" -ne 4 ]; then
        error "Font $title duplicated across theme roots: expected 4 resource files, got $count"
        return 1
    fi

    mods "Font $title: native MRC/MRM resource graph OK ($THEME_RUNTIME)"
}

install_ios_emoji() {
    [ -s "$IOS_EMOJI_FONT" ] || {
        error "Emoji iOS payload missing or empty: $IOS_EMOJI_FONT"
        return 1
    }
    local target count=0 failed=0
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
    error "Emoji iOS: no writable NotoColorEmoji.ttf target found"
    return 1
}

case "$rom_os" in
    OS1|OS2|OS3|OS4) ;;
    *) mods "Fonts: unsupported ROM $rom_os -> skipped"; exit 0 ;;
esac

select_theme_root || {
    error "FAST-FAIL: no Xiaomi theme root found"
    exit 1
}
mods "Fonts: using one catalog only -> $THEME_RUNTIME"
cleanup_legacy_generated_fonts

# Ensure both custom fonts actually contain a wght axis, and publish ten
# ThemeManager fontWeight stops like stock MiSans. Fail early rather than
# silently creating a non-adjustable font entry.
python3 "$FONT_UTILS" prepare "$SF_FONT" "$ROBOTO_FONT" "$FONT_PREPARED_DIR" || {
    error "FAST-FAIL: custom fonts must provide a usable variable wght axis"
    exit 1
}
# These values are generated from validated numeric OpenType axes.
source "$FONT_PREPARED_DIR/font_weights.env"

install_xiaomi_font_resource \
    "$SF_PREPARED_FONT" \
    "9c6f0f9a-4c74-4bd1-9c18-1d7f5b3a2102" \
    "9c6f0f9a-4c74-4bd1-9c18-1d7f5b3a2101" \
    "SF Pro" "Apple" "$SF_WEIGHTS" || {
    error "FAST-FAIL: SF Pro native ThemeManager integration failed"
    exit 1
}

install_xiaomi_font_resource \
    "$ROBOTO_FONT" \
    "b1e6e1d4-5f63-4a3d-8df1-2f9a4c6b3102" \
    "b1e6e1d4-5f63-4a3d-8df1-2f9a4c6b3101" \
    "Roboto" "Google" "$ROBOTO_WEIGHTS" || {
    error "FAST-FAIL: Roboto native ThemeManager integration failed"
    exit 1
}

# Stock MiSans/default resource is deliberately untouched. There is no custom
# MiSans copy, so the selector should expose one stock MiSans entry plus the two
# native resources above.
install_ios_emoji || exit 1
mods "Fonts integration -> Done"
