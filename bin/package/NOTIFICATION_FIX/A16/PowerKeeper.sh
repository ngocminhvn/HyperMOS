#!/usr/bin/env bash
# Port the original pinned ZKOS executable bytecode into stock Xiaomi
# PowerKeeper. All non-DEX APK content and META-INF are sourced from Xiaomi stock.
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
image_root="$work_dir/build/baserom/images"
base_dir="$work_dir/bin/package/NOTIFICATION_FIX/A16"
apkeditor=(java -jar "$work_dir/bin/apktool/apke.jar")
zk_dex="$base_dir/classes.dex"
tmp="$work_dir/apk_temp/notification-zk-local-dex"

[[ -s "$zk_dex" ]] || {
  error "PowerKeeper: original local ZKOS DEX is missing"; exit 1;
}
[[ "$(git -C "$work_dir" hash-object "$zk_dex")" == f229fb0a5c67d41a55310a119ef64b18a86d6c04 ]] || {
  error "PowerKeeper: ZKOS DEX differs from uploaded pinned source"; exit 1;
}

mapfile -d '' apks < <(find "$image_root" -type f -name PowerKeeper.apk -print0)
(( ${#apks[@]} == 1 )) || {
  error "PowerKeeper: exactly one Xiaomi stock PowerKeeper.apk required"; exit 1;
}
apk="${apks[0]}"
python3 "$base_dir/preserve_powerkeeper_identity.py" \
  --check-base --apk "$apk" --reference "$apk" \
  --apksigner "$work_dir/bin/apktool/apksigner.jar"

rm -rf "$tmp"
mkdir -p "$tmp/final"
trap 'rm -rf "$tmp"' EXIT

# Wrap each checked-in DEX with stock manifest/resources solely for decoding.
# Neither temporary wrapper is installed into the final ROM.
python3 "$base_dir/powerkeeper.py" prepare-donor \
  --stock-apk "$apk" --dex-file "$zk_dex" --output "$tmp/zk-source.apk"
"${apkeditor[@]}" d -t raw -f -no-dex-debug -i "$tmp/zk-source.apk" -o "$tmp/zk-raw" >/dev/null

# Adapt original ZK classes only where ZK branding/private identity must become TNM.
# Do not transplant RYU KillProcessController or PerfHook; preserve all ZK policy.
python3 "$base_dir/zk_full_powerkeeper_a16.py" --zk-raw "$tmp/zk-raw"

# APKEditor raw-build can silently preserve old DEX; explicit smali rebuild
# is required before copying compiled DEX into the verified stock APK.
"${apkeditor[@]}" b -t raw -f -i "$tmp/zk-raw" -o "$tmp/final/PowerKeeper.dex.apk" >/dev/null
python3 "$base_dir/rebuild_powerkeeper_dex.py" \
  --decoded "$tmp/zk-raw" --apk "$tmp/final/PowerKeeper.dex.apk" \
  --smali-jar "$work_dir/bin/apktool/smaliv2.jar" --api 36

# Preserve Xiaomi's exact manifest/resources/assets/JNI and original META-INF.
# The modified DEX has no authentic Xiaomi cryptographic signature; the
# existing ROM signature-policy path remains independent of this port.
python3 "$base_dir/preserve_powerkeeper_identity.py" \
  --base "$apk" --patched "$tmp/final/PowerKeeper.dex.apk" \
  --reference "$apk" --apksigner "$work_dir/bin/apktool/apksigner.jar" \
  --apk "$tmp/final/PowerKeeper.preserved.apk" --report "$tmp/certificate-identity.json"
command -v zipalign >/dev/null || { error "PowerKeeper: zipalign missing"; exit 1; }
zipalign -p -f 4 "$tmp/final/PowerKeeper.preserved.apk" "$tmp/final/PowerKeeper.aligned.apk"
zipalign -c -p 4 "$tmp/final/PowerKeeper.aligned.apk"
python3 "$base_dir/preserve_powerkeeper_identity.py" \
  --apk "$tmp/final/PowerKeeper.aligned.apk" --reference "$apk" \
  --report "$tmp/final-identity.json"

report_dir="$work_dir/build/reports/powerkeeper-a16"
mkdir -p "$report_dir"
cp "$tmp/certificate-identity.json" "$report_dir/certificate-identity.json"
cp "$tmp/final-identity.json" "$report_dir/final-identity.json"
sha256sum "$tmp/final/PowerKeeper.aligned.apk" | awk '{print $1}' > "$report_dir/patched-sha256.txt"
cp -f "$tmp/final/PowerKeeper.aligned.apk" "$apk"
rm -rf "$(dirname "$apk")/oat"
mods "PowerKeeper: original ZKOS executable DEX with TNM identity; stock Xiaomi manifest/resources/META-INF"
patch "PowerKeeper: no ZKOS donor APK/artifact download required"
