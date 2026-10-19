#!/usr/bin/env bash
# Native MiCTS CSHelper DEX port. Android 16 HyperOS 3 only.
# No APK changes, no RRO, no LSPosed hooks, no background daemon.
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
source "$work_dir/bin/package/COREPATCH/helper.sh"

android_ver="$(tr -d ' \r\n' < "$work_dir/bin/ddevice/androidver.txt")"
rom_os="$(tr -d ' \r\n' < "$work_dir/bin/ddevice/rom_os.txt")"
if [[ "$android_ver" != "16" || "$rom_os" != "OS3" ]]; then
  info "MiCTS: Android $android_ver / $rom_os skipped (OS3/A16 only)"
  exit 0
fi

WORK_DIR="$work_dir"
TOOLS_DIR="$work_dir/bin/apktool"
API_LEVEL=36
images="$work_dir/build/baserom/images"
report="$work_dir/build/reports/micts-native.txt"
patch="$work_dir/bin/package/MiCTS/patch_micts.py"
decoded="$work_dir/services_decompile"
output="$work_dir/services_patched.jar"

# CorePatch runs first and may already have changed this JAR. Patch only the
# final staged services.jar and replace it only after a verified rebuild.
if [[ -s "$images/system/system/framework/services.jar" ]]; then
  jar="$images/system/system/framework/services.jar"
elif [[ -s "$images/system/framework/services.jar" ]]; then
  jar="$images/system/framework/services.jar"
else
  error "MiCTS: services.jar not found in A16 staged system image"
  exit 1
fi

init_env
ensure_tools
[[ -s "$patch" ]] || { error "MiCTS: Python patcher missing"; exit 1; }
trap 'rm -rf "$decoded" "$output"' EXIT

decompile_jar "$jar" >/dev/null
python3 "$patch" "$decoded" --report "$report"
recompile_jar "$jar" >/dev/null

if [[ ! -s "$output" ]] || ! unzip -t "$output" >/dev/null 2>&1; then
  error "MiCTS: rebuilt services.jar is missing or invalid"
  exit 1
fi
if ! unzip -Z -1 "$output" | grep -Eq '^classes[0-9]*\.dex$'; then
  error "MiCTS: rebuilt services.jar contains no DEX"
  exit 1
fi
mv -f "$output" "$jar"
# Remove the old package's own overlay; no framework-res or APK is modified.
rm -f "$images/product/overlay/HyperMOSMiCTSOverlay.apk"
rm -f "$images/product/overlay/HyperMOSContextualSearchOverlay.apk"
mods "MiCTS: services.jar CSHelper DEX patched, no APK changes, no background runtime"
