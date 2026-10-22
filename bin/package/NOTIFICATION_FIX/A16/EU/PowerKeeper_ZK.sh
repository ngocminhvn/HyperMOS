#!/usr/bin/env bash
# Merge compatible ZK304 power-management methods into the original EU APK DEX.
# Never substitute the whole ZK APK or remove EU-only ABI methods.
set -euo pipefail
w="$(pwd)"
source "$w/functions.sh"
d="$w/bin/package/NOTIFICATION_FIX/A16/EU"
cn="$w/bin/package/NOTIFICATION_FIX/A16/CN"
archive="$d/ZK304/zk304-powerkeeper.dex.zst"
manifest="$d/ZK304/manifest.json"
report="$w/build/reports/zk304-powerkeeper-eu"
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/rom_source.txt")" == "xiaomi_eu" ]] || exit 0
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/androidver.txt")" == 16 ]] || exit 0
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/sdkLevel.txt")" == 36 ]] || exit 1
for p in "$archive" "$manifest" "$w/bin/apktool/baksmaliv2.jar" "$w/bin/apktool/smaliv2.jar"; do
  [[ -s "$p" ]] || { error "ZK PowerKeeper missing $p"; exit 1; }
done
for c in python3 zstd unzip zipalign aapt java; do command -v "$c" >/dev/null || exit 1; done
mapfile -d '' apks < <(find "$w/build/baserom/images" -type f -name PowerKeeper.apk -print0)
(( ${#apks[@]} == 1 )) || { error "ZK PowerKeeper requires one original APK"; exit 1; }
apk="${apks[0]}"
badging="$(aapt dump badging "$apk")"
grep -Fq "package: name='com.miui.powerkeeper' versionCode='40200'" <<< "$badging" || exit 1
grep -Fq "sdkVersion:'36'" <<< "$badging" || exit 1
tmp="$(mktemp -d "$w/zk304-powerkeeper.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/eu" "$tmp/zk" "$report"
python3 "$cn/preserve_powerkeeper_identity.py" --check-base --apk "$apk" --reference "$apk" \
  --apksigner "$w/bin/apktool/apksigner.jar" --report "$report/stock.json"
unzip -p "$apk" classes.dex > "$tmp/eu.dex"
zstd -d -q -f "$archive" -o "$tmp/zk.dex"
python3 - "$tmp/zk.dex" "$manifest" <<'PY'
import hashlib,json,sys
from pathlib import Path
expected=json.loads(Path(sys.argv[2]).read_text())["files"]["classes.dex"]
assert hashlib.sha256(Path(sys.argv[1]).read_bytes()).hexdigest()==expected
PY
java -jar "$w/bin/apktool/baksmaliv2.jar" d --api 36 "$tmp/eu.dex" -o "$tmp/eu" >/dev/null
java -jar "$w/bin/apktool/baksmaliv2.jar" d --api 36 "$tmp/zk.dex" -o "$tmp/zk" >/dev/null
python3 "$d/zk304_powerkeeper_port_a16.py" \
  --eu "$tmp/eu" --zk "$tmp/zk" --report "$report/methods.json"
java -jar "$w/bin/apktool/smaliv2.jar" a --api 36 "$tmp/eu" -o "$tmp/classes.dex" >/dev/null
java -jar "$w/bin/apktool/baksmaliv2.jar" d --api 36 "$tmp/classes.dex" \
  -o "$tmp/verified" >/dev/null
! grep -R -F -q 'Lmiui/zk/Build;->IS_ZK_BUILD:Z' "$tmp/verified" || exit 1
python3 "$cn/powerkeeper.py" prepare-donor --stock-apk "$apk" \
  --dex-file "$tmp/classes.dex" --output "$tmp/wrapper.apk"
python3 "$cn/preserve_powerkeeper_identity.py" --base "$apk" --patched "$tmp/wrapper.apk" \
  --reference "$apk" --apksigner "$w/bin/apktool/apksigner.jar" \
  --apk "$tmp/preserved.apk" --report "$report/metadata.json"
zipalign -p -f 4 "$tmp/preserved.apk" "$tmp/aligned.apk"
zipalign -c -p 4 "$tmp/aligned.apk"
python3 "$cn/preserve_powerkeeper_identity.py" --apk "$tmp/aligned.apk" \
  --reference "$apk" --report "$report/final.json"
python3 - "$tmp/aligned.apk" "$tmp/classes.dex" <<'PY'
import sys,zipfile
from pathlib import Path
with zipfile.ZipFile(sys.argv[1]) as z:
    assert not z.testzip()
    assert z.read("classes.dex")==Path(sys.argv[2]).read_bytes()
PY
cp -f "$tmp/aligned.apk" "$apk"
rm -rf "$(dirname "$apk")/oat"
mods "EU: ZK304 PowerKeeper policies merged into EU APK; EU ABI kept; original APK signature invalid"
