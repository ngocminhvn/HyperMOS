WDIR=$(pwd)
source "$WDIR/functions.sh"

MAINF="$WDIR/build/baserom/images"
deviceTYPE=$(cat "$WDIR/bin/ddevice/device_type.txt")

INSTALLER_DIR="$WDIR/bin/modfile/Universal/packageinstaller"
WHITELIST="$INSTALLER_DIR/privapp_whitelist_kashi.pkginstaller.xml"

CONFIG_ENV="$WDIR/config.env"
dirtyflash="${dirtyflash:-off}"
if [[ -f "$CONFIG_ENV" ]]; then
    # shellcheck disable=SC1090
    source "$CONFIG_ENV"
fi
dirtyflash=$(printf '%s' "$dirtyflash" | tr '[:upper:]' '[:lower:]')
case "$dirtyflash" in
    on|off) ;;
    *)
        echo "[ERROR] packageinstaller: dirtyflash must be on or off in config.env"
        exit 1
        ;;
esac

# Snapshot used when dirtyflash=on.
PINNED_INSTALLERX_VERSION="26.09"

SOURCE_PACKAGE="com.rosan.installer.x.revived"
TARGET_PACKAGE="com.miui.packageinstaller"

APKEDITOR="java -Xmx4g -jar $WDIR/bin/apktool/apke.jar"
APKSIGNER="java -jar $WDIR/bin/apktool/apksigner.jar"
AAPT="${AAPT:-aapt}"

# Fixed signing key: keep this unchanged so future ROM dirty flashes use the same cert.
SIGN_KEY="$WDIR/bin/package/DISABLE_AVB/HMATools/aosp/security/testkey.pk8"
SIGN_CERT="$WDIR/bin/package/DISABLE_AVB/HMATools/aosp/security/testkey.x509.pem"

TMP_DIR="$WDIR/apk_temp/InstallerX"
DECODE_DIR="$TMP_DIR/decode"
UNSIGNED_APK="$TMP_DIR/MIUIPackageInstaller-unsigned.apk"
PATCHED_APK="$TMP_DIR/MIUIPackageInstaller.apk"

