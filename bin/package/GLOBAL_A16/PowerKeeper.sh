#!/usr/bin/env bash
# Global303 classes.dex on the Xiaomi.eu original PowerKeeper container.
# Preserve original APK manifest, assets, JNI and all META-INF bytes.
# No APK signing: modifying DEX necessarily invalidates the Xiaomi signature.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
base="$work_dir/bin/package/GLOBAL_A16"
policy="$work_dir/bin/package/NOTIFICATION_FIX/A16/EU"
images="$work_dir/build/baserom/images"
[[ "$(tr -d '\r\n' < "$work_dir/bin/ddevice/rom_source.txt")" == "xiaomi_eu" ]] || {
  error "Global A16 policy is scoped to Xiaomi.eu only"; exit 1;
}
[[ "$(tr -d '\r\n' < "$work_dir/bin/ddevice/androidver.txt")" == "16" ]] || {
  error "Global A16 policy requires Android 16"; exit 1;
}
for tool in python3 unzip zipalign zstd aapt; do
  command -v "$tool" >/dev/null || { error "Global A16 missing $tool"; exit 1; }
done
mapfile -d '' found < <(find "$images" -type f -name 'PowerKeeper.apk' -print0)
(( ${#found[@]} == 1 )) || { error "Global A16 requires exactly one stock PowerKeeper"; exit 1; }
apk="${found[0]}"
badging="$(aapt dump badging "$apk")"
grep -Fq "package: name='com.miui.powerkeeper' versionCode='40200'" <<< "$badging" || {
  error "Global A16 PowerKeeper package/version mismatch"; exit 1;
}
grep -Fq "sdkVersion:'36'" <<< "$badging" || {
  error "Global A16 requires PowerKeeper minSdk 36"; exit 1;
}
tmp="$(mktemp -d "$work_dir/global303-a16.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$work_dir/build/reports/global-a16"
archive="$base/global-powerkeeper.dex.zst"
if [[ -s "$archive" ]]; then
  zstd -q -d -f "$archive" -o "$tmp/global.dex"
  log "[GLOBAL A16] using pinned repository donor"
else
  python3 "$base/fetch_donor.py" "$tmp/global.dex"
fi
unzip -p "$apk" classes.dex > "$tmp/stock.dex"
python3 - "$tmp/stock.dex" "$tmp/global.dex" "$work_dir/bin/package/NOTIFICATION_FIX/A16/CN" <<'PY'
import hashlib
import sys
from pathlib import Path
original, global_dex, scope = (Path(p) for p in sys.argv[1:])
sys.path.insert(0, str(scope))
from eu_scoped_gates import Dex
expect = "21c20b3ddbaab981276bab60ab6c2a0f62587ea6d87b84bc54aa33def6df25bf"
reference = global_dex.read_bytes()
if hashlib.sha256(reference).hexdigest() != expect:
    raise SystemExit("[GLOBAL A16] donor DEX hash mismatch")
stock = original.read_bytes()
# The compared Global303/EU309 images have exactly matching defined
# executable method sets (17,818). Recheck rather than assume this of a new ROM.
stock_definitions = set(Dex(stock).codes)
global_definitions = set(Dex(reference).codes)
if len(global_definitions) != 17818 or stock_definitions != global_definitions:
    raise SystemExit("[GLOBAL A16] unsupported PowerKeeper ABI: method definitions differ")
print("[GLOBAL A16] matched all 17818 executable method definitions")
PY
if cmp -s "$tmp/stock.dex" "$tmp/global.dex"; then
  mods "[GLOBAL A16] PowerKeeper already has verified Global303 DEX"
  exit 0
fi
python3 "$policy/eu_powerkeeper_keep_metadata.py" \
  --base "$apk" --dex "$tmp/global.dex" --output "$tmp/preserved.apk" \
  --report "$work_dir/build/reports/global-a16/powerkeeper.json"
zipalign -p -f 4 "$tmp/preserved.apk" "$tmp/aligned.apk"
python3 "$policy/eu_powerkeeper_keep_metadata.py" \
  --base "$apk" --dex "$tmp/global.dex" --output "$tmp/aligned.apk" \
  --verify-only
cp -f "$tmp/aligned.apk" "$apk"
rm -rf "$(dirname "$apk")/oat"
mods "[GLOBAL A16] exact Global303 PowerKeeper DEX; EU APK metadata preserved; unsigned"
