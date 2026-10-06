#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

case "${HYPERMOS_FK_LOCK:-true}" in
    1|true|yes|on) ;;
    0|false|no|off)
        mods "FK_LOCK disabled"
        exit 0
        ;;
    *)
        error "FK_LOCK: invalid HYPERMOS_FK_LOCK value"
        exit 1
        ;;
esac

mods "FK_LOCK: synchronize system/system_ext/product fingerprints"
python3 "$work_dir/bin/package/FK_LOCK/install.py" "$work_dir"
mods "FK_LOCK: Done"
