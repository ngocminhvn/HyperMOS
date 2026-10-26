#!/usr/bin/env bash
# HAOTIAN Xiaomi.eu Android 16: method-scoped DADA Global303 == Taiwan303 port.
# No donor JAR copied, no thermal/power-save whitelist or GMS wakelock bypass.
set -euo pipefail
w="$(pwd)"
source "$w/functions.sh"
base="$w/bin/package/NOTIFICATION_FIX/A16/EU"
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/rom_source.txt")" == xiaomi_eu ]] || { error "EU Global/Taiwan gate: wrong ROM source"; exit 1; }
[[ "$(tr -d '\r\n' < "$w/bin/ddevice/androidver.txt")" == 16 ]] || { error "EU Global/Taiwan gate: wrong Android version"; exit 1; }
source "$w/bin/package/COREPATCH/helper.sh"
WORK_DIR="$w"
TOOLS_DIR="$w/bin/apktool"
API_LEVEL=36
init_env
ensure_tools
report="$w/build/reports/global-taiwan-a16"
mkdir -p "$report"
patch_jar() {
  local jar="$1" script="$2" output="$3" title="$4"
  local decoded="$w/$(basename "$jar" .jar)_decompile"
  [[ -s "$jar" ]] || { error "[EU A16] Missing $jar"; return 1; }
  decompile_jar "$jar" >/dev/null
  python3 "$base/$script" --root "$decoded" --report "$report/$title.json"
  recompile_jar "$jar" >/dev/null
  [[ -s "$w/$output" ]] && unzip -tq "$w/$output" >/dev/null || { error "[EU A16] $title invalid rebuilt JAR"; return 1; }
  local verify
  verify="$(mktemp -d "$w/eu-global-verify.XXXXXX")"
  # Independently inspect the reassembled DEX, not only the edited source files.
  unzip -q "$w/$output" 'classes*.dex' -d "$verify"
  mkdir "$verify/smali"
  local dex
  for dex in "$verify"/classes*.dex; do
    [[ -s "$dex" ]] || { error "[EU A16] rebuilt DEX absent"; rm -rf "$verify"; return 1; }
    local name; name="$(basename "$dex" .dex)"
    java -jar "$TOOLS_DIR/baksmaliv2.jar" d --api 36 "$dex" -o "$verify/smali/$name" >/dev/null
  done
  python3 "$base/$script" --root "$verify/smali" --verify --report "$report/$title-verified.json"
  rm -rf "$verify"
  mv -f "$w/$output" "$jar"
  rm -rf "$decoded"
  mods "[EU A16] $title: Global303/Taiwan303 policy matched"
}
patch_jar "$w/build/baserom/images/system_ext/framework/miui-services.jar" \
  appops_global_policy.py miui-services_patched.jar appops
patch_jar "$w/build/baserom/images/system_ext/framework/miui-framework.jar" \
  notification_filter_global.py miui-framework_patched.jar notification-filter
# PowerKeeper: only 4 cloud/region differences. Keep original EU GMS, Millet,
# Doze, thermal, KillProcessController and the 18-app MAP_APP list.
bash "$base/PowerKeeper.sh"
mods "[EU A16] Nine scoped Global303/Taiwan303 differences complete"
