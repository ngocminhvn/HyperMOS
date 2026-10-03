#!/usr/bin/env bash

work_dir=${work_dir:-$(pwd)}
source "$work_dir/functions.sh"

OS3_MOD_CACHE="$work_dir/build/os3_modscenter"
OS3_IMAGES="$work_dir/build/baserom/images"
OS3_FIXED_ASSET_DIR="$work_dir/bin/modfile/OS3/assets"
MODSCENTER_ARCHIVE=""
MODSCENTER_TAG=""

modscenter_fixed_metadata() {
    local repo="$1"
    case "$repo" in
        "Mods-Center/HyperOS-App-Vault")
            printf '%s|%s|%s\n' "V4.5" "HyperOS_AppVaultV4.5@kashis_cringey_stuffs.zip" "fee4f5398472b1febe1d10a12695a2ce7b7d7e3b1f4102be11117dd3150c97ab"
            ;;
        "Mods-Center/ColorOS_Control_Center")
            printf '%s|%s|%s\n' "V3" "ColorOS_plugin_mod_V3_@kashis_cringey_stuffs.zip" "0cd9436b9cc76a7c4138137190a44d830783a4cc67980d40e9e273f2c3327499"
            ;;
        "Mods-Center/HyperOS-Launcher")
            printf '%s|%s|%s\n' "V7.1" "HyperOS_LauncherV7.1@kashis_cringey_stuffs.zip" "386d95cb96574108d61524589cd21c3ccab18afdb221a31b04eca94ba8d30e0e"
            ;;
        "Mods-Center/HyperOS-Security-Center")
            printf '%s|%s|%s\n' "V7" "HyperOS_SecurityV7@kashis_cringey_stuffs.zip" "b1722752144805f15e8e7d2d619403257594b05f123afb5ff61af004ba642d9c"
            ;;
        "Mods-Center/HyperOS-Theme-Manager")
            printf '%s|%s|%s\n' "V7" "HyperOS_ThemeManagerV7@kashis_cringey_stuffs.zip" "caba9debf6ce68d42a734125d9956707ad89ab4beda9aa6bca84d6f904d28398"
            ;;
        *) return 1 ;;
    esac
}

modscenter_prepare_fixed() {
    local label="$1"
    local repo="$2"
    local meta tag asset_name sha256 archive actual_sha

    meta=$(modscenter_fixed_metadata "$repo") || {
        error "$label: no fixed local snapshot configured for $repo"
        return 1
    }

    IFS='|' read -r tag asset_name sha256 <<< "$meta"
    archive="$OS3_FIXED_ASSET_DIR/$asset_name"

    if [[ ! -s "$archive" ]]; then
        error "$label: fixed asset missing: $archive"
        error "$label: run the Vendor fixed system apps workflow once"
        return 1
    fi

    actual_sha=$(sha256sum "$archive" | awk '{print $1}')
    if [[ "$actual_sha" != "$sha256" ]]; then
        error "$label: SHA256 mismatch for fixed asset $asset_name"
        error "$label: expected $sha256"
        error "$label: actual   $actual_sha"
        return 1
    fi

    MODSCENTER_TAG="$tag"
    MODSCENTER_ARCHIVE="$archive"
    mods "$label: fixed local $tag -> $asset_name (SHA256 OK)"
}

# Compatibility name kept so individual module scripts do not need network logic.
# This function only reads a fixed archive already committed in this repository.
modscenter_unpack_latest() {
    local label="$1"
    local repo="$2"
    local extract_dir="$3"

    modscenter_prepare_fixed "$label" "$repo" || return 1

    rm -rf "$extract_dir"
    mkdir -p "$extract_dir"
    if ! unzip -q "$MODSCENTER_ARCHIVE" -d "$extract_dir"; then
        error "$label: unzip fixed asset failed"
        return 1
    fi
}

modscenter_apk_package() {
    local apk="$1"
    aapt dump badging "$apk" 2>/dev/null \
        | sed -n "s/^package: name='\([^']*\)'.*/\1/p" \
        | head -n 1
}

