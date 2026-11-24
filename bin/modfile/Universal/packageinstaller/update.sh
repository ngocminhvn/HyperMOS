WDIR=$(pwd)
source "$WDIR/functions.sh"

MAINF="$WDIR/build/baserom/images"
deviceTYPE=$(cat "$WDIR/bin/ddevice/device_type.txt")

INSTALLER_DIR="$WDIR/bin/modfile/Universal/packageinstaller"
PREBUILT_APK="$INSTALLER_DIR/prebuilt/MIUIPackageInstaller.apk"
WHITELIST="$INSTALLER_DIR/privapp_whitelist_kashi.pkginstaller.xml"

TARGET_PACKAGE="com.miui.packageinstaller"

APKSIGNER_JAR="$WDIR/bin/apktool/apksigner.jar"
AAPT="${AAPT:-aapt}"

# Keep the same HyperMOS certificate across ROM builds so future updates and
# dirty flashes do not introduce an unexpected signing-certificate change.
SIGN_CERT="$WDIR/bin/package/DISABLE_AVB/HMATools/aosp/security/testkey.x509.pem"

check_existing_signing_cert() {
    local fixed_cert old_cert

    [[ -s "$SIGN_CERT" ]] || {
        echo "[ERROR] HyperMOS signing certificate not found"
        return 1
    }

    fixed_cert=$(openssl x509 -in "$SIGN_CERT" -outform DER 2>/dev/null \
        | sha256sum | awk '{print tolower($1)}')

    if [[ -f "$INSTALLER_DIR/MIUIPackageInstaller.apk" ]]; then
        old_cert=$(java -jar "$APKSIGNER_JAR" verify --print-certs \
            "$INSTALLER_DIR/MIUIPackageInstaller.apk" 2>/dev/null \
            | awk -F': ' '/Signer #1 certificate SHA-256 digest/ {gsub(/:/, "", $2); print tolower($2); exit}')

        if [[ -n "$old_cert" && -n "$fixed_cert" && "$old_cert" != "$fixed_cert" ]]; then
            echo "[INFO] Existing MIUIPackageInstaller uses another signing certificate"
            echo "[INFO] The first transition may require a clean flash; future builds keep the HyperMOS certificate"
        fi
    fi
}

verify_prebuilt_installer() {
    local package_name expected_cert actual_cert signature_info

    [[ -s "$PREBUILT_APK" ]] || {
        echo "[ERROR] InstallerX dev APK artifact is missing: $PREBUILT_APK"
        echo "[ERROR] The build-installerx job must run before HyperMOS ROM packaging"
        return 1
    }

    if ! signature_info=$(java -jar "$APKSIGNER_JAR" verify --verbose --print-certs "$PREBUILT_APK" 2>&1); then
        echo "[ERROR] InstallerX APK signature verification failed"
        printf '%s\\n' "$signature_info"
        return 1
    fi

    package_name=$("$AAPT" dump badging "$PREBUILT_APK" 2>/dev/null \
        | sed -n "s/^package: name='\\([^']*\\)'.*/\\1/p" | head -n 1)
    if [[ "$package_name" != "$TARGET_PACKAGE" ]]; then
        echo "[ERROR] InstallerX package mismatch: expected $TARGET_PACKAGE, got ${package_name:-<empty>}"
        return 1
    fi

    expected_cert=$(openssl x509 -in "$SIGN_CERT" -outform DER 2>/dev/null \
        | sha256sum | awk '{print tolower($1)}')
    actual_cert=$(printf '%s\\n' "$signature_info" \
        | awk -F': ' '/Signer #1 certificate SHA-256 digest/ {gsub(/:/, "", $2); print tolower($2); exit}')

    if [[ -z "$actual_cert" || "$actual_cert" != "$expected_cert" ]]; then
        echo "[ERROR] InstallerX APK is not signed with the fixed HyperMOS certificate"
        printf '%s\\n' "$signature_info"
        return 1
    fi

    mods "InstallerX Dev verified: $TARGET_PACKAGE -> Done"
}

if [[ "$deviceTYPE" == "China" ]]; then
    check_existing_signing_cert || exit 1
    verify_prebuilt_installer || exit 1

    TARGET="$MAINF/product/priv-app/MIUIPackageInstaller"
    mkdir -p "$TARGET"
    rm -rf "$TARGET"/*
    cp -f "$PREBUILT_APK" "$TARGET/MIUIPackageInstaller.apk" || exit 1

    mkdir -p "$MAINF/product/etc/permissions"
    cp -f "$WHITELIST" "$MAINF/product/etc/permissions/"

    [[ -s "$TARGET/MIUIPackageInstaller.apk" ]] || {
        echo "[ERROR] MIUIPackageInstaller was not staged into product/priv-app"
        exit 1
    }

    mods "MIUIPackageInstaller Dev -> Done"
else
    TARGET="$MAINF/system/system/priv-app/GooglePackageInstaller"
    mkdir -p "$TARGET"
    rm -rf "$TARGET"/*
    cp -f "$INSTALLER_DIR/GooglePackageInstaller.apk" "$TARGET/GooglePackageInstaller.apk"

    mkdir -p "$MAINF/system/system/etc/permissions"
    cp -f "$WHITELIST" "$MAINF/system/system/etc/permissions/"

    mods "GooglePackageInstaller -> Done"
fi
