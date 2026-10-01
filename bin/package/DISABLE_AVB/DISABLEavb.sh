#!/usr/bin/env bash
work_dir=$(pwd)
source "$work_dir/functions.sh"
device_code=$(cat "$work_dir/bin/ddevice/device_f.txt")

if grep -qw "$device_code" "$work_dir/bin/package/DISABLE_AVB/avb_list.txt"; then
    disable_avb_verify "$work_dir/build/baserom/images/vendor" >/dev/null 2>&1 || {
        error "DISABLE_AVB: vendor AVB patch failed"
        exit 1
    }

    bash "$work_dir/bin/package/DISABLE_AVB/HMATools/start" || {
        error "DISABLE_AVB: HMATools failed"
        exit 1
    }
else
    while IFS= read -r -d '' img; do
        sudo "$work_dir/bin/vbmeta-disable-verification" "$img" || {
            error "DISABLE_AVB: vbmeta-disable-verification failed for $(basename "$img")"
            exit 1
        }
        python3 "$work_dir/bin/patch-vbmeta.py" "$img" || {
            error "DISABLE_AVB: patch-vbmeta failed for $(basename "$img")"
            exit 1
        }
    done < <(find "$work_dir/build/baserom/images" -type f -name "vbmeta*.img" -print0)

    disable_avb_verify "$work_dir/build/baserom/images/vendor" >/dev/null 2>&1 || {
        error "DISABLE_AVB: vendor AVB patch failed"
        exit 1
    }
fi
