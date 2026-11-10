#!/usr/bin/env bash
# Reuse OS3's validated ZIP, APK package, native-library and system-tree helpers.
# Only the source selection changes: OS4-specific member first, shared second.
work_dir="${work_dir:-$(pwd)}"
OS3_MOD_CACHE="${OS4_MOD_CACHE:-$work_dir/build/os4_modscenter}"
OS3_IMAGES="${OS4_IMAGES:-$work_dir/build/baserom/images}"
OS3_KASHI_DIR="${OS4_KASHI_DIR:-$work_dir/bin/modfile/ModApp/Kashi}"
source "$work_dir/bin/modfile/ModApp/OS3/_common.sh"

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

# Select among paths already filtered by package name or exact filename.
# Never fall back to OS3 when only an OS3 variant is present.
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
    local root="$1" expected_package="$2" fallback_pattern="$3"
    local apk pkg
    local -a apks=() matched=()
    mapfile -d '' -t apks < <(find "$root" -type f -iname '*.apk' -print0 2>/dev/null)
    for apk in "${apks[@]}"; do
        pkg="$(modscenter_apk_package "$apk" || true)"
        if [[ "$pkg" == "$expected_package" ]]; then
            matched+=("$apk")
        fi
    done
    if (( ${#matched[@]} == 0 )); then
        printf 'OS4: expected Android package %s not found in %s (%s)\n' \
            "$expected_package" "$root" "$fallback_pattern" >&2
        return 1
    fi
    modscenter_select_os4_file "$root" "${matched[@]}"
}

modscenter_find_os4_member() {
    local root="$1" filename="$2" path
    local -a matched=()
    mapfile -d '' -t matched < <(find "$root" -type f -name "$filename" -print0 2>/dev/null)
    (( ${#matched[@]} > 0 )) || {
        printf 'OS4: required file %s missing in %s\n' "$filename" "$root" >&2
        return 1
    }
    modscenter_select_os4_file "$root" "${matched[@]}"
}

# Copy the *upstream ZIP's* App Vault permissions beside its installed system
# partition. On OS4, the original App Vault directory may be entirely missing.
modscenter_os4_stage_appvault_whitelist() {
    local label="HyperOS App Vault OS4 permissions"
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

    modscenter_prepare_fixed "$label" "Mods-Center/HyperOS-App-Vault" || return 1
    if ! unzip -Z1 "$MODSCENTER_ARCHIVE" 2>/dev/null | grep -Fxq "$member"; then
        error "$label: upstream ZIP has no $member"
        return 1
    fi
    mkdir -p "$permissions"
    out="$permissions/privapp_whitelist_com.miui.personalassistant.xml"
    tmp="$(mktemp)"
    if ! unzip -p "$MODSCENTER_ARCHIVE" "$member" >"$tmp" ||
        [[ ! -s "$tmp" ]]; then
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
