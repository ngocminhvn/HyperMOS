#!/usr/bin/env bash
# Use the complete ZKOS PowerKeeper payload while grafting only TNM's existing
# per-app percentage PerfHook. The local RYU DEX is a source for that hook only.
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
image_root="$work_dir/build/baserom/images"
apkeditor=(java -jar "$work_dir/bin/apktool/apke.jar")
expected_zk="559665acc17f0e6c900cbaf644331ea431d1c59519a0c44a944b6cb16d7c003f"
expected_tnm_blob="1b5a46ea3f9ead44a5467584e15dddd7ba4b0555"
donor="${ZK_POWERKEEPER_APK:-}"
tmp="$work_dir/apk_temp/notification-zk-full-port"

[[ -n "$donor" && -s "$donor" ]] || { error "TNM ZK port: audited donor required"; exit 1; }
echo "$expected_zk  $donor" | sha256sum -c - >/dev/null || {
  error "TNM ZK port: donor SHA-256 mismatch"; exit 1;
}
mapfile -d '' apks < <(find "$image_root" -type f -name PowerKeeper.apk -print0)
(( ${#apks[@]} == 1 )) || { error "TNM ZK port: expected one Xiaomi stock PowerKeeper"; exit 1; }
apk="${apks[0]}"
[[ "$(git -C "$work_dir" hash-object "$work_dir/bin/package/NOTIFICATION_FIX/A16/classes.dex")" == "$expected_tnm_blob" ]] || {
  error "TNM ZK port: pinned TNM PerfHook source DEX changed"; exit 1;
}
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/preserve_powerkeeper_identity.py" \
  --check-base --apk "$apk" --reference "$apk" \
  --apksigner "$work_dir/bin/apktool/apksigner.jar"

rm -rf "$tmp"
mkdir -p "$tmp/final"
trap 'rm -rf "$tmp"' EXIT
"${apkeditor[@]}" d -t raw -f -no-dex-debug -i "$donor" -o "$tmp/zk-raw" >/dev/null
"${apkeditor[@]}" d -t xml -dex -f -i "$donor" -o "$tmp/zk-xml" >/dev/null

# Decode the checked-in TNM DEX against stock manifest/resources; only the
# per-app percentage PerfHook classes are grafted into the ZK codebase.
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/powerkeeper.py" prepare-donor \
  --stock-apk "$apk" \
  --dex-file "$work_dir/bin/package/NOTIFICATION_FIX/A16/classes.dex" \
  --output "$tmp/tnm-perf-source.apk"
"${apkeditor[@]}" d -t raw -f -no-dex-debug \
  -i "$tmp/tnm-perf-source.apk" -o "$tmp/tnm-raw" >/dev/null
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/zk_full_powerkeeper_a16.py" \
  --zk-raw "$tmp/zk-raw" --zk-xml "$tmp/zk-xml" --tnm-raw "$tmp/tnm-raw"

# Explicitly assemble all ZK classes plus the TNM per-app PerfHook before
# injecting that DEX into the full ZK manifest/resources/assets tree.
"${apkeditor[@]}" b -t raw -f -i "$tmp/zk-raw" -o "$tmp/final/PowerKeeper.dex.apk" >/dev/null
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/rebuild_powerkeeper_dex.py" \
  --decoded "$tmp/zk-raw" --apk "$tmp/final/PowerKeeper.dex.apk" \
  --smali-jar "$work_dir/bin/apktool/smaliv2.jar" --api 36
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/zk_full_powerkeeper_a16.py" \
  --zk-raw "$tmp/zk-raw" --zk-xml "$tmp/zk-xml" --tnm-raw "$tmp/tnm-raw" \
  --compiled-apk "$tmp/final/PowerKeeper.dex.apk"
"${apkeditor[@]}" b -t xml -f -i "$tmp/zk-xml" -o "$tmp/final/PowerKeeper.apk" >/dev/null
unzip -tq "$tmp/final/PowerKeeper.apk" >/dev/null

command -v zipalign >/dev/null || { error "TNM ZK port: zipalign missing"; exit 1; }
identity="$work_dir/bin/package/NOTIFICATION_FIX/A16/preserve_powerkeeper_identity.py"
python3 "$identity" --base "$apk" --patched "$tmp/final/PowerKeeper.apk" \
  --reference "$apk" --apksigner "$work_dir/bin/apktool/apksigner.jar" \
  --apk "$tmp/final/PowerKeeper.preserved.apk" --report "$tmp/certificate-identity.json"
zipalign -p -f 4 "$tmp/final/PowerKeeper.preserved.apk" "$tmp/final/PowerKeeper.aligned.apk"
zipalign -c -p 4 "$tmp/final/PowerKeeper.aligned.apk"
python3 "$identity" --apk "$tmp/final/PowerKeeper.aligned.apk" \
  --reference "$apk" --report "$tmp/final-identity.json"

report_dir="$work_dir/build/reports/powerkeeper-a16"
mkdir -p "$report_dir"
cp "$tmp/certificate-identity.json" "$report_dir/certificate-identity.json"
cp "$tmp/final-identity.json" "$report_dir/final-identity.json"
sha256sum "$tmp/final/PowerKeeper.aligned.apk" | awk '{print $1}' > "$report_dir/patched-sha256.txt"
cp -f "$tmp/final/PowerKeeper.aligned.apk" "$apk"
rm -rf "$(dirname "$apk")/oat"

mods "PowerKeeper: complete ZKOS code/resources/manifest + TNM per-app percentage control"
patch "PowerKeeper: ZK policy port adapted to TNM; RYU donor contributes only app PerfHook"
