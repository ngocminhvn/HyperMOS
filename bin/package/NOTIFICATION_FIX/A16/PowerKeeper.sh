#!/usr/bin/env bash
# HAOTIAN Android 16: retain original Xiaomi-signed PowerKeeper unchanged.
# RYU notification policy lives in the independently patched framework.
# RYU CPU/powerhint/thermal configuration is installed by RYUPerfProfile.
# No bytecode rewrite, testkey, root hook, polling worker or resident daemon.
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
images="$work_dir/build/baserom/images"
signer="$work_dir/bin/apktool/apksigner.jar"
expected_cert="c9009d01ebf9f5d0302bc71b2fe9aa9a47a432bba17308a3111b75d7b2149025"

mapfile -d '' apks < <(find "$images" -type f -name PowerKeeper.apk -print0)
(( ${#apks[@]} == 1 )) || {
  error "PowerKeeper: expected exactly one original APK, found ${#apks[@]}"
  exit 1
}
apk="${apks[0]}"
[[ -s "$apk" && -s "$signer" ]] || {
  error "PowerKeeper: missing stock APK or apksigner"
  exit 1
}

# Android 16 must verify the actual APK bytes; certificate copying alone
# cannot restore a Xiaomi signature after an APK is modified.
signature_output="$(java -jar "$signer" verify --verbose --print-certs \
  --min-sdk-version 36 "$apk")" || {
  error "PowerKeeper: Xiaomi stock APK signature verification failed"
  exit 1
}
printf '%s\n' "$signature_output" |
  grep -Eq '^Verified using v[23] scheme \(APK Signature Scheme v[23]\): true' || {
  error "PowerKeeper: no valid APK signature scheme v2/v3"
  exit 1
}
actual_cert="$(printf '%s\n' "$signature_output" |
  sed -n 's/^Signer #1 certificate SHA-256 digest: //p' |
  head -n 1 | tr -d ':' | tr '[:upper:]' '[:lower:]')"
[[ -n "$actual_cert" && "$actual_cert" == "$expected_cert" ]] || {
  error "PowerKeeper: unexpected signer ($actual_cert), refusing to package system UID app"
  exit 1
}
package="$(aapt dump badging "$apk" |
  sed -n "s/^package: name='\([^']*\)'.*/\1/p" | head -n 1)" || {
  error "PowerKeeper: aapt failed to read original APK"
  exit 1
}
[[ "$package" == "com.miui.powerkeeper" ]] || {
  error "PowerKeeper: unexpected package $package"
  exit 1
}

report="$work_dir/build/reports/powerkeeper-a16"
mkdir -p "$report"
hash="$(sha256sum "$apk" | awk '{print $1}')"
printf '{"mode":"xiaomi-stock-unchanged","package":"%s","sha256":"%s","certificate_sha256":"%s","ryu_apk_bytecode":"not_applied"}\n' \
  "$package" "$hash" "$actual_cert" > "$report/stock-identity.json"

mods "PowerKeeper A16: Xiaomi stock verified (V2/V3, cert=$actual_cert)"
mods "RYU notification fix stays in framework; RYU perf/CPU/thermal stays in RYUPerfProfile"
patch "PowerKeeper A16 stock retained: no APK rewriting or runtime hooking"
