#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"
python3 "$work_dir/bin/package/TNM/integrate_lock.py" \
  --images "$work_dir/build/baserom/images" \
  --binary "$work_dir/bin/package/TNM/system_ext/xbin/tnm_helper" \
  --report "$work_dir/build/reports/tnm/lock" "$@"

mods "TNM LOCK: post-fs integration and SELinux staging verified"
info "TNM LOCK: property reporting configured; no hardware bootloader/TEE operation performed"
