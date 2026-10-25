#!/usr/bin/env bash
# Xiaomi.eu A16: narrow GMS FCM wake delivery; stock PowerKeeper and Greezer otherwise.
set -euo pipefail
w="$(pwd)"
source "$w/functions.sh"
base="$w/bin/package/NOTIFICATION_FIX/A16/EU"
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/rom_source.txt")" == xiaomi_eu ]] || { error "EU FCM patch requires Xiaomi.eu"; exit 1; }
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/androidver.txt")" == 16 ]] || { error "EU FCM patch requires Android 16"; exit 1; }
source "$w/bin/package/COREPATCH/helper.sh"
WORK_DIR="$w"
TOOLS_DIR="$w/bin/apktool"
API_LEVEL=36
jar="$w/build/baserom/images/system_ext/framework/miui-services.jar"
decoded="$w/miui-services_decompile"
output="$w/miui-services_patched.jar"
manifest="$base/ryu_policy.json"
[[ -s "$jar" && -s "$manifest" ]] || { error "EU FCM input missing"; exit 1; }
init_env
ensure_tools
tmp="$(mktemp -d "$w/eu-fcm.XXXXXX")"
trap 'rm -rf "$decoded" "$w/miui-services" "$output" "$tmp"' EXIT
decompile_jar "$jar" >/dev/null
python3 "$base/ryu_policy.py" --root "$decoded" --manifest "$manifest" \
  --group miui-services --report "$w/build/reports/eu-fcm/independent-methods.json"
python3 "$base/fcm_autostart.py" "$decoded" --report "$w/build/reports/eu-fcm/autostart.json"
python3 "$base/fcm_greeze.py" "$decoded" --report "$w/build/reports/eu-fcm/greeze.json"
recompile_jar "$jar" >/dev/null
[[ -s "$output" ]] && unzip -t "$output" >/dev/null || { error "EU FCM rebuilt JAR invalid"; exit 1; }
mkdir -p "$tmp/raw" "$tmp/decoded"
unzip -q "$output" 'classes*.dex' -d "$tmp/raw"
for dex in "$tmp/raw"/classes*.dex; do
  [[ -s "$dex" ]] || { error "EU FCM DEX missing"; exit 1; }
  stem="$(basename "$dex" .dex)"
  group=smali
  [[ "$stem" == classes ]] || group="smali_$(echo "$stem" | sed 's/^classes_//')"
  java -jar "$TOOLS_DIR/baksmaliv2.jar" d --api "$API_LEVEL" "$dex" -o "$tmp/decoded/$group" >/dev/null
done
python3 "$base/ryu_policy.py" --root "$tmp/decoded" --manifest "$manifest" \
  --group miui-services --verify --report "$w/build/reports/eu-fcm/independent-verified.json"
python3 "$base/fcm_autostart.py" "$tmp/decoded" --verify --report "$w/build/reports/eu-fcm/autostart-verified.json"
python3 "$base/fcm_greeze.py" "$tmp/decoded" --verify --report "$w/build/reports/eu-fcm/greeze-verified.json"
mv -f "$output" "$jar"
mods "[EU A16] only targeted FCM Autostart + Greeze; no broad policy keepalive"
mods "[EU A16] original Xiaomi.eu PowerKeeper.apk untouched and signature preserved"
