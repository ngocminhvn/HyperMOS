#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SOURCE_DIR="${1:?Usage: build.sh <InstallerX source directory> <output directory>}"
OUTPUT_DIR="${2:?Usage: build.sh <InstallerX source directory> <output directory>}"

TARGET_PACKAGE="com.miui.packageinstaller"
SIGN_KEY="$ROOT/bin/package/DISABLE_AVB/HMATools/aosp/security/testkey.pk8"
SIGN_CERT="$ROOT/bin/package/DISABLE_AVB/HMATools/aosp/security/testkey.x509.pem"

SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
BUILD_TOOLS="$SDK_ROOT/build-tools/37.0.0"
AAPT="$BUILD_TOOLS/aapt"
APKSIGNER="$BUILD_TOOLS/apksigner"
ZIPALIGN="$BUILD_TOOLS/zipalign"

for tool in git openssl unzip; do
    command -v "$tool" >/dev/null 2>&1 || {
        echo "::error::Required tool not found: $tool"
        exit 1
    }
done

[[ -d "$SOURCE_DIR" && -x "$SOURCE_DIR/gradlew" ]] || {
    echo "::error::InstallerX source or Gradle wrapper not found: $SOURCE_DIR"
    exit 1
}
[[ -n "$SDK_ROOT" && -x "$AAPT" && -x "$APKSIGNER" && -x "$ZIPALIGN" ]] || {
    echo "::error::Android SDK Build Tools 37.0.0 are required"
    exit 1
}
[[ -s "$SIGN_KEY" && -s "$SIGN_CERT" ]] || {
    echo "::error::HyperMOS signing key/certificate not found"
    exit 1
}

SOURCE_SHA="$(git -C "$SOURCE_DIR" rev-parse HEAD)"
SOURCE_SUBJECT="$(git -C "$SOURCE_DIR" log -1 --format=%s)"
echo "[InstallerX] Upstream dev commit: $SOURCE_SHA"
echo "[InstallerX] Commit subject: $SOURCE_SUBJECT"

# Fail early if upstream removes the supported APP_ID Gradle property.
if ! grep -Fq 'project.findProperty("APP_ID")' "$SOURCE_DIR/app/build.gradle.kts"; then
    echo "::error::InstallerX no longer exposes the APP_ID Gradle property"
    exit 1
fi

# Build with the same HyperMOS certificate used by the existing ROM package.
# The HyperMOS PKCS#8 key is DER encoded; convert it to PEM and then PKCS#12.
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT
SIGN_PASSWORD="$(openssl rand -hex 24)"

if ! openssl pkcs8 -inform DER -in "$SIGN_KEY" -out "$TEMP_DIR/hypermos-key.pem" -nocrypt 2>/dev/null; then
    openssl pkcs8 -in "$SIGN_KEY" -out "$TEMP_DIR/hypermos-key.pem" -nocrypt
fi

openssl pkcs12 -export -inkey "$TEMP_DIR/hypermos-key.pem" -in "$SIGN_CERT" -name hypermos -out "$TEMP_DIR/hypermos-signing.p12" -passout "pass:$SIGN_PASSWORD"

(
    cd "$SOURCE_DIR"
    export KEYSTORE_FILE="$TEMP_DIR/hypermos-signing.p12"
    export KEYSTORE_PASSWORD="$SIGN_PASSWORD"
    export KEY_ALIAS="hypermos"
    export KEY_PASSWORD="$SIGN_PASSWORD"
    ./gradlew --no-daemon --no-configuration-cache assembleUnstableRelease "-PAPP_ID=$TARGET_PACKAGE"
)

# Require R8 mapping output so an upstream build-type change cannot silently
# turn this into an unminified package.
MAPPING_FILE="$(find "$SOURCE_DIR/app/build/outputs/mapping" -type f -name mapping.txt -size +0c -print -quit 2>/dev/null || true)"
[[ -n "$MAPPING_FILE" ]] || {
    echo "::error::R8 mapping.txt was not generated; refusing a non-optimized build"
    exit 1
}
echo "[InstallerX] R8 mapping: $MAPPING_FILE"

