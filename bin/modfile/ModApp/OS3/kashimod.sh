#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/bin/modfile/ModApp/OS3/_common.sh"

rom_os=$(cat "$work_dir/bin/ddevice/rom_os.txt" 2>/dev/null)
[[ "$rom_os" == "OS3" ]] || exit 0

mods "Kashi mods: App Vault + ColorOS CC (current) + Screenshot + Theme Manager + Launcher; stock Security Center patched"

modscenter_apply_native_module \
    "HyperOS App Vault" \
    "Mods-Center/HyperOS-App-Vault" \
    "com.miui.personalassistant" \
    "*PersonalAssistant*.apk" \
    "-" \
    "MIUIGlobalMinusScreenWidget" \
    "MIUIGlobalMinusScreen" \
    "MIUIPersonalAssistantT" \
    "MIUIPersonalAssistant" \
    "PersonalAssistant" \
    "MIUIPersonalAssistantPhoneMIUI15" \
    "MIUIPersonalAssistantPhoneOS2NoBeta" \
    "MIUIPersonalAssistantPhoneOS2" \
    "MIUIPersonalAssistantPhoneOS3" \
    "MIUIPersonalAssistantPhoneOS3NoBeta" \
    "MIUIPersonalAssistantOS3" \
    "MIUIPersonalAssistantPadOS3" || exit 1

# Reuse the current Kashi ColorOS ZIP from the local updated snapshots,
# including its app-local native libraries and system-tree overlays.
# Do not execute the module's Magisk installation scripts.
modscenter_apply_native_module \
    "ColorOS Control Center (OS3)" \
    "Mods-Center/ColorOS_Control_Center" \
    "miui.systemui.plugin" \
    "*MIUISystemUIPlugin*.apk" \
    "product/app/MIUISystemUIPlugin" \
    "MIUISystemUIPlugin" || exit 1

modscenter_apply_fixed_archive_apk \
    "HyperOS Screenshot" \
    "Mods-Center/HyperOS-Screenshot-mod" \
    "files/MIUIScreenshot.apk" \
    "com.miui.screenshot" \
    "MIUIScreenshot" || exit 1

modscenter_apply_native_module \
    "HyperOS Theme Manager" \
    "Mods-Center/HyperOS-Theme-Manager" \
    "com.android.thememanager" \
    "*ThemeManager*.apk" \
    "product/priv-app/MIUIThemeManager" \
    "MIUIThemeManager" \
    "MIUIThemeManagerT" \
    "MIUIThemeManagerGlobal" \
    "MIUIThemeManagerPad" \
    "ThemeManager" || exit 1

patch_stock_securitycenter() (
    set -euo pipefail

    local tmp="$work_dir/apk_temp/securitycenter-countdown"
    local stock_apk stock_package stock_cert rebuilt_package signature_log
    local xiaomi_cert="c9009d01ebf9f5d0302bc71b2fe9aa9a47a432bba17308a3111b75d7b2149025"
    local -a apkeditor=(java -Xmx4g -jar "$work_dir/bin/apktool/apke.jar")
    local -a apksigner=(java -jar "$work_dir/bin/apktool/apksigner.jar")

    stock_apk=$(modscenter_find_stock_apk "com.miui.securitycenter" "SecurityCenter") || {
        error "SecurityCenter countdown: stock ROM APK not found uniquely"
        exit 1
    }
    stock_package=$(modscenter_apk_package "$stock_apk" || true)
    [[ "$stock_package" == "com.miui.securitycenter" ]] || {
        error "SecurityCenter countdown: unexpected package ${stock_package:-<unreadable>}"
        exit 1
    }

    rm -rf "$tmp"
    mkdir -p "$tmp"
    trap 'rm -rf "$tmp"' EXIT
    signature_log="$tmp/stock-signature.txt"
    if ! "${apksigner[@]}" verify --verbose --print-certs "$stock_apk" >"$signature_log" 2>&1; then
        error "SecurityCenter countdown: base APK is not a valid signed stock artifact"
        cat "$signature_log" >&2
        exit 1
    fi
    stock_cert=$(sed -n 's/^Signer #1 certificate SHA-256 digest: //p' "$signature_log" | head -n1 | tr '[:upper:]' '[:lower:]' | tr -d ':')
    [[ "$stock_cert" == "$xiaomi_cert" ]] || {
        error "SecurityCenter countdown: stock signer is not the expected Xiaomi certificate"
        exit 1
    }

    mods "Security Center: decoding stock ROM APK for ZKOS-style countdown patch; preserving ADB timing"
    "${apkeditor[@]}" d -t raw -f -no-dex-debug \
        -i "$stock_apk" -o "$tmp/raw" >/dev/null
    find "$tmp/raw/signatures" -type f -name '*.signature.info.bin' -print -quit | grep -q . || {
        error "SecurityCenter countdown: APKEditor did not retain the Xiaomi signing block"
        exit 1
    }

    python3 "$work_dir/bin/modfile/ModApp/OS3/securitycenter_countdown.py" "$tmp/raw"
    "${apkeditor[@]}" b -t raw -f -i "$tmp/raw" -o "$tmp/SecurityCenter.apk" >/dev/null

    rebuilt_package=$(modscenter_apk_package "$tmp/SecurityCenter.apk" || true)
    [[ "$rebuilt_package" == "$stock_package" ]] || {
        error "SecurityCenter countdown: rebuilt package identity changed"
        exit 1
    }

    # APKEditor restores Xiaomi's signer block like the ZKOS mod. DEX changes
    # invalidate its integrity digest, so the finished ROM still needs CorePatch.
    cp -f "$tmp/SecurityCenter.apk" "$stock_apk"
    rm -rf "$(dirname "$stock_apk")/oat"
    chmod 0644 "$stock_apk" 2>/dev/null || true
    mods "Security Center: permission countdown = 0; stock ADB handler timings preserved -> Done"
    patch "Security Center: Xiaomi signer block preserved in ZKOS-style invalid-integrity mode"
)

