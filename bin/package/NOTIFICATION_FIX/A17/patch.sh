#!/usr/bin/env bash
# Version-specific Android 17 driver, keeping existing PowerKeeper/SystemUI
# workflow unchanged until independent A17 policy methods are verified.
set -euo pipefail
work_dir="$(pwd)"
[[ "$(tr -d '\r\n' < "$work_dir/bin/ddevice/androidver.txt")" == "17" ]] || {
  echo "[A17 Notification] version guard failed" >&2
  exit 1
}
bash "$work_dir/bin/package/NOTIFICATION_FIX/PowerKeeper.sh"
bash "$work_dir/bin/package/NOTIFICATION_FIX/A17/SystemUI.sh"
