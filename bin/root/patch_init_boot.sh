#!/usr/bin/env bash
# HyperMOS HAOTIAN: KernelSU Next LKM integration (stock mode supported in Actions).
# Source images are taken from the SAME Xiaomi firmware used by build.sh.
set -euo pipefail

flavor="${ROOT_MODE:-root}"
# Kernel KMI is always detected from the current stock ROM, not a user input.
workdir="$(pwd)"
images="$workdir/build/baserom/images"
input="$images/init_boot.img"
scratch="${RUNNER_TEMP:-/tmp}/hypermos-root-${GITHUB_RUN_ID:-local}"
mkdir -p "$scratch"

die() { echo "::error::$*" >&2; exit 1; }
fetch() {
  local url="$1" dest="$2"
  echo "[ROOT] Downloading $(basename "$dest")"
  curl --fail --silent --show-error --location --retry 5 --retry-delay 3 "$url" --output "$dest" ||
    die "Download failed: $url"
  test -s "$dest" || die "Empty download: $url"
}
case "$flavor" in
  root) ;;
  *) die "ROOT_MODE must be root; stock builds must not run this script: $flavor" ;;
esac
[ "$(cat "$workdir/bin/ddevice/device_f.txt" 2>/dev/null)" = "haotian" ] ||
  die "Root experiment restricted to HAOTIAN"
test -s "$input" || die "init_boot.img not extracted; do not patch boot.img as a fallback"
test -s "$images/boot.img" || die "boot.img missing; cannot establish paired stock images"
[ "$(head -c 8 "$input")" = "ANDROID!" ] || die "init_boot.img has invalid Android boot header"

# Auto-select only when stock boot kernel and/or vendor modules prove the KMI.
# Do not silently fall back to android15-6.6 or infer it from Android 16.
kmi="$(python3 "$workdir/bin/root/detect_kernel_kmi.py" \
  --boot-image "$images/boot.img" \
  --magiskboot "$workdir/bin/Linux/x86_64/magiskboot" \
  --images-dir "$images")" || die "Automatic stock KMI detection failed"
[[ "$kmi" =~ ^android(12|13|14|15|16|17)-(5\.10|5\.15|6\.1|6\.6|6\.12|6\.18)$ ]] ||
  die "Unsupported detected KMI=$kmi"
echo "[ROOT] Automatically detected stock kernel KMI: $kmi"


# Retain exactly the stock input used to produce the rooted image.
cp -f "$input" "$workdir/build/baserom/root-stock-init_boot.img"
sha256sum "$images/boot.img" "$workdir/build/baserom/root-stock-init_boot.img"

ko="$scratch/kernelsu.ko"
ksud="$scratch/ksud"
manager="$scratch/RootManager.apk"

