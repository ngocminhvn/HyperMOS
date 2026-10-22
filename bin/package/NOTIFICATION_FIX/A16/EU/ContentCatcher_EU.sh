#!/usr/bin/env bash
# Xiaomi.eu A16-only; no China notification/PowerKeeper transplantation.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
source "$work_dir/bin/package/COREPATCH/helper.sh"
WORK_DIR="$work_dir"
TOOLS_DIR="$work_dir/bin/apktool"
API_LEVEL=36
if [[ ! -s "$work_dir/bin/ddevice/rom_source.txt" ]] ||
   [[ "$(tr -d '\r\n' < "$work_dir/bin/ddevice/rom_source.txt")" != "xiaomi_eu" ]] ||
   [[ ! -s "$work_dir/bin/ddevice/androidver.txt" ]] ||
   [[ "$(tr -d '\r\n' < "$work_dir/bin/ddevice/androidver.txt")" != "16" ]]; then
    exit 0
fi
jar="$work_dir/build/baserom/images/system_ext/framework/miui-services.jar"
decoded="$work_dir/miui-services_decompile"
output="$work_dir/miui-services_patched.jar"
report="$work_dir/build/reports/frameworkpatcher-a16/eu-contentcatcher.json"
[[ -s "$jar" ]] || { echo "[EU CONTENTCATCHER A16] missing miui-services.jar" >&2; exit 1; }
init_env
ensure_tools
trap 'rm -rf "$decoded" "$work_dir/miui-services" "$output"' EXIT
decompile_jar "$jar" >/dev/null
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/EU/contentcatcher_eu_a16.py" \
    "$decoded" --report "$report"
# Verify donor-identical native region/build gates; never force a constant.
# Any explicit donor IS_ZK_BUILD reference maps to native IS_INTERNATIONAL_BUILD.
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/EU/eu_zk_broadcast_greeze_parity_a16.py" \
    "$decoded" --report "$work_dir/build/reports/frameworkpatcher-a16/eu-zk-broadcast-greeze-parity.json"
# All-app FCM delivery: reuse existing ZK-style thaw path; do not disable Greeze.
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/EU/eu_zk_fcm_delivery_a16.py" \
    "$decoded" --report "$work_dir/build/reports/frameworkpatcher-a16/eu-greeze-fcm.json"
recompile_jar "$jar" >/dev/null
if [[ ! -s "$output" ]] || ! unzip -t "$output" >/dev/null 2>&1; then
    echo "[EU CONTENTCATCHER A16] rebuilt JAR invalid" >&2
    exit 1
fi
mv -f "$output" "$jar"
log "[EU A16] ContentCatcher + ZK304 gate parity + selective Google FCM Greeze thaw"
