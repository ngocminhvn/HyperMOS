#!/usr/bin/env bash
# Port Global303's seven audited method bodies into original EU PowerKeeper.
# Preserve EU classes/fields, manifest, assets, JNI and META-INF; no signing.
set -euo pipefail
w="$(pwd)"
source "$w/functions.sh"
base="$w/bin/package/NOTIFICATION_FIX/A16/EU"
meta_tool="$w/bin/package/NOTIFICATION_FIX/A16/EU/eu_powerkeeper_keep_metadata.py"
images="$w/build/baserom/images"
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/rom_source.txt")" == "xiaomi_eu" ]] || { error "Global A16 EU only"; exit 1; }
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/androidver.txt")" == "16" ]] || { error "Global A16 Android 16 only"; exit 1; }
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/sdkLevel.txt")" == "36" ]] || { error "Global A16 SDK 36 only"; exit 1; }
for tool in python3 unzip zipalign zstd aapt java; do
  command -v "$tool" >/dev/null || { error "Global A16 missing $tool"; exit 1; }
done
count="$(find "$images" -type f -name PowerKeeper.apk | wc -l)"
[[ "$count" == "1" ]] || { error "Global A16 requires one PowerKeeper.apk, found $count"; exit 1; }
apk="$(find "$images" -type f -name PowerKeeper.apk -print -quit)"
badging="$(aapt dump badging "$apk")"
grep -Fq "package: name='com.miui.powerkeeper' versionCode='40200'" <<< "$badging" || {
  error "Global A16: wrong PowerKeeper package/version"; exit 1;
}
grep -Fq "sdkVersion:'36'" <<< "$badging" || { error "Global A16: wrong minSdk"; exit 1; }
baksmali="$w/bin/apktool/baksmaliv2.jar"
smali="$w/bin/apktool/smaliv2.jar"
[[ -s "$baksmali" && -s "$smali" ]] || { error "Global A16 missing smali tools"; exit 1; }
report="$w/build/reports/global-a16"
mkdir -p "$report"
tmp="$(mktemp -d "$w/global303-eu-methods.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT
archive="$base/global-powerkeeper.dex.zst"
if [[ -s "$archive" ]]; then
  zstd -q -d -f "$archive" -o "$tmp/global.dex"
else
  python3 "$base/fetch_donor.py" "$tmp/global.dex"
fi
unzip -p "$apk" classes.dex > "$tmp/eu.dex"
python3 - "$tmp/eu.dex" "$tmp/global.dex" "$w/bin/package/NOTIFICATION_FIX/A16/CN" <<'PY'
import hashlib, sys
from pathlib import Path
eu_file, glo_file, scripts = map(Path, sys.argv[1:])
sys.path.insert(0, str(scripts))
from eu_scoped_gates import Dex
assert hashlib.sha256(glo_file.read_bytes()).hexdigest() == '21c20b3ddbaab981276bab60ab6c2a0f62587ea6d87b84bc54aa33def6df25bf', 'Global donor SHA256'
eu, glo = Dex(eu_file.read_bytes()), Dex(glo_file.read_bytes())
eu_only = {('Landroid/miui/AppOpsUtils;', 'isXOptMode', '()Z')}
if not (len(eu.codes) == len(glo.codes) == 17818
        and eu.codes.keys() == glo.codes.keys()
        and set(eu.fields) == set(glo.fields)
        and set(glo.methods).issubset(set(eu.methods))
        and set(eu.methods) - set(glo.methods) == eu_only):
    raise SystemExit('Global303/EU original DEX ABI mismatch')
print('[GLOBAL A16] original EU/Global303 DEX ABI matched')
PY
java -jar "$baksmali" d --api 36 "$tmp/eu.dex" -o "$tmp/eu" >/dev/null
java -jar "$baksmali" d --api 36 "$tmp/global.dex" -o "$tmp/global" >/dev/null
cp -a "$tmp/eu" "$tmp/eu-original"
python3 "$base/port_global_powerkeeper.py" --eu "$tmp/eu" --global-donor "$tmp/global" \
  --report "$report/ported-methods.json"
python3 "$base/port_global_powerkeeper.py" --eu "$tmp/eu" \
  --global-donor "$tmp/global" --verify-original "$tmp/eu-original"
cp -a "$tmp/eu" "$tmp/eu-after-global"
# One EU build: Global303 battery methods plus selected ZK304 GMS/Millet policy.
zk_archive="$base/backupzk.zip"
zk_prefix="bin/package/NOTIFICATION_FIX/A16/EU/ZK304"
[[ -s "$zk_archive" ]] && unzip -tq "$zk_archive" >/dev/null || {
  error "ZK304 verified donor archive missing or corrupt"; exit 1;
}
unzip -p "$zk_archive" "$zk_prefix/zk304-powerkeeper.dex.zst" | zstd -d -q -c > "$tmp/zk.dex"
python3 - "$zk_archive" "$tmp/zk.dex" "$zk_prefix" <<'PYZK'
import hashlib,json,sys,zipfile
from pathlib import Path
with zipfile.ZipFile(sys.argv[1]) as z:
    manifest=json.loads(z.read(sys.argv[3]+'/manifest.json'))
actual=hashlib.sha256(Path(sys.argv[2]).read_bytes()).hexdigest()
assert actual == manifest['files']['classes.dex'], "ZK304 donor PowerKeeper DEX SHA mismatch"
PYZK
java -jar "$baksmali" d --api 36 "$tmp/zk.dex" -o "$tmp/zk" >/dev/null
python3 "$base/port_zk_selected_a16.py" --component power --eu-root "$tmp/eu" \
  --donor-root "$tmp/zk" --report "$report/zk-gms-millet.json"
java -jar "$smali" a --api 36 "$tmp/eu" -o "$tmp/merged.dex" >/dev/null
java -jar "$baksmali" d --api 36 "$tmp/merged.dex" -o "$tmp/verified" >/dev/null
python3 "$base/port_zk_selected_a16.py" --component power --eu-root "$tmp/verified" \
  --donor-root "$tmp/zk" --verify-original "$tmp/eu-after-global"
python3 "$meta_tool" --base "$apk" --dex "$tmp/merged.dex" \
  --output "$tmp/preserved.apk" --report "$report/preserve-metadata.json"
zipalign -p -f 4 "$tmp/preserved.apk" "$tmp/aligned.apk"
zipalign -c -p 4 "$tmp/aligned.apk"
python3 "$meta_tool" --base "$apk" --dex "$tmp/merged.dex" \
  --output "$tmp/aligned.apk" --verify-only
cp -f "$tmp/aligned.apk" "$apk"
rm -rf "$(dirname "$apk")/oat"
mods "[EU A16] 7 Global303 PowerKeeper methods plus guarded ZK304 GmsObserver/ActiveStateController; no signing"
