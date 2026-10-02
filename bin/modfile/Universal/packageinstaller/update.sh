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
INSTALLERX_TMP="$INSTALLER_DIR/InstallerX-Revived-stable.apk"

if [[ "$deviceTYPE" == "China" ]]; then
    mods "InstallerX Stable $INSTALLERX_VERSION"

    rm -f "$INSTALLERX_TMP"

    if ! aria2c -q         --allow-overwrite=true         --auto-file-renaming=false         -d "$INSTALLER_DIR"         -o "$(basename "$INSTALLERX_TMP")"         "$INSTALLERX_URL"; then
        echo "[ERROR] Failed to download InstallerX Stable $INSTALLERX_VERSION"
        exit 1
    fi

    if ! echo "$INSTALLERX_SHA256  $INSTALLERX_TMP" | sha256sum -c - >/dev/null 2>&1; then
        echo "[ERROR] InstallerX Stable $INSTALLERX_VERSION SHA-256 mismatch"
        rm -f "$INSTALLERX_TMP"
        exit 1
    fi

    TARGET="$MAINF/product/priv-app/MIUIPackageInstaller"
    mkdir -p "$TARGET"
    rm -rf "$TARGET"/*
    cp -f "$INSTALLERX_TMP" "$TARGET/MIUIPackageInstaller.apk"
    rm -f "$INSTALLERX_TMP"

    mkdir -p "$MAINF/product/etc/permissions"
    cp -f "$WHITELIST" "$MAINF/product/etc/permissions/"

    mods "InstallerX Stable $INSTALLERX_VERSION -> Done"
else
    TARGET="$MAINF/system/system/priv-app/GooglePackageInstaller"
    mkdir -p "$TARGET"
    rm -rf "$TARGET"/*
    cp -f "$INSTALLER_DIR/GooglePackageInstaller.apk" "$TARGET/GooglePackageInstaller.apk"

    mkdir -p "$MAINF/system/system/etc/permissions"
    cp -f "$WHITELIST" "$MAINF/system/system/etc/permissions/"

    mods "GooglePackageInstaller -> Done"
fi
