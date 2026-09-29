#!/bin/bash
set -e

# SPDX-License-Identifier: GPL-3.0

dir=$(pwd)
work_dir="$dir"
sdkLevel=$(tr -d ' \r\n' < "$dir/bin/ddevice/sdkLevel.txt")
patch_py="$dir/bin/package/KouseiPatcher/toolbox.py"
a17_patch_py="$dir/bin/package/KouseiPatcher/a17_patcher.py"

if [[ ! "$sdkLevel" =~ ^[0-9]+$ ]]; then
    echo "Invalid sdkLevel: $sdkLevel"
    exit 1
fi

if (( sdkLevel >= 37 )); then
    echo "Kaorios patch mode: Android 17 / SDK $sdkLevel"
else
    echo "Kaorios patch mode: Android 13-16 / SDK $sdkLevel"
fi

mkdir -p "$dir/jar_temp"

get_file_dir() {
    if [[ -n "$1" ]]; then
        sudo find "$dir/build/baserom/images/" -type f -name "$1" | head -n 1
    fi
}

jar_util() {
    cd "$dir"

    if [[ "$3" == "fw" ]]; then
        bak="java -jar $dir/bin/apktool/baksmaliv2.jar d --api $sdkLevel"
        sma="java -jar $dir/bin/apktool/smaliv2.jar a --api $sdkLevel"
    fi

    if [[ "$1" == "d" ]]; then
        echo -ne "====> Patching $2 : "

        file_path=$(get_file_dir "$2")
        if [[ -z "$file_path" ]]; then
            echo "Fail - $2 not found"
            return 1
        fi

        rm -rf "$dir/jar_temp/$2" "$dir/jar_temp/$2.out"
        sudo cp "$file_path" "$dir/jar_temp/$2"
        sudo chown "$(whoami)" "$dir/jar_temp/$2"
        unzip "$dir/jar_temp/$2" -d "$dir/jar_temp/$2.out" >/dev/null 2>&1
        rm -f "$dir/jar_temp/$2"

        for dex in "$dir/jar_temp/$2.out"/classes*.dex; do
            [[ -f "$dex" ]] || continue
            $bak "$dex" -o "$dex.out"
            [[ -d "$dex.out" ]] && rm -f "$dex"
        done
        return 0
    fi

    if [[ "$1" == "a" && -d "$dir/jar_temp/$2.out" ]]; then
        cd "$dir/jar_temp/$2.out"

        for fld in ./*.dex.out; do
            [[ -d "$fld" ]] || continue
            $sma "$fld" -o "${fld%.out}"
            [[ -f "${fld%.out}" ]] && rm -rf "$fld"
        done

        rm -f "$dir/jar_temp/$2_notal" "$dir/jar_temp/$2"
        7za a -tzip -mx=0 "$dir/jar_temp/$2_notal" "$dir/jar_temp/$2.out/." >/dev/null 2>&1
        zipalign 4 "$dir/jar_temp/$2_notal" "$dir/jar_temp/$2"

        if [[ -f "$dir/jar_temp/$2" ]]; then
            sudo cp -f "$dir/jar_temp/$2" "$(get_file_dir "$2")"
            echo "Success"
            rm -rf "$dir/jar_temp/$2.out" "$dir/jar_temp/$2_notal" "$dir/jar_temp/$2"
        else
            echo "Fail"
            return 1
        fi
    fi
}

mvsml() {
    local file_name="$1"
    local target_folder="$2"
    local framework_dir="$work_dir/jar_temp/framework.jar.out"
    local file_path

    file_path=$(find "$framework_dir" -type f -name "$file_name" | head -n 1)
    if [[ -z "$file_path" ]]; then
        echo "File $file_name not found in $framework_dir"
        return 1
    fi

    local parent_dex_folder
    local relative_path
    local target_path

    parent_dex_folder=$(echo "$file_path" | sed "s|$framework_dir/||" | cut -d/ -f1)
    relative_path=$(echo "$file_path" | sed "s|$framework_dir/$parent_dex_folder/||")
    target_path="$target_folder/$relative_path"

    mkdir -p "$(dirname "$target_path")"
    mv "$file_path" "$target_path"
    echo "Moved $file_name -> $(basename "$target_folder")"
}

next_dex_number() {
    local framework_dir="$1"
    local max=0
    local path base suffix num

    shopt -s nullglob
    for path in "$framework_dir"/classes*.dex.out "$framework_dir"/classes*.dex; do
        base=$(basename "$path")
        if [[ "$base" =~ ^classes([0-9]*)\.dex(\.out)?$ ]]; then
            suffix="${BASH_REMATCH[1]}"
            if [[ -z "$suffix" ]]; then
                num=1
            else
                num="$suffix"
            fi
            (( num > max )) && max=$num
        fi
    done
    shopt -u nullglob

    echo $((max + 1))
}

Patch_Framework() {
    jar_util d 'framework.jar' fw 0 10
    FRAMEWORK_DIR="$dir/jar_temp/framework.jar.out"

    # Common Android 13-17 framework hooks + Developer Options/ADB hide.
    python3 "$patch_py" "$FRAMEWORK_DIR"

    # Android 17 has extra ActivityThread + Build/Build$VERSION requirements.
    if (( sdkLevel >= 37 )); then
        python3 "$a17_patch_py" "$FRAMEWORK_DIR" --framework
    fi

    patch_dex_num=$(next_dex_number "$FRAMEWORK_DIR")
    patch_dex_folder="$FRAMEWORK_DIR/classes${patch_dex_num}.dex.out"
    mkdir -p "$patch_dex_folder"

    mvsml "AndroidKeyStoreSpi.smali" "$patch_dex_folder"
    mvsml "Instrumentation.smali" "$patch_dex_folder"
    mvsml "AndroidKeyStoreKeyPairGeneratorSpi.smali" "$patch_dex_folder"
    mvsml "ApplicationPackageManager.smali" "$patch_dex_folder"
    mvsml 'Settings$NameValueCache.smali' "$patch_dex_folder"

    if (( sdkLevel >= 37 )); then
        mvsml "ActivityThread.smali" "$patch_dex_folder"
        mvsml "Build.smali" "$patch_dex_folder"
        mvsml 'Build$VERSION.smali' "$patch_dex_folder"
    fi

    # Keep Kaorios release-108 driver as its own DEX.
    driver_dex_num=$((patch_dex_num + 1))
    driver_dex="$dir/bin/package/KouseiPatcher/classes.dex"
    if [[ ! -f "$driver_dex" ]]; then
        echo "Missing Kaorios classes.dex: $driver_dex"
        exit 1
    fi
    cp -f "$driver_dex" "$FRAMEWORK_DIR/classes${driver_dex_num}.dex"

    jar_util a 'framework.jar' fw 0 10
}

Patch_services() {
    jar_util d 'services.jar' fw 0 10
    SERVICES_DIR="$dir/jar_temp/services.jar.out"

    if (( sdkLevel >= 37 )); then
        # A17 uses the Looper.loop() anchor.
        python3 "$a17_patch_py" "$SERVICES_DIR" --services
    else
        # A13-16 uses the startOtherServices(...) anchor.
        python3 "$patch_py" "$SERVICES_DIR" --services
    fi

    jar_util a 'services.jar' fw 0 10
}

Patch_Framework
Patch_services
