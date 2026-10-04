#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

mods "Add Package..."
target_dir="$work_dir/bin/package"

run_package_mod() {
  local script="$1"
  local label="$2"

  [[ -f "$script" ]] || {
    error "Package mod missing: $label ($script)"
    exit 1
  }

  if ! bash "$script"; then
    error "Package mod failed: $label ($script)"
    exit 1
  fi
}

run_package_mod "$target_dir/COREPATCH/update.sh" "COREPATCH"
run_package_mod "$target_dir/DISABLE_AVB/DISABLEavb.sh" "DISABLE_AVB"
run_package_mod "$target_dir/NOTIFICATION_FIX/notificationFIX.sh" "NOTIFICATION_FIX"
run_package_mod "$target_dir/RefreshRate/1hz.sh" "RefreshRate"
run_package_mod "$target_dir/ResetProp/update.sh" "ResetProp"

mods "Add Package Done"
