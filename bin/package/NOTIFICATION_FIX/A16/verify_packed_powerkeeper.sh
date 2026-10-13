#!/usr/bin/env bash
# Verify patched PowerKeeper identity stored in the packed system_ext partition.
# Run before super.img creation and before the partition image is removed.
# Test branch: require patched DEX identity and pinned Xiaomi v1 metadata.
set -euo pipefail

work_dir="${1:?pass repository working directory}"
fstype="${2:?pass partition filesystem type}"
prefix="[POWERKEEPER XIAOMI IDENTITY PACK]"
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

# Bit-for-bit match proves the compiled APK survived partition filesystem packing.
cmp -s "$apk" "$packed" || fail "packed PowerKeeper differs from the verified staging APK"
unzip -tq "$packed" >/dev/null || fail "packed APK ZIP structure is corrupted"
report="$work_dir/build/reports/powerkeeper-a16/final-identity.json"
[[ -s "$report" ]] || fail "validated stock identity report missing"
python3 - "$packed" "$report" <<'PYMETA'
import hashlib, json, sys, zipfile
from pathlib import Path
apk = Path(sys.argv[1])
identity = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
with zipfile.ZipFile(apk) as z:
    entries = {n: hashlib.sha256(z.read(n)).hexdigest()
               for n in z.namelist() if n.upper().startswith("META-INF/") and not n.endswith("/")}
assert entries == identity["metadata_sha256"], "Packed Xiaomi metadata differs"
PYMETA
python3 - "$report" "$packed" <<'PYVERIFY'
import hashlib,json,sys
from pathlib import Path
r=json.loads(Path(sys.argv[1]).read_text())
assert r['mode']=='xiaomi-certificate-preserved-patched-v1'
assert r['sha256']==hashlib.sha256(Path(sys.argv[2]).read_bytes()).hexdigest()
PYVERIFY
echo "$prefix PASS: compiled patched APK and Xiaomi metadata survived filesystem packing"
echo "$prefix Signature cryptographically invalid by design; ROM v1 bypass required; runtime NOT tested"
