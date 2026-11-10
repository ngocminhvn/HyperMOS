#!/usr/bin/env bash
# Android 17 / OS4 PowerKeeper patcher:
# Preserves legacy region-gate behavior and disables OS4's replacement GMS limiter.
# Rebuilds APK while preserving original Xiaomi certificate identity, resources, and v1 metadata.
# Does NOT sign with testkey; invalidates v2/v3 signing block for ROM CorePatch v1 bypass.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
image_root="$work_dir/build/baserom/images"
base_dir="$work_dir/bin/package/NOTIFICATION_FIX/A17"
report_dir="$work_dir/build/reports/powerkeeper-a17"
tmp="$work_dir/apk_temp/powerkeeper-a17"
tools_dir="$work_dir/bin/apktool"

mapfile -d '' apks < <(find "$image_root" -type f -name PowerKeeper.apk -print0)
(( ${#apks[@]} == 1 )) || { error "PowerKeeper: exactly one stock Xiaomi APK required"; exit 1; }
apk="${apks[0]}"
[[ -s "$apk" ]] || { error "PowerKeeper: empty base APK"; exit 1; }

# Find tools
apksigner="$tools_dir/apksigner.jar"
[[ -s "$apksigner" ]] || apksigner="$(find "$work_dir/bin" -name "apksigner.jar" | head -n1)"
[[ -s "$apksigner" ]] || { error "PowerKeeper: apksigner.jar not found"; exit 1; }

# A16/A17 share the canonical, compatibility-tested Smali toolchain.
baksmali="$tools_dir/baksmaliv2.jar"
[[ -s "$baksmali" ]] || { error "PowerKeeper: baksmaliv2.jar not found"; exit 1; }

smali="$tools_dir/smaliv2.jar"
[[ -s "$smali" ]] || { error "PowerKeeper: smaliv2.jar not found"; exit 1; }

rm -rf "$tmp"
mkdir -p "$tmp/smali" "$report_dir"
trap 'rm -rf "$tmp"' EXIT

base_hash="$(sha256sum "$apk" | cut -d ' ' -f1)"

# 1. Verify Xiaomi base signature
python3 "$base_dir/preserve_powerkeeper_identity.py" \
  --check-base --apk "$apk" --reference "$apk" \
  --allow-stripped-base \
  --apksigner "$apksigner" \
  --report "$report_dir/stock-identity.json"

# 2. Extract and disassemble classes.dex
unzip -p "$apk" classes.dex > "$tmp/classes.dex"
java -jar "$baksmali" d --api 34 "$tmp/classes.dex" -o "$tmp/smali"

# 3. Patch Smali (Doze, SleepMode, CustomerPower, CloudUpdate, etc.)
python3 "$base_dir/powerkeeper_patcher_a17.py" "$tmp/smali" \
  --report "$report_dir/powerkeeper-patch-report.json"

# 4. Reassemble patched classes.dex
java -jar "$smali" a --api 34 "$tmp/smali" -o "$tmp/classes_patched.dex"
[[ -s "$tmp/classes_patched.dex" ]] || { error "PowerKeeper: failed to assemble patched classes.dex"; exit 1; }

# 5. Build donor wrapper and transplant classes.dex with preserved identity
python3 "$base_dir/powerkeeper.py" prepare-donor \
  --stock-apk "$apk" --dex-file "$tmp/classes_patched.dex" --output "$tmp/wrapper.apk"

python3 "$base_dir/preserve_powerkeeper_identity.py" \
  --base "$apk" --patched "$tmp/wrapper.apk" \
  --reference "$apk" --apksigner "$apksigner" \
  --allow-stripped-base \
  --apk "$tmp/PowerKeeper.preserved.apk" \
  --report "$report_dir/preserved-metadata.json"

# 6. Zipalign if available
if command -v zipalign >/dev/null 2>&1; then
  zipalign -p -f 4 "$tmp/PowerKeeper.preserved.apk" "$tmp/PowerKeeper.aligned.apk"
  zipalign -c -p 4 "$tmp/PowerKeeper.aligned.apk"
  final_apk="$tmp/PowerKeeper.aligned.apk"
else
  final_apk="$tmp/PowerKeeper.preserved.apk"
fi

# 7. Final verification of preserved identity
python3 "$base_dir/preserve_powerkeeper_identity.py" \
  --apk "$final_apk" --reference "$apk" \
  --report "$report_dir/final-metadata.json"

cp -f "$final_apk" "$apk"
rm -rf "$(dirname "$apk")/oat"

mods "PowerKeeper: disabled the OS4 GMS notification limiter; preserved Xiaomi certificate & v1 metadata"
patch "PowerKeeper: Android 17 / OS4 PowerKeeper successfully patched"
