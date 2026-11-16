#!/usr/bin/env bash
# ==============================================================================
# Shared helper functions for Kashi Mods (OS3 & OS4)
# ==============================================================================
set -euo pipefail

work_dir="${work_dir:-$(pwd)}"
source "$work_dir/functions.sh"

# Determine target directories
rom_os="$(cat "$work_dir/bin/ddevice/rom_os.txt" 2>/dev/null || true)"
OS3_MOD_CACHE="${OS3_MOD_CACHE:-$work_dir/build/kashi_modscenter}"
OS3_IMAGES="${OS3_IMAGES:-$work_dir/build/baserom/images}"

# Read zip_dir from config_reader.py if available, else prefer Zip/
if [[ -f "$work_dir/bin/modfile/ModApp/Kashi/config_reader.py" ]]; then
    configured_zip_dir="$(python3 "$work_dir/bin/modfile/ModApp/Kashi/config_reader.py" get_zip_dir 2>/dev/null || true)"
fi

if [[ -n "${configured_zip_dir:-}" && -d "$work_dir/$configured_zip_dir" ]]; then
    OS3_KASHI_DIR="${OS3_KASHI_DIR:-$work_dir/$configured_zip_dir}"
elif [[ -d "$work_dir/bin/modfile/ModApp/Kashi/Zip" ]]; then
    OS3_KASHI_DIR="${OS3_KASHI_DIR:-$work_dir/bin/modfile/ModApp/Kashi/Zip}"
else
    OS3_KASHI_DIR="${OS3_KASHI_DIR:-$work_dir/bin/modfile/ModApp/Kashi}"
fi

MODSCENTER_ARCHIVE=""
MODSCENTER_TAG=""

modscenter_fixed_prefix() {
    local repo="$1"
    case "$repo" in
        "Mods-Center/HyperOS-App-Vault") printf '%s\n' "HyperOS_AppVault" ;;
        "Mods-Center/FreeStyle-Control-Center") printf '%s\n' "FreeStyle_CC_mod_" ;;
        "Mods-Center/ColorOS_Control_Center") printf '%s\n' "ColorOS_plugin_mod_" ;;
        "Mods-Center/HyperOS-Screenshot-mod") printf '%s\n' "HyperOS_Screenshot" ;;
        "Mods-Center/HyperOS-Launcher") printf '%s\n' "HyperOS_Launcher" ;;
        "Mods-Center/HyperOS-Rust-Launcher-Mod") printf '%s\n' "HyperOS4_RustLauncherMod_" ;;
        "Mods-Center/HyperOS-Security-Center") printf '%s\n' "HyperOS_Security" ;;
        "Mods-Center/HyperOS-Theme-Manager") printf '%s\n' "HyperOS_ThemeManager" ;;
        *) return 1 ;;
    esac
}