# Resolve the latest stable release at build time; validate all upstream SHA256 digests.
release_repo="KernelSU-Next/KernelSU-Next"
release_json="$scratch/release.json"
fetch "https://api.github.com/repos/$release_repo/releases/latest" "$release_json"
tag="$(jq -er '.tag_name' "$release_json")" || die "Failed to resolve latest release"
[[ "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "Unexpected release tag: $tag"
echo "[ROOT] Latest stable: $release_repo@$tag"
release_asset() {
  local pattern="$1" dest="$2" record url digest
  record="$(jq -er --arg regex "$pattern" '
    [.assets[] | select(.name | test($regex))] |
    if length == 1 then (.[0] | [.browser_download_url,.digest] | @tsv)
    else error("Expected exactly one matching release asset") end' "$release_json")" ||
    die "Missing or ambiguous upstream release asset: $pattern"
  IFS=$'\t' read -r url digest <<< "$record"
  [[ "$digest" =~ ^sha256:[[:xdigit:]]{64}$ ]] || die "No upstream SHA256 for $pattern"
  fetch "$url" "$dest"
  printf '%s  %s\n' "${digest#sha256:}" "$dest" | sha256sum -c - ||
    die "Upstream SHA256 mismatch for $pattern"
}

# Only KernelSU Next is supported on main. No other root forks are downloaded.
release_asset '^ksud-x86_64-unknown-linux-musl$' "$ksud"
release_asset "^aarch64_${kmi}_kernelsu\\.ko$" "$ko"
release_asset '^KernelSU_Next_v[0-9.]+_[0-9]+-release\\.apk$' "$manager"
manager_filename="KernelSU-Next_${tag}.apk"
test -s "$ko" && test -s "$manager" && test -s "$ksud" || die "Missing official root files"
unzip -tq "$manager" || die "Upstream manager APK is corrupt"
chmod 0755 "$ksud"
cmd=("$ksud" boot-patch --boot "$input" --module "$ko" --kmi "$kmi" --out "$scratch" --out-name patched_init_boot.img)
echo "[ROOT] provider=KernelSU-Next tag=$tag KMI=$kmi target=init_boot.img (LKM)"
"${cmd[@]}" || die "Official ksud patch failed"
patched="$scratch/patched_init_boot.img"
test -s "$patched" || die "Root patch tool returned no output image"
[ "$(head -c 8 "$patched")" = "ANDROID!" ] || die "Patched image has invalid header"
if cmp -s "$input" "$patched"; then die "Patch tool returned unchanged image"; fi

# A new ramdisk image must still unpack successfully with the build's magiskboot.
magiskboot="$workdir/bin/Linux/x86_64/magiskboot"
test -x "$magiskboot" || die "magiskboot unavailable for boot-image validation"
mkdir -p "$scratch/validate"
(cd "$scratch/validate" && "$magiskboot" unpack "$patched" >/dev/null) ||
  die "Patched init_boot.img cannot be unpacked; refusing to package"
test -s "$scratch/validate/ramdisk.cpio" ||
  die "Patched image contains no readable ramdisk"
"$magiskboot" cpio "$scratch/validate/ramdisk.cpio" "exists kernelsu.ko" >/dev/null ||
  die "Patched ramdisk missing kernelsu.ko"
mv -f "$patched" "$input"
# Only a payload in read-only system_ext: no installation or package scanning.
system_ext="$images/system_ext"
[ -d "$system_ext" ] || die "Missing system_ext partition for manager staging"
apk_stage="$system_ext/etc/hypermos-root"
test -s "$workdir/bin/root/stage_root_manager.sh" ||
  die "Missing post-boot stage script"
test -s "$workdir/bin/root/stage_root_manager.rc" ||
  die "Missing post-unlock init rc"
mkdir -p "$apk_stage" "$system_ext/bin" "$system_ext/etc/init"
install -m 0644 "$manager" "$apk_stage/RootManager.apk"
printf '%s\n' "$manager_filename" > "$apk_stage/manager-name.txt"
chmod 0644 "$apk_stage/manager-name.txt"
install -m 0755 "$workdir/bin/root/stage_root_manager.sh" "$system_ext/bin/hypermos-root-manager-stage"
install -m 0644 "$workdir/bin/root/stage_root_manager.rc" "$system_ext/etc/init/hypermos-root-manager.rc"
test -s "$apk_stage/RootManager.apk" || die "Manager payload copy failed"
test -s "$system_ext/etc/init/hypermos-root-manager.rc" || die "Missing init trigger"
[ ! -e "$system_ext/priv-app/RootManager" ] || die "Root manager must not be preinstalled"

mkdir -p "$workdir/build/baserom/root-package"
cp -f "$manager" "$workdir/build/baserom/root-package/RootManager.apk"
{
  printf 'HyperMOS HAOTIAN ROOT_PROVIDER=KernelSU-Next\n'
  printf 'ROOT_KMI=%s\nROOT_VERSION=%s\n' "$kmi" "$tag"
  printf 'MANAGER_DOWNLOAD=%s\n' "/storage/emulated/0/Download/$manager_filename"
  printf 'Patched partition: init_boot (LKM); stock boot left unchanged\n'
  sha256sum "$workdir/build/baserom/root-stock-init_boot.img" "$input"
} > "$workdir/build/baserom/root-package/ROOT-INFO.txt"
echo "[ROOT] Root image patched; manager staged for Download after unlock: $manager_filename"
