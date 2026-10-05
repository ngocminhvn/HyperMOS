#!/usr/bin/env bash
set -euo pipefail
work_dir=$(pwd)
source "$work_dir/functions.sh"

case "${HYPERMOS_FAKE_LOCK:-true}" in
    true|1|yes|on) ;;
    false|0|no|off) mods "Fake Lock disabled"; exit 0 ;;
    *) error "Invalid HYPERMOS_FAKE_LOCK value"; exit 1 ;;
esac

mods "Fake Lock: early Xiaomi-aware property overrides"
python3 "$work_dir/bin/package/ResetProp/install.py" "$work_dir"
mods "Fake Lock installed; post-fs-data early pass + boot-complete reinforcement (0s intentional delay)"
