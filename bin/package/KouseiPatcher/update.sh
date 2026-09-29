#!/usr/bin/env bash
set -e

work_dir=$(pwd)
source "$work_dir/functions.sh"

patcher_dir="$work_dir/bin/package/KouseiPatcher"
install_toolbox=$(grep -m1 '^install_toolbox=' "$work_dir/config.env" | cut -d '=' -f 2 | tr -d ' \r')

if [[ "$install_toolbox" != "true" ]]; then
    mods "Skip Kaorios Toolbox: install_toolbox is disabled"
    exit 0
fi

# Kaorios Toolbox v2.0.6.0 / release 108.
# Files are expected directly in:
# bin/package/KouseiPatcher/
#   KaoriosToolbox.apk
#   classes.dex
#   lib/arm64-v8a/libkaorios_toolbox.so

export KAORIOS_RELEASE_DIR="$patcher_dir"

mods "Patch framework/services for Kaorios release 108"
bash "$patcher_dir/patcher.sh"

privapp_dir="$work_dir/build/baserom/images/system/system/priv-app/KaoriosToolbox"
perm_dir="$work_dir/build/baserom/images/system/system/etc/permissions"
mkdir -p "$privapp_dir/lib/arm64-v8a" "$perm_dir"

cp -f "$patcher_dir/KaoriosToolbox.apk" "$privapp_dir/KaoriosToolbox.apk"
cp -f "$patcher_dir/lib/arm64-v8a/libkaorios_toolbox.so" "$privapp_dir/lib/arm64-v8a/libkaorios_toolbox.so"
cp -f "$patcher_dir/app/com.kousei.kaorios.xml" "$perm_dir/com.kousei.kaorios.xml"

mods "Kaorios Toolbox release 108 integrated"
