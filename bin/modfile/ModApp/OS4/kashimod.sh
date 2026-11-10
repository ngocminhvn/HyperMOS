#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/bin/modfile/ModApp/OS4/_common.sh"

rom_os=$(cat "$work_dir/bin/ddevice/rom_os.txt" 2>/dev/null)
[[ "$rom_os" == "OS4" ]] || exit 0

mods "OS4 Kashi mods: App Vault + ColorOS Control Center + Screenshot + Theme Manager + Launcher"

modscenter_apply_native_module \
    "HyperOS App Vault OS4" \
    "Mods-Center/HyperOS-App-Vault" \
    "com.miui.personalassistant" \
    "*AppVault*.apk" \
    "product/priv-app/MIUIPersonalAssistant" \
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

# OS4 may lack the stock App Vault; keep the privilege XML in its target partition.
modscenter_os4_stage_appvault_whitelist || exit 1

# Install the OS4 ColorOS plugin normally.
modscenter_apply_native_module \
    "ColorOS Control Center (OS4)" \
    "Mods-Center/ColorOS_Control_Center" \
    "miui.systemui.plugin" \
    "*MIUISystemUIPlugin*.apk" \
    "product/app/MIUISystemUIPlugin" \
    "MIUISystemUIPlugin" || exit 1

modscenter_apply_fixed_archive_apk \
    "HyperOS Screenshot OS4" \
    "Mods-Center/HyperOS-Screenshot-mod" \
    "files/MIUIScreenshot.apk" \
    "com.miui.screenshot" \
    "MIUIScreenshot" || exit 1

modscenter_apply_native_module \
    "HyperOS Theme Manager OS4" \
    "Mods-Center/HyperOS-Theme-Manager" \
    "com.android.thememanager" \
    "*ThemeManager*.apk" \
    "product/priv-app/MIUIThemeManager" \
    "MIUIThemeManager" \
    "MIUIThemeManagerT" \
    "MIUIThemeManagerGlobal" \
    "MIUIThemeManagerPad" \
    "ThemeManager" || exit 1

# SecurityCenter countdown is applied by UpdateFile/SecurityCountdown (OS3/OS4).

apply_kashi_launcher() {
    local label="HyperOS Launcher OS4"
    local repo="Mods-Center/HyperOS-Launcher"
    local extract_dir="$OS3_MOD_CACHE/extract-HyperOS-Launcher"
    local main_apk overlay_apk home_perm source_app_dir
    local target_home target_perm target_overlay required

    # Use the OS3 lookup flow, but select files/OS4 when available.
    find_unique_file() {
        modscenter_find_os4_member "$1" "$2"
    }

    mods "$label: installing fixed local Kashi/Mods Center snapshot for OS4 ROM"

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

    # Keep XiaomiEUExt disabled as in OS3, but retain the original
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
# Use the OS4-specific launcher package when available.
apply_kashi_launcher || exit 1

mods "OS4 Kashi mods -> Done"
