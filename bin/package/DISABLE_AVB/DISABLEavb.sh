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
        # Keep FakeLock cmdline spoof in this single vendor_boot repack.
        # KAORIOS_TOOLBOX/fakelock_patch.sh intentionally does not repack
        # vendor_boot again, avoiding the previous double-patch path.
        python3 - "$boot_work/config.json" <<'PY'
import json
import sys

path = sys.argv[1]
flags = (
    "androidboot.verifiedbootstate=green",
    "androidboot.flash.locked=1",
    "androidboot.vbmeta.device_state=locked",
)
with open(path, "r", encoding="utf-8") as f:
    config = json.load(f)

tokens = config.get("cmdline", "").split()
keys = {flag.split("=", 1)[0] for flag in flags}
tokens = [token for token in tokens if token.split("=", 1)[0] not in keys]
tokens.extend(flags)
config["cmdline"] = " ".join(tokens)

with open(path, "w", encoding="utf-8") as f:
    json.dump(config, f, indent=4)
PY
        info "FakeLock: injected locked-state androidboot flags into vendor_boot cmdline"
        disable_avb_verify "$boot_work"
        python3 "$work_dir/bin/vbpatcher.py" repack -c "$boot_work/config.json" -o "$boot_work/vendor_boot.img"
        python3 "$work_dir/bin/verify_boot_chain.py" inspect --images "$boot_work"
        mv -f "$boot_work/vendor_boot.img" "$images/vendor_boot.img"
        info "Patched vendor_boot.img"
    fi
fi
