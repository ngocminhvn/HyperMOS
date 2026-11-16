#!/usr/bin/env bash
# ==============================================================================
# Replace stock OS4 China Gallery, Gallery Plugin, and Weather with Global APKs
# Extracted from Myron EEA (HyperOS 4).
# Never re-signs APKs; preserves original package identity and metadata.
# ==============================================================================
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"

rom_os="$(cat "$work_dir/bin/ddevice/rom_os.txt" 2>/dev/null || true)"
rom_source="$(cat "$work_dir/bin/ddevice/rom_source.txt" 2>/dev/null || true)"
if [[ "$rom_os" != "OS4" || "$rom_source" != "china" ]]; then
    mods "SystemApp Global: skip for rom_os=$rom_os rom_source=$rom_source (OS4 China only)"
    exit 0
fi

images_root="$work_dir/build/baserom/images"
source_dir="$work_dir/bin/modfile/ModApp/System/Apk"
staging_base="$work_dir/build/os4_system_global"
rm -rf "$staging_base"
mkdir -p "$staging_base"
trap 'rm -rf "$staging_base"' EXIT

# Helper: Extract package name from an APK via aapt
apk_package_name() {
    local apk="$1"
    aapt dump badging "$apk" 2>/dev/null \
        | sed -n "s/^package: name='\([^']*\)'.*/\1/p" \
        | head -n 1
}

# Helper: Extract bundled native libs into app folder matching target ABI
extract_native_libs() {
    local apk="$1"
    local app_dir="$2"
    local mapping apk_abi rom_abi entry rel out
    local -a entries=()

    mapfile -t entries < <(unzip -Z1 "$apk" 'lib/*/*.so' 2>/dev/null || true)
    if (( ${#entries[@]} == 0 )); then
        return 0
    fi

    for mapping in "arm64-v8a:arm64" "armeabi-v7a:arm" "arm64:arm64" "arm:arm"; do
        apk_abi="${mapping%%:*}"
        rom_abi="${mapping##*:}"

        for entry in "${entries[@]}"; do
            [[ "$entry" == lib/"$apk_abi"/*.so ]] || continue
            rel="${entry#lib/"$apk_abi"/}"
            out="$app_dir/lib/$rom_abi/$rel"
            mkdir -p "$(dirname "$out")"
            unzip -p "$apk" "$entry" > "$out" || return 1
            chmod 0644 "$out" 2>/dev/null || true
        done
    done
}

# Helper: Find the stock app folder for an APK package name
find_stock_app_folder() {
    local target_pkg="$1"
    local preferred_dirname="$2"
    local folder apk pkg
    local -a matches=()

    # Search preferred dir first
    while IFS= read -r -d '' folder; do
        while IFS= read -r -d '' apk; do
            pkg=$(apk_package_name "$apk" || true)
            if [[ "$pkg" == "$target_pkg" ]]; then
                printf '%s\n' "$folder"
                return 0
            fi
        done < <(find "$folder" -maxdepth 1 -type f -iname '*.apk' -print0 2>/dev/null)
    done < <(find "$images_root" -type d -name "$preferred_dirname" -print0 2>/dev/null)

    # Search all folders in images_root
    while IFS= read -r -d '' apk; do
        pkg=$(apk_package_name "$apk" || true)
        if [[ "$pkg" == "$target_pkg" ]]; then
            dirname "$apk"
            return 0
        fi
    done < <(find "$images_root" -type f -iname '*.apk' -print0 2>/dev/null)

    return 1
}

replace_system_app() {
    local label="$1"
    local apk_filename="$2"
    local expected_pkg="$3"
    local preferred_folder="$4"

    local source_apk="$source_dir/$apk_filename"
    if [[ ! -f "$source_apk" ]]; then
        mods "$label: $apk_filename not found, skipping"
        return 0
    fi

    if head -n 1 "$source_apk" | grep -Fqx 'version https://git-lfs.github.com/spec/v1'; then
        error "$label: Git LFS pointer found; checkout with LFS enabled / git lfs pull"
        return 1
    fi

    if ! unzip -tqq "$source_apk" >/dev/null; then
        error "$label: invalid ZIP/APK: $source_apk"
        return 1
    fi

    local mod_pkg
    mod_pkg="$(apk_package_name "$source_apk" || true)"
    if [[ "$mod_pkg" != "$expected_pkg" ]]; then
        error "$label: expected package $expected_pkg; got ${mod_pkg:-<unreadable>}"
        return 1
    fi

    local stock_dir
    stock_dir="$(find_stock_app_folder "$expected_pkg" "$preferred_folder" || true)"
    if [[ -z "$stock_dir" || ! -d "$stock_dir" ]]; then
        # If stock directory not found, check standard fallback path in product/data-app
        stock_dir="$images_root/product/data-app/$preferred_folder"
        mods "$label: stock folder not found by package search, using default: $stock_dir"
    fi

    local staging="$staging_base/${expected_pkg//./_}"
    rm -rf "$staging"
    mkdir -p "$staging"

    # Find the stock APK name if present, otherwise use standard convention
    local stock_apk_name
    stock_apk_name="$(find "$stock_dir" -maxdepth 1 -type f -iname '*.apk' -exec basename {} \; 2>/dev/null | head -n 1 || true)"
    if [[ -z "$stock_apk_name" ]]; then
        stock_apk_name="$preferred_folder.apk"
    fi

    cp -f "$source_apk" "$staging/$stock_apk_name"
    extract_native_libs "$staging/$stock_apk_name" "$staging" || {
        error "$label: failed to extract native libraries"
        return 1
    }

    find "$staging" -type d -exec chmod 0755 {} +
    find "$staging" -type f -exec chmod 0644 {} +

    mods "$label: replacing $stock_dir with $apk_filename ($expected_pkg)"
    rm -rf "$stock_dir"
    mkdir -p "$stock_dir"
    cp -a "$staging/." "$stock_dir/" || {
        error "$label: failed copying replacement app"
        return 1
    }

    local copied_pkg
    copied_pkg="$(apk_package_name "$stock_dir/$stock_apk_name" || true)"
    if [[ "$copied_pkg" != "$expected_pkg" ]]; then
        error "$label: verification failed after copy: expected $expected_pkg, got $copied_pkg"
        return 1
    fi

    mods "$label: replacement complete -> $stock_dir/$stock_apk_name"
}

mods "Starting System Global APK replacements for OS4 China..."

# 1. HyperGalleryPluginGlobal (replaces HyperGalleryPluginCn)
replace_system_app \
    "SystemApp GalleryPlugin" \
    "HyperGalleryPluginGlobal.apk" \
    "com.hyper.gallery.plugin" \
    "HyperGalleryPluginCn"

# 2. MIUIGalleryGlobal (replaces MIUIGallery)
replace_system_app \
    "SystemApp Gallery" \
    "MIUIGalleryGlobal.apk" \
    "com.miui.gallery" \
    "MIUIGallery"

# 3. MIUIWeatherGlobal (replaces MIUIWeather)
replace_system_app \
    "SystemApp Weather" \
    "MIUIWeatherGlobal.apk" \
    "com.miui.weather2" \
    "MIUIWeather"

# 4. MIUICloudBackupGlobal (replaces MIUICloudBackup)
replace_system_app \
    "SystemApp CloudBackup" \
    "MIUICloudBackupGlobal.apk" \
    "com.miui.cloudbackup" \
    "MIUICloudBackup"

mods "System Global APK replacements -> Done"