fetch_latest_release() {
    local release_json api_url release_mode

    if [[ "$dirtyflash" == "on" ]]; then
        release_mode="pinned"
        api_url="https://api.github.com/repos/wxxsfxyzm/InstallerX-Revived/releases/tags/$PINNED_INSTALLERX_VERSION"
    else
        release_mode="latest"
        api_url="https://api.github.com/repos/wxxsfxyzm/InstallerX-Revived/releases/latest"
    fi

    release_json=$(curl -fsSL         -H "Accept: application/vnd.github+json"         "$api_url") || {
        echo "[ERROR] Failed to query $release_mode InstallerX release"
        return 1
    }

    INSTALLERX_VERSION=$(printf '%s' "$release_json" | python3 -c '
import json, sys
data = json.load(sys.stdin)
print(data.get("tag_name", ""))
')

    INSTALLERX_URL=$(printf '%s' "$release_json" | python3 -c '
import json, sys
data = json.load(sys.stdin)
assets = data.get("assets", [])
apk = next((a for a in assets if a.get("name", "").lower().endswith(".apk")), None)
print(apk.get("browser_download_url", "") if apk else "")
')

    INSTALLERX_SHA256=$(printf '%s' "$release_json" | python3 -c '
import json, sys
data = json.load(sys.stdin)
assets = data.get("assets", [])
apk = next((a for a in assets if a.get("name", "").lower().endswith(".apk")), None)
digest = apk.get("digest", "") if apk else ""
print(digest.split(":", 1)[1] if digest.startswith("sha256:") else "")
')

    if [[ -z "$INSTALLERX_VERSION" || -z "$INSTALLERX_URL" ]]; then
        echo "[ERROR] $release_mode InstallerX release has no usable APK asset"
        return 1
    fi

    if [[ "$dirtyflash" == "on" && "$INSTALLERX_VERSION" != "$PINNED_INSTALLERX_VERSION" ]]; then
        echo "[ERROR] Pinned InstallerX tag mismatch: expected $PINNED_INSTALLERX_VERSION, got $INSTALLERX_VERSION"
        return 1
    fi

    DOWNLOAD_APK="$TMP_DIR/InstallerX-Revived-$INSTALLERX_VERSION.apk"
    mods "InstallerX Stable $INSTALLERX_VERSION ($release_mode)"
}

patch_package_identity() {
    local manifest="$DECODE_DIR/AndroidManifest.xml"

    # XML decode writes the main manifest at the decode root. Keep discovery as
    # a fallback in case a future APKEditor version changes the output layout.
    if [[ ! -f "$manifest" ]]; then
        manifest=$(find "$DECODE_DIR" -type f -name 'AndroidManifest.xml' -print -quit)
    fi

    [[ -n "${manifest:-}" && -f "$manifest" ]] || {
        echo "[ERROR] InstallerX AndroidManifest.xml not found after decode"
        return 1
    }

    # Only replace the dotted application id in decoded UTF-8 text.
    # Do NOT rewrite com/rosan/... class descriptor paths: Java/Kotlin classes
    # are allowed to keep their original namespace when the Android package id
    # is changed, and rewriting descriptors can break dex/class resolution.
    if ! python3 - "$DECODE_DIR" "$SOURCE_PACKAGE" "$TARGET_PACKAGE" <<'PY'
from pathlib import Path
import sys

root = Path(sys.argv[1])
source = sys.argv[2]
target = sys.argv[3]
changed = 0

for path in root.rglob("*"):
    if not path.is_file():
        continue
    try:
        raw = path.read_bytes()
        text = raw.decode("utf-8")
    except (OSError, UnicodeDecodeError):
        continue

    if source not in text:
        continue

    path.write_text(text.replace(source, target), encoding="utf-8")
    changed += 1

if changed == 0:
    print(f"InstallerX package identity not found: {source}", file=sys.stderr)
    raise SystemExit(2)
PY
    then
        echo "[ERROR] Failed to patch InstallerX package identity"
        return 1
    fi

    if ! grep -Fq "package=\"$TARGET_PACKAGE\"" "$manifest"; then
        echo "[ERROR] AndroidManifest package is not $TARGET_PACKAGE"
        return 1
    fi

    # Remaining source-package strings in binary blobs are harmless and must
    # not make the build fail. Relevant decoded text has already been patched.
    local remaining_text
    remaining_text=$(grep -RIl --binary-files=without-match -- "$SOURCE_PACKAGE" "$DECODE_DIR" 2>/dev/null | head -n 1 || true)
    if [[ -n "$remaining_text" ]]; then
        echo "[ERROR] InstallerX text package rename is incomplete: $remaining_text"
        return 1
    fi

    mods "Package + authorities -> $TARGET_PACKAGE Done"
}

check_dirty_flash_cert() {
    local fixed_cert old_cert

    fixed_cert=$(openssl x509 -in "$SIGN_CERT" -outform DER 2>/dev/null         | sha256sum | awk '{print tolower($1)}')

    if [[ -f "$INSTALLER_DIR/MIUIPackageInstaller.apk" ]]; then
        old_cert=$($APKSIGNER verify --print-certs "$INSTALLER_DIR/MIUIPackageInstaller.apk" 2>/dev/null             | awk -F': ' '/Signer #1 certificate SHA-256 digest/ {print tolower($2); exit}'             | tr -d ':')

        if [[ -n "$old_cert" && -n "$fixed_cert" && "$old_cert" != "$fixed_cert" ]]; then
            echo "[INFO] Existing MIUIPackageInstaller uses another signing certificate"
            echo "[INFO] First transition may not be dirty-flash compatible; future builds will be"
        fi
    fi
}

build_installerx_stable() {
    rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"

    fetch_latest_release || return 1

    if ! aria2c -q         --allow-overwrite=true         --auto-file-renaming=false         -d "$TMP_DIR"         -o "$(basename "$DOWNLOAD_APK")"         "$INSTALLERX_URL"; then
        echo "[ERROR] Failed to download InstallerX Stable $INSTALLERX_VERSION"
        return 1
    fi

    if [[ -n "$INSTALLERX_SHA256" ]]; then
        if ! echo "$INSTALLERX_SHA256  $DOWNLOAD_APK" | sha256sum -c - >/dev/null 2>&1; then
            echo "[ERROR] InstallerX Stable $INSTALLERX_VERSION SHA-256 mismatch"
            return 1
        fi
    fi

    # Package/authority rewriting requires a readable AndroidManifest.xml.
    # APKEditor raw mode does not provide the XML manifest expected below.
    if ! $APKEDITOR d -t xml -f -no-dex-debug         -i "$DOWNLOAD_APK"         -o "$DECODE_DIR" >/dev/null 2>&1; then
        echo "[ERROR] Failed to XML-decode InstallerX Stable $INSTALLERX_VERSION"
        return 1
    fi

    patch_package_identity || return 1

    if ! $APKEDITOR b -f         -i "$DECODE_DIR"         -o "$UNSIGNED_APK" >/dev/null 2>&1; then
        echo "[ERROR] Failed to rebuild InstallerX Stable $INSTALLERX_VERSION"
        return 1
    fi

    if [[ ! -f "$SIGN_KEY" || ! -f "$SIGN_CERT" ]]; then
        echo "[ERROR] Fixed InstallerX signing key/cert not found"
        return 1
    fi

    if ! $APKSIGNER sign         --key "$SIGN_KEY"         --cert "$SIGN_CERT"         --out "$PATCHED_APK"         "$UNSIGNED_APK" >/dev/null 2>&1; then
        echo "[ERROR] Failed to sign MIUIPackageInstaller.apk"
        return 1
    fi

    if ! $APKSIGNER verify --verbose --print-certs "$PATCHED_APK" >/dev/null 2>&1; then
        echo "[ERROR] MIUIPackageInstaller.apk signature verification failed"
        return 1
    fi

    local rebuilt_package
    rebuilt_package=$($AAPT dump badging "$PATCHED_APK" 2>/dev/null \
        | sed -n "s/^package: name='\([^']*\)'.*/\1/p" | head -n 1)
    if [[ "$rebuilt_package" != "$TARGET_PACKAGE" ]]; then
        echo "[ERROR] Rebuilt InstallerX package mismatch: expected $TARGET_PACKAGE, got ${rebuilt_package:-<empty>}"
        return 1
    fi

    mods "Signed + verified package $TARGET_PACKAGE -> Done"
}

if [[ "$deviceTYPE" == "China" ]]; then
    check_dirty_flash_cert

    if ! build_installerx_stable; then
        rm -rf "$TMP_DIR"
        exit 1
    fi

    TARGET="$MAINF/product/priv-app/MIUIPackageInstaller"
    mkdir -p "$TARGET"
    rm -rf "$TARGET"/*
    cp -f "$PATCHED_APK" "$TARGET/MIUIPackageInstaller.apk" || exit 1

    if [[ ! -s "$TARGET/MIUIPackageInstaller.apk" ]]; then
        echo "[ERROR] InstallerX output missing from product/priv-app"
        rm -rf "$TMP_DIR"
        exit 1
    fi

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
