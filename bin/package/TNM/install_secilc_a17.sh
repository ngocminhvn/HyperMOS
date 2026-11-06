#!/usr/bin/env bash
# Build an Android-17-compatible host secilc with verified upstream source.
# Ubuntu 24.04's apt secilc does not understand permissionx nlmsg.
# Keep all SELinux validations enabled; never rewrite or strip platform CIL.
set -euo pipefail

if (( EUID != 0 )); then
  echo "[SELINUX ERROR] This helper must run as root on the GitHub runner" >&2
  exit 1
fi

# Release source and SHA-256 are published by SELinuxProject:
# https://github.com/SELinuxProject/selinux/wiki/Releases
version="3.11"
expected_sha256="6b6d47ab0f35fe1c09bda0c62821c8d97a0cbe7f6e9404b338df7bde0182c4f4"
url="https://github.com/SELinuxProject/selinux/releases/download/$version/selinux-$version.tar.gz"
temp_dir="$(mktemp -d -t hypermos-secilc-XXXXXX)"
trap 'rm -rf "$temp_dir"' EXIT
archive="$temp_dir/selinux-$version.tar.gz"

echo "[SELINUX] Fetching verified SELinuxProject userspace $version"
curl --fail --location --silent --show-error \
  --retry 4 --retry-delay 3 --connect-timeout 20 --max-time 300 \
  "$url" --output "$archive"
printf '%s  %s\n' "$expected_sha256" "$archive" | sha256sum --check --status || {
  echo "[SELINUX ERROR] Upstream source digest mismatch; refusing unverified compiler" >&2
  exit 1
}

tar -xzf "$archive" -C "$temp_dir"
source_dir="$temp_dir/selinux-$version"
if [[ ! -f "$source_dir/libsepol/src/Makefile" ||
      ! -f "$source_dir/secilc/Makefile" ||
      ! -f "$source_dir/secilc/test/policy.cil" ]]; then
  echo "[SELINUX ERROR] Unexpected SELinuxProject source archive layout" >&2
  exit 1
fi

for program in make gcc curl sha256sum tar install; do
  command -v "$program" >/dev/null || {
    echo "[SELINUX ERROR] Missing build dependency: $program" >&2
    exit 1
  }
done
if ! command -v flex >/dev/null 2>&1; then
  echo "[SELINUX] Installing flex, needed for libsepol CIL parser"
  DEBIAN_FRONTEND=noninteractive apt-get -y -qq install flex
fi

echo "[SELINUX] Building libsepol $version (static) and secilc $version"
if ! make -C "$source_dir/libsepol/src" -j2 DISABLE_SHARED=y \
  >"$temp_dir/libsepol-build.log" 2>&1; then
  tail -n 100 "$temp_dir/libsepol-build.log" >&2
  exit 1
fi
if [[ ! -s "$source_dir/libsepol/src/libsepol.a" ]]; then
  echo "[SELINUX ERROR] Missing compiled libsepol.a" >&2
  exit 1
fi
if ! make -C "$source_dir/secilc" secilc \
  CPPFLAGS="-I$source_dir/libsepol/include" \
  LDFLAGS="-L$source_dir/libsepol/src" \
  >"$temp_dir/secilc-build.log" 2>&1; then
  tail -n 100 "$temp_dir/secilc-build.log" >&2
  exit 1
fi
binary="$source_dir/secilc/secilc"
if [[ ! -x "$binary" ]]; then
  echo "[SELINUX ERROR] secilc binary was not built" >&2
  exit 1
fi
# Reject accidental linkage to the stale runner libsepol shared library.
if ldd "$binary" | grep -F "libsepol" >/dev/null; then
  echo "[SELINUX ERROR] secilc dynamically links an unverified system libsepol" >&2
  exit 1
fi
# Upstream's CIL test policy includes NLMSG extended permission rules.
if ! "$binary" "$source_dir/secilc/test/policy.cil" \
  -o "$temp_dir/test-policy" -f "$temp_dir/test-contexts" \
  >"$temp_dir/secilc-selftest.log" 2>&1; then
  tail -n 100 "$temp_dir/secilc-selftest.log" >&2
  echo "[SELINUX ERROR] Upstream secilc policy self-test failed" >&2
  exit 1
fi
if [[ ! -s "$temp_dir/test-policy" ]]; then
  echo "[SELINUX ERROR] secilc self-test produced no binary policy" >&2
  exit 1
fi

install -m 0755 "$binary" /usr/local/bin/secilc
echo "[SELINUX OK] Installed verified secilc $version with nlmsg support: /usr/local/bin/secilc"