# Select the single Unstable Release APK whose merged manifest has our package ID.
APK=""
while IFS= read -r candidate; do
    [[ -n "$candidate" ]] || continue
    package="$("$AAPT" dump badging "$candidate" 2>/dev/null | sed -n "s/^package: name='\([^']*\)'.*/\1/p" | head -n 1)"
    if [[ "$package" == "$TARGET_PACKAGE" ]]; then
        if [[ -n "$APK" ]]; then
            echo "::error::More than one InstallerX APK matches $TARGET_PACKAGE"
            exit 1
        fi
        APK="$candidate"
    fi
done < <(find "$SOURCE_DIR/app/build/outputs/apk" -type f -name '*.apk' -path '*/unstable/release/*' -print | sort)

[[ -n "$APK" && -s "$APK" ]] || {
    echo "::error::No Unstable Release APK found with package $TARGET_PACKAGE"
    exit 1
}

# Verify that Gradle signed the APK with the fixed HyperMOS certificate.
EXPECTED_CERT="$(openssl x509 -in "$SIGN_CERT" -outform DER | sha256sum | awk '{print tolower($1)}')"
SIGNATURE_INFO="$("$APKSIGNER" verify --verbose --print-certs "$APK")"
ACTUAL_CERT="$(printf '%s\n' "$SIGNATURE_INFO" | awk -F': ' '/Signer #1 certificate SHA-256 digest/ {gsub(/:/, "", $2); print tolower($2); exit}')"

[[ -n "$ACTUAL_CERT" && "$ACTUAL_CERT" == "$EXPECTED_CERT" ]] || {
    echo "::error::InstallerX signing certificate does not match the HyperMOS testkey"
    printf '%s\n' "$SIGNATURE_INFO"
    exit 1
}

"$ZIPALIGN" -c -v 4 "$APK" >/dev/null

BADGING="$("$AAPT" dump badging "$APK")"
VERSION_NAME="$(printf '%s\n' "$BADGING" | sed -n "s/^package:.*versionName='\([^']*\)'.*/\1/p" | head -n 1)"
VERSION_CODE="$(printf '%s\n' "$BADGING" | sed -n "s/^package:.*versionCode='\([^']*\)'.*/\1/p" | head -n 1)"

mkdir -p "$OUTPUT_DIR"
cp -f "$APK" "$OUTPUT_DIR/MIUIPackageInstaller.apk"

if unzip -Z1 "$OUTPUT_DIR/MIUIPackageInstaller.apk" | grep -qx 'assets/dexopt/baseline.prof'; then
    PROFILE_STATUS="present"
    echo "[InstallerX] Baseline Profile: present"
else
    PROFILE_STATUS="not packaged by upstream dev build"
    echo "::warning::Upstream dev APK does not contain assets/dexopt/baseline.prof"
fi

APK_SHA256="$(sha256sum "$OUTPUT_DIR/MIUIPackageInstaller.apk" | awk '{print $1}')"
echo "[InstallerX] Package: $TARGET_PACKAGE"
echo "[InstallerX] Version: ${VERSION_NAME:-unknown} (${VERSION_CODE:-unknown})"
echo "[InstallerX] APK: $OUTPUT_DIR/MIUIPackageInstaller.apk"
echo "[InstallerX] SHA-256: $APK_SHA256"

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
        echo "### InstallerX Dev APK"
        echo "- Upstream branch: dev"
        echo "- Upstream commit: $SOURCE_SHA"
        echo "- Package: $TARGET_PACKAGE"
        echo "- Version: ${VERSION_NAME:-unknown} (${VERSION_CODE:-unknown})"
        echo "- R8: enabled (mapping generated)"
        echo "- Baseline Profile: $PROFILE_STATUS"
        echo "- Signing: HyperMOS testkey verified"
        echo "- APK SHA-256: $APK_SHA256"
    } >> "$GITHUB_STEP_SUMMARY"
fi
