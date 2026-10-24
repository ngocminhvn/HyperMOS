#!/usr/bin/env bash
# RYU EU A16 PowerKeeper: no non-PerfHook GMS/Millet behavior delta exists.
# Verify exact methods from RYU reference and preserve entire stock Xiaomi.eu APK.
# Deliberately do not import RYU PerfHook, altered thermal paths or FPS hooks.
set -euo pipefail
w="$(pwd)"
source "$w/functions.sh"
base="$w/bin/package/NOTIFICATION_FIX/A16/EU"
images="$w/build/baserom/images"
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/rom_source.txt")" == xiaomi_eu ]] || { error "RYU PowerKeeper requires EU"; exit 1; }
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/androidver.txt")" == 16 ]] || { error "RYU PowerKeeper requires A16"; exit 1; }
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/sdkLevel.txt")" == 36 ]] || { error "RYU PowerKeeper requires SDK 36"; exit 1; }
for t in python3 unzip aapt java; do command -v "$t" >/dev/null || { error "Missing $t"; exit 1; }; done
[[ -s "$base/ryu_policy.json" ]] || { error "RYU JSON policy missing"; exit 1; }
count="$(find "$images" -type f -name PowerKeeper.apk | wc -l)"
[[ "$count" == 1 ]] || { error "Expected exactly one PowerKeeper APK"; exit 1; }
apk="$(find "$images" -type f -name PowerKeeper.apk -print -quit)"
badging="$(aapt dump badging "$apk")"
grep -Fq "package: name='com.miui.powerkeeper' versionCode='40200'" <<< "$badging" || { error "PowerKeeper version does not match EU309"; exit 1; }
grep -Fq "sdkVersion:'36'" <<< "$badging" || { error "PowerKeeper SDK mismatch"; exit 1; }
[[ -s "$w/bin/apktool/baksmaliv2.jar" ]] || { error "baksmali missing"; exit 1; }
tmp="$(mktemp -d "$w/eu-ryu-stock-pk.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT
unzip -t "$apk" >/dev/null || { error "Stock EU PowerKeeper ZIP invalid"; exit 1; }
unzip -p "$apk" classes.dex > "$tmp/classes.dex"
[[ -s "$tmp/classes.dex" ]] || { error "Stock EU PowerKeeper DEX missing"; exit 1; }
java -jar "$w/bin/apktool/baksmaliv2.jar" d --api 36 "$tmp/classes.dex" -o "$tmp/smali/smali" >/dev/null
python3 "$base/ryu_policy.py" --root "$tmp/smali" --manifest "$base/ryu_policy.json" \
  --group powerkeeper --verify --report "$w/build/reports/ryu-a16/powerkeeper-stock.json"
# No PowerKeeper APK bytes are written: all ZIP entries, META-INF and signing
# blocks stay precisely as shipped in Xiaomi.eu, unlike DEX-repack-with-META-INF.
mods "[EU A16] RYU-equivalent PowerKeeper GMS/Millet retained from stock EU; no APK rewrite, no signing"
