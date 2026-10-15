#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"
python3 "$work_dir/bin/package/LOCK/integrate.py" \
  --images "$work_dir/build/baserom/images" \
  --binary "$work_dir/bin/package/LOCK/system_ext/xbin/ryu_helper" \
  --report "$work_dir/build/reports/lock" "$@"

mods "LOCK: RYU post-fs integration and SELinux staging verified"
info "LOCK: property reporting configured; no hardware bootloader/TEE operation performed"
