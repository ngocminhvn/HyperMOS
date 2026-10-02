work_dir=$(pwd)
source "$work_dir/functions.sh"

rom_os=$(cat "$work_dir/bin/ddevice/rom_os.txt")
MAIN_FOLDER="$work_dir/build/baserom/images"
regionTYPE=$(cat "$work_dir/bin/ddevice/device_type.txt")
androidVER=$(cat "$work_dir/bin/ddevice/androidver.txt")
APKEDITOR="java -jar $work_dir/bin/apktool/apke.jar"

if [[ $regionTYPE == "China" ]]; then
    mods "Patching Enhanced Keyboard"

    # HyperOS China input helper should point to Gboard after the China IMEs are removed.
    TARGET_IME_PACKAGE="com.google.android.inputmethod.latin"

    if [[ $androidVER == "16" ]]; then
        GMS_A16="$work_dir/bin/modfile/Universal/gmsservices16"
        GBOARD_HELPER="$GMS_A16/gboard.inc"
        GBOARD_A16_APK="$GMS_A16/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk"

        if [[ ! -f "$GBOARD_HELPER" ]]; then
            echo "[ERROR] Missing gmsservices16 Gboard helper: $GBOARD_HELPER"
            exit 1
        fi

        source "$GBOARD_HELPER"
        if ! ensure_gboard_a16; then
            echo "[ERROR] Gboard A16 is required before Enhanced Keyboard patch"
            exit 1
        fi

        if [[ ! -s "$GBOARD_A16_APK" ]]; then
            echo "[ERROR] Gboard A16 payload missing in gmsservices16"
            exit 1
        fi
    fi

    MIUIFrequentPhraseDIR=$(find "$MAIN_FOLDER" -type d -name "MIUIFrequentPhrase" | head -n 1)
    MIUIFrequentPhrase=$(find "$MAIN_FOLDER" -type f -name "MIUIFrequentPhrase.apk" | head -n 1)

    if [[ -z "$MIUIFrequentPhrase" || ! -f "$MIUIFrequentPhrase" ]]; then
        echo "[INFO] MIUIFrequentPhrase.apk not found, skip Enhanced Keyboard patch"
        exit 0
    fi

    rm -rf "$work_dir/apk_temp"
    mkdir -p "$work_dir/apk_temp/final"

    if ! $APKEDITOR d -t raw -f -no-dex-debug         -i "$MIUIFrequentPhrase"         -o "$work_dir/apk_temp/MIUIFrequentPhrase.apk.out" >/dev/null 2>&1; then
        echo "[ERROR] Failed to decode MIUIFrequentPhrase.apk"
        rm -rf "$work_dir/apk_temp"
        exit 1
    fi

    Smali1=$(find "$work_dir/apk_temp/MIUIFrequentPhrase.apk.out"         -type f -name "InputMethodBottomManager.smali" 2>/dev/null | head -n 1)

    if [[ -z "$Smali1" || ! -f "$Smali1" ]]; then
        echo "[INFO] InputMethodBottomManager.smali not found, skip Enhanced Keyboard patch"
        rm -rf "$work_dir/apk_temp"
        exit 0
    fi

    # Cover the common China keyboard package names and make the patch idempotent.
    sed -i         -e "s/com\.baidu\.input_mi/$TARGET_IME_PACKAGE/g"         -e "s/com\.iflytek\.inputmethod\.miui/$TARGET_IME_PACKAGE/g"         -e "s/com\.sohu\.inputmethod\.sogou\.xiaomi/$TARGET_IME_PACKAGE/g"         "$Smali1"

    if ! grep -q "$TARGET_IME_PACKAGE" "$Smali1"; then
        echo "[INFO] No supported China IME package found in InputMethodBottomManager.smali"
        rm -rf "$work_dir/apk_temp"
        exit 0
    fi

    MIUIFrequentPhraseName=$(basename "$MIUIFrequentPhrase")

    if ! $APKEDITOR b -f         -i "$work_dir/apk_temp/MIUIFrequentPhrase.apk.out"         -o "$work_dir/apk_temp/final/$MIUIFrequentPhraseName" >/dev/null 2>&1; then
        echo "[ERROR] Failed to rebuild MIUIFrequentPhrase.apk"
        rm -rf "$work_dir/apk_temp"
        exit 1
    fi

    if [[ ! -s "$work_dir/apk_temp/final/$MIUIFrequentPhraseName" ]]; then
        echo "[ERROR] Rebuilt MIUIFrequentPhrase.apk is missing"
        rm -rf "$work_dir/apk_temp"
        exit 1
    fi

    rm -rf "$MIUIFrequentPhraseDIR/oat"
    rm -f "$MIUIFrequentPhraseDIR/$MIUIFrequentPhraseName"
    cp -f "$work_dir/apk_temp/final/$MIUIFrequentPhraseName" "$MIUIFrequentPhraseDIR/"

    rm -rf "$work_dir/apk_temp"
    mods "Enhanced Keyboard -> $TARGET_IME_PACKAGE Done"
fi
