#!/usr/bin/env bash
# Patch the Xiaomi SecurityCenter APK extracted from the downloaded base ROM.
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
source "$work_dir/bin/modfile/OS3/_common.sh"

tool_dir="$work_dir/bin/modfile/OS3"
tmp="$work_dir/apk_temp/securitycenter-countdown"
apkeditor=(java -Xmx4g -jar "$work_dir/bin/apktool/apke.jar")
apksigner=(java -jar "$work_dir/bin/apktool/apksigner.jar")
xiaomi_cert="c9009d01ebf9f5d0302bc71b2fe9aa9a47a432bba17308a3111b75d7b2149025"

stock_apk=$(modscenter_find_stock_apk "com.miui.securitycenter" "SecurityCenter") || {
  error "SecurityCenter countdown: stock ROM APK not found uniquely"
  exit 1
}

stock_package=$(modscenter_apk_package "$stock_apk" || true)
[[ "$stock_package" == "com.miui.securitycenter" ]] || {
  error "SecurityCenter countdown: unexpected package ${stock_package:-<unreadable>}"
  exit 1
}

signature_log="$tmp/stock-signature.txt"
rm -rf "$tmp"
mkdir -p "$tmp"
trap 'rm -rf "$tmp"' EXIT
if ! "${apksigner[@]}" verify --verbose --print-certs "$stock_apk" >"$signature_log" 2>&1; then
  error "SecurityCenter countdown: base APK is not a valid signed stock artifact"
  cat "$signature_log" >&2
  exit 1
fi
stock_cert=$(sed -n 's/^Signer #1 certificate SHA-256 digest: //p' "$signature_log" | head -n1 | tr '[:upper:]' '[:lower:]' | tr -d ':')
[[ "$stock_cert" == "$xiaomi_cert" ]] || {
  error "SecurityCenter countdown: stock signer is not the expected Xiaomi certificate"
  exit 1
}

mods "Security Center: decoding stock ROM APK for zero-countdown patch"
"${apkeditor[@]}" d -t raw -f -no-dex-debug \
  -i "$stock_apk" -o "$tmp/raw" >/dev/null

find "$tmp/raw/signatures" -type f -name '*.signature.info.bin' -print -quit | grep -q . || {
  error "SecurityCenter countdown: APKEditor did not retain the Xiaomi signing block"
  exit 1
}

python3 "$tool_dir/securitycenter_countdown.py" "$tmp/raw"

"${apkeditor[@]}" b -t raw -f -i "$tmp/raw" -o "$tmp/SecurityCenter.apk" >/dev/null

rebuilt_package=$(modscenter_apk_package "$tmp/SecurityCenter.apk" || true)
[[ "$rebuilt_package" == "$stock_package" ]] || {
  error "SecurityCenter countdown: rebuilt package identity changed"
  exit 1
}

# APKEditor restores Xiaomi's V2/V3 signer block exactly like the ZKOS mod.
# DEX changes intentionally invalidate its integrity digest; CorePatch handles
# that ROM policy.  Never describe this output as cryptographically Xiaomi-signed.
cp -f "$tmp/SecurityCenter.apk" "$stock_apk"
rm -rf "$(dirname "$stock_apk")/oat"
chmod 0644 "$stock_apk" 2>/dev/null || true
mods "Security Center: stock ROM APK patched to 0-second confirmations -> Done"
patch "Security Center: Xiaomi signer block preserved in ZKOS-style invalid-integrity mode"
