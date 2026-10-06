#!/usr/bin/env bash
# Integration build of the actual stock boot-chain images, without a full ROM.
set -euo pipefail
repo=$(cd "$(dirname "$0")/../.." && pwd)
test_work=$(mktemp -d)
trap 'rm -rf "$test_work"' EXIT
mkdir -p "$test_work/bin/package/DISABLE_AVB/HMATools/aosp/avb" \
    "$test_work/bin/ddevice" "$test_work/build/baserom/images/vendor/etc"
cp "$repo/bin/vbpatcher.py" "$repo/bin/patch-vbmeta.py" "$repo/bin/verify_boot_chain.py" "$test_work/bin/"
cp "$repo/bin/package/DISABLE_AVB/DISABLEavb.sh" "$repo/bin/package/DISABLE_AVB/avb_list.txt" "$test_work/bin/package/DISABLE_AVB/"
cp "$repo/bin/package/DISABLE_AVB/HMATools/aosp/avb/avbtool.v1.2.py" "$test_work/bin/package/DISABLE_AVB/HMATools/aosp/avb/"
sed 's/\r$//' "$repo/functions.sh" > "$test_work/functions.sh"
if [ "$#" -gt 0 ]; then
    cp "$1/"*.img "$test_work/build/baserom/images/"
else
    "$repo/bin/Linux/x86_64/payload-extract" extract -v -q \
        -p boot,vendor_boot,vbmeta,vbmeta_system,init_boot,dtbo,recovery \
        -o "$test_work/build/baserom/images" \
        'https://bkt-sgp-miui-ota-update-alisgp.oss-ap-southeast-1.aliyuncs.com/OS3.0.308.0.WOBCNXM/haotian-ota_full-OS3.0.308.0.WOBCNXM-user-16.0-9aea0c2b20.zip'
fi
printf 'haotian\n' > "$test_work/bin/ddevice/device_f.txt"
printf '/dev/block/by-name/vendor /vendor erofs ro wait,first_stage_mount,avb=vbmeta_system_ext\n' > "$test_work/build/baserom/images/vendor/etc/fstab.test"
cd "$test_work"
python3 bin/verify_boot_chain.py before --images build/baserom/images
bash bin/package/DISABLE_AVB/DISABLEavb.sh
python3 bin/verify_boot_chain.py after --images build/baserom/images
python3 - <<'PY'
import json
from pathlib import Path
before = json.loads(Path('build/boot-chain/before.json').read_text())
after = json.loads(Path('build/boot-chain/after.json').read_text())
for name in ('boot.img', 'init_boot.img', 'dtbo.img'):
    assert before['images'][name]['sha256'] == after['images'][name]['sha256'], name
vendor = after['images']['vendor_boot.img']
assert vendor['avb']['descriptors'][0]['payload_hash_matches']
assert after['images']['vbmeta.img']['avb']['flags'] == 3
assert before['images']['vendor_boot.img']['dtb_sha256'] == vendor['dtb_sha256']
assert before['images']['vendor_boot.img']['bootconfig'] == vendor['bootconfig']
assert not any(after['boot_vbmeta_parameters'].values())
assert '_system_ext' not in Path('build/baserom/images/vendor/etc/fstab.test').read_text()
print('Real stock-image DISABLE_AVB integration build: PASS')
PY
mkdir -p "$repo/build/boot-chain-integration"
cp build/boot-chain/*.json "$repo/build/boot-chain-integration/"
