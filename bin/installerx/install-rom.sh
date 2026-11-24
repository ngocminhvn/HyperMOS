#!/usr/bin/env bash
# InstallerX is compiled and signed by the independent APK publishing workflow.
WDIR=$(pwd)
source "$WDIR/functions.sh"
MAINF="$WDIR/build/baserom/images"
deviceTYPE=$(cat "$WDIR/bin/ddevice/device_type.txt")
INSTALLER_DIR="$WDIR/bin/modfile/Universal/packageinstaller"
WHITELIST="$INSTALLER_DIR/privapp_whitelist_kashi.pkginstaller.xml"

if [[ "$deviceTYPE" == "China" ]]; then
    APK="$INSTALLER_DIR/MIUIPackageInstaller.apk"
    TARGET="$MAINF/product/priv-app/MIUIPackageInstaller"
    [[ -s "$APK" ]] || { echo "[ERROR] Prebuilt InstallerX APK missing: $APK"; exit 1; }
    BADGING=$(aapt dump badging "$APK") || exit 1
    [[ "$BADGING" == "package: name='com.miui.packageinstaller'"* ]] || { echo "[ERROR] InstallerX package ID mismatch"; exit 1; }
    SIGN_INFO=$(java -jar "$WDIR/bin/apktool/apksigner.jar" verify --print-certs "$APK") || exit 1
    EXPECTED=$(openssl x509 -in "$WDIR/bin/package/DISABLE_AVB/HMATools/aosp/security/testkey.x509.pem" -outform DER | sha256sum | awk '{print tolower($1)}')
    ACTUAL=$(printf '%s\n' "$SIGN_INFO" | awk -F': ' '/Signer #1 certificate SHA-256 digest/ {gsub(/:/, "", $2); print tolower($2); exit}')
    [[ -n "$ACTUAL" && "$ACTUAL" == "$EXPECTED" ]] || { echo "[ERROR] InstallerX signing certificate mismatch"; exit 1; }
    mkdir -p "$TARGET" "$MAINF/product/etc/permissions" || exit 1
    rm -rf "$TARGET"/* || exit 1
    cp -f "$APK" "$TARGET/MIUIPackageInstaller.apk" || exit 1
    cp -f "$WHITELIST" "$MAINF/product/etc/permissions/" || exit 1
    cmp -s "$APK" "$TARGET/MIUIPackageInstaller.apk" || exit 1
    mods "MIUIPackageInstaller Dev (prebuilt) -> Done"
else
    TARGET="$MAINF/system/system/priv-app/GooglePackageInstaller"
    mkdir -p "$TARGET" "$MAINF/system/system/etc/permissions" || exit 1
    rm -rf "$TARGET"/* || exit 1
    cp -f "$INSTALLER_DIR/GooglePackageInstaller.apk" "$TARGET/GooglePackageInstaller.apk" || exit 1
    cp -f "$WHITELIST" "$MAINF/system/system/etc/permissions/" || exit 1
    mods "GooglePackageInstaller -> Done"
fi
