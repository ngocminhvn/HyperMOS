#!/usr/bin/env bash

work_dir=$(pwd)
source "$work_dir/bin/modfile/OS3/_common.sh"

LLIONS_DIR="$work_dir/bin/modfile/OS3/llionsapps"
CACHE_DIR="$work_dir/build/os3_llionsapps"

rm -rf "$CACHE_DIR"
mkdir -p "$CACHE_DIR"

is_lfs_pointer() {
    local file="$1"
    [[ -f "$file" ]] || return 1
    head -n 1 "$file" 2>/dev/null | grep -Fqx 'version https://git-lfs.github.com/spec/v1'
}

find_stock_apk() {
    local mod_package="$1"
    local preferred_dir="$2"
    local dir apk pkg

    while IFS= read -r -d '' dir; do
        while IFS= read -r -d '' apk; do
            pkg=$(modscenter_apk_package "$apk" || true)
            if [[ "$pkg" == "$mod_package" ]]; then
                printf '%s\n' "$apk"
                return 0
            fi
        done < <(find "$dir" -maxdepth 1 -type f -iname '*.apk' -print0 2>/dev/null)
    done < <(find "$OS3_IMAGES" -type d -name "$preferred_dir" -print0 2>/dev/null)

    while IFS= read -r -d '' apk; do
        pkg=$(modscenter_apk_package "$apk" || true)
        if [[ "$pkg" == "$mod_package" ]]; then
            printf '%s\n' "$apk"
            return 0
        fi
    done < <(find "$OS3_IMAGES" -type f -iname '*.apk' -print0 2>/dev/null)

    return 1
}

copy_external_libs() {
    local label="$1"
    local source_dir="$2"
    local prepared="$3"
    local source_lib="$source_dir/lib"
    local src dst count=0

    if [[ ! -d "$source_lib" ]]; then
        mods "$label: no external lib folder"
        return 0
    fi

    mkdir -p "$prepared/lib"

    # Preserve non-ABI files stored directly under lib/ (for example bundled JARs).
    while IFS= read -r -d '' src; do
        cp -a "$src" "$prepared/lib/" || return 1
        count=$((count + 1))
    done < <(find "$source_lib" -maxdepth 1 -type f -print0 2>/dev/null)

    for mapping in "arm64-v8a:arm64" "armeabi-v7a:arm" "arm64:arm64" "arm:arm"; do
        local src_abi="${mapping%%:*}"
        local dst_abi="${mapping##*:}"

        [[ -d "$source_lib/$src_abi" ]] || continue
        mkdir -p "$prepared/lib/$dst_abi"

        while IFS= read -r -d '' src; do
            dst="$prepared/lib/$dst_abi/$(basename "$src")"
            cp -a "$src" "$dst" || return 1
            count=$((count + 1))
        done < <(find "$source_lib/$src_abi" -maxdepth 1 -type f -print0 2>/dev/null)
    done

    mods "$label: copied $count external lib file(s)"
}

apply_llions_app() {
    local label="$1"
    local apk_name="$2"
    local preferred_stock_dir="$3"

    local source_apk="$LLIONS_DIR/$apk_name"
    local source_dir="${source_apk%.apk}"
    local mod_package stock_apk stock_dir stock_name prepared copied_package

    [[ -f "$source_apk" ]] || {
        error "$label: APK missing: $source_apk"
        return 1
    }

    if is_lfs_pointer "$source_apk"; then
        error "$label: APK is still a Git LFS pointer; run git lfs pull during checkout"
        return 1
    fi

    mod_package=$(modscenter_apk_package "$source_apk" || true)
    [[ -n "$mod_package" ]] || {
        error "$label: cannot read package name from mod APK"
        return 1
    }

    stock_apk=$(find_stock_apk "$mod_package" "$preferred_stock_dir") || {
        error "$label: stock package not found: $mod_package"
        return 1
    }

    stock_dir=$(dirname "$stock_apk")
    stock_name=$(basename "$stock_apk")
    prepared="$CACHE_DIR/${mod_package//./_}"

    rm -rf "$prepared"
    mkdir -p "$prepared"

    cp -f "$source_apk" "$prepared/$stock_name" || {
        error "$label: failed to stage APK"
        return 1
    }

    copy_external_libs "$label" "$source_dir" "$prepared" || {
        error "$label: failed to stage external libs"
        return 1
    }

    find "$prepared" -type d -exec chmod 0755 {} +
    find "$prepared" -type f -exec chmod 0644 {} +

    mods "$label: $mod_package -> $stock_dir"

    rm -rf "$stock_dir"
    mkdir -p "$stock_dir"
    cp -a "$prepared/." "$stock_dir/" || {
        error "$label: failed replacing stock app"
        return 1
    }

    copied_package=$(modscenter_apk_package "$stock_dir/$stock_name" || true)
    if [[ "$copied_package" != "$mod_package" ]]; then
        error "$label: package verification failed after copy"
        return 1
    fi

    modscenter_verify_folder_shape "$label" "$prepared" "$stock_dir" || return 1
    mods "$label -> Done"
}

mods "LLions system apps: starting"

apply_llions_app \
    "LLions File Manager" \
    "[LLions] HyperOS File Manager Mod v8.1.0.5 Fix.apk" \
    "MIUIFileExplorer" || exit 1

apply_llions_app \
    "LLions Gallery Editor" \
    "[LLions] HyperOS Gallery Editor Mod v2.3.0.5.apk" \
    "MIMediaEditor" || exit 1

GALLERY_APK="MIUIGallery.apk"
if [[ ! -f "$LLIONS_DIR/$GALLERY_APK" ]]; then
    info "Xiaomi Gallery 4.3.1.8-global not found; fallback to LLions Gallery v4.3.1.16"
    GALLERY_APK="[LLions] HyperOS Gallery Mod v4.3.1.16.apk"
fi

apply_llions_app \
    "Xiaomi Gallery 4.3.1.8-global" \
    "$GALLERY_APK" \
    "MIUIGallery" || exit 1

apply_llions_app \
    "LLions Screen Recorder" \
    "[LLions] HyperOS Screen Recorder Mod v4.15.2.12.1.apk" \
    "ScreenRecorder" || exit 1

apply_llions_app \
    "LLions Screenshot" \
    "[LLions] HyperOS Screenshot Mod v1.6.2.9.apk" \
    "MIUIScreenshot" || exit 1

rm -rf "$CACHE_DIR"
mods "LLions system apps -> Done"
