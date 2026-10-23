#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

info "KAORIOS CorePatch: applying static signature/downgrade patch set"
export COREPATCH_DISABLE_SIGNATURE_VERIFICATION=1
export COREPATCH_RUN_HYPERMOS_EXTRAS=0

android_version="$(tr -d ' \r\n' < "$work_dir/bin/ddevice/androidver.txt")"
case "$android_version" in
  15)
    bash "$work_dir/bin/package/COREPATCH/jar_patcher_a15.sh"
    ;;
  16)
    bash "$work_dir/bin/package/COREPATCH/jar_patcher_a16.sh" \
      --disable-signature-verification
    ;;
  17)
    bash "$work_dir/bin/package/COREPATCH/jar_patcher_a17.sh"
    ;;
  *)
    error "KAORIOS CorePatch: unsupported Android version: $android_version"
    exit 1
    ;;
esac
info "KAORIOS CorePatch: completed"
