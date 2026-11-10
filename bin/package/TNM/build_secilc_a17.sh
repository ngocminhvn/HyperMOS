#!/usr/bin/env bash
# Isolated A17-only SELinux compiler; never replace system secilc/libsepol.
set -euo pipefail

[[ "$#" -eq 1 ]] || { echo 'Usage: build_secilc_a17.sh <output-binary>' >&2; exit 2; }
target="$1"
if [[ -x "$target" ]]; then
  echo "[TNM SELINUX] Reusing A17 secilc: $target"
  exit 0
fi
for cmd in curl sha256sum tar make cc flex; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "[TNM SELINUX] Missing build dependency: $cmd" >&2
    exit 1
  }
done

mkdir -p "$(dirname "$target")"
tmp="$(mktemp -d -t tnm-secilc311-XXXXXXXX)"
trap 'rm -rf "$tmp"' EXIT
base='https://github.com/SELinuxProject/selinux/releases/download/3.11'
for spec in \
  'libsepol-3.11.tar.gz:79f3d2c88f44b7eb5cf54d9792e03232297e17f97a179163f2750099a00f164d' \
  'secilc-3.11.tar.gz:1fb7de005d35ae0ac6ff8f8fc955d08a15b5c1a67e961b97ef987576af0db11a'; do
  filename="${spec%%:*}"
  digest="${spec#*:}"
  echo "[TNM SELINUX] Downloading official SELinux 3.11 $filename"
  curl --fail --location --show-error --silent --retry 3 --connect-timeout 20 \
    "$base/$filename" -o "$tmp/$filename"
  echo "$digest  $tmp/$filename" | sha256sum -c -
  tar -xzf "$tmp/$filename" -C "$tmp"
done

# Compile matching libsepol 3.11 as a static archive, then link secilc
# directly to it. No system library overrides or linker-path changes.
echo '[TNM SELINUX] Building isolated libsepol and secilc 3.11'
log="$(dirname "$target")/build.log"
if ! {
  make -C "$tmp/libsepol-3.11/src" DISABLE_SHARED=y -j 4
  make -C "$tmp/libsepol-3.11/include" install PREFIX="$tmp/prefix"
  cc -O2 -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 \
    -I"$tmp/prefix/include" \
    "$tmp/secilc-3.11/secilc.c" \
    "$tmp/libsepol-3.11/src/libsepol.a" \
    -o "$target.tmp"
} >"$log" 2>&1; then
  echo '[TNM SELINUX] secilc 3.11 compile failure:' >&2
  tail -n 100 "$log" >&2
  exit 1
fi
mv -f "$target.tmp" "$target"
chmod 0755 "$target"
echo "[TNM SELINUX] Built isolated secilc 3.11 with static libsepol: $target"
