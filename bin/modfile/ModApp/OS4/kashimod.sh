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

apply_kashi_rust_launcher() {
    local label="HyperOS 4 Rust Launcher"
    local repo="Mods-Center/HyperOS-Rust-Launcher-Mod"
    local extract_dir="$OS3_MOD_CACHE/extract-HyperOS4-Rust-Launcher"
    local main_apk ext_apk src_perm src_dir pkg lib runtime_lib location
    local target_home target_ext target_perm required
    local found

    # Fail closed before changing the system image if this is not an A17 OS4
    # Rust/Flutter environment. The legacy Kashi dex launcher is OS3-only.
    if [[ "$(tr -d ' \r\n' < "$work_dir/bin/ddevice/androidver.txt" 2>/dev/null)" != "17" ]]; then
        error "$label: Android 17 is required"
        return 1
    fi
    found=0
    for location in \
        "$OS3_IMAGES/system_ext/bin/hyos_spawner" \
        "$OS3_IMAGES/system/system_ext/bin/hyos_spawner" \
        "$OS3_IMAGES/system/system/bin/hyos_spawner"; do
        [[ -f "$location" ]] && found=1
    done
    if (( found != 1 )); then
        error "$label: missing hyos_spawner (Rust launcher runtime)"
        return 1
    fi
    for runtime_lib in \
        libhyper_os_flutter.so libhyper_os_app_public.so \
        libhyper_os_ui_public.so libhyper_os_system_public.so; do
        found=0
        for location in \
            "$OS3_IMAGES/system_ext/lib64/$runtime_lib" \
            "$OS3_IMAGES/system/system_ext/lib64/$runtime_lib" \
            "$OS3_IMAGES/system/system/lib64/$runtime_lib"; do
            [[ -f "$location" ]] && found=1
        done
        if (( found != 1 )); then
            error "$label: missing required OS4 runtime $runtime_lib"
            return 1
        fi
    done

    # Use only the verified Kashi ZIP managed by update-kashi-apps.yml.
    # Do not run Magisk install hooks or fetch arbitrary assets during ROM build.
    modscenter_unpack_latest "$label" "$repo" "$extract_dir" || return 1

    main_apk="$extract_dir/files/MiuiHome.apk"
    ext_apk="$extract_dir/files/HyperLauncherExt.apk"
    src_perm="$extract_dir/system/product/etc/permissions"
    for required in \
        "$main_apk" "$ext_apk" \
        "$src_perm/privapp-permissions-com.miui.home-mod.xml" \
        "$src_perm/privapp-permissions-com.miui.home.kashi.ext.xml"; do
        if [[ ! -s "$required" ]]; then
            error "$label: required ZIP member missing: $required"
            rm -rf "$extract_dir"
            return 1
        fi
    done

    pkg="$(modscenter_apk_package "$main_apk" || true)"
    if [[ "$pkg" != "com.miui.home" ]]; then
        error "$label: invalid launcher APK package: $pkg"
        rm -rf "$extract_dir"
        return 1
    fi
    pkg="$(modscenter_apk_package "$ext_apk" || true)"
    if [[ "$pkg" != "com.miui.home.kashi.ext" ]]; then
        error "$label: invalid settings APK package: $pkg"
        rm -rf "$extract_dir"
        return 1
    fi
    for lib in libapp.so libapp_launcher.so libkashidock.so; do
        if ! unzip -Z1 "$main_apk" 2>/dev/null | grep -Fxq "lib/arm64-v8a/$lib"; then
            error "$label: required native helper/library absent: $lib"
            rm -rf "$extract_dir"
            return 1
        fi
    done
    if ! python3 - "$src_perm" <<'PY'
import pathlib
import sys
import xml.etree.ElementTree as ET
folder = pathlib.Path(sys.argv[1])
for filename, package in (
    ("privapp-permissions-com.miui.home-mod.xml", "com.miui.home"),
    ("privapp-permissions-com.miui.home.kashi.ext.xml", "com.miui.home.kashi.ext"),
):
    tree = ET.parse(folder / filename)
    if not any(
        elem.tag.rsplit("}", 1)[-1] == "privapp-permissions"
        and elem.attrib.get("package") == package
        for elem in tree.getroot().iter()
    ):
        raise SystemExit(f"bad privileged-permission XML: {filename}")
PY
    then
        error "$label: upstream privileged-permission XML invalid"
        rm -rf "$extract_dir"
        return 1
    fi

    src_dir="$(dirname "$main_apk")"
    modscenter_supplement_native_libs "$label" "$main_apk" "$src_dir" || {
        rm -rf "$extract_dir"
        return 1
    }

    target_home="$OS3_IMAGES/product/priv-app/MiuiHome"
    target_ext="$OS3_IMAGES/product/priv-app/HyperLauncherExt"
    target_perm="$OS3_IMAGES/product/etc/permissions"

    modscenter_remove_named_dirs "$OS3_IMAGES" \
        "MiuiHomeT" "MiuiHome" "MiLauncherGlobal" "PocoHome" "PocoLauncher"
    rm -rf "$target_home" "$target_ext"
    mkdir -p "$target_home" "$target_ext" "$target_perm"
    cp -f "$main_apk" "$target_home/MiuiHome.apk" || return 1
    cp -f "$ext_apk" "$target_ext/HyperLauncherExt.apk" || return 1
    if [[ -d "$src_dir/lib" ]]; then
        cp -a "$src_dir/lib" "$target_home/" || return 1
    fi

    # Do not retain the OS3-era launcher overlay or whitelist on OS4.
    find "$OS3_IMAGES" -type f \
        \( -name "MiuiHomeLauncherResOverlay.apk" -o -name "privapp_whitelist_com.miui.home.xml" \) \
        -delete 2>/dev/null || true
    cp -f "$src_perm/privapp-permissions-com.miui.home-mod.xml" "$target_perm/" || return 1
    cp -f "$src_perm/privapp-permissions-com.miui.home.kashi.ext.xml" "$target_perm/" || return 1

    for required in \
        "$target_home/MiuiHome.apk" \
        "$target_ext/HyperLauncherExt.apk" \
        "$target_perm/privapp-permissions-com.miui.home-mod.xml" \
        "$target_perm/privapp-permissions-com.miui.home.kashi.ext.xml"; do
        [[ -s "$required" ]] || {
            error "$label: missing installed file: $required"
            return 1
        }
        chmod 0644 "$required" || return 1
    done
    find "$target_home" "$target_ext" -type d -exec chmod 0755 {} +
    if [[ -d "$target_home/lib" ]]; then
        find "$target_home/lib" -type f -name '*.so' -exec chmod 0644 {} +
    fi

    mods "$label: Rust MiuiHome + HyperLauncherExt + 2 privileged allowlists installed ($MODSCENTER_TAG)"
    mods "$label: no APK re-signing; HyperMOS CorePatch A17 is required at package stage"
    mods "$label: rootless icon packs still require an optional SELinux policy change"
    rm -rf "$extract_dir"
}

apply_kashi_rust_launcher || exit 1

mods "OS4 Kashi mods -> Done"
