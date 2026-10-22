#!/usr/bin/env bash
# TNM package entry point: preserve the mandatory property integration even
# when the optional A16 App Privacy patch is disabled or unsupported.
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
base="$work_dir/bin/package/TNM"

bash "$base/lock.sh"

# China ROM must always carry the TNM visibility backend, regardless of
# workflow opt-out inputs; EU/other sources retain the existing optional path.
source_file="$work_dir/bin/ddevice/rom_source.txt"
[[ -s "$source_file" ]] || { error "TNM App Privacy: missing ROM source"; exit 1; }
rom_source="$(tr -d '\r\n' < "$source_file")"
case "$rom_source" in
  china)
    info "TNM App Privacy: mandatory on China ROM (override cannot disable)"
    bash "$base/patch_app_privacy.sh"
    ;;
  xiaomi_eu|other)
    if [[ "${TNM_ENABLE_APP_PRIVACY:-1}" == "1" ]]; then
      bash "$base/patch_app_privacy.sh"
    else
      info "TNM App Privacy: disabled explicitly for $rom_source"
    fi
    ;;
  *)
    error "TNM App Privacy: unknown ROM source '$rom_source'"
    exit 1
    ;;
esac

