#!/usr/bin/env bash
# One A16 driver and JAR lifecycle; independent CN/EU policy patchers.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
base="$work_dir/bin/package/NOTIFICATION_FIX/A16"
identity="$work_dir/bin/ddevice/rom_source.txt"
version="$work_dir/bin/ddevice/androidver.txt"
[[ -s "$identity" && -s "$version" ]] || { error "A16 Notification: ROM identity/version missing"; exit 1; }
rom_source="$(tr -d '\r\n' < "$identity")"
android_ver="$(tr -d '\r\n' < "$version")"
[[ "$android_ver" == "16" ]] || { error "A16 Notification: refused Android $android_ver"; exit 1; }
case "$rom_source" in
  china|xiaomi_eu) ;;
  *) error "A16 Notification: unsupported ROM source $rom_source"; exit 1 ;;
esac

source "$work_dir/bin/package/COREPATCH/helper.sh"
WORK_DIR="$work_dir"
TOOLS_DIR="$work_dir/bin/apktool"
API_LEVEL=36
jar="$work_dir/build/baserom/images/system_ext/framework/miui-services.jar"
decoded="$work_dir/miui-services_decompile"
output="$work_dir/miui-services_patched.jar"
[[ -s "$jar" ]] || { error "A16 Notification: miui-services.jar missing"; exit 1; }
init_env
ensure_tools
zk_tmp=""
trap 'rm -rf "$decoded" "$work_dir/miui-services" "$output"; if [[ -n "$zk_tmp" ]]; then rm -rf "$zk_tmp"; fi' EXIT
decompile_jar "$jar" >/dev/null

if [[ "$rom_source" == "china" ]]; then
  report="$work_dir/build/reports/frameworkpatcher-a16/notification-gates.json"
  python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/CN/frameworkpatcher_cn_a16.py" \
    "$decoded" --report "$report"
else
  report="$work_dir/build/reports/frameworkpatcher-a16/eu-contentcatcher.json"
  python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/EU/contentcatcher_eu_a16.py" \
      "$decoded" --report "$report"
  # Verify donor-identical native region/build gates; never force a constant.
  # Any explicit donor IS_ZK_BUILD reference maps to native IS_INTERNATIONAL_BUILD.
  python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/EU/eu_zk_broadcast_greeze_parity_a16.py" \
      "$decoded" --report "$work_dir/build/reports/frameworkpatcher-a16/eu-zk-broadcast-greeze-parity.json"
  # Use the original, SHA-pinned ZK304 donor for exact static-policy parity.
  # Keep the EU-only Greeze/PowerKeeper API and method layout intact.
  zk_tmp="$(mktemp -d "$work_dir/zk304-notification.XXXXXX")"
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
  # Port the actual ZK304 Greeze freeze/thaw, broadcast and Doze methods.
  # Preserve Xiaomi.eu-specific constructors, callbacks and class ABI.
  # Unexpected methods or references are hard errors; never guess a port.
  python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/EU/zk304_greeze_policy_port_a16.py" \
      "$decoded" "$zk_tmp/decoded" \
      --report "$work_dir/build/reports/frameworkpatcher-a16/eu-zk304-greeze-doze.json"
fi

recompile_jar "$jar" >/dev/null
if [[ ! -s "$output" ]] || ! unzip -t "$output" >/dev/null 2>&1; then
  error "A16 Notification: invalid rebuilt miui-services.jar ($rom_source)"
  exit 1
fi
mv -f "$output" "$jar"
if [[ "$rom_source" == "china" ]]; then
  log "[FRAMEWORKPATCHER A16] CN notification port complete (CorePatch / EU filter unchanged)"
  bash "$base/CN/PowerKeeper.sh"
else
  log "[EU A16] ContentCatcher + pinned ZK304 NotificationManager, Greeze freeze/thaw and Doze method ports"
  # The EU 61-method ZK304 PowerKeeper port is still intentionally disabled.
  info "EU ZK304 PowerKeeper APK port: temporarily disabled (keeping #181 behavior)"
fi
