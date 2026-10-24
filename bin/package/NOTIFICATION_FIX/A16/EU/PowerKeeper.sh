#!/usr/bin/env bash
# EU Android 16 PowerKeeper: original EU DEX plus small pinned policy deltas.
set -euo pipefail
w="$(pwd)"
source "$w/functions.sh"
base="$w/bin/package/NOTIFICATION_FIX/A16/EU"
meta="$base/eu_powerkeeper_keep_metadata.py"
images="$w/build/baserom/images"
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/rom_source.txt")" == xiaomi_eu ]] || { error "EU A16 PowerKeeper source mismatch"; exit 1; }
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/androidver.txt")" == 16 ]] || { error "EU A16 PowerKeeper requires Android 16"; exit 1; }
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/sdkLevel.txt")" == 36 ]] || { error "EU A16 PowerKeeper requires SDK 36"; exit 1; }
for t in python3 unzip zipalign aapt java; do command -v "$t" >/dev/null || { error "EU A16 missing $t"; exit 1; }; done
manifest="$base/policy_deltas.json"
[[ -s "$manifest" ]] || { error "EU A16 PowerKeeper patch data missing"; exit 1; }
count="$(find "$images" -type f -name PowerKeeper.apk | wc -l)"
[[ "$count" == 1 ]] || { error "EU A16 requires exactly one PowerKeeper APK"; exit 1; }
apk="$(find "$images" -type f -name PowerKeeper.apk -print -quit)"
badging="$(aapt dump badging "$apk")"
grep -Fq "package: name='com.miui.powerkeeper' versionCode='40200'" <<< "$badging" || { error "EU A16 PowerKeeper version mismatch"; exit 1; }
grep -Fq "sdkVersion:'36'" <<< "$badging" || { error "EU A16 PowerKeeper minSdk mismatch"; exit 1; }
baksmali="$w/bin/apktool/baksmaliv2.jar"
smali="$w/bin/apktool/smaliv2.jar"
[[ -s "$baksmali" && -s "$smali" ]] || { error "EU A16 DEX assembler missing"; exit 1; }
report="$w/build/reports/global-a16"
mkdir -p "$report"
tmp="$(mktemp -d "$w/eu-policy-apk.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT
unzip -p "$apk" classes.dex > "$tmp/original.dex"
[[ -s "$tmp/original.dex" ]] || { error "EU A16 PowerKeeper DEX missing"; exit 1; }
java -jar "$baksmali" d --api 36 "$tmp/original.dex" -o "$tmp/decoded/smali" >/dev/null
python3 "$base/policy_delta.py" --root "$tmp/decoded" --manifest "$manifest" --policy global-power --report "$report/ported-methods.json"
python3 "$base/policy_delta.py" --root "$tmp/decoded" --manifest "$manifest" --policy zk-power --report "$report/zk-gms-millet.json"
java -jar "$smali" a --api 36 "$tmp/decoded/smali" -o "$tmp/patched.dex" >/dev/null
java -jar "$baksmali" d --api 36 "$tmp/patched.dex" -o "$tmp/verified/smali" >/dev/null
python3 "$base/policy_delta.py" --root "$tmp/verified" --manifest "$manifest" --policy global-power --verify
python3 "$base/policy_delta.py" --root "$tmp/verified" --manifest "$manifest" --policy zk-power --verify
python3 "$meta" --base "$apk" --dex "$tmp/patched.dex" --output "$tmp/preserved.apk" --report "$report/preserve-metadata.json"
zipalign -p -f 4 "$tmp/preserved.apk" "$tmp/aligned.apk"
zipalign -c -p 4 "$tmp/aligned.apk"
python3 "$meta" --base "$apk" --dex "$tmp/patched.dex" --output "$tmp/aligned.apk" --verify-only
cp -f "$tmp/aligned.apk" "$apk"
rm -rf "$(dirname "$apk")/oat"
mods "[EU A16] PowerKeeper 7 Global303 + ZK304 selective edits, original EU APK metadata retained, not re-signed"
