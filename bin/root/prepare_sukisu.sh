#!/usr/bin/env bash
# Prepare SukiSU Ultra v4.2.1 LKM, ksuinit and Linux patcher from ONE verified source tag.
# This runs as the Actions runner (not sudo); it deliberately never flashes a device.
set -euo pipefail

workdir="$(pwd)"
images="$workdir/build/baserom/images"
out="${RUNNER_TEMP:-/tmp}/hypermos-sukisu-v4.2.1"
source_dir="$out/source"
tag="v4.2.1"
commit="fd2a85151c8312fd9b4237db9ba827dcea692228"
ddk_image="ghcr.io/ylarod/ddk-min:android15-6.6-20260828"

die() { echo "::error title=SukiSU preparation::$*" >&2; exit 1; }
[ "$(cat "$workdir/bin/ddevice/device_f.txt" 2>/dev/null)" = "haotian" ] ||
  die "SukiSU root is limited to HAOTIAN"
test -s "$images/boot.img" && test -s "$images/init_boot.img" ||
  die "Paired stock boot/init_boot images are missing"
kmi="$(python3 "$workdir/bin/root/detect_kernel_kmi.py" \
  --boot-image "$images/boot.img" \
  --magiskboot "$workdir/bin/Linux/x86_64/magiskboot" \
  --images-dir "$images")" || die "Stock kernel KMI detection failed"
# The DDK container below is the officially documented android15-6.6 toolchain.
# Never substitute an unrelated LKM when stock KMI does not match.
[ "$kmi" = "android15-6.6" ] ||
  die "Detected KMI=$kmi is unsupported by the pinned HAOTIAN SukiSU builder"
command -v docker >/dev/null || die "Docker is required for upstream DDK build"
command -v cargo >/dev/null || die "Cargo/Rust is required for upstream SukiSU build"
command -v rustup >/dev/null || die "rustup is required for upstream SukiSU build"
test -x "${ANDROID_NDK_HOME:-}/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android26-clang" ||
  die "Android NDK r29 is not configured"

mkdir -p "$out"
if [ ! -d "$source_dir/.git" ]; then
  echo "[ROOT] Cloning pinned upstream SukiSU Ultra $tag source"
  git clone --quiet --branch "$tag" --single-branch \
    https://github.com/SukiSU-Ultra/SukiSU-Ultra.git "$source_dir" ||
    die "SukiSU source checkout failed"
fi
head="$(git -C "$source_dir" rev-parse HEAD)" || die "Cannot inspect upstream commit"
[ "$head" = "$commit" ] || die "Pinned tag checksum mismatch: $head"
echo "[ROOT] Upstream SukiSU $tag commit $head; KMI=$kmi"

# The upstream DDK workflow builds this exact module using CONFIG_KSU=m CC=clang.
# Build only the detected HAOTIAN ARM64 KMI; never replace the stock boot kernel.
docker run --rm --privileged \
  -v "$source_dir:/workspace" -w /workspace/kernel "$ddk_image" \
  bash -euo pipefail -c 'CONFIG_KSU=m CC=clang make -j2 && llvm-strip -d kernelsu.ko' ||
  die "Official SukiSU v4.2.1 DDK LKM build failed"
test -s "$source_dir/kernel/kernelsu.ko" || die "Kernel module build has no output"

# Build a matching Android ARM64 init and a Linux x86_64 ksud patch tool.
# Full Git history is essential: upstream embeds git commit count as versionCode.
rustup target add aarch64-linux-android >/dev/null ||
  die "Could not install Android Rust target"
(
  cd "$source_dir"
  # shellcheck source=/dev/null
  source .github/scripts/setup-rust-build.sh aarch64-linux-android 26
  BUILTINS="$("$CLANG_PATH" --print-resource-dir)/lib/linux/libclang_rt.builtins-aarch64-android.a"
  test -s "$BUILTINS"
  export RUSTFLAGS="-C target-feature=+crt-static -C link-arg=-Wl,-z,max-page-size=16384 -C link-arg=-Wno-unused-command-line-argument -C link-arg=$BUILTINS"
  cargo build --locked --package ksuinit --target aarch64-linux-android --release
) || die "SukiSU v4.2.1 ksuinit build failed"
(
  cd "$source_dir"
  cargo build --locked --package ksud --target x86_64-unknown-linux-gnu --release
) || die "SukiSU v4.2.1 Linux ksud build failed"
install -m 0644 "$source_dir/kernel/kernelsu.ko" "$out/kernelsu.ko"
install -m 0755 "$source_dir/target/aarch64-linux-android/release/ksuinit" "$out/ksuinit"
install -m 0755 "$source_dir/target/x86_64-unknown-linux-gnu/release/ksud" "$out/ksud"
for part in kernelsu.ko ksuinit ksud; do
  test -s "$out/$part" || die "Missing upstream-built $part"
done
printf '%s\n' "$kmi" > "$out/kmi.txt"
printf '%s\n' "$head" > "$out/source-commit.txt"
echo "[ROOT] SukiSU Ultra $tag LKM, ksuinit and host ksud ready"
