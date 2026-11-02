#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 /path/to/android-ndk" >&2
  exit 2
fi

ndk="$1"
toolchain="$ndk/toolchains/llvm/prebuilt/linux-x86_64/bin"
src="$(cd "$(dirname "$0")" && pwd)/property_overlay.c"
kaorios_dir="$(cd "$(dirname "$0")/../.." && pwd)"

build_one() {
  local compiler="$1" output="$2"
  "$compiler" -std=c11 -O2 -fPIC -shared -fvisibility=hidden -Wall -Wextra -Werror \
    -Wl,-soname,libkaoripif.so -Wl,-z,relro,-z,now -llog \
    "$src" -o "$output"
  "$toolchain/llvm-strip" --strip-unneeded "$output"
  chmod 0644 "$output"
}

build_one "$toolchain/aarch64-linux-android33-clang" \
  "$kaorios_dir/bin/lib/arm64-v8a/libkaoripif.so"
build_one "$toolchain/armv7a-linux-androideabi33-clang" \
  "$kaorios_dir/bin/lib/armeabi-v7a/libkaoripif.so"
