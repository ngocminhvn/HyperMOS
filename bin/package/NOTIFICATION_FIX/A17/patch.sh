#!/usr/bin/env bash
# Android 17 / OS4 XNotifyFix integration for HyperMOS.
# Build-time alert options take 0 or 1: A17_GROUP_ALERT_BYPASS,
# A17_ANTI_MUTE_UPDATE (enabled by default), A17_UNTHROTTLE_ALERT,
# A17_DISABLE_MIUI_COOLDOWN, A17_DISABLE_ANDROID_COOLDOWN and A17_DISABLE_OFFBODY_MUTE.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
base="$work_dir/bin/package/NOTIFICATION_FIX/A17"
version="$work_dir/bin/ddevice/androidver.txt"

[[ -s "$version" ]] || { error "A17 Notification: missing androidver.txt"; exit 1; }
android_ver="$(tr -d '\r\n' < "$version")"
[[ "$android_ver" == "17" ]] || { error "A17 Notification: Android $android_ver unsupported"; exit 1; }

source "$base/jar_ops.sh"
WORK_DIR="$work_dir"
TOOLS_DIR="$work_dir/bin/apktool"
API_LEVEL=36
services_jar="$work_dir/build/baserom/images/system/system/framework/services.jar"
miui_jar="$work_dir/build/baserom/images/system_ext/framework/miui-services.jar"
report_dir="$work_dir/build/reports/frameworkpatcher-a17"
services_output="$work_dir/services_patched.jar"
miui_output="$work_dir/miui-services_patched.jar"
systemui_output="$work_dir/MiuiSystemUI_a17_patched.apk"
systemui_target="$report_dir/systemui-target"
images="$work_dir/build/baserom/images"

init_env
ensure_tools
mkdir -p "$report_dir"
trap 'rm -rf "$work_dir/services_decompile" "$work_dir/miui-services_decompile" "$services_output" "$miui_output" "$systemui_output"' EXIT
rm -f "$services_output" "$miui_output" "$systemui_output" "$systemui_target"

stage_jar() {
  local jar="$1" patcher="$2" report="$3" output="$4" decoded changed
  info "[A17 Notification] Checking $(basename "$jar")"
  decoded="$(decompile_jar "$jar")"
  python3 "$base/$patcher" "$decoded" --report "$report"
  changed="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["changed"])' "$report")"
  if [[ "$changed" == "False" ]]; then
    info "[A17 Notification] $(basename "$jar") already patched"
    return
  fi
  recompile_jar "$jar" >/dev/null
  [[ -s "$output" ]] && unzip -t "$output" >/dev/null || {
    error "A17 Notification: invalid rebuilt $(basename "$jar")"
    return 1
  }
}

stage_jar "$services_jar" servicespatcher_a17.py "$report_dir/services-fcm-wake.json" "$services_output"
stage_jar "$miui_jar" frameworkpatcher_a17.py "$report_dir/notification-gates.json" "$miui_output"

bash "$base/systemui_a17.sh" "$systemui_output" "$systemui_target"

if [[ -z "${TNM_SECILC:-}" ]]; then
  export TNM_SECILC="$work_dir/build/tools/tnm-secilc-3.11/secilc"
  bash "$work_dir/bin/package/TNM/build_secilc_a17.sh" "$TNM_SECILC"
fi
python3 "$base/gmswall_a17.py" "$images" "$report_dir"

if [[ -f "$systemui_output" ]]; then
  systemui="$(<"$systemui_target")"
  mv -f "$systemui_output" "$systemui"
  rm -rf "$(dirname "$systemui")/oat"
fi

if [[ -f "$services_output" ]]; then
  mv -f "$services_output" "$services_jar"
fi
if [[ -f "$miui_output" ]]; then
  mv -f "$miui_output" "$miui_jar"
fi

bash "$base/PowerKeeper.sh"

log "[A17 Notification] Android 17 framework patch complete"
