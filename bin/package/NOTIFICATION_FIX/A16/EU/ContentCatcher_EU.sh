#!/usr/bin/env bash
# Xiaomi.eu A16-only; no China notification/PowerKeeper transplantation.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
source "$work_dir/bin/package/COREPATCH/helper.sh"
WORK_DIR="$work_dir"
TOOLS_DIR="$work_dir/bin/apktool"
API_LEVEL=36
if [[ ! -s "$work_dir/bin/ddevice/rom_source.txt" ]] ||
   [[ "$(tr -d '\r\n' < "$work_dir/bin/ddevice/rom_source.txt")" != "xiaomi_eu" ]] ||
   [[ ! -s "$work_dir/bin/ddevice/androidver.txt" ]] ||
   [[ "$(tr -d '\r\n' < "$work_dir/bin/ddevice/androidver.txt")" != "16" ]]; then
    exit 0
fi
jar="$work_dir/build/baserom/images/system_ext/framework/miui-services.jar"
decoded="$work_dir/miui-services_decompile"
output="$work_dir/miui-services_patched.jar"
report="$work_dir/build/reports/frameworkpatcher-a16/eu-contentcatcher.json"
[[ -s "$jar" ]] || { echo "[EU CONTENTCATCHER A16] missing miui-services.jar" >&2; exit 1; }
init_env
ensure_tools
trap 'rm -rf "$decoded" "$work_dir/miui-services" "$output"' EXIT
decompile_jar "$jar" >/dev/null
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/EU/contentcatcher_eu_a16.py" \
    "$decoded" --report "$report"
# Verify donor-identical native region/build gates; never force a constant.
# Any explicit donor IS_ZK_BUILD reference maps to native IS_INTERNATIONAL_BUILD.
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/EU/eu_zk_broadcast_greeze_parity_a16.py" \
    "$decoded" --report "$work_dir/build/reports/frameworkpatcher-a16/eu-zk-broadcast-greeze-parity.json"
# Use the original, SHA-pinned ZK304 donor for exact static-policy parity.
# Keep the EU-only Greeze/PowerKeeper API and method layout intact.
zk_tmp="$(mktemp -d "$work_dir/zk304-notification.XXXXXX")"
cleanup_zk() { rm -rf "$zk_tmp"; }
trap 'rm -rf "$decoded" "$work_dir/miui-services" "$output"; cleanup_zk' EXIT
zk_dir="$work_dir/bin/package/NOTIFICATION_FIX/A16/EU/ZK304"
zk_archive="$zk_dir/zk304-miui-services.jar.zst"
[[ -s "$zk_archive" && -s "$zk_dir/manifest.json" ]] || {
    error "ZK304: verified EU donor archive/manifest missing"
    exit 1
}
zstd -q -d -f "$zk_archive" -o "$zk_tmp/zk304.jar"
python3 - "$zk_tmp/zk304.jar" "$zk_dir/manifest.json" <<'PYZKSHA'
import hashlib, json, sys
from pathlib import Path
donor, manifest = (Path(p) for p in sys.argv[1:])
expected = json.loads(manifest.read_text())["files"]["miui-services.jar"]
if hashlib.sha256(donor.read_bytes()).hexdigest() != expected:
    raise SystemExit("ZK304: donor JAR SHA-256 does not match pinned manifest")
PYZKSHA
mkdir -p "$zk_tmp/decoded"
unzip -q "$zk_tmp/zk304.jar" 'classes*.dex' -d "$zk_tmp/decoded"
for dex in "$zk_tmp/decoded"/classes*.dex; do
    [ -s "$dex" ] || { error "ZK304: donor DEX missing"; exit 1; }
    name="$(basename "$dex" .dex)"
    smali="smali"
    [[ "$name" == "classes" ]] || smali="smali_$name"
    java -jar "$TOOLS_DIR/baksmaliv2.jar" d --api "$API_LEVEL" "$dex" \
        -o "$zk_tmp/decoded/$smali" >/dev/null
done
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/EU/zk304_notification_policy_a16.py" \
    "$decoded" "$zk_tmp/decoded" \
    --report "$work_dir/build/reports/frameworkpatcher-a16/eu-zk304-notification-policy.json"
recompile_jar "$jar" >/dev/null
if [[ ! -s "$output" ]] || ! unzip -t "$output" >/dev/null 2>&1; then
    echo "[EU CONTENTCATCHER A16] rebuilt JAR invalid" >&2
    exit 1
fi
mv -f "$output" "$jar"
log "[EU A16] ContentCatcher + pinned-ZK304 NotificationManager static policy + Greeze gate parity"
