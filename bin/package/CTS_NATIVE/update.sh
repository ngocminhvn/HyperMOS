#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

CTS_DIR="$work_dir/bin/package/CTS_NATIVE"
IMAGES="$work_dir/build/baserom/images"
ANDROID_VER="$(tr -d ' \r\n' < "$work_dir/bin/ddevice/androidver.txt")"
SDK_LEVEL="$(tr -d ' \r\n' < "$work_dir/bin/ddevice/sdkLevel.txt")"
ROM_OS="$(tr -d ' \r\n' < "$work_dir/bin/ddevice/rom_os.txt")"

BAKSMALI="$work_dir/bin/apktool/baksmaliv2.jar"
APKSIGNER="$work_dir/bin/apktool/apksigner.jar"
SIGN_KEY="$work_dir/bin/package/DISABLE_AVB/HMATools/aosp/security/testkey.pk8"
SIGN_CERT="$work_dir/bin/package/DISABLE_AVB/HMATools/aosp/security/testkey.x509.pem"

if [[ "$ANDROID_VER" != "16" || "$ROM_OS" != "OS3" ]]; then
  info "CTS_NATIVE: Android $ANDROID_VER / $ROM_OS -> skipped (A16 HyperOS 3 only)"
  exit 0
fi

for cmd in aapt zipalign java unzip grep find; do
  command -v "$cmd" >/dev/null 2>&1 || {
    error "CTS_NATIVE: required host tool missing: $cmd"
    exit 1
  }
done

for file in "$BAKSMALI" "$APKSIGNER" "$SIGN_KEY" "$SIGN_CERT"; do
  [[ -s "$file" ]] || {
    error "CTS_NATIVE: required build payload missing: $file"
    exit 1
  }
done

