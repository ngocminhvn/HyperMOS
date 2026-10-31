#!/usr/bin/env bash
# TNM entry: mandatory property integration + A16 Hide App List on CN and EU.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
base="$work_dir/bin/package/TNM"

lock_action() {
  if [[ ! -f "$base/integrate_lock.py" ]]; then
    info "TNM LOCK: skipped (integrate_lock.py not present)"
    return 0
  fi
  python3 "$base/integrate_lock.py" \
    --images "$work_dir/build/baserom/images" \
    --binary "$base/system_ext/xbin/tnm_helper" \
    --report "$work_dir/build/reports/tnm/lock" "$@"
}

# Keep LOCK staging pre-pack sanity check; the duplicate Hide App List
# pre-pack audit was removed. Hide App List validates as part of patching.
if [[ "${1:-}" == "--check-lock" && "$#" -eq 1 ]]; then
  lock_action --check
  exit 0
fi
[[ "$#" -eq 0 ]] || { error "TNM: unknown arguments"; exit 2; }

lock_action
if [[ -f "$base/integrate_lock.py" ]]; then
  mods "TNM LOCK: post-fs property integration and SELinux staging verified"
  info "TNM LOCK: property reporting configured; no hardware bootloader/TEE operation performed"
else
  info "TNM LOCK: skipped (integrate_lock.py not present)"
fi

source_file="$work_dir/bin/ddevice/rom_source.txt"
[[ -s "$source_file" ]] || { error "TNM App Privacy: missing ROM source"; exit 1; }
rom_source="$(tr -d '\r\n' < "$source_file")"
case "$rom_source" in
  china|xiaomi_eu)
    info "TNM App Privacy: mandatory on $rom_source (no opt-out)"
    bash "$base/patch_app_privacy.sh"
    ;;
  other)
    if [[ "${TNM_ENABLE_APP_PRIVACY:-1}" == "1" ]]; then
      bash "$base/patch_app_privacy.sh"
    else
      info "TNM App Privacy: disabled for other ROM source"
    fi
    ;;
  *)
    error "TNM App Privacy: unknown ROM source '$rom_source'"
    exit 1
    ;;
esac
