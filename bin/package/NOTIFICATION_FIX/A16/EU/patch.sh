#!/usr/bin/env bash
# Xiaomi.eu A16 policy from Global303: scoped miui-services + PowerKeeper.
set -euo pipefail
w="$(pwd)"
source "$w/functions.sh"
base="$w/bin/package/NOTIFICATION_FIX/A16/EU"
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/rom_source.txt")" == xiaomi_eu ]] || { error "Global A16: Xiaomi.eu required"; exit 1; }
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/androidver.txt")" == 16 ]] || { error "Global A16: Android 16 required"; exit 1; }
source "$w/bin/package/COREPATCH/helper.sh"
WORK_DIR="$w"
TOOLS_DIR="$w/bin/apktool"
API_LEVEL=36
jar="$w/build/baserom/images/system_ext/framework/miui-services.jar"
decoded="$w/miui-services_decompile"
output="$w/miui-services_patched.jar"
[[ -s "$jar" ]] || { error "Global A16: miui-services.jar missing"; exit 1; }
[[ -s "$base/global-battery.smali" ]] || { error "Global A16: pinned battery donor missing"; exit 1; }
init_env
ensure_tools
zk_work="$(mktemp -d "$w/a16-zk-jar.XXXXXX")"
trap 'rm -rf "$decoded" "$w/miui-services" "$output" "$zk_work"' EXIT
decompile_jar "$jar" >/dev/null
python3 "$base/jar_port.py" "$decoded" "$base/global-battery.smali" \
  --report "$w/build/reports/global-a16/miui-battery.json"
# Scoped FCM exception from the legacy EU patch (not wholesale ZK Greeze).
# Allow Play Services C2DM receive through isAllowBroadcast; all other
# freeze, thaw, cache, UID and region checks remain EU-original.
python3 "$base/fcm_greeze.py" "$decoded" \
  --report "$w/build/reports/global-a16/fcm-greeze.json"
# Single-build ZK304 targeted Greeze important-app cache behavior.
zk_archive="$base/backupzk.zip"
zk_prefix="bin/package/NOTIFICATION_FIX/A16/EU/ZK304"
[[ -s "$zk_archive" ]] && unzip -tq "$zk_archive" >/dev/null || {
  error "ZK304 verified donor archive missing or corrupt"; exit 1;
}
unzip -p "$zk_archive" "$zk_prefix/zk304-miui-services.jar.zst" | zstd -d -q -c > "$zk_work/zk.jar"
python3 - "$zk_archive" "$zk_work/zk.jar" "$zk_prefix" <<'PYZK'
import hashlib,json,sys,zipfile
from pathlib import Path
with zipfile.ZipFile(sys.argv[1]) as z:
    manifest=json.loads(z.read(sys.argv[3]+'/manifest.json'))
actual=hashlib.sha256(Path(sys.argv[2]).read_bytes()).hexdigest()
assert actual == manifest['files']['miui-services.jar'], "ZK304 donor JAR SHA mismatch"
PYZK
mkdir -p "$zk_work/raw" "$zk_work/decoded"
unzip -q "$zk_work/zk.jar" 'classes*.dex' -d "$zk_work/raw"
for dex in "$zk_work/raw"/classes*.dex; do
  [[ -s "$dex" ]] || { error "ZK304 donor JAR DEX absent"; exit 1; }
  stem="$(basename "$dex" .dex)"
  group=smali
  [[ "$stem" == classes ]] || group="smali_${stem}"
  java -jar "$TOOLS_DIR/baksmaliv2.jar" d --api "$API_LEVEL" "$dex" -o "$zk_work/decoded/$group" >/dev/null
done
cp -a "$decoded" "$zk_work/eu-before-zk"
python3 "$base/port_zk_selected_a16.py" --component jar --eu-root "$decoded" \
  --donor-root "$zk_work/decoded" --report "$w/build/reports/global-a16/zk-important-apps.json"
recompile_jar "$jar" >/dev/null
mkdir -p "$zk_work/rebuilt-dex" "$zk_work/verified"
unzip -q "$output" 'classes*.dex' -d "$zk_work/rebuilt-dex"
for dex in "$zk_work/rebuilt-dex"/classes*.dex; do
  [[ -s "$dex" ]] || { error "Rebuilt EU JAR DEX absent"; exit 1; }
  stem="$(basename "$dex" .dex)"
  group=smali
  [[ "$stem" == classes ]] || group="smali_${stem}"
  java -jar "$TOOLS_DIR/baksmaliv2.jar" d --api "$API_LEVEL" "$dex" -o "$zk_work/verified/$group" >/dev/null
done
python3 "$base/port_zk_selected_a16.py" --component jar --eu-root "$zk_work/verified" \
  --donor-root "$zk_work/decoded" --verify-original "$zk_work/eu-before-zk"
[[ -s "$output" ]] && unzip -t "$output" >/dev/null || {
  error "Global A16: rebuilt JAR invalid"; exit 1;
}
mv -f "$output" "$jar"
mods "[GLOBAL A16] miui-services.jar: three battery methods + MAP_APP + scoped GMS FCM broadcast allow"
bash "$base/PowerKeeper.sh"