modscenter_prepare_fixed() {
    local label="$1"
    local repo="$2"
    local explicit_zip="${3:-}"
    local prefix archive
    local -a matches=()

    # If a specific zip is configured in kashi.json, load it directly
    if [[ -n "$explicit_zip" ]]; then
        for search_dir in "$OS3_KASHI_DIR" "$work_dir/bin/modfile/ModApp/Kashi/Zip" "$work_dir/bin/modfile/ModApp/Kashi"; do
            if [[ -f "$search_dir/$explicit_zip" ]]; then
                archive="$search_dir/$explicit_zip"
                break
            elif [[ -f "$explicit_zip" ]]; then
                archive="$explicit_zip"
                break
            fi
        done
        if [[ -z "${archive:-}" || ! -s "$archive" ]]; then
            error "$label: configured zip file not found or empty: $explicit_zip"
            return 1
        fi
        MODSCENTER_ARCHIVE="$archive"
        MODSCENTER_TAG=$(basename "$archive" .zip)
        mods "$label: selected zip (from config) -> $(basename "$archive")"
        return 0
    fi

    prefix=$(modscenter_fixed_prefix "$repo") || {
        error "$label: no fixed local filename prefix configured for $repo"
        return 1
    }

    # Search in configured zip dir and its parent
    for search_dir in "$OS3_KASHI_DIR" "$work_dir/bin/modfile/ModApp/Kashi/Zip" "$work_dir/bin/modfile/ModApp/Kashi"; do
        if [[ -d "$search_dir" ]]; then
            while IFS= read -r -d '' item; do
                matches+=("$item")
            done < <(find "$search_dir" -maxdepth 1 -type f -iname "${prefix}*.zip" -print0 2>/dev/null)
        fi
        (( ${#matches[@]} > 0 )) && break
    done

    if (( ${#matches[@]} == 0 )); then
        error "$label: no local ZIP matching ${prefix}*.zip in $OS3_KASHI_DIR"
        return 1
    fi

    if (( ${#matches[@]} > 1 )); then
        error "$label: multiple local ZIPs match ${prefix}*.zip; specify selected_zip in kashi.json"
        printf '  %s\n' "${matches[@]}" >&2
        return 1
    fi

    archive="${matches[0]}"
    [[ -s "$archive" ]] || {
        error "$label: matched ZIP is empty: $archive"
        return 1
    }

    MODSCENTER_ARCHIVE="$archive"
    MODSCENTER_TAG=$(basename "$archive" .zip)
    mods "$label: fixed local -> $(basename "$archive")"
}

modscenter_unpack_latest() {
    local label="$1"
    local repo="$2"
    local extract_dir="$3"
    local explicit_zip="${4:-}"

    modscenter_prepare_fixed "$label" "$repo" "$explicit_zip" || return 1

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

modscenter_os4_variant() {
    local rel="$1"
    if [[ "$rel" =~ (^|[/_.-])([Hh]yper)?[Oo][Ss]4([/_.-]|$) ]]; then
        printf '%s\n' OS4
    elif [[ "$rel" =~ (^|[/_.-])([Hh]yper)?[Oo][Ss]3([/_.-]|$) ]]; then
        printf '%s\n' OS3
    else
        printf '%s\n' common
    fi
}

modscenter_select_os4_file() {
    local root="$1"
    shift
    local path rel variant
    local -a os4=() shared=()
    for path in "$@"; do
        rel="${path#"$root"/}"
        variant="$(modscenter_os4_variant "$rel")"
        case "$variant" in
            OS4) os4+=("$path") ;;
            common) shared+=("$path") ;;
        esac
    done
    if (( ${#os4[@]} == 1 )); then
        printf '%s\n' "${os4[0]}"
        return 0
    elif (( ${#os4[@]} > 1 )); then
        printf 'Multiple OS4 candidates found:\n  %s\n' "${os4[@]}" >&2
        return 1
    fi
    if (( ${#shared[@]} == 1 )); then
        printf '%s\n' "${shared[0]}"
        return 0
    fi
    printf 'OS4 selection failed: OS4=%s shared=%s (OS3 variants prohibited)\n' \
        "${#os4[@]}" "${#shared[@]}" >&2
    return 1
}

modscenter_find_apk() {
    local root="$1"
    local expected_package="$2"
    local fallback_pattern="$3"
    local apk pkg
    local -a apks=() package_matches=()

    mapfile -d '' -t apks < <(find "$root" -type f -iname '*.apk' -print0 2>/dev/null)
    for apk in "${apks[@]}"; do
        pkg=$(modscenter_apk_package "$apk" || true)
        if [[ "$pkg" == "$expected_package" ]]; then
            package_matches+=("$apk")
        fi
    done

    # If rom_os is OS4, use OS4 selector logic
    if [[ "${rom_os:-}" == "OS4" ]]; then
        if (( ${#package_matches[@]} == 0 )); then
            printf 'OS4: expected Android package %s not found in %s (%s)\n' \
                "$expected_package" "$root" "$fallback_pattern" >&2
            return 1
        fi
        modscenter_select_os4_file "$root" "${package_matches[@]}"
        return $?
    fi

    # OS3 logic
    local rel
    local -a os3_matches=()
    for apk in "${package_matches[@]}"; do
        rel="${apk#"$root"/}"
        if [[ "$rel" =~ (^|[/_.-])([Hh]yper)?[Oo][Ss]4([/_.-]|$) ]]; then
            continue
        fi
        if [[ "$rel" =~ (^|[/_.-])([Hh]yper)?[Oo][Ss]3([/_.-]|$) ]]; then
            os3_matches+=("$apk")
        fi
    done

    if (( ${#package_matches[@]} == 1 )); then
        apk="${package_matches[0]}"
        rel="${apk#"$root"/}"
        if [[ "$rel" =~ (^|[/_.-])([Hh]yper)?[Oo][Ss]4([/_.-]|$) ]]; then
            printf 'Only OS4 APK available for %s: %s\n' "$expected_package" "$rel" >&2
            return 1
        fi
        printf '%s\n' "$apk"
        return 0
    fi

    if (( ${#package_matches[@]} > 1 )); then
        if (( ${#os3_matches[@]} == 1 )); then
            printf '%s\n' "${os3_matches[0]}"
            return 0
        fi
        printf 'Cannot uniquely select OS3 APK for package %s. OS3 matches: %s\n' \
            "$expected_package" "${#os3_matches[@]}" >&2
        printf '  %s\n' "${package_matches[@]#"$root"/}" >&2
        return 1
    fi

    local -a filename_matches=()
    mapfile -d '' -t filename_matches < <(find "$root" -type f -name "$fallback_pattern" -print0 2>/dev/null)
    if (( ${#filename_matches[@]} == 1 )); then
        printf '%s\n' "${filename_matches[0]}"
        return 0
    fi

    error "Cannot find APK for $expected_package with fallback pattern $fallback_pattern"
    return 1
}

modscenter_find_os4_member() {
    local root="$1" filename="$2"
    local -a matched=()
    mapfile -d '' -t matched < <(find "$root" -type f -name "$filename" -print0 2>/dev/null)
    (( ${#matched[@]} > 0 )) || {
        printf 'OS4: required file %s missing in %s\n' "$filename" "$root" >&2
        return 1
    }
    modscenter_select_os4_file "$root" "${matched[@]}"
}

modscenter_supplement_native_libs() {
    local label="$1"
    local apk="$2"
    local app_dir="$3"
    local existing_count=0
    local extracted=0
    local mapping apk_abi rom_abi entry rel out
    local -a entries=()

    if [[ -d "$app_dir/lib/arm" || -d "$app_dir/lib/arm64" ]]; then
        existing_count=$(find "$app_dir/lib" \( -path '*/arm/*.so' -o -path '*/arm64/*.so' \) -type f 2>/dev/null | wc -l)
    fi

    if (( existing_count > 0 )); then
        mods "$label: release already provides $existing_count external arm/arm64 .so files; keep them unchanged"
        return 0
    fi

    mapfile -t entries < <(unzip -Z1 "$apk" 'lib/*/*.so' 2>/dev/null || true)
    if (( ${#entries[@]} == 0 )); then
        mods "$label: APK has no bundled native libraries; no external lib folder required"
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
            extracted=$((extracted + 1))
        done
    done

    if (( extracted > 0 )); then
        mods "$label: extracted $extracted external native libraries from APK into lib/(arm|arm64)"
    fi
}

modscenter_remove_named_dirs() {
    local images_root="$1"
    shift
    local name
    for name in "$@"; do
        find "$images_root" -type d -name "$name" -exec rm -rf {} + 2>/dev/null || true
    done
}

modscenter_verify_folder_shape() {
    local label="$1"
    local source_dir="$2"
    local target_dir="$3"
    local src_count dst_count
    src_count=$(find "$source_dir" -type f | wc -l)
    dst_count=$(find "$target_dir" -type f | wc -l)
    if (( src_count != dst_count )); then
        error "$label: file count mismatch between source ($src_count) and target ($dst_count)"
        return 1
    fi
}

modscenter_map_system_path() {
    local system_root="$1"
    local source_app_dir="$2"
    local rel_path="${source_app_dir#"$system_root"/}"
    local partition="${rel_path%%/*}"
    local sub_path="${rel_path#"$partition"/}"

    case "$partition" in
        system|system_ext|product|mi_ext)
            printf '%s/%s/%s\n' "$OS3_IMAGES" "$partition" "$sub_path"
            ;;
        *)
            printf '%s/system/system/%s\n' "$OS3_IMAGES" "$rel_path"
            ;;
    esac
}

modscenter_find_stock_apk() {
    local expected_package="$1" preferred_dir="$2"
    local folder apk pkg
    local -a matches=()
    while IFS= read -r -d '' folder; do
        while IFS= read -r -d '' apk; do
            pkg=$(modscenter_apk_package "$apk" || true)
            [[ "$pkg" == "$expected_package" ]] && matches+=("$apk")
        done < <(find "$folder" -maxdepth 1 -type f -iname '*.apk' -print0 2>/dev/null)
    done < <(find "$OS3_IMAGES" -type d -name "$preferred_dir" -print0 2>/dev/null)
    if (( ${#matches[@]} == 0 )); then
        while IFS= read -r -d '' apk; do
            pkg=$(modscenter_apk_package "$apk" || true)
            [[ "$pkg" == "$expected_package" ]] && matches+=("$apk")
        done < <(find "$OS3_IMAGES" -type f -iname '*.apk' -print0 2>/dev/null)
    fi
    if (( ${#matches[@]} != 1 )); then
        error "Stock APK for $expected_package: expected 1, found ${#matches[@]}"
        printf '  %s\n' "${matches[@]}" >&2
        return 1
    fi
    printf '%s\n' "${matches[0]}"
}

modscenter_apply_native_module() {
    local label="$1"
    local repo="$2"
    local expected_package="$3"
    local fallback_pattern="$4"
    local preferred_stock_dir="$5"
    local explicit_zip="${6:-}"
    shift 6 2>/dev/null || shift $#
    local extract_dir="$OS3_MOD_CACHE/extract-${repo##*/}"
    local source_apk source_app_dir target_app_dir system_root actual_package

    mods "$label: preparing native module ($repo)"
    modscenter_unpack_latest "$label" "$repo" "$extract_dir" "$explicit_zip" || return 1

    source_apk=$(modscenter_find_apk "$extract_dir" "$expected_package" "$fallback_pattern") || {
        error "$label: cannot identify mod APK by package or filename"
        rm -rf "$extract_dir"
        return 1
    }

    source_app_dir=$(dirname "$source_apk")
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
        mkdir -p "$target_app_dir"
        cp -a "$source_app_dir/." "$target_app_dir/" || {
            error "$label: failed copying module app folder"
            rm -rf "$extract_dir"
            return 1
        }
    else
        local stock_apk
        stock_apk=$(modscenter_find_stock_apk "$expected_package" "$preferred_stock_dir" 2>/dev/null || true)
        if [[ -n "$stock_apk" ]]; then
            target_app_dir=$(dirname "$stock_apk")
        elif [[ "$preferred_stock_dir" != "-" ]]; then
            target_app_dir="$OS3_IMAGES/$preferred_stock_dir"
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
    fi

    rm -rf "$extract_dir"
    mods "$label: fixed local $MODSCENTER_TAG integrated"
}

modscenter_apply_fixed_archive_apk() {
    local label="$1" repo="$2" member="$3" expected_package="$4" preferred_dir="$5"
    local explicit_zip="${6:-}"
    local staging="$OS3_MOD_CACHE/single-${repo##*/}"
    local source_apk="$staging/selected.apk"
    local unpacked="$staging/extracted"
    local prepared="$staging/prepared"
    local stock_apk stock_folder stock_filename copied_package actual_package found_apk

    modscenter_prepare_fixed "$label" "$repo" "$explicit_zip" || return 1
    if ! unzip -tqq "$MODSCENTER_ARCHIVE" >/dev/null; then
        error "$label: ZIP integrity check failed"
        return 1
    fi
    rm -rf "$staging"
    mkdir -p "$staging"
    if ! unzip -q "$MODSCENTER_ARCHIVE" -d "$unpacked"; then
        error "$label: cannot extract module payload"
        rm -rf "$staging"
        return 1
    fi
    found_apk=$(modscenter_find_apk "$unpacked" "$expected_package" "__no_filename_fallback__") || {
        error "$label: exactly one APK with $expected_package required"
        rm -rf "$staging"
        return 1
    }
    cp -f "$found_apk" "$source_apk" || return 1
    actual_package=$(modscenter_apk_package "$source_apk" || true)
    if [[ "$actual_package" != "$expected_package" ]]; then
        error "$label: package mismatch: ${actual_package:-<unreadable>}"
        rm -rf "$staging"
        return 1
    fi
    stock_apk=$(modscenter_find_stock_apk "$expected_package" "$preferred_dir") || {
        error "$label: stock APK absent; refusing to guess destination partition"
        rm -rf "$staging"
        return 1
    }
    stock_folder=$(dirname "$stock_apk")
    stock_filename=$(basename "$stock_apk")
    mkdir -p "$prepared"
    cp -f "$source_apk" "$prepared/$stock_filename" || return 1
    modscenter_supplement_native_libs "$label" "$prepared/$stock_filename" "$prepared" || {
        rm -rf "$staging"
        return 1
    }
    find "$prepared" -type d -exec chmod 0755 {} +
    find "$prepared" -type f -exec chmod 0644 {} +

    mods "$label: $member -> $stock_folder/$stock_filename"
    rm -rf "$stock_folder"
    mkdir -p "$stock_folder"
    if ! cp -a "$prepared/." "$stock_folder/"; then
        error "$label: failed to copy mod app folder"
        rm -rf "$staging"
        return 1
    fi
    copied_package=$(modscenter_apk_package "$stock_folder/$stock_filename" || true)
    if [[ "$copied_package" != "$expected_package" ]] ||
       ! modscenter_verify_folder_shape "$label" "$prepared" "$stock_folder"; then
        error "$label: post-copy verification failed"
        rm -rf "$staging"
        return 1
    fi
    mods "$label: exact APK installed successfully ($MODSCENTER_TAG)"
    rm -rf "$staging"
}

modscenter_os4_stage_appvault_whitelist() {
    local label="HyperOS App Vault OS4 permissions"
    local explicit_zip="${1:-}"
    local member="system/etc/permissions/privapp_whitelist_com.miui.personalassistant.xml"
    local app apk relative partition permissions out tmp
    local -a installed=()

    mapfile -d '' -t installed < <(find "$OS3_IMAGES" -type f -name 'AppVault.apk' -print0 2>/dev/null)
    if (( ${#installed[@]} != 1 )); then
        error "$label: expected one installed AppVault.apk; found ${#installed[@]}"
        return 1
    fi
    apk="${installed[0]}"
    [[ "$(modscenter_apk_package "$apk" || true)" == "com.miui.personalassistant" ]] || {
        error "$label: installed APK package mismatch"
        return 1
    }

    relative="${apk#"$OS3_IMAGES"/}"
    partition="${relative%%/*}"
    case "$partition" in
        product|system_ext|mi_ext) permissions="$OS3_IMAGES/$partition/etc/permissions" ;;
        system) permissions="$OS3_IMAGES/system/system/etc/permissions" ;;
        *)
            error "$label: unsupported installed partition $partition"
            return 1
            ;;
    esac

    modscenter_prepare_fixed "$label" "Mods-Center/HyperOS-App-Vault" "$explicit_zip" || return 1
    if ! unzip -Z1 "$MODSCENTER_ARCHIVE" 2>/dev/null | grep -Fxq "$member"; then
        error "$label: upstream ZIP has no $member"
        return 1
    fi
    mkdir -p "$permissions"
    out="$permissions/privapp_whitelist_com.miui.personalassistant.xml"
    tmp="$(mktemp)"
    if ! unzip -p "$MODSCENTER_ARCHIVE" "$member" >"$tmp" || [[ ! -s "$tmp" ]]; then
        rm -f "$tmp"
        error "$label: cannot extract whitelist XML"
        return 1
    fi
    if ! python3 - "$tmp" <<'PY'
import sys
import xml.etree.ElementTree as ET
try:
    root=ET.parse(sys.argv[1]).getroot()
    assert any(
        node.tag.rsplit("}", 1)[-1] == "privapp-permissions"
        and node.attrib.get("package") == "com.miui.personalassistant"
        for node in root.iter()
    )
except (ET.ParseError, AssertionError) as exc:
    raise SystemExit("App Vault whitelist XML is invalid: " + str(exc))
PY
    then
        rm -f "$tmp"
        error "$label: invalid permission XML"
        return 1
    fi

    if [[ -e "$out" ]]; then
        mods "$label: keep existing stock whitelist -> $out"
        rm -f "$tmp"
    else
        install -m 0644 "$tmp" "$out" || { rm -f "$tmp"; return 1; }
        rm -f "$tmp"
        mods "$label: installed verified upstream whitelist -> $out"
    fi
}
