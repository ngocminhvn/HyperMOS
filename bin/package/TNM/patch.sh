#!/usr/bin/env bash
# TNM package entry point: preserve the mandatory property integration even
# when the optional A16 App Privacy patch is disabled or unsupported.
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
base="$work_dir/bin/package/TNM"

bash "$base/lock.sh"

if [[ "${TNM_ENABLE_APP_PRIVACY:-1}" == "1" ]]; then
  bash "$base/patch_app_privacy.sh"
else
  info "TNM App Privacy: disabled explicitly with TNM_ENABLE_APP_PRIVACY=0"
fi
