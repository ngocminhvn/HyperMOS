work_dir=$(pwd)
source "$work_dir/functions.sh"

rom_os=$(cat "$work_dir/bin/ddevice/rom_os.txt")
MAIN_FOLDER="$work_dir/build/baserom/images"
regionTYPE=$(cat "$work_dir/bin/ddevice/device_type.txt")
androidVER=$(cat "$work_dir/bin/ddevice/androidver.txt")
APKEDITOR="java -jar $work_dir/bin/apktool/apke.jar"

if [[ $regionTYPE == "China" ]]; then
mods "Patching Enhanced Keyboard"

if [[ $androidVER == "16" ]]; then
    KEYBOARD_SOURCE="$work_dir/bin/modfile/Universal/gmsservices16/product/app/LatinIMEGooglePrebuilt"
else
    KEYBOARD_SOURCE="$work_dir/bin/modfile/Universal/gmsservices/product/app/LatinIMEGooglePrebuilt"
fi

if [[ -f "$KEYBOARD_SOURCE/LatinIMEGooglePrebuilt.apk" ]]; then
    mkdir -p "$MAIN_FOLDER/product/app/LatinIMEGooglePrebuilt"
    cp -rf "$KEYBOARD_SOURCE/." "$MAIN_FOLDER/product/app/LatinIMEGooglePrebuilt/"
    mods "Keyboard Android ${androidVER} -> Done"
else
    echo "[ERROR] Keyboard not found: $KEYBOARD_SOURCE/LatinIMEGooglePrebuilt.apk"
    exit 1
fi

MIUIFrequentPhraseDIR=$(find "$MAIN_FOLDER" -type d -name "MIUIFrequentPhrase" | head -n 1)
MIUIFrequentPhrase=$(find "$MAIN_FOLDER" -type f -name "MIUIFrequentPhrase.apk" | head -n 1)

if [ -n "$MIUIFrequentPhrase" ] && [ -f "$MIUIFrequentPhrase" ]; then
    mkdir -p "$work_dir/apk_temp"
    $APKEDITOR d -t raw -f -no-dex-debug -i "$MIUIFrequentPhrase" -o "$work_dir/apk_temp/MIUIFrequentPhrase.apk.out" >/dev/null 2>&1
    Smali1=$(find "$work_dir/apk_temp/MIUIFrequentPhrase.apk.out" -type f -name "InputMethodBottomManager.smali" 2>/dev/null | head -n 1)

    if [ -n "$Smali1" ] && [ -f "$Smali1" ]; then
        sed -i 's/com.baidu.input_mi/com.google.android.inputmethod.latin/g' "$Smali1"

        MIUIFrequentPhraseName=$(basename "$MIUIFrequentPhrase")
        mkdir -p "$work_dir/apk_temp/final"
        $APKEDITOR b -f -i "$work_dir/apk_temp/MIUIFrequentPhrase.apk.out" -o "$work_dir/apk_temp/final/$MIUIFrequentPhraseName" >/dev/null 2>&1

        if [ -f "$work_dir/apk_temp/final/$MIUIFrequentPhraseName" ]; then
            rm -rf "$MIUIFrequentPhraseDIR/oat"
            rm -f "$MIUIFrequentPhraseDIR/$MIUIFrequentPhraseName"
            cp -f "$work_dir/apk_temp/final/$MIUIFrequentPhraseName" "$MIUIFrequentPhraseDIR/"
        fi
    else
        mods "InputMethodBottomManager.smali not found, skipping patch"
    fi

    rm -rf "$work_dir/apk_temp"
else
    mods "MIUIFrequentPhrase.apk not found, skipping patch"
fi

mods "Done"
fi
