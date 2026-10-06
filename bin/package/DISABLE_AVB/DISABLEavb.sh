#!/usr/bin/env bash
set -euo pipefail
work_dir=$(pwd)
source "$work_dir/functions.sh"
device_code=$(cat "$work_dir/bin/ddevice/device_f.txt")
images="$work_dir/build/baserom/images"
shopt -s nullglob

# This stage deliberately modifies verified partitions. Disable verification
# consistently, including when vendor ramdisk has no /avb directory.
for img in "$images"/vbmeta*.img; do
    python3 "$work_dir/bin/patch-vbmeta.py" "$img"
done

if grep -qw "$device_code" "$work_dir/bin/package/DISABLE_AVB/avb_list.txt"; then
    disable_avb_verify "$images/vendor"
    if [ -f "$images/vendor_boot.img" ]; then
        # Fresh workspace and temporary output exclude stale/partial results.
        boot_work=$(mktemp -d "$work_dir/build/baserom/vendor-boot.XXXXXX")
        trap 'rm -rf "$boot_work"' EXIT
        python3 "$work_dir/bin/vbpatcher.py" unpack -i "$images/vendor_boot.img" -o "$boot_work"
        # Whole-file SHA256/size are not libavb's loaded-structure digest/size.
        # Preserve bootloader-derived values instead of injecting properties.
        info "Patched vbmeta flags; no boot property injection"
        disable_avb_verify "$boot_work"
        python3 "$work_dir/bin/vbpatcher.py" repack -c "$boot_work/config.json" -o "$boot_work/vendor_boot.img"
        python3 "$work_dir/bin/verify_boot_chain.py" inspect --images "$boot_work"
        mv -f "$boot_work/vendor_boot.img" "$images/vendor_boot.img"
        info "Patched vendor_boot.img"
    fi
fi
