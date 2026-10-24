#!/usr/bin/env bash
# Select the newest stable SukiSU-Ultra release and matching official GKI module.
# Root is conditional on verified KMI and ramdisk, never on a codename allowlist.
set -euo pipefail

workdir="$(pwd)"
images="$workdir/build/baserom/images"
out="${RUNNER_TEMP:-/tmp}/hypermos-sukisu"
host_cache="${SUKISU_HOST_CACHE_DIR:-${RUNNER_TEMP:-/tmp}/hypermos-sukisu-host-cache}"
cargo_target="${RUNNER_TEMP:-/tmp}/hypermos-sukisu-cargo-target"

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

mkdir -p "$out"
python3 "$workdir/bin/root/fetch_sukisu_latest.py" --out "$out" --kmi "$kmi" ||
  die "Latest official SukiSU release does not support $kmi or failed digest verification"

tag="$(cat "$out/tag.txt")"
[[ "$tag" =~ ^v[0-9][0-9A-Za-z._-]*$ ]] || die "Invalid upstream release tag"
expected_tag="${SUKISU_EXPECTED_TAG:-}"
[[ -z "$expected_tag" || "$tag" == "$expected_tag" ]] ||
  die "Latest release changed during build ($expected_tag -> $tag); retry the workflow"

cache_dir="$host_cache/$tag"
cache_binary="$cache_dir/ksud"
cache_commit="$cache_dir/source-commit.txt"
cache_digest="$cache_dir/ksud.sha256"
if [[ -x "$cache_binary" && -s "$cache_commit" && -s "$cache_digest" ]] &&
   (cd "$cache_dir" && sha256sum -c ksud.sha256 >/dev/null) &&
   [[ "$(tr -d '\r\n' < "$cache_commit")" =~ ^[a-f0-9]{40}$ ]]; then
  install -m 0755 "$cache_binary" "$out/ksud"
  cp "$cache_commit" "$out/source-commit.txt"
  head="$(tr -d '\r\n' < "$cache_commit")"
  echo "[ROOT] Reused verified host ksud cache for $tag ($head)"
else
  command -v cargo >/dev/null || die "Cargo/Rust is needed to build upstream host ksud"
  command -v git >/dev/null || die "Git is needed to verify the matching release source"
  source_dir="$out/source"
  # Clone only the immutable release snapshot; history is not used by boot-patch.
  git clone --quiet --depth 1 --branch "$tag" --single-branch \
    https://github.com/SukiSU-Ultra/SukiSU-Ultra.git "$source_dir" ||
    die "Could not clone SukiSU upstream release $tag"
  head="$(git -C "$source_dir" rev-parse HEAD)" || die "Could not inspect upstream tag"
  [[ "$head" =~ ^[a-f0-9]{40}$ ]] || die "Missing upstream commit"

  # v4.2.1-r1 exposes feature.rs to the GNU host build even though that module
  # calls Android-only code. Keep the official boot-patch host CLI and gate only
  # that unrelated runtime module, matching the rest of upstream's cfg layout.
  main_rs="$source_dir/userspace/ksud/src/main.rs"
  python3 "$workdir/bin/root/patch_sukisu_host_source.py" --source "$main_rs" ||
    die "Unsupported upstream host ksud source layout"
  echo "[ROOT] Latest stable SukiSU $tag ($head) device=$device KMI=$kmi"
  # Android release ksud uses /system/bin/linker64 and cannot run on Ubuntu.
  # Build only its upstream non-Android boot-patch CLI.
  (
    cd "$source_dir"
    CARGO_TARGET_DIR="$cargo_target" \
      cargo build --package ksud --target x86_64-unknown-linux-gnu --release
  ) || die "Could not build matching host ksud for release $tag"
  built="$cargo_target/x86_64-unknown-linux-gnu/release/ksud"
  test -s "$built" || die "Host ksud build produced no executable"
  install -m 0755 "$built" "$out/ksud"
  mkdir -p "$cache_dir"
  install -m 0755 "$built" "$cache_binary"
  printf '%s\n' "$head" > "$cache_commit"
  (cd "$cache_dir" && sha256sum ksud > ksud.sha256)
  echo "[ROOT] Saved verified host ksud cache for $tag"
fi
for item in kernelsu.ko ksuinit RootManager.apk ksud; do
  test -s "$out/$item" || die "Missing validated SukiSU $item"
done
printf '%s\n' "$device" > "$out/device.txt"
printf '%s\n' "$head" > "$out/source-commit.txt"
echo "[ROOT] Prepared latest stable SukiSU $tag for $device ($kmi)"