modscenter_find_apk() {
    local root="$1"
    local expected_package="$2"
    local fallback_pattern="$3"
    local apk pkg
    local -a package_matches filename_matches all_apks

    mapfile -d '' -t all_apks < <(find "$root" -type f -iname '*.apk' -print0 2>/dev/null)

    for apk in "${all_apks[@]}"; do
        pkg=$(modscenter_apk_package "$apk" || true)
        if [[ "$pkg" == "$expected_package" ]]; then
            package_matches+=("$apk")
        fi
    done

    if (( ${#package_matches[@]} == 1 )); then
        printf '%s\n' "${package_matches[0]}"
        return 0
    fi

    if (( ${#package_matches[@]} > 1 )); then
        printf 'Multiple APKs expose package %s:\n' "$expected_package" >&2
        printf '  %s\n' "${package_matches[@]}" >&2
        return 1
    fi

    mapfile -d '' -t filename_matches < <(find "$root" -type f -iname "$fallback_pattern" -print0 2>/dev/null)
    if (( ${#filename_matches[@]} == 1 )); then
        printf '%s\n' "${filename_matches[0]}"
        return 0
    fi

    printf 'No unique APK for package %s / pattern %s. APK inventory:\n' "$expected_package" "$fallback_pattern" >&2
    for apk in "${all_apks[@]}"; do
        pkg=$(modscenter_apk_package "$apk" || true)
        printf '  %s -> %s\n' "$apk" "${pkg:-<unknown>}" >&2
    done
    return 1
}

modscenter_inspect_app_folder() {
    local label="$1"
    local app_dir="$2"
    local file_count so_count xml_count

    file_count=$(find "$app_dir" -type f | wc -l)
    so_count=$(find "$app_dir" -type f -name '*.so' | wc -l)
    xml_count=$(find "$app_dir" -type f -name '*.xml' | wc -l)

    mods "$label: inspect extracted app folder BEFORE replacing stock"
    echo "----- $label app folder: $app_dir -----"
    (
        cd "$app_dir" || exit 1
        find . -mindepth 1 -printf '%y %p\n' | LC_ALL=C sort
    )
    echo "----- end app folder ($file_count files, $so_count .so, $xml_count .xml) -----"
}

modscenter_supplement_native_libs() {
    local label="$1"
    local apk="$2"
    local app_dir="$3"
    local existing_count=0
    local extracted=0
    local mapping apk_abi rom_abi entry rel out src_hash dst_hash
    local -a entries

    if [[ -d "$app_dir/lib/arm" || -d "$app_dir/lib/arm64" ]]; then
        existing_count=$(find "$app_dir/lib" \( -path '*/arm/*.so' -o -path '*/arm64/*.so' \) -type f 2>/dev/null | wc -l)
    fi

    if (( existing_count > 0 )); then
        mods "$label: release already provides $existing_count external arm/arm64 .so files; keep them unchanged"
        return 0
    fi

    mods "$label: release has no external arm/arm64 libs; inspect native libs inside APK"

    for mapping in "arm64-v8a:arm64" "armeabi-v7a:arm"; do
        apk_abi="${mapping%%:*}"
        rom_abi="${mapping##*:}"

        mapfile -t entries < <(
            unzip -Z1 "$apk" 2>/dev/null \
                | grep -E "^lib/${apk_abi}/.+[.]so$" \
                | LC_ALL=C sort \
                || true
        )

        for entry in "${entries[@]}"; do
            rel="${entry#lib/${apk_abi}/}"
            # Android system-app external native-lib layout is flat per ABI.
            out="$app_dir/lib/$rom_abi/$(basename "$rel")"
            mkdir -p "$(dirname "$out")"

            if ! unzip -p "$apk" "$entry" > "$out"; then
                rm -f "$out"
                error "$label: failed extracting native lib $entry"
                return 1
            fi

            if [[ ! -s "$out" ]]; then
                rm -f "$out"
                error "$label: extracted empty native lib from $entry"
                return 1
            fi

            src_hash=$(unzip -p "$apk" "$entry" | sha256sum | awk '{print $1}')
            dst_hash=$(sha256sum "$out" | awk '{print $1}')
            if [[ "$src_hash" != "$dst_hash" ]]; then
                rm -f "$out"
                error "$label: native lib checksum mismatch: $entry"
                return 1
            fi

            chmod 0644 "$out"
            extracted=$((extracted + 1))
            mods "$label: APK $apk_abi -> lib/$rom_abi/$(basename "$out")"
        done
    done

    if (( extracted == 0 )); then
        mods "$label: APK contains no ARM native .so payload; no external lib folder needed"
    else
        mods "$label: rebuilt $extracted external native .so files from the SAME mod APK"
    fi
}

modscenter_remove_named_dirs() {
    local root="$1"
    shift
    local name path

    for name in "$@"; do
        while IFS= read -r -d '' path; do
            mods "Remove stock app dir: $path"
            rm -rf "$path"
        done < <(find "$root" -type d -name "$name" -prune -print0 2>/dev/null)
    done
}

modscenter_collect_named_dirs() {
    local root="$1"
    shift
    local name path

    for name in "$@"; do
        while IFS= read -r -d '' path; do
            printf '%s\0' "$path"
        done < <(find "$root" -type d -name "$name" -prune -print0 2>/dev/null)
    done
}

modscenter_map_system_path() {
    local system_root="$1"
    local source_path="$2"
    local rel first rest
    local logical_parts="product system_ext vendor odm mi_ext mi_product product_dlkm system_dlkm vendor_dlkm odm_dlkm"

    rel="${source_path#"$system_root"/}"
    first="${rel%%/*}"

    if [[ "$rel" == "$first" ]]; then
        rest=""
    else
        rest="${rel#*/}"
    fi

    case " $logical_parts " in
        *" $first "*)
            printf '%s\n' "$OS3_IMAGES/$first/$rest"
            ;;
        *)
            if [[ "$first" == "system" ]]; then
                printf '%s\n' "$OS3_IMAGES/system/system/$rest"
            else
                printf '%s\n' "$OS3_IMAGES/system/system/$rel"
            fi
            ;;
    esac
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
                cp -a "$entry/." "$target/" || return 1
                ;;
            *)
                target="$OS3_IMAGES/system/system"
                mkdir -p "$target"
                if [[ "$base" == "system" && -d "$entry" ]]; then
                    cp -a "$entry/." "$target/" || return 1
                else
                    cp -a "$entry" "$target/" || return 1
                fi
                ;;
        esac
    done < <(find "$system_root" -mindepth 1 -maxdepth 1 -print0)

    mods "$label: copied module system tree"
}

modscenter_verify_folder_shape() {
    local label="$1"
    local source_dir="$2"
    local target_dir="$3"
    local src_list dst_list

    [[ -d "$target_dir" ]] || {
        error "$label: target app folder missing after copy: $target_dir"
        return 1
    }

    src_list=$(mktemp)
    dst_list=$(mktemp)

    (
        cd "$source_dir" || exit 1
        find . -mindepth 1 -printf '%y %p\n' | LC_ALL=C sort
    ) > "$src_list"

    (
        cd "$target_dir" || exit 1
        find . -mindepth 1 -printf '%y %p\n' | LC_ALL=C sort
    ) > "$dst_list"

    if ! diff -u "$src_list" "$dst_list" >/dev/null; then
        error "$label: copied app folder shape differs from prepared mod folder"
        diff -u "$src_list" "$dst_list" || true
        rm -f "$src_list" "$dst_list"
        return 1
    fi

    rm -f "$src_list" "$dst_list"
    mods "$label: prepared app folder shape verified after copy"
}

modscenter_apply_native_module() {
    local label="$1"
    local repo="$2"
    local expected_package="$3"
    local fallback_pattern="$4"
    local fallback_relpath="$5"
    shift 5

    local extract_dir="$OS3_MOD_CACHE/extract-${repo##*/}"
    local source_apk source_app_dir system_root target_app_dir
    local -a stock_dirs

    modscenter_unpack_latest "$label" "$repo" "$extract_dir" || return 1

    source_apk=$(modscenter_find_apk "$extract_dir" "$expected_package" "$fallback_pattern") || {
        error "$label: cannot identify mod APK by package or filename"
        rm -rf "$extract_dir"
        return 1
    }

    source_app_dir=$(dirname "$source_apk")
    modscenter_inspect_app_folder "$label" "$source_app_dir" || {
        rm -rf "$extract_dir"
        return 1
    }

    # If the release does not already ship system-style external native libs,
    # rebuild them byte-for-byte from the same mod APK.
    modscenter_supplement_native_libs "$label" "$source_apk" "$source_app_dir" || {
        rm -rf "$extract_dir"
        return 1
    }

    system_root=""
    case "$source_apk" in
        */system/*)
            system_root="${source_apk%%/system/*}/system"
            ;;
    esac

    if [[ -n "$system_root" && -d "$system_root" ]]; then
        target_app_dir=$(modscenter_map_system_path "$system_root" "$source_app_dir")

        modscenter_remove_named_dirs "$OS3_IMAGES" "$@"
        rm -rf "$target_app_dir"

        modscenter_copy_system_tree "$label" "$system_root" || {
            error "$label: failed copying module payload"
            rm -rf "$extract_dir"
            return 1
        }

        modscenter_verify_folder_shape "$label" "$source_app_dir" "$target_app_dir" || {
            rm -rf "$extract_dir"
            return 1
        }

        mods "$label: stock app replaced using module system path -> $target_app_dir"
    else
        mapfile -d '' -t stock_dirs < <(modscenter_collect_named_dirs "$OS3_IMAGES" "$@")

        if (( ${#stock_dirs[@]} > 0 )); then
            target_app_dir="${stock_dirs[0]}"
        elif [[ -n "$fallback_relpath" && "$fallback_relpath" != "-" ]]; then
            target_app_dir="$OS3_IMAGES/$fallback_relpath"
            mods "$label: stock folder was already removed; restore original OS3 path -> $target_app_dir"
        else
            error "$label: standalone app payload found and no stock/fallback path is available"
            rm -rf "$extract_dir"
            return 1
        fi

        modscenter_remove_named_dirs "$OS3_IMAGES" "$@"
        rm -rf "$target_app_dir"
        mkdir -p "$target_app_dir"

        cp -a "$source_app_dir/." "$target_app_dir/" || {
            error "$label: failed mirroring prepared standalone app folder"
            rm -rf "$extract_dir"
            return 1
        }

        modscenter_verify_folder_shape "$label" "$source_app_dir" "$target_app_dir" || {
            rm -rf "$extract_dir"
            return 1
        }

        mods "$label: stock app replaced in-place from prepared release folder -> $target_app_dir"
    fi

    rm -rf "$extract_dir"
    mods "$label: fixed local $MODSCENTER_TAG integrated"
}
