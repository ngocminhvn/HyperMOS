#!/usr/bin/env bash
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"

KAORIOS_TAG="v2.0.6.0"
KAORIOS_ZIP="KaoriosToolbox-release-108.zip"
KAORIOS_URL="https://github.com/hzzmonetvn/Kaorios-Toolbox/releases/download/$KAORIOS_TAG/$KAORIOS_ZIP"
KAORIOS_SHA256="33d6fa838892a85bceb3571f13fba361523635d23d5f65e5b0abaa8d1a2c3f32"

download_kaorios() {
    local cache_dir="$work_dir/build/kaorios"
    mkdir -p "$cache_dir"
    local zip_path="$cache_dir/$KAORIOS_ZIP"
    if [[ ! -f "$zip_path" ]]; then
        info "Downloading Kaorios Toolbox $KAORIOS_TAG..."
        aria2c -q -x 8 -s 8 -d "$cache_dir" -o "$KAORIOS_ZIP" "$KAORIOS_URL"
    fi
    echo "$KAORIOS_SHA256  $zip_path" | sha256sum -c - >/dev/null
    echo "$zip_path"
}

android_ver="$(cat "$work_dir/bin/ddevice/androidver.txt")"
[[ "$android_ver" == "17" ]] || { error "Kaorios A17 requires Android 17, got $android_ver"; exit 1; }

zip_path="$(download_kaorios)"
stage="$work_dir/build/kaorios/a17"
rm -rf "$stage"
mkdir -p "$stage"
unzip -q "$zip_path" -d "$stage"

apk="$(find "$stage" -type f -name 'KaoriosToolbox-release.apk' -print -quit)"
[[ -n "$apk" ]] || { error "Kaorios Toolbox APK not found in release asset."; exit 1; }

target="$work_dir/build/baserom/images/product/priv-app/KaoriosToolbox"
mkdir -p "$target"
cp -f "$apk" "$target/KaoriosToolbox.apk"

mods "Kaorios Toolbox v2.0.6.0 app added for Android 17."
info "A17 framework patch path is kept separate; no unsupported automatic framework mutation is applied."
