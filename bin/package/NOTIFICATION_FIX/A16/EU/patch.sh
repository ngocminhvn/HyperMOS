#!/usr/bin/env bash
# Xiaomi.eu A16 policy from Global303: scoped miui-services + PowerKeeper.
set -euo pipefail
w="$(pwd)"
source "$w/functions.sh"
base="$w/bin/package/NOTIFICATION_FIX/A16/EU"
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/rom_source.txt")" == xiaomi_eu ]] || { error "Global A16: Xiaomi.eu required"; exit 1; }
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/androidver.txt")" == 16 ]] || { error "Global A16: Android 16 required"; exit 1; }
source "$w/bin/package/COREPATCH/helper.sh"
WORK_DIR="$w"
TOOLS_DIR="$w/bin/apktool"
API_LEVEL=36
jar="$w/build/baserom/images/system_ext/framework/miui-services.jar"
decoded="$w/miui-services_decompile"
output="$w/miui-services_patched.jar"
[[ -s "$jar" ]] || { error "Global A16: miui-services.jar missing"; exit 1; }
[[ -s "$base/global-battery.smali" ]] || { error "Global A16: pinned battery donor missing"; exit 1; }
init_env
ensure_tools
trap 'rm -rf "$decoded" "$w/miui-services" "$output"' EXIT
decompile_jar "$jar" >/dev/null
python3 "$base/jar_port.py" "$decoded" "$base/global-battery.smali" \
  --report "$w/build/reports/global-a16/miui-battery.json"
# Scoped FCM exception from the legacy EU patch (not wholesale ZK Greeze).
# Allow Play Services C2DM receive through isAllowBroadcast; all other
# freeze, thaw, cache, UID and region checks remain EU-original.
python3 "$base/fcm_greeze.py" "$decoded" \
  --report "$w/build/reports/global-a16/fcm-greeze.json"
recompile_jar "$jar" >/dev/null
[[ -s "$output" ]] && unzip -t "$output" >/dev/null || {
  error "Global A16: rebuilt JAR invalid"; exit 1;
}
mv -f "$output" "$jar"
mods "[GLOBAL A16] miui-services.jar: three battery methods + MAP_APP + scoped GMS FCM broadcast allow"
bash "$base/PowerKeeper.sh"
