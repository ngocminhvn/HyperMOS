#!/usr/bin/env bash
# Patch the Xiaomi SecurityCenter APK extracted from the downloaded base ROM.
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
source "$work_dir/bin/modfile/OS3/_common.sh"

tool_dir="$work_dir/bin/modfile/OS3"
tmp="$work_dir/apk_temp/securitycenter-countdown"
report_dir="$work_dir/build/reports/securitycenter"
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
mkdir -p "$tmp" "$report_dir"
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

python3 "$tool_dir/securitycenter_countdown.py" apply \
  --decoded "$tmp/raw" --report "$tmp/patch.json"
python3 "$tool_dir/securitycenter_countdown.py" verify --decoded "$tmp/raw"

"${apkeditor[@]}" b -t raw -f -i "$tmp/raw" -o "$tmp/SecurityCenter.apk" >/dev/null
unzip -tqq "$tmp/SecurityCenter.apk" || {
  error "SecurityCenter countdown: rebuilt APK archive is corrupt"
  exit 1
}
python3 "$tool_dir/securitycenter_countdown.py" compare \
  --base "$stock_apk" --apk "$tmp/SecurityCenter.apk" \
  --report "$tmp/apk-content.json"

# Verify the compiled output, not only the editable smali tree.  All five
# countdown classes are expected in the same DEX on supported Xiaomi builds.
target_dex=""
while IFS= read -r dex; do
  if java -jar "$work_dir/bin/apktool/baksmaliv2.jar" list classes \
      "$tmp/SecurityCenter.apk/$dex" 2>/dev/null \
      | grep -Fxq 'Lcom/miui/permcenter/privacymanager/InterceptPermissionFragment;'; then
    target_dex="$dex"
    break
  fi
done < <(unzip -Z1 "$tmp/SecurityCenter.apk" | grep -E '^classes([2-9]|[1-9][0-9]+)?\.dex$')
[[ -n "$target_dex" ]] || {
  error "SecurityCenter countdown: patched classes absent from rebuilt DEX"
  exit 1
}
target_classes='Lcom/miui/permcenter/privacymanager/InterceptPermissionFragment;,Lcom/miui/permcenter/install/AdbInputApplyActivity;,Lcom/miui/permcenter/install/AdbInputApplyActivity$a;,Lcom/miui/permcenter/install/AdbInstallActivity;,Lcom/miui/permcenter/install/AdbInstallActivity$a;'
java -jar "$work_dir/bin/apktool/baksmaliv2.jar" d \
  --api "$(tr -d '\r\n' < "$work_dir/bin/ddevice/sdkLevel.txt")" \
  --classes "$target_classes" "$tmp/SecurityCenter.apk/$target_dex" \
  -o "$tmp/compiled-check" >/dev/null
python3 "$tool_dir/securitycenter_countdown.py" verify --decoded "$tmp/compiled-check"

rebuilt_package=$(modscenter_apk_package "$tmp/SecurityCenter.apk" || true)
[[ "$rebuilt_package" == "$stock_package" ]] || {
  error "SecurityCenter countdown: rebuilt package identity changed"
  exit 1
}

# APKEditor restores Xiaomi's V2/V3 signer block exactly like the ZKOS mod.
# DEX changes intentionally invalidate its integrity digest; CorePatch handles
# that ROM policy.  Never describe this output as cryptographically Xiaomi-signed.
cp -f "$tmp/patch.json" "$report_dir/countdown-patch.json"
cp -f "$tmp/apk-content.json" "$report_dir/apk-content.json"
sha256sum "$stock_apk" | awk '{print $1}' > "$report_dir/stock-sha256.txt"
sha256sum "$tmp/SecurityCenter.apk" | awk '{print $1}' > "$report_dir/patched-sha256.txt"
printf '%s\n' "$stock_cert" > "$report_dir/source-certificate-sha256.txt"
printf '%s\n' 'xiaomi-v2-v3-block-preserved-integrity-invalid-corepatch-required' \
  > "$report_dir/signature-mode.txt"

cp -f "$tmp/SecurityCenter.apk" "$stock_apk"
rm -rf "$(dirname "$stock_apk")/oat"
chmod 0644 "$stock_apk" 2>/dev/null || true
mods "Security Center: stock ROM APK patched to 0-second confirmations -> Done"
patch "Security Center: Xiaomi signer block preserved in ZKOS-style invalid-integrity mode"