# Xiaomi.eu already carries its own SecurityCenter changes/signature.
# Keep that APK untouched; the China-only countdown patch requires stock Xiaomi signing.
# Do not skip the rest of the Kashi mod pipeline.
rom_source_file="$work_dir/bin/ddevice/rom_source.txt"
if [[ -s "$rom_source_file" ]] && [[ "$(tr -d '\r\n' < "$rom_source_file")" == "xiaomi_eu" ]]; then
    mods "Security Center: Xiaomi.eu detected -> skip countdown patch, preserve original APK"
else
    # China and other supported sources retain the existing certificate-checked patch.
    patch_stock_securitycenter || exit 1
fi

apply_kashi_launcher() {
    local label="HyperOS Launcher"
    local repo="Mods-Center/HyperOS-Launcher"
    local extract_dir="$OS3_MOD_CACHE/extract-HyperOS-Launcher"
    local main_apk overlay_apk home_perm source_app_dir
    local target_home target_perm target_overlay required

    find_unique_file() {
        local root="$1"
        local name="$2"
        local -a matches

        mapfile -d '' -t matches < <(find "$root" -type f -name "$name" -print0 2>/dev/null)
        if (( ${#matches[@]} != 1 )); then
            error "$label: expected one $name, found ${#matches[@]}"
            return 1
        fi
        printf '%s\n' "${matches[0]}"
    }

    mods "$label: installing fixed local Kashi/Mods Center snapshot for China ROM"

    modscenter_unpack_latest "$label" "$repo" "$extract_dir" || return 1

    main_apk=$(modscenter_find_apk "$extract_dir" "com.miui.home" "MiuiHome*.apk") || {
        error "$label: com.miui.home APK not found uniquely"
        rm -rf "$extract_dir"
        return 1
    }
    overlay_apk=$(modscenter_find_apk "$extract_dir" "android.miui.home.launcher.res" "*LauncherResOverlay*.apk") || {
        error "$label: launcher resource overlay not found uniquely"
        rm -rf "$extract_dir"
        return 1
    }
    home_perm=$(find_unique_file "$extract_dir" "privapp_whitelist_com.miui.home.xml") || {
        rm -rf "$extract_dir"
        return 1
    }

    # Keep XiaomiEUExt disabled for China ROM, but retain the original
    # native-lib extraction behavior for the launcher mod.
    source_app_dir=$(dirname "$main_apk")
    modscenter_supplement_native_libs "$label" "$main_apk" "$source_app_dir" || {
        rm -rf "$extract_dir"
        return 1
    }

    modscenter_remove_named_dirs "$OS3_IMAGES" \
        "MiuiHomeT" \
        "MiuiHome" \
        "MiLauncherGlobal" \
        "PocoHome" \
        "PocoLauncher"

    target_home="$OS3_IMAGES/product/priv-app/MiuiHome"
    target_perm="$OS3_IMAGES/product/etc/permissions"
    target_overlay="$OS3_IMAGES/product/overlay"

    rm -rf "$target_home"
    mkdir -p "$target_home" "$target_perm" "$target_overlay"

    cp -f "$main_apk" "$target_home/MiuiHome.apk" || return 1
    if [[ -d "$source_app_dir/lib" ]]; then
        cp -a "$source_app_dir/lib" "$target_home/" || return 1
    fi

    find "$OS3_IMAGES" -type f -name "MiuiHomeLauncherResOverlay.apk" -delete 2>/dev/null || true
    find "$OS3_IMAGES" -type f -name "privapp_whitelist_com.miui.home.xml" -delete 2>/dev/null || true

    cp -f "$overlay_apk" "$target_overlay/MiuiHomeLauncherResOverlay.apk" || return 1
    cp -f "$home_perm" "$target_perm/privapp_whitelist_com.miui.home.xml" || return 1

    for required in \
        "$target_home/MiuiHome.apk" \
        "$target_overlay/MiuiHomeLauncherResOverlay.apk" \
        "$target_perm/privapp_whitelist_com.miui.home.xml"; do
        [[ -s "$required" ]] || {
            error "$label: required payload missing after copy: $required"
            rm -rf "$extract_dir"
            return 1
        }
        chmod 0644 "$required" 2>/dev/null || true
    done

    if [[ -d "$target_home/lib" ]]; then
        find "$target_home/lib" -type f -name '*.so' -exec chmod 0644 {} + 2>/dev/null || true
        mods "$label: external native libs copied from the mod payload/APK"
    fi

    mods "$label: MiuiHome + native libs + launcher overlay + MiuiHome whitelist -> Done ($MODSCENTER_TAG)"
    mods "$label: XiaomiEUExt not injected"
    rm -rf "$extract_dir"
}
apply_kashi_launcher || exit 1

mods "Kashi mods -> Done"
