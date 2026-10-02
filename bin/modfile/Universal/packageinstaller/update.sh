WDIR=$(pwd)
source "$WDIR/functions.sh"

MAINF="$WDIR/build/baserom/images"
androidVer=$(cat "$WDIR/bin/ddevice/androidver.txt")
deviceTYPE=$(cat "$WDIR/bin/ddevice/device_type.txt")

INSTALLER_DIR="$WDIR/bin/modfile/Universal/packageinstaller"
WHITELIST="$INSTALLER_DIR/privapp_whitelist_kashi.pkginstaller.xml"

# InstallerX-Revived Stable 26.09
INSTALLERX_VERSION="26.09"
INSTALLERX_URL="https://github.com/wxxsfxyzm/InstallerX-Revived/releases/download/26.09/InstallerX-Revived-online-26.09.apk"
INSTALLERX_SHA256="fe7ac4737885a0426042222e27ed0a637e481e72c742ebe09142fd51448ae85b"

# Keep Xiaomi's package identity so it can replace MIUIPackageInstaller.
SOURCE_PACKAGE="com.rosan.installer.x.revived"
TARGET_PACKAGE="com.miui.packageinstaller"

APKEDITOR="java -Xmx4g -jar $WDIR/bin/apktool/apke.jar"
APKSIGNER="java -jar $WDIR/bin/apktool/apksigner.jar"
SIGN_KEY="$WDIR/bin/package/DISABLE_AVB/HMATools/aosp/security/testkey.pk8"
SIGN_CERT="$WDIR/bin/package/DISABLE_AVB/HMATools/aosp/security/testkey.x509.pem"

TMP_DIR="$WDIR/apk_temp/InstallerX"
DOWNLOAD_APK="$TMP_DIR/InstallerX-Revived-online-$INSTALLERX_VERSION.apk"
DECODE_DIR="$TMP_DIR/decode"
UNSIGNED_APK="$TMP_DIR/MIUIPackageInstaller-unsigned.apk"
PATCHED_APK="$TMP_DIR/MIUIPackageInstaller.apk"

build_installerx_stable() {
    rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"

    mods "InstallerX Stable $INSTALLERX_VERSION"

    if ! aria2c -q         --allow-overwrite=true         --auto-file-renaming=false         -d "$TMP_DIR"         -o "$(basename "$DOWNLOAD_APK")"         "$INSTALLERX_URL"; then
        echo "[ERROR] Failed to download InstallerX Stable $INSTALLERX_VERSION"
        return 1
    fi

    if ! echo "$INSTALLERX_SHA256  $DOWNLOAD_APK" | sha256sum -c - >/dev/null 2>&1; then
        echo "[ERROR] InstallerX Stable $INSTALLERX_VERSION SHA-256 mismatch"
        return 1
    fi

    if ! $APKEDITOR d -t raw -f -no-dex-debug         -i "$DOWNLOAD_APK"         -o "$DECODE_DIR" >/dev/null 2>&1; then
        echo "[ERROR] Failed to decode InstallerX Stable $INSTALLERX_VERSION"
        return 1
    fi

    mapfile -d '' package_files < <(
        grep -RIlZ -- "$SOURCE_PACKAGE" "$DECODE_DIR" 2>/dev/null || true
    )

    if (( ${#package_files[@]} == 0 )); then
        echo "[ERROR] InstallerX package identity not found: $SOURCE_PACKAGE"
        return 1
    fi

    for file in "${package_files[@]}"; do
        sed -i "s#com\\.rosan\\.installer\\.x\\.revived#$TARGET_PACKAGE#g" "$file"
    done

    if grep -RIl -- "$SOURCE_PACKAGE" "$DECODE_DIR" >/dev/null 2>&1; then
        echo "[ERROR] InstallerX package rename is incomplete"
        return 1
    fi

    if ! $APKEDITOR b -f         -i "$DECODE_DIR"         -o "$UNSIGNED_APK" >/dev/null 2>&1; then
        echo "[ERROR] Failed to rebuild InstallerX Stable $INSTALLERX_VERSION"
        return 1
    fi

    if ! $APKSIGNER sign         --key "$SIGN_KEY"         --cert "$SIGN_CERT"         --out "$PATCHED_APK"         "$UNSIGNED_APK" >/dev/null 2>&1; then
        echo "[ERROR] Failed to sign MIUIPackageInstaller.apk"
        return 1
    fi

    if ! $APKSIGNER verify "$PATCHED_APK" >/dev/null 2>&1; then
        echo "[ERROR] MIUIPackageInstaller.apk signature verification failed"
        return 1
    fi

    mods "InstallerX Stable $INSTALLERX_VERSION -> $TARGET_PACKAGE Done"
}

if [[ "$deviceTYPE" == "China" ]]; then
    if ! build_installerx_stable; then
        rm -rf "$TMP_DIR"
        exit 1
    fi

    TARGET="$MAINF/product/priv-app/MIUIPackageInstaller"
    mkdir -p "$TARGET"
    rm -rf "$TARGET"/*
    cp -f "$PATCHED_APK" "$TARGET/MIUIPackageInstaller.apk"

    mkdir -p "$MAINF/product/etc/permissions"
    cp -f "$WHITELIST" "$MAINF/product/etc/permissions/"

    rm -rf "$TMP_DIR"
    mods "MIUIPackageInstaller Stable $INSTALLERX_VERSION -> Done"
else
    TARGET="$MAINF/system/system/priv-app/GooglePackageInstaller"
    mkdir -p "$TARGET"
    rm -rf "$TARGET"/*
    cp -f "$INSTALLER_DIR/GooglePackageInstaller.apk" "$TARGET/GooglePackageInstaller.apk"

    mkdir -p "$MAINF/system/system/etc/permissions"
    cp -f "$WHITELIST" "$MAINF/system/system/etc/permissions/"

    mods "GooglePackageInstaller -> Done"
fi