find_unique_file() {
  local label="$1"
  shift
  local -a matches=()
  local candidate
  for candidate in "$@"; do
    if [[ -f "$candidate" ]]; then
      matches+=("$candidate")
    fi
  done
  if (( ${#matches[@]} == 1 )); then
    printf '%s\n' "${matches[0]}"
    return 0
  fi
  if (( ${#matches[@]} > 1 )); then
    error "CTS_NATIVE: ambiguous $label: ${#matches[@]} preferred matches"
    return 1
  fi
  return 2
}

FRAMEWORK_RES="$(find_unique_file "framework-res.apk" \
  "$IMAGES/system/system/framework/framework-res.apk" \
  "$IMAGES/system/framework/framework-res.apk")" || {
    mapfile -d '' -t _fw < <(find "$IMAGES" -type f -name framework-res.apk -print0)
    (( ${#_fw[@]} == 1 )) || {
      error "CTS_NATIVE: expected exactly one framework-res.apk, found ${#_fw[@]}"
      exit 1
    }
    FRAMEWORK_RES="${_fw[0]}"
  }

SERVICES_JAR="$(find_unique_file "services.jar" \
  "$IMAGES/system/system/framework/services.jar" \
  "$IMAGES/system/framework/services.jar")" || {
    mapfile -d '' -t _services < <(find "$IMAGES" -type f -name services.jar -print0)
    (( ${#_services[@]} == 1 )) || {
      error "CTS_NATIVE: expected exactly one services.jar, found ${#_services[@]}"
      exit 1
    }
    SERVICES_JAR="${_services[0]}"
  }

LAUNCHER_APK="$(find_unique_file "MiuiHome.apk" \
  "$IMAGES/product/priv-app/MiuiHome/MiuiHome.apk" \
  "$IMAGES/system/system/priv-app/MiuiHome/MiuiHome.apk" \
  "$IMAGES/system_ext/priv-app/MiuiHome/MiuiHome.apk")" || {
    mapfile -d '' -t _homes < <(find "$IMAGES" -type f \( -name 'MiuiHome.apk' -o -name 'MiuiHome*.apk' \) -print0)
    if (( ${#_homes[@]} == 0 )); then
      error "CTS_NATIVE: stock MiuiHome APK not found"
      exit 1
    fi
    LAUNCHER_APK=""
    for _apk in "${_homes[@]}"; do
      if aapt dump badging "$_apk" 2>/dev/null | grep -q "package: name='com.miui.home'"; then
        if [[ -n "$LAUNCHER_APK" ]]; then
          error "CTS_NATIVE: more than one com.miui.home APK found"
          exit 1
        fi
        LAUNCHER_APK="$_apk"
      fi
    done
    [[ -n "$LAUNCHER_APK" ]] || {
      error "CTS_NATIVE: no APK with package com.miui.home found"
      exit 1
    }
  }

GOOGLE_APK="$IMAGES/product/priv-app/GoogleVelvet_CTS/GoogleVelvet_CTS.apk"
[[ -s "$GOOGLE_APK" ]] || {
  mapfile -d '' -t _google < <(find "$IMAGES" -type f \( -name 'GoogleVelvet_CTS.apk' -o -name 'Velvet.apk' \) -print0)
  GOOGLE_APK=""
  for _apk in "${_google[@]}"; do
    if aapt dump badging "$_apk" 2>/dev/null | grep -q "package: name='com.google.android.googlequicksearchbox'"; then
      GOOGLE_APK="$_apk"
      break
    fi
  done
}
[[ -s "$GOOGLE_APK" ]] || {
  error "CTS_NATIVE: Google app (com.google.android.googlequicksearchbox) missing"
  exit 1
}

mods "CTS_NATIVE: preflight framework + stock launcher"

# Framework resources required by AOSP CSHelper / ContextualSearchService.
FW_RES_DUMP="$(mktemp)"
trap 'rm -f "$FW_RES_DUMP"; rm -rf "$work_dir/jar_temp/cts-native"' EXIT
aapt dump resources "$FRAMEWORK_RES" > "$FW_RES_DUMP" 2>/dev/null || {
  error "CTS_NATIVE: cannot inspect framework-res.apk"
  exit 1
}
for name in config_defaultContextualSearchPackageName config_defaultContextualSearchKey; do
  grep -q "$name" "$FW_RES_DUMP" || {
    error "CTS_NATIVE: framework resource missing: $name"
    exit 1
  }
done

TMP="$work_dir/jar_temp/cts-native"
rm -rf "$TMP"
mkdir -p "$TMP/services-raw" "$TMP/services-smali" "$TMP/launcher-raw" "$TMP/launcher-smali"

# Verify that Android 16 services.jar actually carries AOSP CSHelper.
unzip -j -o "$SERVICES_JAR" 'classes*.dex' -d "$TMP/services-raw" >/dev/null
shopt -s nullglob
_service_dex=("$TMP/services-raw"/classes*.dex)
shopt -u nullglob
(( ${#_service_dex[@]} > 0 )) || {
  error "CTS_NATIVE: no DEX found in services.jar"
  exit 1
}

for dex in "${_service_dex[@]}"; do
  out="$TMP/services-smali/$(basename "$dex").out"
  java -jar "$BAKSMALI" d --api "$SDK_LEVEL" "$dex" -o "$out" >/dev/null
done

VIMS_FILE="$(find "$TMP/services-smali" -type f -path '*/com/android/server/voiceinteraction/VoiceInteractionManagerService*.smali' -print -quit)"
[[ -n "$VIMS_FILE" ]] || {
  error "CTS_NATIVE: VoiceInteractionManagerService smali not found"
  exit 1
}

grep -Rqs 'config_defaultContextualSearchKey' "$TMP/services-smali" || {
  error "CTS_NATIVE: A16 VoiceInteractionManagerService has no CSHelper key path"
  exit 1
}
grep -Rqs 'config_defaultContextualSearchPackageName' "$TMP/services-smali" || {
  error "CTS_NATIVE: A16 VoiceInteractionManagerService has no contextual-search package path"
  exit 1
}

# Keep MiuiHome stock-signed: only verify its built-in CTS path, never rebuild it.
unzip -j -o "$LAUNCHER_APK" 'classes*.dex' -d "$TMP/launcher-raw" >/dev/null
shopt -s nullglob
_launcher_dex=("$TMP/launcher-raw"/classes*.dex)
shopt -u nullglob
(( ${#_launcher_dex[@]} > 0 )) || {
  error "CTS_NATIVE: no DEX found in MiuiHome.apk"
  exit 1
}

for dex in "${_launcher_dex[@]}"; do
  out="$TMP/launcher-smali/$(basename "$dex").out"
  java -jar "$BAKSMALI" d --api "$SDK_LEVEL" "$dex" -o "$out" >/dev/null
done

CTS_CLASS=0
for rel in \
  'com/miui/home/recents/cts/CircleToSearchHelper.smali' \
  'com/miui/home/recents/cts/NavBarEventHelper.smali' \
  'com/miui/home/recents/gesture/NavStubGestureEventManager.smali'; do
  if find "$TMP/launcher-smali" -type f -path "*/$rel" -print -quit | grep -q .; then
    CTS_CLASS=1
    break
  fi
done
(( CTS_CLASS == 1 )) || {
  error "CTS_NATIVE: stock MiuiHome has no known CTS/long-press implementation"
  exit 1
}

grep -Rqs 'omni.entry_point' "$TMP/launcher-smali" || {
  error "CTS_NATIVE: stock MiuiHome has no omni.entry_point trigger"
  exit 1
}

# Google must expose one of the A14/A15+ contextual-search entry actions.
GOOGLE_XML="$TMP/google-manifest.txt"
aapt dump xmltree "$GOOGLE_APK" AndroidManifest.xml > "$GOOGLE_XML" 2>/dev/null || {
  error "CTS_NATIVE: cannot inspect Google app manifest"
  exit 1
}
if ! grep -Eq 'com\.android\.contextualsearch\.LAUNCH|android\.app\.contextualsearch\.action\.LAUNCH_CONTEXTUAL_SEARCH' "$GOOGLE_XML"; then
  error "CTS_NATIVE: installed Google app has no Contextual Search launch activity"
  exit 1
fi

info "CTS_NATIVE: preflight PASS (A16 CSHelper + stock MiuiHome CTS + Google handler)"

# Build a static framework RRO. This enables both the AOSP CSHelper path and
# ContextualSearchManagerService discovery without touching framework-res.apk.
OVL_SRC="$TMP/overlay"
OVL_UNSIGNED="$TMP/HyperMOSContextualSearchOverlay-unsigned.apk"
OVL_ALIGNED="$TMP/HyperMOSContextualSearchOverlay-aligned.apk"
OVL_SIGNED="$TMP/HyperMOSContextualSearchOverlay.apk"
mkdir -p "$OVL_SRC/res/values"

cat > "$OVL_SRC/AndroidManifest.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.hypermos.overlay.contextualsearch"
    android:versionCode="1"
    android:versionName="1.0">
    <uses-sdk android:minSdkVersion="35" android:targetSdkVersion="36" />
    <overlay
        android:targetPackage="android"
        android:isStatic="true"
        android:priority="999" />
    <application android:hasCode="false" />
</manifest>
EOF

cat > "$OVL_SRC/res/values/config.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="config_defaultContextualSearchPackageName" translatable="false">com.google.android.googlequicksearchbox</string>
    <string name="config_defaultContextualSearchKey" translatable="false">omni.entry_point</string>
</resources>
EOF

aapt package -f --auto-add-overlay \
  -M "$OVL_SRC/AndroidManifest.xml" \
  -S "$OVL_SRC/res" \
  -I "$FRAMEWORK_RES" \
  -F "$OVL_UNSIGNED" || {
    error "CTS_NATIVE: framework contextual-search RRO compile failed"
    exit 1
  }

zipalign -f -p 4 "$OVL_UNSIGNED" "$OVL_ALIGNED" || {
  error "CTS_NATIVE: overlay zipalign failed"
  exit 1
}

java -jar "$APKSIGNER" sign \
  --key "$SIGN_KEY" \
  --cert "$SIGN_CERT" \
  --out "$OVL_SIGNED" \
  "$OVL_ALIGNED" >/dev/null 2>&1 || {
    error "CTS_NATIVE: overlay signing failed"
    exit 1
  }

java -jar "$APKSIGNER" verify --verbose "$OVL_SIGNED" >/dev/null 2>&1 || {
  error "CTS_NATIVE: signed overlay verification failed"
  exit 1
}

TARGET_OVERLAY="$IMAGES/product/overlay/HyperMOSContextualSearchOverlay.apk"
mkdir -p "$(dirname "$TARGET_OVERLAY")"
cp -f "$OVL_SIGNED" "$TARGET_OVERLAY"
chmod 0644 "$TARGET_OVERLAY"
[[ -s "$TARGET_OVERLAY" ]] || {
  error "CTS_NATIVE: final overlay missing"
  exit 1
}

# If stock launcher already requests the A15+ permission, grant it as well.
# CSHelper does not require this permission; this only unlocks the native
# ContextualSearchManager path when Xiaomi's launcher uses it.
if aapt dump permissions "$LAUNCHER_APK" 2>/dev/null | grep -q 'android.permission.ACCESS_CONTEXTUAL_SEARCH'; then
  PERM_DIR="$IMAGES/product/etc/permissions"
  mkdir -p "$PERM_DIR"
  cat > "$PERM_DIR/privapp-permissions-hypermos-cts.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<permissions>
    <privapp-permissions package="com.miui.home">
        <permission name="android.permission.ACCESS_CONTEXTUAL_SEARCH" />
    </privapp-permissions>
</permissions>
EOF
  chmod 0644 "$PERM_DIR/privapp-permissions-hypermos-cts.xml"
  info "CTS_NATIVE: launcher ACCESS_CONTEXTUAL_SEARCH permission -> granted"
else
  info "CTS_NATIVE: launcher does not request ACCESS_CONTEXTUAL_SEARCH; using CSHelper/VIMS path"
fi

mods "CTS_NATIVE: framework CSHelper + stock MiuiHome direct CTS -> Done"
