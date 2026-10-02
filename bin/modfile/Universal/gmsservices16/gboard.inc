# Google Keyboard payload manager for Android 16 / arm64.
# Kept inside gmsservices16 so the legacy gmsservices payload stays unchanged.

GBOARD_A16_URL="https://sourceforge.net/projects/litegapps/files/addon/arm64/36/gapps/GoogleKeyboard/GoogleKeyboard-LiteGapps-Addon-arm64-16.0.zip/download"
GBOARD_A16_ZIP_SHA256="6fe9ae5d44c0faf162a951e648f8b320628ac444a77bdc6ef5be73bb413ca5f8"
GBOARD_A16_APK_SHA256="dce96b08812304387c30e45c67548cff6f00f5a1ed6f457ac7b66618acc1350e"
GBOARD_A16_ENTRY="system/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk"
GBOARD_A16_DIR="$work_dir/bin/modfile/Universal/gmsservices16/product/app/LatinIMEGooglePrebuilt"
GBOARD_A16_APK="$GBOARD_A16_DIR/LatinIMEGooglePrebuilt.apk"
GBOARD_A16_ZIP="$work_dir/.GoogleKeyboard-LiteGapps-Addon-arm64-16.0.zip"

ensure_gboard_a16() {
    local apk_sha=""

    if [[ -s "$GBOARD_A16_APK" ]]; then
        apk_sha=$(sha256sum "$GBOARD_A16_APK" | awk '{print $1}')
        if [[ "$apk_sha" == "$GBOARD_A16_APK_SHA256" ]]; then
            mods "Gboard A16 payload -> Ready"
            return 0
        fi

        echo "[INFO] Existing Gboard A16 payload has unexpected hash; refreshing it"
        rm -f "$GBOARD_A16_APK"
    fi

    mkdir -p "$GBOARD_A16_DIR"
    rm -f "$GBOARD_A16_ZIP" "$GBOARD_A16_APK.tmp"

    mods "Fetching Gboard A16 -> gmsservices16"

    if ! aria2c -q \
        --allow-overwrite=true \
        --auto-file-renaming=false \
        -d "$(dirname "$GBOARD_A16_ZIP")" \
        -o "$(basename "$GBOARD_A16_ZIP")" \
        "$GBOARD_A16_URL"; then
        echo "[ERROR] Failed to download GoogleKeyboard LiteGapps A16"
        rm -f "$GBOARD_A16_ZIP"
        return 1
    fi

    if ! echo "$GBOARD_A16_ZIP_SHA256  $GBOARD_A16_ZIP" | sha256sum -c - >/dev/null 2>&1; then
        echo "[ERROR] GoogleKeyboard A16 ZIP SHA-256 mismatch"
        rm -f "$GBOARD_A16_ZIP"
        return 1
    fi

    if ! unzip -p "$GBOARD_A16_ZIP" "$GBOARD_A16_ENTRY" > "$GBOARD_A16_APK.tmp"; then
        echo "[ERROR] Failed to extract LatinIMEGooglePrebuilt.apk"
        rm -f "$GBOARD_A16_ZIP" "$GBOARD_A16_APK.tmp"
        return 1
    fi

    apk_sha=$(sha256sum "$GBOARD_A16_APK.tmp" | awk '{print $1}')
    if [[ "$apk_sha" != "$GBOARD_A16_APK_SHA256" ]]; then
        echo "[ERROR] LatinIMEGooglePrebuilt.apk SHA-256 mismatch"
        rm -f "$GBOARD_A16_ZIP" "$GBOARD_A16_APK.tmp"
        return 1
    fi

    mv -f "$GBOARD_A16_APK.tmp" "$GBOARD_A16_APK"
    rm -f "$GBOARD_A16_ZIP"

    mods "Gboard A16 -> gmsservices16/product/app/LatinIMEGooglePrebuilt"
}
