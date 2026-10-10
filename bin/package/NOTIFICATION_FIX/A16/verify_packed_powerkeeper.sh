#!/usr/bin/env bash
# Verify actual PowerKeeper.apk stored in the packed system_ext partition.
# Run before super.img creation and before the partition image is removed.
# RYU test branch only; fail closed on extraction/signature errors.
set -euo pipefail

work_dir="${1:?pass repository working directory}"
fstype="${2:?pass partition filesystem type}"
prefix="[RYU PACK SIGN]"
partition="$work_dir/build/baserom/images/system_ext"
image="$work_dir/build/baserom/images/system_ext.img"
signer="$work_dir/bin/apktool/apksigner.jar"
cert="$work_dir/bin/package/DISABLE_AVB/HMATools/aosp/security/testkey.x509.pem"
fail() { echo "$prefix ERROR: $*" >&2; exit 1; }

[[ -s "$image" && -d "$partition" ]] || fail "system_ext image or extracted source is missing"
[[ -s "$signer" && -s "$cert" ]] || fail "APK verifier or pinned testkey certificate is missing"

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
[[ "$found" -eq 1 ]] || {
  [[ ! -s "$tmp/extract-error.txt" ]] || tail -n 8 "$tmp/extract-error.txt" >&2
  fail "cannot extract PowerKeeper APK from the PACKED image (check paths/tools)"
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

expected="$(openssl x509 -in "$cert" -outform DER | sha256sum | awk '{print tolower($1)}')"
actual="$(printf '%s\n' "$verification" |
  sed -n 's/^Signer #1 certificate SHA-256 digest: //p' |
  head -n 1 | tr -d ':' | tr '[:upper:]' '[:lower:]')"
[[ -n "$expected" && "$actual" == "$expected" ]] ||
  fail "packed APK certificate does not match the ROM's pinned InstallerX testkey"

printf '%s\n' "$prefix PASS: PowerKeeper copied unchanged into system_ext.img"
printf '%s\n' "$prefix sha256=$(sha256sum "$packed" | awk '{print $1}') cert=$actual"
printf '%s\n' "$prefix checked V2/V3 APK signature in PACKED partition (device runtime NOT tested)"
