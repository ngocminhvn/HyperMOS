#!/usr/bin/env bash
# HyperMOS HAOTIAN SukiSU Ultra v4.2.1 LKM integration.
# Only init_boot is patched. Stock boot and init_boot backups are retained.
set -euo pipefail

workdir="$(pwd)"
images="$workdir/build/baserom/images"
input="$images/init_boot.img"
scratch="${RUNNER_TEMP:-/tmp}/hypermos-sukisu-v4.2.1"
tag="v4.2.1"
manager_name="SukiSU_v4.2.1_40994-release.apk"
manager_url="https://github.com/SukiSU-Ultra/SukiSU-Ultra/releases/download/$tag/$manager_name"
manager_sha256="c7f69280cf468e8415c585ff31f963d0147386831217a1e89b822afddc5f40ed"

die() { echo "::error title=SukiSU root::$*" >&2; exit 1; }
[ "${ROOT_MODE:-root}" = "root" ] || die "Only root mode may patch init_boot"
[ "$(cat "$workdir/bin/ddevice/device_f.txt" 2>/dev/null)" = "haotian" ] ||
  die "Root patch restricted to HAOTIAN"
test -s "$input" && test -s "$images/boot.img" ||
  die "Paired stock init_boot.img / boot.img missing"
[ "$(head -c 8 "$input")" = "ANDROID!" ] || die "Stock init_boot has invalid header"

kmi="$(python3 "$workdir/bin/root/detect_kernel_kmi.py" \
  --boot-image "$images/boot.img" \
  --magiskboot "$workdir/bin/Linux/x86_64/magiskboot" \
  --images-dir "$images")" || die "Stock KMI detection failed"
[ "$kmi" = "android15-6.6" ] || die "Unexpected HAOTIAN KMI=$kmi"
[ "$(cat "$scratch/kmi.txt" 2>/dev/null)" = "$kmi" ] ||
  die "Prepared LKM KMI does not match stock"
[ "$(cat "$scratch/source-commit.txt" 2>/dev/null)" = "fd2a85151c8312fd9b4237db9ba827dcea692228" ] ||
  die "SukiSU source commit has not been verified"
for part in kernelsu.ko ksuinit ksud; do
  test -s "$scratch/$part" || die "Missing official source-built $part"
done

# Back up exactly the image provided by the Xiaomi firmware.
cp -f "$input" "$workdir/build/baserom/root-stock-init_boot.img"
sha256sum "$workdir/build/baserom/root-stock-init_boot.img"

manager="$scratch/$manager_name"
if [ ! -s "$manager" ]; then
  curl --fail --silent --show-error --location --retry 5 --retry-delay 3 \
    --connect-timeout 20 --max-time 180 "$manager_url" -o "$manager" ||
    die "Cannot download the official $tag manager"
fi
printf '%s  %s\n' "$manager_sha256" "$manager" | sha256sum -c - ||
  die "Official manager APK SHA-256 mismatch"
unzip -tq "$manager" || die "Official SukiSU manager is not a valid APK"

patched="$scratch/patched_init_boot.img"
rm -f "$patched"
echo "[ROOT] provider=SukiSU-Ultra tag=$tag KMI=$kmi target=init_boot.img"
"$scratch/ksud" boot-patch \
  --boot "$input" \
  --module "$scratch/kernelsu.ko" \
  --init "$scratch/ksuinit" \
  --kmi "$kmi" \
  --out "$scratch" --out-name patched_init_boot.img ||
  die "SukiSU v4.2.1 ksud boot-patch failed"
test -s "$patched" || die "No SukiSU patched image created"
[ "$(head -c 8 "$patched")" = "ANDROID!" ] || die "Patched init_boot has invalid header"
cmp -s "$input" "$patched" && die "SukiSU returned an unchanged init_boot"

magiskboot="$workdir/bin/Linux/x86_64/magiskboot"
test -x "$magiskboot" || die "magiskboot validation binary unavailable"
mkdir -p "$scratch/validate"
(cd "$scratch/validate" && "$magiskboot" unpack "$patched" >/dev/null) ||
  die "Patched init_boot cannot be unpacked"
test -s "$scratch/validate/ramdisk.cpio" ||
  die "Patched init_boot contains no ramdisk"
"$magiskboot" cpio "$scratch/validate/ramdisk.cpio" "exists kernelsu.ko" >/dev/null ||
  die "Patched init_boot ramdisk missing SukiSU LKM"
"$magiskboot" cpio "$scratch/validate/ramdisk.cpio" "exists init" >/dev/null ||
  die "Patched init_boot ramdisk missing SukiSU init"
mv -f "$patched" "$input"

# The manager APK is packaged in the flashable ZIP for optional manual
# installation with adb install (normal /data/app user app).
# Never stage an init trigger or perform any boot-time package checks.
mkdir -p "$workdir/build/baserom/root-package"
install -m 0644 "$manager" "$workdir/build/baserom/root-package/RootManager.apk"
{
  printf 'HyperMOS HAOTIAN ROOT_PROVIDER=SukiSU-Ultra\n'
  printf 'ROOT_KMI=%s\nROOT_VERSION=%s\n' "$kmi" "$tag"
  printf 'MANAGER_PACKAGE=com.sukisu.ultra\n'
  printf 'MANAGER_INSTALL=manual-user-app-only\n'
  printf 'MANAGER_RELEASE=%s\n' "$manager_name"
  printf 'ROOT_SOURCE_COMMIT=%s\n' "$(cat "$scratch/source-commit.txt")"
  printf 'Patched partition: init_boot (LKM); stock boot left unchanged\n'
  sha256sum "$workdir/build/baserom/root-stock-init_boot.img" "$input"
  sha256sum "$workdir/build/baserom/root-package/RootManager.apk"
} > "$workdir/build/baserom/root-package/ROOT-INFO.txt"
echo "[ROOT] SukiSU v4.2.1 patched init_boot; signed manager APK bundled for manual installation"
