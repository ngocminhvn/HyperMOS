#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"
device_code=$(cat "$work_dir/bin/ddevice/device_f.txt")
images="$work_dir/build/baserom/images"
shopt -s nullglob

# Match PenguinOS for devices in avb_list (including haotian):
# patch boot/vendor_boot through HMATools/bbootimg instead of rebuilding
# vendor_boot with HyperMOS vbpatcher.py.
if grep -qw "$device_code" "$work_dir/bin/package/DISABLE_AVB/avb_list.txt"; then
    info "DISABLE_AVB: $device_code -> PenguinOS HMATools path"
    disable_avb_verify "$images/vendor"
    bash "$work_dir/bin/package/DISABLE_AVB/HMATools/start"
else
    # Preserve the existing HyperMOS path for devices outside avb_list.
    for img in "$images"/vbmeta*.img; do
        python3 "$work_dir/bin/patch-vbmeta.py" "$img"
    done
    disable_avb_verify "$images/vendor"
fi
