#!/usr/bin/env bash
# Android 17 / OS4 Notification & Power patcher driver for HyperMOS.
# Patches services.jar + miui-services.jar (FCM wake/thaw, autostart, JobScheduler,
# force-stop, full-screen intents)
# and PowerKeeper.apk's OS4 GMS limiter while preserving Xiaomi identity.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
base="$work_dir/bin/package/NOTIFICATION_FIX/A17"
identity="$work_dir/bin/ddevice/rom_source.txt"
version="$work_dir/bin/ddevice/androidver.txt"

[[ -s "$version" ]] || { error "A17 Notification: missing androidver.txt"; exit 1; }
android_ver="$(tr -d '\r\n' < "$version")"
[[ "$android_ver" == "17" ]] || { error "A17 Notification: Android $android_ver unsupported"; exit 1; }

info "[A17 Notification] Starting Android 17 / OS4 notification & power patch"

# 1. Patch services.jar
source "$base/jar_ops.sh"
WORK_DIR="$work_dir"
TOOLS_DIR="$work_dir/bin/apktool"
API_LEVEL=36
services_jar="$work_dir/build/baserom/images/system/framework/services.jar"
services_decoded="$work_dir/services_decompile"
services_output="$work_dir/services_patched.jar"
jar="$work_dir/build/baserom/images/system_ext/framework/miui-services.jar"
decoded="$work_dir/miui-services_decompile"
output="$work_dir/miui-services_patched.jar"
report_dir="$work_dir/build/reports/frameworkpatcher-a17"

[[ -s "$services_jar" ]] || { error "A17 Notification: services.jar missing at $services_jar"; exit 1; }
[[ -s "$jar" ]] || { error "A17 Notification: miui-services.jar missing at $jar"; exit 1; }
init_env
ensure_tools

trap 'rm -rf "$services_decoded" "$decoded" "$work_dir/services" "$work_dir/miui-services" "$services_output" "$output"' EXIT

mkdir -p "$report_dir"

info "[A17 Notification] Decompiling services.jar..."
decompile_jar "$services_jar" >/dev/null

info "[A17 Notification] Adding the C2DM stopped-package wake flag..."
python3 "$base/servicespatcher_a17.py" "$services_decoded" \
  --report "$report_dir/services-fcm-wake.json"

info "[A17 Notification] Recompiling services.jar..."
recompile_jar "$services_jar" >/dev/null

[[ -s "$services_output" ]] && unzip -t "$services_output" >/dev/null || {
  error "A17 Notification: invalid rebuilt services.jar"
  exit 1
}

mv -f "$services_output" "$services_jar"
log "[SERVICESPATCHER A17] services.jar patched successfully"

# 2. Patch miui-services.jar

info "[A17 Notification] Decompiling miui-services.jar..."
decompile_jar "$jar" >/dev/null

report="$report_dir/notification-gates.json"

info "[A17 Notification] Running frameworkpatcher_a17.py..."
python3 "$base/frameworkpatcher_a17.py" "$decoded" --report "$report"

info "[A17 Notification] Recompiling miui-services.jar..."
recompile_jar "$jar" >/dev/null

[[ -s "$output" ]] && unzip -t "$output" >/dev/null || {
  error "A17 Notification: invalid rebuilt miui-services.jar"
  exit 1
}

mv -f "$output" "$jar"
log "[FRAMEWORKPATCHER A17] miui-services.jar patched successfully"

# 3. Patch PowerKeeper.apk
info "[A17 Notification] Running PowerKeeper.sh..."
bash "$base/PowerKeeper.sh"

log "[A17 Notification] All Android 17 notification, power, and thermal fixes complete"
