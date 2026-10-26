#!/usr/bin/env bash
# A16 notification/power dispatch: CN patch only, EU stock + ZK reference extraction.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
base="$work_dir/bin/package/NOTIFICATION_FIX/A16"
identity="$work_dir/bin/ddevice/rom_source.txt"
version="$work_dir/bin/ddevice/androidver.txt"
[[ -s "$identity" && -s "$version" ]] || { error "A16 Notification: missing ROM identity/version"; exit 1; }
rom_source="$(tr -d '\r\n' < "$identity")"
android_ver="$(tr -d '\r\n' < "$version")"
[[ "$android_ver" == 16 ]] || { error "A16 Notification: Android $android_ver unsupported"; exit 1; }
if [[ "$rom_source" == xiaomi_eu ]]; then
  info "[EU A16] ZK304 per-method patch using class/*.dex only"
  python3 "$base/EU/zk_patch.py" \
    --images "$work_dir/build/baserom/images" \
    --tools "$work_dir/bin/apktool" \
    --report "$work_dir/build/reports/zk304-eu/port.json" || exit 1
  exit 0
fi
[[ "$rom_source" == china ]] || { error "A16 Notification: unknown source $rom_source"; exit 1; }

# China A16 remains on its existing scoped FrameworkPatcher/PowerKeeper path.
source "$work_dir/bin/package/COREPATCH/helper.sh"
WORK_DIR="$work_dir"
TOOLS_DIR="$work_dir/bin/apktool"
API_LEVEL=36
jar="$work_dir/build/baserom/images/system_ext/framework/miui-services.jar"
decoded="$work_dir/miui-services_decompile"
output="$work_dir/miui-services_patched.jar"
[[ -s "$jar" ]] || { error "A16 China: miui-services.jar missing"; exit 1; }
init_env
ensure_tools
trap 'rm -rf "$decoded" "$work_dir/miui-services" "$output"' EXIT
decompile_jar "$jar" >/dev/null
report="$work_dir/build/reports/frameworkpatcher-a16/notification-gates.json"
python3 "$base/CN/frameworkpatcher_cn_a16.py" "$decoded" --report "$report"
recompile_jar "$jar" >/dev/null
[[ -s "$output" ]] && unzip -t "$output" >/dev/null || { error "A16 China: invalid rebuilt miui-services.jar"; exit 1; }
mv -f "$output" "$jar"
log "[FRAMEWORKPATCHER A16] China notification port complete"
bash "$base/CN/PowerKeeper.sh"
