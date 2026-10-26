#!/usr/bin/env bash
# Xiaomi.eu A16: preserve Global303-equivalent stock broadcast, Greeze and wakelock methods.
# Audited EU309 vs DADA Global303: the targeted native DEX methods are equivalent.
# Do not add the older HyperMOS FCM/autostart/wakelock exceptions.
set -euo pipefail
w="$(pwd)"
source "$w/functions.sh"
base="$w/bin/package/NOTIFICATION_FIX/A16/EU"
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/rom_source.txt")" == xiaomi_eu ]] || { error "EU Global-aligned policy requires Xiaomi.eu"; exit 1; }
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/androidver.txt")" == 16 ]] || { error "EU Global-aligned policy requires Android 16"; exit 1; }

# ContentCatcher is an independent non-notification change already in main.
# Retain it without affecting Global-equivalent notification / power methods.
source "$w/bin/package/COREPATCH/helper.sh"
WORK_DIR="$w"
TOOLS_DIR="$w/bin/apktool"
API_LEVEL=36
jar="$w/build/baserom/images/system_ext/framework/miui-services.jar"
decoded="$w/miui-services_decompile"
output="$w/miui-services_patched.jar"
manifest="$base/ryu_policy.json"
[[ -s "$jar" && -s "$manifest" && -s "$base/ryu_policy.py" ]] || { error "EU policy inputs missing"; exit 1; }
init_env
ensure_tools
tmp="$(mktemp -d "$w/eu-global.XXXXXX")"
trap 'rm -rf "$decoded" "$w/miui-services" "$output" "$tmp"' EXIT

decompile_jar "$jar" >/dev/null
python3 "$base/ryu_policy.py" --root "$decoded" --manifest "$manifest" \
  --group miui-services --report "$w/build/reports/eu-global/independent-methods.json"

# Stock EU309 equals Global303 at the audited FCM and power sites:
# BroadcastQueueModernStubImpl.checkApplicationAutoStart
# GreezeManagerService.isAllowBroadcast / isRestrictReceiver
# PowerManagerServiceImpl.isWakelockDisabledByPolicy
# PowerManagerServiceImpl.setUidPartialWakeLockDisabledState (both overloads)
# Also audited: GreezeManagerService.freezeUids / freezeAction and
# DeviceIdleControllerStubImpl.isLowPowerDozeEnable.
# Preserve original implementations instead of patching them.

recompile_jar "$jar" >/dev/null
[[ -s "$output" ]] && unzip -t "$output" >/dev/null || { error "EU Global-aligned rebuilt JAR invalid"; exit 1; }
mkdir -p "$tmp/raw" "$tmp/decoded"
unzip -q "$output" 'classes*.dex' -d "$tmp/raw"
for dex in "$tmp/raw"/classes*.dex; do
  [[ -s "$dex" ]] || { error "EU Global-aligned DEX missing"; exit 1; }
  stem="$(basename "$dex" .dex)"
  group=smali
  [[ "$stem" == classes ]] || group="smali_$(echo "$stem" | sed 's/^classes_//')"
  java -jar "$TOOLS_DIR/baksmaliv2.jar" d --api "$API_LEVEL" "$dex" -o "$tmp/decoded/$group" >/dev/null
done
python3 "$base/ryu_policy.py" --root "$tmp/decoded" --manifest "$manifest" \
  --group miui-services --verify --report "$w/build/reports/eu-global/independent-verified.json"
mv -f "$output" "$jar"
mods "[EU A16] Global303-equivalent stock broadcast/Greeze/wakelock JAR methods preserved"
# Port only the four EU-vs-Global cloud/region differences in PowerKeeper.
# Do not add GMS/FCM wakelock bypasses or replace donor APKs.
bash "$base/PowerKeeper.sh"
mods "[EU A16] Global303 cloud endpoint/region policy; GMS/Doze/thermal/process cleanup left EU-stock"
