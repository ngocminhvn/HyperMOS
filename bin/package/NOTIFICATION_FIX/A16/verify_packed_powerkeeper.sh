#!/usr/bin/env bash
# Verify actual PowerKeeper.apk stored in the packed system_ext partition.
# Run before super.img creation and before the partition image is removed.
# Test branch: fail closed unless the packed APK retains stock Xiaomi identity.
set -euo pipefail

work_dir="${1:?pass repository working directory}"
fstype="${2:?pass partition filesystem type}"
prefix="[POWERKEEPER STOCK PACK]"
partition="$work_dir/build/baserom/images/system_ext"
image="$work_dir/build/baserom/images/system_ext.img"
signer="$work_dir/bin/apktool/apksigner.jar"
fail() { echo "$prefix ERROR: $*" >&2; exit 1; }

[[ -s "$image" && -d "$partition" ]] || fail "system_ext image or extracted source is missing"
[[ -s "$signer" ]] || fail "APK verifier is missing"

mapfile -d '' apks < <(find "$partition" -type f -name PowerKeeper.apk -print0)
[[ "${#apks[@]}" -eq 1 ]] || fail "expected one staged PowerKeeper.apk; found ${#apks[@]}"
apk="${apks[0]}"
[[ -s "$apk" ]] || fail "staged PowerKeeper.apk is empty"
rel="${apk#"$partition"/}"
[[ "$rel" != "$apk" && "$rel" != *".."* ]] || fail "bad relative path: $rel"

tmp="$(mktemp -d "${TMPDIR:-/tmp}/ryu-powerkeeper-packed.XXXXXXXX")"
trap 'rm -rf "$tmp"' EXIT
packed="$tmp/from-packed-system_ext.apk"

extract_file() {
  local member="$1"
  rm -f "$packed"
  case "$fstype" in
    EROFS)
      command -v dump.erofs >/dev/null || fail "dump.erofs unavailable: cannot audit EROFS image"
      dump.erofs --cat --path="$member" "$image" > "$packed" 2>"$tmp/extract-error.txt"
      ;;
    EXT)
      command -v debugfs >/dev/null || fail "debugfs unavailable: cannot audit EXT image"
      debugfs -R "dump $member $packed" "$image" >"$tmp/ext-output.txt" 2>"$tmp/extract-error.txt"
      ;;
    *)
      fail "unsupported partition filesystem type: $fstype"
      ;;
  esac
}

found=0
for member in "/$rel" "/system_ext/$rel"; do
  if extract_file "$member" && [[ -s "$packed" ]]; then
    echo "$prefix extracted $member from system_ext.img"
    found=1
    break
  fi
done
# Ubuntu 24.04 ships erofs-utils 1.7.1, whose dump.erofs has no --cat.
# Use fsck.erofs as a compatibility fallback. This reads the real packed
# filesystem (not the staging directory) and fails closed on extraction errors.
if [[ "$found" -ne 1 && "$fstype" == EROFS ]]; then
  command -v fsck.erofs >/dev/null || fail "fsck.erofs missing for EROFS extraction"
  mkdir -p "$tmp/unpacked"
  if fsck.erofs --extract="$tmp/unpacked" "$image" >"$tmp/fsck-output.txt" 2>"$tmp/fsck-error.txt"; then
    for candidate in "$tmp/unpacked/$rel" "$tmp/unpacked/system_ext/$rel"; do
      if [[ -s "$candidate" ]]; then
        cp "$candidate" "$packed"
        echo "$prefix fsck.erofs extracted $candidate"
        found=1
        break
      fi
    done
  else
    tail -n 12 "$tmp/fsck-error.txt" >&2 || true
  fi
fi
[[ "$found" -eq 1 ]] || {
  fail "cannot extract PowerKeeper APK from the PACKED image (EROFS or EXT)"
}

# Bit-for-bit match proves the signed APK survived partition filesystem packing.
cmp -s "$apk" "$packed" || fail "packed PowerKeeper differs from the signed staging APK"
unzip -tq "$packed" >/dev/null || fail "packed APK ZIP structure is corrupted"
verification="$(java -jar "$signer" verify --verbose --print-certs --min-sdk-version 36 "$packed")" || {
  fail "the packed PowerKeeper APK signature does not verify"
}
printf '%s\n' "$verification" |
  grep -Eq '^Verified using v[23] scheme \(APK Signature Scheme v[23]\): true' ||
  fail "packed APK has no verified v2/v3 signature"

expected="c9009d01ebf9f5d0302bc71b2fe9aa9a47a432bba17308a3111b75d7b2149025"
actual="$(printf '%s\n' "$verification" |
  sed -n 's/^Signer #1 certificate SHA-256 digest: //p' |
  head -n 1 | tr -d ':' | tr '[:upper:]' '[:lower:]')"
[[ -n "$expected" && "$actual" == "$expected" ]] ||
  fail "packed PowerKeeper does not have Xiaomi MIUI certificate; rejecting unsafe UID 1000 testkey"

printf '%s\n' "$prefix PASS: Xiaomi-signed PowerKeeper copied unchanged into system_ext.img"
printf '%s\n' "$prefix sha256=$(sha256sum "$packed" | awk '{print $1}') cert=$actual"
printf '%s\n' "$prefix checked V2/V3 APK signature in PACKED partition (device runtime NOT tested)"
