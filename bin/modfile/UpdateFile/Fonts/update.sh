#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

rom_os=$(cat "$work_dir/bin/ddevice/rom_os.txt")

FONT_SOURCE="$work_dir/bin/modfile/UpdateFile/Fonts/HyperOS"
SF_FONT="$FONT_SOURCE/SF-Pro.ttf"
IOS_EMOJI_FONT="$FONT_SOURCE/NotoColorEmoji.ttf"

mods "Fonts: preserve stock MiSans + integrate SF Pro/Roboto into all Xiaomi theme roots"

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

detect_canonical_theme_runtime_root() {
    local meta root
    for meta in \
        "$work_dir/build/baserom/images/product/media/theme/.data/meta/fonts/default.mrm" \
        "$work_dir/build/baserom/images/system/system/media/theme/.data/meta/fonts/default.mrm" \
        "$work_dir/build/baserom/images/system/media/theme/.data/meta/fonts/default.mrm" \
        "$work_dir/build/baserom/images/system_ext/media/theme/.data/meta/fonts/default.mrm"; do
        [ -s "$meta" ] || continue

        root=$(python3 - "$meta" <<'PYROOT'
import json
import os
import sys

try:
    with open(sys.argv[1], "r", encoding="utf-8-sig") as fh:
        data = json.load(fh)
except Exception:
    raise SystemExit(1)

for key in ("contentPath", "downloadPath", "metaPath"):
    value = data.get(key)
    if not isinstance(value, str) or not value.startswith("/"):
        continue
    if "/.data/meta/fonts/" in value:
        print(value.split("/.data/meta/fonts/", 1)[0])
        raise SystemExit(0)
    if value.endswith(".mtz"):
        print(os.path.dirname(value))
        raise SystemExit(0)

raise SystemExit(1)
PYROOT
        ) || root=""

        if [ -n "$root" ]; then
            printf '%s\n' "$root"
            return 0
        fi
    done

    # Xiaomi stock font metadata on HyperOS normally resolves through the
    # canonical /system/media/theme namespace even when a duplicate metadata
    # index is stored under /product. Keep that runtime contract as fallback.
    printf '%s\n' "/system/media/theme"
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
        error "Font $title payload missing or empty: $font_file"
        return 1
    }

    local theme_target
    theme_target=$(find_theme_target) || {
        mods "Font $title theme: ERROR"
        return 1
    }

    local ui_version=16
    [[ "$rom_os" == "OS4" ]] && ui_version=17

    # Do not derive metadata paths from the partition where we happen to write
    # the MTZ first. Xiaomi may index the same built-in resource from /product
    # while stock default.mrm still points to the canonical /system/media/theme
    # runtime namespace. Follow stock metadata so Apply resolves the same path.
    local theme_runtime_root
    theme_runtime_root=$(detect_canonical_theme_runtime_root) || {
        mods "Font $title theme: ERROR (cannot resolve canonical runtime root)"
        return 1
    }
    mods "Font $title canonical runtime root: $theme_runtime_root"

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

    # Xiaomi's font-theme path uses one canonical payload:
    # fonts/Roboto-Regular.ttf. ThemeManager extracts that file at Apply time
    # and creates the runtime symlinks (Miui*, Roboto-* and MI_Theme_VF.ttf)
    # under /data/system/theme/fonts. A non-empty fontWeight resource field is
    # what marks the theme as variable-font capable.
    #
    # Do not pre-pack the runtime aliases: doing so only duplicates the same
    # variable font many times and can make SF-Pro.mtz enormous.
    local runtime_fonts=(
        Roboto-Regular.ttf
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

    if ! printf '%s' 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Y9ZQmcAAAAASUVORK5CYII=' \
        | base64 -d > "$tmp/preview/preview_fonts_0.png" 2>/dev/null; then
        rm -rf "$tmp"
        error "Font $title theme: preview generation failed"
        return 1
    fi

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

# Preserve Xiaomi's canonical runtime namespace. The physical copy used while
# unpacking/building can live under product or system, but ThemeManager follows
# these metadata paths when the user taps Apply.
font_meta_root = f"{theme_runtime_root}/.data/meta/fonts"

data["localId"] = local_id
data["onlineId"] = None
data["productId"] = None
data["downloadPath"] = f"{theme_runtime_root}/{theme_id}.mtz"
data["metaPath"] = f"{font_meta_root}/{theme_id}.mrm"
data["contentPath"] = f"{theme_runtime_root}/{theme_id}.mtz"
data["status"] = 1
data["platform"] = 8
data["hash"] = "0"
data["size"] = 0
data["updatedTime"] = 0
data["title"] = title
data["description"] = f"{title} Variable font"
data["author"] = author
data["designer"] = author
data["version"] = "1.0"
data["fontWeight"] = "100,150,200,250,300,350,400,450,500,550,600,650,700,800,900"

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

    if unzip -Z1 "$theme_target/$theme_id.mtz" 2>/dev/null \
        | grep -qx "fonts/MI_Theme_VF.ttf"; then
        mods "Font $title theme: ERROR (runtime alias packed into MTZ)"
        return 1
    fi

    # MI_Theme_VF.ttf must NOT be pre-packed here. ThemeManager creates the
    # runtime link when the resource exposes a non-empty fontWeight list.
    if ! python3 - "$theme_target/.data/meta/fonts/$theme_id.mrm" "$theme_id" "$title" "$theme_runtime_root" <<'PYVERIFY'
import json
import sys

path, theme_id, title, runtime_root = sys.argv[1:5]
with open(path, "r", encoding="utf-8-sig") as fh:
    data = json.load(fh)

ok = (
    data.get("title") == title
    and bool(str(data.get("localId", "")))
    and data.get("downloadPath") == f"{runtime_root}/{theme_id}.mtz"
    and data.get("contentPath") == f"{runtime_root}/{theme_id}.mtz"
    and data.get("metaPath") == f"{runtime_root}/.data/meta/fonts/{theme_id}.mrm"
    and bool(str(data.get("fontWeight", "")).strip())
)
raise SystemExit(0 if ok else 1)
PYVERIFY
    then
        mods "Font $title theme: ERROR (metadata verification failed)"
        return 1
    fi

    # The initial MTZ lives in a real writable build target. Below we mirror it
    # into every existing Xiaomi theme root so the canonical runtime path and
    # every catalog scanner both resolve the same payload.
    if [ ! -s "$theme_target/$theme_id.mtz" ]; then
        mods "Font $title theme: ERROR (runtime MTZ missing)"
        return 1
    fi

    chmod 0644 "$theme_target/$theme_id.mtz" || {
        error "Font $title theme: chmod failed"
        return 1
    }
    # HyperOS may index built-in fonts from more than one partition. The HAOTIAN
    # stock ROM exposes font metadata under both /product/media/theme and
    # /system/media/theme. Mirror the generated resource to every real theme
    # root so ThemeManager sees the same built-in font catalog regardless of
    # which partition it scans first.
    local mirror_target mirror_runtime mirror_meta
    for mirror_target in \
        "$work_dir/build/baserom/images/product/media/theme" \
        "$work_dir/build/baserom/images/system_ext/media/theme" \
        "$work_dir/build/baserom/images/system/system/media/theme" \
        "$work_dir/build/baserom/images/system/media/theme"; do
        [ -d "$mirror_target" ] || continue
        [ "$mirror_target" = "$theme_target" ] && continue
        mirror_runtime=$(theme_runtime_root_for_target "$mirror_target") || continue
        mkdir -p "$mirror_target/.data/meta/fonts" || continue
        cp -f "$theme_target/$theme_id.mtz" "$mirror_target/$theme_id.mtz" || continue
        mirror_meta="$mirror_target/.data/meta/fonts/$theme_id.mrm"

        # Important: every catalog copy must advertise the SAME canonical
        # runtime path. Rewriting /system -> /product here makes the selector
        # visible but can make Apply resolve a different/non-active resource.
        cp -f "$theme_target/.data/meta/fonts/$theme_id.mrm" "$mirror_meta" || continue

        chmod 0644 "$mirror_target/$theme_id.mtz" "$mirror_meta" || true
        mods "Font $title mirror: OK ($mirror_runtime -> canonical $theme_runtime_root)"
    done

    # If the canonical runtime root has a concrete build directory, require the
    # mirrored MTZ to exist there. This catches the exact "listed but not really
    # applied" failure mode during CI instead of discovering it after flashing.
    local canonical_target=""
    case "$theme_runtime_root" in
        /system/media/theme)
            if [ -d "$work_dir/build/baserom/images/system/system/media/theme" ]; then
                canonical_target="$work_dir/build/baserom/images/system/system/media/theme"
            elif [ -d "$work_dir/build/baserom/images/system/media/theme" ]; then
                canonical_target="$work_dir/build/baserom/images/system/media/theme"
            fi
            ;;
        /product/media/theme)
            [ -d "$work_dir/build/baserom/images/product/media/theme" ] && \
                canonical_target="$work_dir/build/baserom/images/product/media/theme"
            ;;
        /system_ext/media/theme)
            [ -d "$work_dir/build/baserom/images/system_ext/media/theme" ] && \
                canonical_target="$work_dir/build/baserom/images/system_ext/media/theme"
            ;;
    esac

    if [ -n "$canonical_target" ] && [ ! -s "$canonical_target/$theme_id.mtz" ]; then
        mods "Font $title theme: ERROR (canonical MTZ missing: $theme_runtime_root/$theme_id.mtz)"
        return 1
    fi

    mods "Font $title runtime: OK ($theme_runtime_root/$theme_id.mtz)"
    mods "Font $title theme: OK (single payload + canonical metadata + mirrored catalog)"
    return 0

}

install_ios_emoji() {
    [ -s "$IOS_EMOJI_FONT" ] || {
        error "Emoji iOS payload missing or empty: $IOS_EMOJI_FONT"
        return 1
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
        install_font_theme "$SF_FONT" "SF-Pro" "SF Pro" "Apple" "10010" || {
            error "FAST-FAIL: SF Pro integration failed"
            exit 1
        }

        if ! ROBOTO_FONT=$(prepare_roboto_variable); then
            error "FAST-FAIL: Roboto-VF.ttf missing or empty"
            exit 1
        fi
        install_font_theme "$ROBOTO_FONT" "Roboto" "Roboto" "Google" "10011" || {
            error "FAST-FAIL: Roboto integration failed"
            exit 1
        }
        ;;
    *)
        mods "Fonts: unsupported ROM $rom_os -> skipped"
        exit 0
        ;;
esac

install_ios_emoji || {
    error "FAST-FAIL: iOS Emoji integration failed"
    exit 1
}

mods "Fonts integration -> Done"
