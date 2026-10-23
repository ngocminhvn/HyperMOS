#!/usr/bin/env bash
# Select the newest stable SukiSU-Ultra release and matching official GKI module.
# Root is conditional on verified KMI and ramdisk, never on a codename allowlist.
set -euo pipefail

workdir="$(pwd)"
images="$workdir/build/baserom/images"
out="${RUNNER_TEMP:-/tmp}/hypermos-sukisu"

die() { echo "::error title=SukiSU preparation::$*" >&2; exit 1; }
device="$(tr -d '\r\n' < "$workdir/bin/ddevice/device_f.txt" 2>/dev/null || true)"
device="${device,,}"
[[ "$device" =~ ^[a-z0-9_-]+$ ]] || die "Missing or invalid device codename"
test -s "$images/boot.img" || die "Stock boot.img required for kernel KMI detection"
test -x "$workdir/bin/Linux/x86_64/magiskboot" || die "magiskboot unavailable"
kmi="$(python3 "$workdir/bin/root/detect_kernel_kmi.py" \
  --boot-image "$images/boot.img" \
  --magiskboot "$workdir/bin/Linux/x86_64/magiskboot" \
  --images-dir "$images")" || die "Could not establish stock kernel KMI"

case "$kmi" in
  android12-5.10|android13-5.10|android13-5.15|android14-5.15|android14-6.1|android15-6.6|android16-6.12|android17-6.18) ;;
  *) die "No supported official SukiSU LKM for KMI=$kmi (device=$device)" ;;
esac

command -v cargo >/dev/null || die "Cargo/Rust is needed to build upstream host ksud"
command -v git >/dev/null || die "Git is needed to verify the matching release source"
mkdir -p "$out"
python3 "$workdir/bin/root/fetch_sukisu_latest.py" --out "$out" --kmi "$kmi" ||
  die "Latest official SukiSU release does not support $kmi or failed digest verification"

tag="$(cat "$out/tag.txt")"
[[ "$tag" =~ ^v[0-9][0-9A-Za-z._-]*$ ]] || die "Invalid upstream release tag"
source_dir="$out/source"
# Clone the release tag, not mutable main. Full history retains upstream versioning.
git clone --quiet --branch "$tag" --single-branch \
  https://github.com/SukiSU-Ultra/SukiSU-Ultra.git "$source_dir" ||
  die "Could not clone SukiSU upstream release $tag"
head="$(git -C "$source_dir" rev-parse HEAD)" || die "Could not inspect upstream tag"
test -n "$head" || die "Missing upstream commit"
echo "[ROOT] Latest stable SukiSU $tag ($head) device=$device KMI=$kmi"
# Official release binaries are SHA-256 verified; build the Linux host patcher
# from the same release tag because Android ksud cannot run on the Linux runner.
(
  cd "$source_dir"
  cargo build --package ksud --target x86_64-unknown-linux-gnu --release
) || die "Could not build matching host ksud for release $tag"
install -m 0755 "$source_dir/target/x86_64-unknown-linux-gnu/release/ksud" "$out/ksud"
for item in kernelsu.ko ksuinit RootManager.apk ksud; do
  test -s "$out/$item" || die "Missing validated SukiSU $item"
done
printf '%s\n' "$device" > "$out/device.txt"
printf '%s\n' "$head" > "$out/source-commit.txt"
echo "[ROOT] Prepared latest stable SukiSU $tag for $device ($kmi)"
