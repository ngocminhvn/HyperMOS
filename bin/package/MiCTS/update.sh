#!/usr/bin/env bash
# MiCTS native CSHelper adapter for HyperOS 3 Android 16.
# Source model: parallelcc/MiCTS. No daemon, timer or framework-wide permission bypass.
set -euo pipefail

root="$(pwd)"
source "$root/functions.sh"
images="$root/build/baserom/images"
android_ver="$(tr -d ' \r\n' < "$root/bin/ddevice/androidver.txt")"
rom_os="$(tr -d ' \r\n' < "$root/bin/ddevice/rom_os.txt")"
tmp="$root/build/micts-native-work"
report="$root/build/reports/micts-native.txt"
baksmali="$root/bin/apktool/baksmaliv2.jar"
apksigner="$root/bin/apktool/apksigner.jar"
key="$root/bin/package/DISABLE_AVB/HMATools/aosp/security/testkey.pk8"
cert="$root/bin/package/DISABLE_AVB/HMATools/aosp/security/testkey.x509.pem"
target="$images/product/overlay/HyperMOSMiCTSOverlay.apk"

if [[ "$android_ver" != "16" || "$rom_os" != "OS3" ]]; then
  info "MiCTS: Android $android_ver / $rom_os -> skipped (OS3/A16 only)"
  exit 0
fi

for tool in aapt java unzip zipalign find grep; do
  command -v "$tool" >/dev/null 2>&1 || { error "MiCTS: missing tool $tool"; exit 1; }
done
for dep in "$baksmali" "$apksigner" "$key" "$cert"; do
  [[ -s "$dep" ]] || { error "MiCTS: missing build payload $dep"; exit 1; }
done

pick_one() {
  local label="$1"; shift
  local -a found=()
  local path
  for path in "$@"; do [[ -f "$path" ]] && found+=("$path"); done
  (( ${#found[@]} == 1 )) || { error "MiCTS: expected 1 $label, found ${#found[@]}"; return 1; }
  printf '%s\n' "${found[0]}"
}

fw_res="$(pick_one framework-res.apk \
  "$images/system/system/framework/framework-res.apk" \
  "$images/system/framework/framework-res.apk")"
services="$(pick_one services.jar \
  "$images/system/system/framework/services.jar" \
  "$images/system/framework/services.jar")"
[[ -s "$fw_res" && -s "$services" ]] || { error "MiCTS: framework input missing"; exit 1; }

# The existing AOSP CSHelper must be present; never silently install an inert RRO.
rm -rf "$tmp"
mkdir -p "$tmp/dex" "$tmp/smali" "$(dirname "$report")"
trap 'rm -rf "$tmp"' EXIT
unzip -t "$services" >/dev/null
unzip -j -o "$services" 'classes*.dex' -d "$tmp/dex" >/dev/null
shopt -s nullglob
dex_files=("$tmp/dex"/classes*.dex)
shopt -u nullglob
(( ${#dex_files[@]} > 0 )) || { error "MiCTS: no services DEX"; exit 1; }
for dex in "${dex_files[@]}"; do
  java -jar "$baksmali" d --api 36 "$dex" \
    -o "$tmp/smali/$(basename "$dex")" >/dev/null
done
for ref in config_defaultContextualSearchKey \
           config_defaultContextualSearchPackageName \
           'showSessionFromSession('; do
  grep -Rqs "$ref" "$tmp/smali" ||
    { error "MiCTS: missing native CSHelper reference $ref"; exit 1; }
done

# Contextual Search uses MATCH_FACTORY_ONLY when resolving Google's handler.
# Do not assume /data/app Google updates replace the need for a factory APK.
google_factory=""
for apk in \
  "$images/product/priv-app/Velvet/Velvet.apk" \
  "$images/product/priv-app/GoogleVelvet_CTS/GoogleVelvet_CTS.apk"; do
  [[ -s "$apk" ]] || continue
  meta="$(aapt dump badging "$apk" 2>/dev/null || true)"
  if [[ "$meta" == *"package: name='com.google.android.googlequicksearchbox'"* ]]; then
    google_factory="$apk"
    break
  fi
done
[[ -n "$google_factory" ]] || {
  error "MiCTS: Google factory app missing; CSHelper would not resolve its target"
  exit 1
}

aapt dump resources "$fw_res" > "$tmp/framework-resources.txt" 2>/dev/null
for res in config_defaultContextualSearchKey \
           config_defaultContextualSearchPackageName; do
  grep -q "$res" "$tmp/framework-resources.txt" ||
    { error "MiCTS: missing framework-res string $res"; exit 1; }
done

# This is the native equivalent of MiCTS's contextual-search resource hook.
# No services.jar, framework.jar, miui-services.jar or signed Xiaomi APK is edited.
mkdir -p "$tmp/overlay/res/values"
cat > "$tmp/overlay/AndroidManifest.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.hypermos.overlay.micts" android:versionCode="1"
    android:versionName="1.0">
    <uses-sdk android:minSdkVersion="35" android:targetSdkVersion="36" />
    <overlay android:targetPackage="android" android:isStatic="true"
        android:priority="999" />
    <application android:hasCode="false" />
</manifest>
XML
cat > "$tmp/overlay/res/values/config.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="config_defaultContextualSearchKey" translatable="false">omni.entry_point</string>
    <string name="config_defaultContextualSearchPackageName" translatable="false">com.google.android.googlequicksearchbox</string>
</resources>
XML

aapt package -f --auto-add-overlay \
  -M "$tmp/overlay/AndroidManifest.xml" -S "$tmp/overlay/res" \
  -I "$fw_res" -F "$tmp/unsigned.apk" >/dev/null
zipalign -f -p 4 "$tmp/unsigned.apk" "$tmp/aligned.apk" >/dev/null
java -jar "$apksigner" sign --key "$key" --cert "$cert" \
  --out "$tmp/signed.apk" "$tmp/aligned.apk" >/dev/null
java -jar "$apksigner" verify --verbose "$tmp/signed.apk" >/dev/null
unzip -t "$tmp/signed.apk" >/dev/null

install -d "$(dirname "$target")"
install -m 0644 "$tmp/signed.apk" "$target"
[[ -s "$target" ]] || { error "MiCTS: final framework overlay missing"; exit 1; }

# Remove a stale competing CTS_NATIVE overlay if the base tree contains one.
rm -f "$images/product/overlay/HyperMOSContextualSearchOverlay.apk"

cat > "$report" <<EOF
MiCTS native CSHelper report
android=16
rom=OS3
routing=VoiceInteractionManagerService/CSHelper
overlay=/product/overlay/HyperMOSMiCTSOverlay.apk
google_factory=$google_factory
services=$services
contextual_search_permission=stock_unchanged
daemon=no
lsposed_for_launcher_icon_or_qs_tile=no
long_press_gesture=requires_native_launcher_support_or_separate_hook
EOF

mods "MiCTS: native CSHelper routing installed, no resident background process"
