#!/usr/bin/env bash
# EU Android 16: RYU notification/power policy as exact method-level JSON deltas.
# No imported RYU JAR/APK/DEX, no PerfHook and no sha256 method pinning.
set -euo pipefail
w="$(pwd)"
source "$w/functions.sh"
base="$w/bin/package/NOTIFICATION_FIX/A16/EU"
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/rom_source.txt")" == xiaomi_eu ]] || { error "RYU EU policy requires Xiaomi.eu"; exit 1; }
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/androidver.txt")" == 16 ]] || { error "RYU EU policy requires Android 16"; exit 1; }
source "$w/bin/package/COREPATCH/helper.sh"
WORK_DIR="$w"
TOOLS_DIR="$w/bin/apktool"
API_LEVEL=36
jar="$w/build/baserom/images/system_ext/framework/miui-services.jar"
decoded="$w/miui-services_decompile"
output="$w/miui-services_patched.jar"
manifest="$base/ryu_policy.json"
[[ -s "$jar" && -s "$manifest" ]] || { error "RYU EU JAR or policy data missing"; exit 1; }
init_env
ensure_tools
tmp="$(mktemp -d "$w/eu-ryu-policy.XXXXXX")"
trap 'rm -rf "$decoded" "$w/miui-services" "$output" "$tmp"' EXIT
decompile_jar "$jar" >/dev/null
python3 "$base/ryu_policy.py" --root "$decoded" --manifest "$manifest" \
  --group miui-services --report "$w/build/reports/ryu-a16/miui-services.json"
recompile_jar "$jar" >/dev/null
[[ -s "$output" ]] && unzip -t "$output" >/dev/null || { error "Rebuilt RYU policy JAR invalid"; exit 1; }
mkdir -p "$tmp/raw" "$tmp/decoded"
unzip -q "$output" 'classes*.dex' -d "$tmp/raw"
for dex in "$tmp/raw"/classes*.dex; do
  [[ -s "$dex" ]] || { error "RYU JAR DEX missing"; exit 1; }
  stem="$(basename "$dex" .dex)"
  group=smali
  [[ "$stem" == classes ]] || group="smali_$(echo "$stem" | sed 's/^classes_//')"
  java -jar "$TOOLS_DIR/baksmaliv2.jar" d --api "$API_LEVEL" "$dex" -o "$tmp/decoded/$group" >/dev/null
done
python3 "$base/ryu_policy.py" --root "$tmp/decoded" --manifest "$manifest" \
  --group miui-services --verify --report "$w/build/reports/ryu-a16/verified.json"
mv -f "$output" "$jar"
mods "[EU A16] RYU international broadcast/alarm/app ops/job policy; CN_MODEL=false; no PerfHook"
bash "$base/PowerKeeper.sh"
