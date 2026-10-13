#!/usr/bin/env bash
# Build PowerKeeper from a local DEX and genuine Xiaomi stock package.
# No APK donor download, no extraction artifact, no background runtime hook.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
base_dir="$work_dir/bin/package/NOTIFICATION_FIX/A16"
image_root="$work_dir/build/baserom/images"
APKEDITOR="java -jar $work_dir/bin/apktool/apke.jar"

mapfile -d '' apks < <(find "$image_root" -type f -name PowerKeeper.apk -print0)
(( ${#apks[@]} == 1 )) || { error "PowerKeeper: exactly one Xiaomi stock APK required"; exit 1; }
apk="${apks[0]}"
dex="$base_dir/classes.dex"
[[ -s "$dex" ]] || { error "PowerKeeper: local classes.dex missing"; exit 1; }
[[ "$(git -C "$work_dir" hash-object "$dex")" == "1b5a46ea3f9ead44a5467584e15dddd7ba4b0555" ]] || {
  error "PowerKeeper: local DEX differs from pinned checked-in source"; exit 1;
}

tmp="$work_dir/apk_temp/notification-local-dex"
rm -rf "$tmp"
mkdir -p "$tmp"
trap 'rm -rf "$tmp"' EXIT
identity="$base_dir/preserve_powerkeeper_identity.py"

# Keep Xiaomi stock's certificate provenance, manifest and all other payload.
python3 "$identity" --check-base --apk "$apk" --reference "$apk" \
  --apksigner "$work_dir/bin/apktool/apksigner.jar"
$APKEDITOR d -t raw -f -no-dex-debug -i "$apk" -o "$tmp/out" >/dev/null
python3 "$base_dir/powerkeeper.py" prepare-donor \
  --stock-apk "$apk" --dex-file "$dex" --output "$tmp/local-donor.apk"
$APKEDITOR d -t raw -f -no-dex-debug -i "$tmp/local-donor.apk" -o "$tmp/source" >/dev/null

python3 "$base_dir/powerkeeper.py" port \
  --stock-root "$tmp/out" --donor-root "$tmp/source" \
  --stock-apk "$apk" --donor-apk "$tmp/local-donor.apk" \
  --report "$tmp/port-report.json"

mkdir -p "$tmp/final"
$APKEDITOR b -f -i "$tmp/out" -o "$tmp/final/PowerKeeper.apk" >/dev/null
python3 "$base_dir/rebuild_powerkeeper_dex.py" \
  --decoded "$tmp/out" --apk "$tmp/final/PowerKeeper.apk" \
  --smali-jar "$work_dir/bin/apktool/smaliv2.jar" --api 36
# Copy only the verified Xiaomi v1 metadata from the signed stock APK.
# This does not create a valid signature; the ROM verifier dependency remains.
python3 "$identity" --base "$apk" --patched "$tmp/final/PowerKeeper.apk" \
  --reference "$apk" --apksigner "$work_dir/bin/apktool/apksigner.jar" \
  --apk "$tmp/final/PowerKeeper.preserved.apk" \
  --report "$tmp/certificate-identity.json"
zipalign -p -f 4 "$tmp/final/PowerKeeper.preserved.apk" "$tmp/final/PowerKeeper.aligned.apk"
zipalign -c -p 4 "$tmp/final/PowerKeeper.aligned.apk"
python3 "$identity" --apk "$tmp/final/PowerKeeper.aligned.apk" \
  --reference "$apk" --report "$tmp/final-identity.json"
report_dir="$work_dir/build/reports/powerkeeper-a16"
mkdir -p "$report_dir"
cp "$tmp/port-report.json" "$report_dir/powerkeeper-port.json"
cp "$tmp/certificate-identity.json" "$report_dir/certificate-identity.json"
cp "$tmp/final-identity.json" "$report_dir/final-identity.json"
cp "$tmp/final/PowerKeeper.aligned.apk" "$apk"
rm -rf "$(dirname "$apk")/oat"
mods "PowerKeeper: local complete DEX + TNMFramework; stock resources preserved"
patch "PowerKeeper local DEX compiled and staged (runtime test pending)"
