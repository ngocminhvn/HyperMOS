#!/bin/bash
# SPDX-License-Identifier: GPL-3.0

work_dir=$(pwd)
source "$work_dir/functions.sh"
prop="$work_dir/bin/package/KouseiPatcher/prop"
appdir="$work_dir/bin/package/KouseiPatcher/app"
kaoriospatch=$(grep "install_toolbox" "$work_dir/config.env" | cut -d '=' -f 2)

if [[ "$kaoriospatch" == "true" ]]; then
    bash "$work_dir/bin/package/KouseiPatcher/fakelock_patch.sh" || {
        error "Kaorios: fake-lock patch failed"
        exit 1
    }

    bash "$work_dir/bin/package/KouseiPatcher/patcher.sh" || {
        error "Kaorios: framework/services patch failed"
        exit 1
    }

    mkdir -p         "$work_dir/build/baserom/images/system/system/priv-app"         "$work_dir/build/baserom/images/system/system/etc/permissions"

    cp -rf "$appdir/KaoriosToolbox" "$work_dir/build/baserom/images/system/system/priv-app" || exit 1
    cp -rf "$appdir/com.kousei.kaorios.xml" "$work_dir/build/baserom/images/system/system/etc/permissions" || exit 1

    # Keep PenguinOS behavior: build.prop is appended here as well as in fakelock_patch.sh.
    cat "$prop/build.prop" >> "$work_dir/build/baserom/images/system/system/build.prop" || exit 1

    [[ -s "$work_dir/build/baserom/images/system/system/priv-app/KaoriosToolbox/KaoriosToolbox.apk" ]] || {
        error "Kaorios: KaoriosToolbox.apk missing after integration"
        exit 1
    }
    [[ -s "$work_dir/build/baserom/images/system/system/priv-app/KaoriosToolbox/lib/arm64-v8a/libkaorios_toolbox.so" ]] || {
        error "Kaorios: native library missing after integration"
        exit 1
    }
    [[ -s "$work_dir/build/baserom/images/system/system/etc/permissions/com.kousei.kaorios.xml" ]] || {
        error "Kaorios: permission XML missing after integration"
        exit 1
    }

    mods "Kaorios Toolbox integrated"
fi
