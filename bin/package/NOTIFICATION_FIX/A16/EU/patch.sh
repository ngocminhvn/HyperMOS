#!/usr/bin/env bash
# EU Android 16: patch original EU miui-services.jar using only small pinned deltas.
set -euo pipefail
w="$(pwd)"
source "$w/functions.sh"
base="$w/bin/package/NOTIFICATION_FIX/A16/EU"
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/rom_source.txt")" == xiaomi_eu ]] || { error "EU A16 source mismatch"; exit 1; }
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/androidver.txt")" == 16 ]] || { error "EU A16 requires Android 16"; exit 1; }
source "$w/bin/package/COREPATCH/helper.sh"
WORK_DIR="$w"
TOOLS_DIR="$w/bin/apktool"
API_LEVEL=36
jar="$w/build/baserom/images/system_ext/framework/miui-services.jar"
decoded="$w/miui-services_decompile"
output="$w/miui-services_patched.jar"
manifest="$base/policy_deltas.json"
[[ -s "$jar" && -s "$manifest" ]] || { error "EU A16 JAR or patch data missing"; exit 1; }
init_env
ensure_tools
tmp="$(mktemp -d "$w/eu-policy-jar.XXXXXX")"
trap 'rm -rf "$decoded" "$w/miui-services" "$output" "$tmp"' EXIT
decompile_jar "$jar" >/dev/null
python3 "$base/policy_delta.py" --root "$decoded" --manifest "$manifest" --policy global-jar --report "$w/build/reports/global-a16/miui-battery.json"
python3 "$base/policy_delta.py" --root "$decoded" --manifest "$manifest" --policy zk-jar --report "$w/build/reports/global-a16/zk-important-apps.json"
python3 "$base/fcm_greeze.py" "$decoded" --report "$w/build/reports/global-a16/fcm-greeze.json"
recompile_jar "$jar" >/dev/null
[[ -s "$output" ]] && unzip -t "$output" >/dev/null || { error "EU A16 rebuilt JAR invalid"; exit 1; }
mkdir -p "$tmp/raw" "$tmp/decoded"
unzip -q "$output" 'classes*.dex' -d "$tmp/raw"
for dex in "$tmp/raw"/classes*.dex; do
  [[ -s "$dex" ]] || { error "EU A16 rebuilt JAR DEX missing"; exit 1; }
  stem="$(basename "$dex" .dex)"
  group=smali
  [[ "$stem" == classes ]] || group="smali_$(echo "$stem" | sed 's/^classes_//')"
  java -jar "$TOOLS_DIR/baksmaliv2.jar" d --api "$API_LEVEL" "$dex" -o "$tmp/decoded/$group" >/dev/null
done
python3 "$base/policy_delta.py" --root "$tmp/decoded" --manifest "$manifest" --policy global-jar --verify
python3 "$base/policy_delta.py" --root "$tmp/decoded" --manifest "$manifest" --policy zk-jar --verify
mv -f "$output" "$jar"
mods "[EU A16] Global303 battery + scoped FCM + ZK304 important-app deltas (no donor DEX)"
bash "$base/PowerKeeper.sh"
