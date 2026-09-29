#!/usr/bin/env bash

work_dir=${work_dir:-$(pwd)}
source "$work_dir/functions.sh"

OS3_MOD_CACHE="$work_dir/build/os3_modscenter"
OS3_IMAGES="$work_dir/build/baserom/images"

modscenter_remove_stock_dirs() {
    local name path
    for name in "$@"; do
        while IFS= read -r -d '' path; do
            mods "Remove stock: $path"
            rm -rf "$path"
        done < <(find "$OS3_IMAGES" -type d -name "$name" -prune -print0 2>/dev/null)
    done
}

modscenter_download() {
    local label="$1"
    local url="$2"
    local sha256="$3"
    local archive="$4"

    mkdir -p "$OS3_MOD_CACHE"

    if [[ -s "$archive" ]] && printf '%s  %s\n' "$sha256" "$archive" | sha256sum -c - >/dev/null 2>&1; then
        mods "$label: use cached archive"
        return 0
    fi

    rm -f "$archive"
    mods "$label: downloading pinned release"

    if ! aria2c -q --allow-overwrite=true --auto-file-renaming=false --file-allocation=none -x8 -s8 \
        -d "$(dirname "$archive")" -o "$(basename "$archive")" "$url"; then
        error "$label: download failed"
        return 1
    fi

    if ! printf '%s  %s\n' "$sha256" "$archive" | sha256sum -c - >/dev/null 2>&1; then
        rm -f "$archive"
        error "$label: SHA256 mismatch"
        return 1
    fi

    return 0
}

modscenter_copy_system_tree() {
    local label="$1"
    local system_root="$2"
    local entry base target
    local logical_parts="product system_ext vendor odm mi_ext mi_product product_dlkm system_dlkm vendor_dlkm odm_dlkm"

    [[ -d "$system_root" ]] || {
        error "$label: module has no system/ tree"
        return 1
    }

    while IFS= read -r -d '' entry; do
        base=$(basename "$entry")
        case " $logical_parts " in
            *" $base "*)
                target="$OS3_IMAGES/$base"
                mkdir -p "$target"
                if ! cp -a "$entry/." "$target/"; then
                    error "$label: failed to copy logical partition $base"
                    return 1
                fi
                ;;
            *)
                target="$OS3_IMAGES/system/system"
                mkdir -p "$target"
                if ! cp -a "$entry" "$target/"; then
                    error "$label: failed to copy /system/$base"
                    return 1
                fi
                ;;
        esac
    done < <(find "$system_root" -mindepth 1 -maxdepth 1 -print0)

    return 0
}

modscenter_apply_module() {
    local label="$1"
    local url="$2"
    local sha256="$3"
    local archive_name="$4"
    local expected_apk="$5"
    shift 5

    local archive="$OS3_MOD_CACHE/$archive_name"
    local extract_dir="$OS3_MOD_CACHE/${archive_name%.zip}"
    local module_prop module_root system_root apk

    modscenter_download "$label" "$url" "$sha256" "$archive" || return 1

    rm -rf "$extract_dir"
    mkdir -p "$extract_dir"

    if ! unzip -q "$archive" -d "$extract_dir"; then
        error "$label: unzip failed"
        return 1
    fi

    module_prop=$(find "$extract_dir" -type f -name module.prop -print -quit 2>/dev/null)
    if [[ -n "$module_prop" ]]; then
        module_root=$(dirname "$module_prop")
    else
        module_root="$extract_dir"
    fi

    system_root="$module_root/system"
    apk=$(find "$system_root" -type f -iname "$expected_apk" -print -quit 2>/dev/null)

    if [[ -z "$apk" ]]; then
        error "$label: expected APK '$expected_apk' not found in module"
        rm -rf "$extract_dir"
        return 1
    fi

    mods "$label: source APK $(basename "$apk")"

    modscenter_remove_stock_dirs "$@"
    modscenter_copy_system_tree "$label" "$system_root" || {
        rm -rf "$extract_dir"
        return 1
    }

    rm -rf "$extract_dir"
    mods "$label: integrated"
    return 0
}
