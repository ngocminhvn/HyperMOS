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

# EU Android 16: retain original EU Greeze/Doze/Broadcast policies,
# port selected Global303 battery/PowerKeeper methods and a narrowly-scoped
# Play Services FCM exception. Do not transplant whole ZK304 Greeze classes.
# Historical ZK304 policy is retained only in EU/backupzk.zip.
if [[ "$rom_source" == "xiaomi_eu" ]]; then
  log "[GLOBAL A16] selective EU battery + FCM Greeze exception (no wholesale ZK port)"
  bash "$base/EU/patch.sh" || exit 1
  exit 0
fi

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
  python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/EU/verify_broadcast_greeze_a16.py" \
      "$decoded" --report "$work_dir/build/reports/frameworkpatcher-a16/eu-zk-broadcast-greeze-parity.json"
  # Use the original, SHA-pinned ZK304 donor for exact static-policy parity.
  # Keep the EU-only Greeze/PowerKeeper API and method layout intact.
  zk_tmp="$(mktemp -d "$work_dir/zk304-notification.XXXXXX")"
  zk_dir="$base/EU/class/miui-services"
zk_manifest="$base/EU/class/manifest.json"
[[ -s "$zk_manifest" ]] || { error "ZK304 class manifest missing"; exit 1; }
mkdir -p "$zk_tmp/decoded"
python3 - "$zk_dir" "$zk_manifest" "$zk_tmp/decoded" <<'PYZKSHA'
import hashlib,json,re,sys
from pathlib import Path
src,manifest,out=(Path(p) for p in sys.argv[1:])
expected=json.loads(manifest.read_text(encoding="utf-8"))["files"]
files={p.name for p in src.glob("classes*.dex") if re.fullmatch(r"classes\d*\.dex",p.name)}
names={k.removeprefix("miui-services/") for k in expected if k.startswith("miui-services/")}
if not names or names!=files:raise SystemExit("Donor DEX list changed")
for n in sorted(names):
    data=(src/n).read_bytes()
    if hashlib.sha256(data).hexdigest()!=expected["miui-services/"+n]:
        raise SystemExit("Donor DEX SHA mismatch: "+n)
    (out/n).write_bytes(data)
PYZKSHA
  for dex in "$zk_tmp/decoded"/classes*.dex; do
      [ -s "$dex" ] || { error "A16 donor: donor DEX missing"; exit 1; }
      name="$(basename "$dex" .dex)"
      smali="smali"
      [[ "$name" == "classes" ]] || smali="smali_$name"
      java -jar "$TOOLS_DIR/baksmaliv2.jar" d --api "$API_LEVEL" "$dex" \
          -o "$zk_tmp/decoded/$smali" >/dev/null
  done
  python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/EU/donor_notification_policy_a16.py" \
      "$decoded" "$zk_tmp/decoded" \
      --report "$work_dir/build/reports/frameworkpatcher-a16/eu-donor-notification-policy.json"
  # Port the actual ZK304 Greeze freeze/thaw, broadcast and Doze methods.
  # Preserve Xiaomi.eu-specific constructors, callbacks and class ABI.
  # Unexpected methods or references are hard errors; never guess a port.
  python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/EU/donor_greeze_policy_port_a16.py" \
      "$decoded" "$zk_tmp/decoded" \
      --report "$work_dir/build/reports/frameworkpatcher-a16/eu-donor-greeze-doze.json"
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
  log "[EU A16] ContentCatcher + pinned A16 donor NotificationManager, Greeze freeze/thaw and Doze method ports"
  # Merge compatible ZK304 policy methods into the original Xiaomi.eu APK.
  # PowerKeeper_donor.sh replaces classes.dex only, preserves every original
  # non-DEX/META-INF member byte-for-byte, and never signs the resulting APK.
  bash "$base/EU/PowerKeeper_donor.sh"
fi
