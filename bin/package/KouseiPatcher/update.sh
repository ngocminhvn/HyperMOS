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

# Kaorios Toolbox v2.0.6.0, release-108.
# Upstream marks this release as not officially supported by Kaorios Patcher,
# so HyperMOS uses the release's own prebuilt classes.dex instead of old smali.
release_url="https://github.com/hzzmonetvn/Kaorios-Toolbox/releases/download/v2.0.6.0/KaoriosToolbox-release-108.zip"
release_sha256="33d6fa838892a85bceb3571f13fba361523635d23d5f65e5b0abaa8d1a2c3f32"

temp_dir="$work_dir/.kaorios-release108"
archive="$temp_dir/KaoriosToolbox-release-108.zip"
rm -rf "$temp_dir"
mkdir -p "$temp_dir"

mods "Download Kaorios Toolbox release 108"
curl -fL --retry 3 --retry-delay 2 -o "$archive" "$release_url"
echo "$release_sha256  $archive" | sha256sum -c -

unzip -q "$archive" -d "$temp_dir"

echo "6286e734e60df4cfc090aa9c7b6e73a8604fdfc94e2896b5b92062ff04c5036b  $temp_dir/KaoriosToolbox-release.apk" | sha256sum -c -
echo "477b4edf72e09b2e9e438c5d2e14f8e1f69e8f3622cd54f1344f51c5f298e312  $temp_dir/classes.dex" | sha256sum -c -
echo "9e8e0de334b4c940ee669c811cdcd0ac3d364a65287cf1bd1ef1f8fca94a476b  $temp_dir/lib/arm64-v8a/libkaorios_toolbox.so" | sha256sum -c -

export KAORIOS_RELEASE_DIR="$temp_dir"

mods "Patch framework/services for Kaorios release 108"
bash "$patcher_dir/patcher.sh"

privapp_dir="$work_dir/build/baserom/images/system/system/priv-app/KaoriosToolbox"
perm_dir="$work_dir/build/baserom/images/system/system/etc/permissions"
mkdir -p "$privapp_dir/lib/arm64-v8a" "$perm_dir"

cp -f "$temp_dir/KaoriosToolbox-release.apk" "$privapp_dir/KaoriosToolbox.apk"
cp -f "$temp_dir/lib/arm64-v8a/libkaorios_toolbox.so" "$privapp_dir/lib/arm64-v8a/libkaorios_toolbox.so"
cp -f "$patcher_dir/app/com.kousei.kaorios.xml" "$perm_dir/com.kousei.kaorios.xml"

mods "Kaorios Toolbox release 108 integrated (experimental upstream compatibility)"
rm -rf "$temp_dir"
