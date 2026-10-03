#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/bin/modfile/OS3/_common.sh"

rom_os=$(cat "$work_dir/bin/ddevice/rom_os.txt" 2>/dev/null)
[[ "$rom_os" == "OS3" ]] || exit 0

mods "Kashi mods: App Vault + Control Center + Launcher"

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

modscenter_apply_native_module \
    "ColorOS Control Center" \
    "Mods-Center/ColorOS_Control_Center" \
    "miui.systemui.plugin" \
    "*MIUISystemUIPlugin*.apk" \
    "-" \
    "MIUISystemUIPlugin" || exit 1

apply_kashi_launcher() {
    local label="HyperOS Launcher"
    local repo="Mods-Center/HyperOS-Launcher"
    local extract_dir="$OS3_MOD_CACHE/extract-HyperOS-Launcher"
    local main_apk ext_apk overlay_apk home_perm ext_perm source_app_dir
    local target_home target_ext target_perm target_overlay required abi

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

    mods "$label: installing fixed local Kashi/Mods Center snapshot on stable #24 base"

    modscenter_unpack_latest "$label" "$repo" "$extract_dir" || return 1

    main_apk=$(modscenter_find_apk "$extract_dir" "com.miui.home" "MiuiHome*.apk") || {
        error "$label: com.miui.home APK not found uniquely"
        rm -rf "$extract_dir"
        return 1
    }
    ext_apk=$(modscenter_find_apk "$extract_dir" "eu.xiaomi.ext" "XiaomiEUExt*.apk") || {
        error "$label: eu.xiaomi.ext APK not found uniquely"
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
    ext_perm=$(find_unique_file "$extract_dir" "privapp_whitelist_eu.xiaomi.ext.xml") || {
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
        "PocoLauncher" \
        "XiaomiEUExt"

    target_home="$OS3_IMAGES/product/priv-app/MiuiHome"
    target_ext="$OS3_IMAGES/product/priv-app/XiaomiEUExt"
    target_perm="$OS3_IMAGES/product/etc/permissions"
    target_overlay="$OS3_IMAGES/product/overlay"

    rm -rf "$target_home" "$target_ext"
    mkdir -p "$target_home" "$target_ext" "$target_perm" "$target_overlay"

    cp -f "$main_apk" "$target_home/MiuiHome.apk" || return 1
    if [[ -d "$source_app_dir/lib" ]]; then
        cp -a "$source_app_dir/lib" "$target_home/" || return 1
    fi
    cp -f "$ext_apk" "$target_ext/XiaomiEUExt.apk" || return 1

    find "$OS3_IMAGES" -type f -name "MiuiHomeLauncherResOverlay.apk" -delete 2>/dev/null || true
    find "$OS3_IMAGES" -type f \( \
        -name "privapp_whitelist_com.miui.home.xml" -o \
        -name "privapp_whitelist_eu.xiaomi.ext.xml" \
    \) -delete 2>/dev/null || true

    cp -f "$overlay_apk" "$target_overlay/MiuiHomeLauncherResOverlay.apk" || return 1
    cp -f "$home_perm" "$target_perm/privapp_whitelist_com.miui.home.xml" || return 1
    cp -f "$ext_perm" "$target_perm/privapp_whitelist_eu.xiaomi.ext.xml" || return 1

    for required in \
        "$target_home/MiuiHome.apk" \
        "$target_ext/XiaomiEUExt.apk" \
        "$target_overlay/MiuiHomeLauncherResOverlay.apk" \
        "$target_perm/privapp_whitelist_com.miui.home.xml" \
        "$target_perm/privapp_whitelist_eu.xiaomi.ext.xml"; do
        [[ -s "$required" ]] || {
            error "$label: required payload missing after copy: $required"
            rm -rf "$extract_dir"
            return 1
        }
        chmod 0644 "$required" 2>/dev/null || true
    done

    for abi in arm arm64; do
        if ! find "$target_home/lib/$abi" -maxdepth 1 -type f -name '*.so' -print -quit 2>/dev/null | grep -q .; then
            error "$label: no native libraries installed for $abi"
            rm -rf "$extract_dir"
            return 1
        fi
        find "$target_home/lib/$abi" -maxdepth 1 -type f -name '*.so' -exec chmod 0644 {} + 2>/dev/null || true
    done

    mods "$label: MiuiHome + ARM/ARM64 libs + XiaomiEUExt + icon overlay + whitelists -> Done ($MODSCENTER_TAG)"
    rm -rf "$extract_dir"
}

apply_kashi_launcher || exit 1

mods "Kashi mods -> Done"
