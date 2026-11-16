#!/usr/bin/env bash
# ==============================================================================
# Kashi Mods Installer (OS3 & OS4 Unified)
# Controlled by kashi.jsonc (or kashi.json)
# ==============================================================================
set -euo pipefail

work_dir="${work_dir:-$(pwd)}"
source "$work_dir/bin/modfile/ModApp/Kashi/_common.sh"

kashi_dir="$work_dir/bin/modfile/ModApp/Kashi"
reader="$kashi_dir/config_reader.py"

rom_os="$(cat "$work_dir/bin/ddevice/rom_os.txt" 2>/dev/null || true)"
if [[ "$rom_os" != "OS3" && "$rom_os" != "OS4" ]]; then
    mods "Kashi mods: unsupported rom_os=$rom_os, skipping"
    exit 0
fi

is_mod_enabled() {
    local mod_key="$1"
    if [[ -f "$reader" ]]; then
        python3 "$reader" is_enabled "$mod_key" "$rom_os" 2>/dev/null || echo "1"
    else
        echo "1"
    fi
}

get_mod_zip() {
    local mod_key="$1"
    if [[ -f "$reader" ]]; then
        python3 "$reader" get_zip "$mod_key" "$rom_os" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

mods "Starting Kashi mods integration for $rom_os (via kashi.jsonc)..."

# 1. HyperOS App Vault
if [[ "$(is_mod_enabled "app_vault")" == "1" ]]; then
    app_vault_zip="$(get_mod_zip "app_vault")"
    if [[ "$rom_os" == "OS4" ]]; then
        modscenter_apply_native_module \
            "HyperOS App Vault OS4" \
            "Mods-Center/HyperOS-App-Vault" \
            "com.miui.personalassistant" \
            "*AppVault*.apk" \
            "product/priv-app/MIUIPersonalAssistant" \
            "$app_vault_zip" \
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
            "MIUIPersonalAssistantPadOS3" \
            "MIUIPersonalAssistantPhoneOS4" \
            "MIUIPersonalAssistantOS4" \
            "AppVault" || exit 1

        modscenter_os4_stage_appvault_whitelist "$app_vault_zip" || exit 1
    else
        modscenter_apply_native_module \
            "HyperOS App Vault OS3" \
            "Mods-Center/HyperOS-App-Vault" \
            "com.miui.personalassistant" \
            "*PersonalAssistant*.apk" \
            "-" \
            "$app_vault_zip" \
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
    fi
else
    mods "HyperOS App Vault: disabled in kashi.jsonc"
fi

# 2. Control Center Plugin (ColorOS or FreeStyle)
if [[ "$(is_mod_enabled "control_center")" == "1" ]]; then
    cc_zip="$(get_mod_zip "control_center")"
    modscenter_apply_native_module \
        "Control Center Plugin ($rom_os)" \
        "Mods-Center/ColorOS_Control_Center" \
        "miui.systemui.plugin" \
        "*MIUISystemUIPlugin*.apk" \
        "product/app/MIUISystemUIPlugin" \
        "$cc_zip" \
        "MIUISystemUIPlugin" || exit 1
else
    mods "Control Center Plugin: disabled in kashi.jsonc"
fi

# 3. HyperOS Screenshot
if [[ "$(is_mod_enabled "screenshot")" == "1" ]]; then
    screenshot_zip="$(get_mod_zip "screenshot")"
    modscenter_apply_fixed_archive_apk \
        "HyperOS Screenshot ($rom_os)" \
        "Mods-Center/HyperOS-Screenshot-mod" \
        "files/MIUIScreenshot.apk" \
        "com.miui.screenshot" \
        "MIUIScreenshot" \
        "$screenshot_zip" || exit 1
else
    mods "HyperOS Screenshot: disabled in kashi.jsonc"
fi

# 4. HyperOS Theme Manager
if [[ "$(is_mod_enabled "theme_manager")" == "1" ]]; then
    theme_zip="$(get_mod_zip "theme_manager")"
    modscenter_apply_native_module \
        "HyperOS Theme Manager ($rom_os)" \
        "Mods-Center/HyperOS-Theme-Manager" \
        "com.android.thememanager" \
        "*ThemeManager*.apk" \
        "product/priv-app/MIUIThemeManager" \
        "$theme_zip" \
        "MIUIThemeManager" \
        "MIUIThemeManagerT" \
        "MIUIThemeManagerGlobal" \
        "MIUIThemeManagerPad" \
        "ThemeManager" || exit 1
else
    mods "HyperOS Theme Manager: disabled in kashi.jsonc"
fi

# 5. HyperOS Launcher
if [[ "$(is_mod_enabled "launcher")" == "1" ]]; then
    apply_kashi_launcher() {
        local label="HyperOS Launcher ($rom_os)"
        local repo="Mods-Center/HyperOS-Launcher"
        local launcher_zip
        launcher_zip="$(get_mod_zip "launcher")"
        local extract_dir="$OS3_MOD_CACHE/extract-HyperOS-Launcher"
        local main_apk overlay_apk home_perm source_app_dir
        local target_home target_perm target_overlay required

        find_launcher_perm() {
            if [[ "$rom_os" == "OS4" ]]; then
                modscenter_find_os4_member "$1" "$2"
            else
                local root="$1" name="$2"
                local -a matches=()
                mapfile -d '' -t matches < <(find "$root" -type f -name "$name" -print0 2>/dev/null)
                if (( ${#matches[@]} != 1 )); then
                    error "$label: expected one $name, found ${#matches[@]}"
                    return 1
                fi
                printf '%s\n' "${matches[0]}"
            fi
        }

        mods "$label: installing local Kashi snapshot for $rom_os"
        modscenter_unpack_latest "$label" "$repo" "$extract_dir" "$launcher_zip" || return 1

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
        home_perm=$(find_launcher_perm "$extract_dir" "privapp_whitelist_com.miui.home.xml") || {
            rm -rf "$extract_dir"
            return 1
        }

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
            mods "$label: external native libs copied from mod payload/APK"
        fi

        mods "$label: MiuiHome + native libs + launcher overlay + whitelist -> Done ($MODSCENTER_TAG)"
        rm -rf "$extract_dir"
    }
    apply_kashi_launcher || exit 1
else
    mods "HyperOS Launcher: disabled in kashi.jsonc"
fi

# 6. HyperOS Security Center (Disabled by default)
if [[ "$(is_mod_enabled "security_center")" == "1" ]]; then
    sec_zip="$(get_mod_zip "security_center")"
    modscenter_apply_native_module \
        "HyperOS Security Center ($rom_os)" \
        "Mods-Center/HyperOS-Security-Center" \
        "com.miui.securitycenter" \
        "*SecurityCenter*.apk" \
        "system_ext/priv-app/SecurityCenter" \
        "$sec_zip" \
        "SecurityCenter" || exit 1
fi

mods "Kashi mods integration for $rom_os -> Complete"
