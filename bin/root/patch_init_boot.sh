#!/usr/bin/env bash
# Offline SukiSU Ultra LKM integration for a detected, compatible GKI ROM.
# Stock boot images are backed up; never flash a device in CI.
set -euo pipefail

workdir="$(pwd)"
images="$workdir/build/baserom/images"
scratch="${RUNNER_TEMP:-/tmp}/hypermos-sukisu"
magiskboot="$workdir/bin/Linux/x86_64/magiskboot"
die() { echo "::error title=SukiSU root::$*" >&2; exit 1; }

[ "${ROOT_MODE:-root}" = "root" ] || die "Only root mode may patch boot images"
device="$(tr -d '\r\n' < "$workdir/bin/ddevice/device_f.txt" 2>/dev/null || true)"
device="${device,,}"
[[ "$device" =~ ^[a-z0-9_-]+$ ]] || die "Missing or invalid device codename"
[ "$(cat "$scratch/device.txt" 2>/dev/null)" = "$device" ] ||
  die "Prepared SukiSU source is for a different device"
tag="$(cat "$scratch/tag.txt" 2>/dev/null)" || die "Missing official release tag"
[[ "$tag" =~ ^v[0-9][0-9A-Za-z._-]*$ ]] || die "Invalid prepared SukiSU release"
[[ "$(cat "$scratch/source-commit.txt" 2>/dev/null)" =~ ^[a-f0-9]{40}$ ]] ||
  die "Missing checked upstream source commit"
test -s "$images/boot.img" || die "Stock boot.img missing"
test -x "$magiskboot" || die "magiskboot binary missing"

kmi="$(python3 "$workdir/bin/root/detect_kernel_kmi.py" \
  --boot-image "$images/boot.img" \
  --magiskboot "$magiskboot" \
  --images-dir "$images")" || die "Stock KMI detection failed"
[ "$(cat "$scratch/kmi.txt" 2>/dev/null)" = "$kmi" ] ||
  die "Prepared LKM KMI does not match stock ($kmi)"
for item in kernelsu.ko ksuinit ksud RootManager.apk release-metadata.json; do
  test -s "$scratch/$item" || die "Missing official SukiSU asset: $item"
done
python3 - "$scratch/release-metadata.json" "$tag" "$kmi" <<'PYVERIFY' ||
  die "Prepared release metadata mismatch"
import json, sys
info = json.load(open(sys.argv[1], encoding="utf-8"))
if info.get("tag") != sys.argv[2] or info.get("kmi") != sys.argv[3]:
    raise SystemExit("release/KMI mismatch")
PYVERIFY

# Choose an actual boot partition with a usable ramdisk. Prefer init_boot
# on newer Android, then boot for older devices. Do not invent partitions.
probe_dir="$(mktemp -d "${RUNNER_TEMP:-/tmp}/hypermos-root-probe.XXXXXX")"
trap 'rm -rf "$probe_dir"' EXIT
partition=""
for candidate in init_boot boot; do
  candidate_file="$images/$candidate.img"
  [ -s "$candidate_file" ] || continue
  [ "$(head -c 8 "$candidate_file")" = "ANDROID!" ] || continue
  mkdir -p "$probe_dir/$candidate"
  if (cd "$probe_dir/$candidate" && "$magiskboot" unpack "$candidate_file" >/dev/null 2>&1) &&
     [ -s "$probe_dir/$candidate/ramdisk.cpio" ]; then
    partition="$candidate"
    break
  fi
done
[ -n "$partition" ] ||
  die "No supported boot/init_boot image with ramdisk; device needs an explicit kernel integration"
input="$images/$partition.img"
stock_backup="$workdir/build/baserom/root-stock-$partition.img"
cp -f "$input" "$stock_backup"
cmp -s "$input" "$stock_backup" || die "Could not preserve exact stock $partition"
printf '%s\n' "$partition" > "$workdir/build/baserom/root-partition.txt"
sha256sum "$stock_backup"

patched="$scratch/patched_$partition.img"
rm -f "$patched"
echo "[ROOT] device=$device KMI=$kmi SukiSU=$tag target=$partition"
"$scratch/ksud" boot-patch \
  --boot "$input" \
  --module "$scratch/kernelsu.ko" \
  --init "$scratch/ksuinit" \
  --kmi "$kmi" \
  --out "$scratch" --out-name "patched_$partition.img" ||
  die "SukiSU $tag boot-patch failed on $partition"
test -s "$patched" || die "No SukiSU-patched image created"
[ "$(head -c 8 "$patched")" = "ANDROID!" ] ||
  die "Patched $partition has an invalid Android boot header"
cmp -s "$input" "$patched" && die "SukiSU returned an unchanged image"
rm -rf "$scratch/validate"
mkdir -p "$scratch/validate"
(cd "$scratch/validate" && "$magiskboot" unpack "$patched" >/dev/null) ||
  die "Patched $partition cannot be unpacked"
test -s "$scratch/validate/ramdisk.cpio" ||
  die "Patched $partition contains no ramdisk"
"$magiskboot" cpio "$scratch/validate/ramdisk.cpio" "exists kernelsu.ko" >/dev/null ||
  die "Patched $partition ramdisk has no SukiSU LKM"
"$magiskboot" cpio "$scratch/validate/ramdisk.cpio" "exists init" >/dev/null ||
  die "Patched $partition ramdisk has no init"
mv -f "$patched" "$input"

# Manager is provided for manual installation in /data/app, not as a system app.
mkdir -p "$workdir/build/baserom/root-package"
install -m 0644 "$scratch/RootManager.apk" \
  "$workdir/build/baserom/root-package/RootManager.apk"
{
  printf 'HyperMOS %s ROOT_PROVIDER=SukiSU-Ultra\n' "${device^^}"
  printf 'ROOT_KMI=%s\nROOT_VERSION=%s\n' "$kmi" "$tag"
  printf 'PATCHED_PARTITION=%s\n' "$partition"
  printf 'MANAGER_PACKAGE=com.sukisu.ultra\n'
  printf 'MANAGER_INSTALL=manual-user-app-only\n'
  printf 'ROOT_SOURCE_COMMIT=%s\n' "$(cat "$scratch/source-commit.txt")"
  printf 'ROOT_RELEASE=%s\n' "https://github.com/SukiSU-Ultra/SukiSU-Ultra/releases/tag/$tag"
  printf 'Stock backup and patched %s SHA-256:\n' "$partition"
  sha256sum "$stock_backup" "$input"
  sha256sum "$workdir/build/baserom/root-package/RootManager.apk"
} > "$workdir/build/baserom/root-package/ROOT-INFO.txt"
echo "[ROOT] SukiSU $tag patched $partition; stock backup and manager packaged separately"
