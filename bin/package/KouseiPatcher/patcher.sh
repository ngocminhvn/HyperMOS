#!/bin/bash
# SPDX-License-Identifier: GPL-3.0

dir=$(pwd)
work_dir="$dir"
sdkLevel=$(cat $dir/bin/ddevice/sdkLevel.txt)
patch="python3 $dir/bin/package/KouseiPatcher/toolbox.py"
JARDIR="$dir/jar_temp"

if [[ ! -d $dir/jar_temp ]]; then

	mkdir $dir/jar_temp
	
fi

get_file_dir() {
	if [[ $1 ]]; then
		sudo find $dir/build/baserom/images/ -name $1 
	else 
		return 0
	fi
}

jar_util()
{
    cd "$dir" || return 1

    if [[ "$3" == "fw" ]]; then
        bak="java -jar $dir/bin/apktool/baksmaliv2.jar d --api $sdkLevel"
        sma="java -jar $dir/bin/apktool/smaliv2.jar a --api $sdkLevel"
    fi

    if [[ "$1" == "d" ]]; then
        echo -ne "====> Patching $2 : "

        file_path=$(get_file_dir "$2" | head -n 1)
        [[ -n "$file_path" && -f "$file_path" ]] || {
            echo "Fail (source not found)"
            return 1
        }

        rm -rf "$dir/jar_temp/$2.out"
        sudo cp "$file_path" "$dir/jar_temp/$2" || return 1
        sudo chown "$(whoami)" "$dir/jar_temp/$2" || return 1
        unzip "$dir/jar_temp/$2" -d "$dir/jar_temp/$2.out" >/dev/null 2>&1 || return 1

        rm -f "$dir/jar_temp/$2"
        while IFS= read -r dex; do
            [[ -f "$dex" ]] || continue
            if [[ "$4" && "$dex" == *"$4"* ]]; then
                continue
            fi
            $bak "$dex" -o "$dex.out" || return 1
            [[ -d "$dex.out" ]] || return 1
            rm -f "$dex"
        done < <(find "$dir/jar_temp/$2.out" -maxdepth 1 -type f -name "*dex" | LC_ALL=C sort)

        return 0
    fi

    if [[ "$1" == "a" ]]; then
        [[ -d "$dir/jar_temp/$2.out" ]] || return 1
        cd "$dir/jar_temp/$2.out" || return 1

        while IFS= read -r fld; do
            [[ -d "$fld" ]] || continue
            if [[ "$4" && "$fld" == *"$4"* ]]; then
                continue
            fi
            out_dex="${fld%.out}"
            $sma "$fld" -o "$out_dex" || return 1
            [[ -f "$out_dex" ]] || return 1
            rm -rf "$fld"
        done < <(find . -maxdepth 1 -type d -name "*.out" | LC_ALL=C sort)

        rm -f "$dir/jar_temp/$2_notal" "$dir/jar_temp/$2"
        zip_bin=$(command -v 7za || command -v 7z) || return 1
        "$zip_bin" a -tzip -mx=0 "$dir/jar_temp/$2_notal" "$dir/jar_temp/$2.out/." >/dev/null 2>&1 || return 1
        zipalign 4 "$dir/jar_temp/$2_notal" "$dir/jar_temp/$2" || return 1

        target_path=$(get_file_dir "$2" | head -n 1)
        [[ -n "$target_path" && -f "$dir/jar_temp/$2" ]] || {
            echo "Fail"
            return 1
        }

        sudo cp -rf "$dir/jar_temp/$2" "$target_path" || return 1
        echo "Success"
        rm -rf "$dir/jar_temp/$2.out" "$dir/jar_temp/$2_notal" "$dir/jar_temp/$2"
        return 0
    fi

    return 1
}

mvsml() {
    local file_name="$1"
    local target_folder="$2"
    local framework_dir="$work_dir/jar_temp/framework.jar.out"

    # Search for the smali file within the framework directory
    file_path=$(find "$framework_dir" -type f -name "$file_name")

    if [ -z "$file_path" ]; then
        echo "File $file_name not found in any dex folder within $framework_dir."
        return 1
    fi

    # Extract the parent dex folder and the relative path from it
    parent_dex_folder=$(dirname "$file_path" | sed "s|$framework_dir/||" | cut -d/ -f1)
    relative_path=$(echo "$file_path" | sed "s|$framework_dir/$parent_dex_folder/||")

    # Construct the new target path, preserving subdirectories
    target_path="$target_folder/$relative_path"

    # Ensure the target directory exists
    mkdir -p "$(dirname "$target_path")"

    # Move the file
    mv "$file_path" "$target_path"

    echo "Moved $file_name to $target_path"
}

mvdir() {
    local folder_name="$1"
    local target_folder="$2"
    local framework_dir="$work_dir/jar_temp/framework.jar.out"

    # Search for the folder within the framework directory
    folder_path=$(find "$framework_dir" -type d -name "$folder_name")

    if [ -z "$folder_path" ]; then
        echo "Folder $folder_name not found in any dex folder within $framework_dir."
        return 1
    fi

    # Loop through all .smali files in the found folder
    find "$folder_path" -type f -name "*.smali" | while read -r file_path; do
        # Extract the relative path from the framework_dir
        parent_dex_folder=$(dirname "$file_path" | sed "s|$framework_dir/||" | cut -d/ -f1)
        relative_path=$(echo "$file_path" | sed "s|$framework_dir/$parent_dex_folder/||")

        # Construct the new target path, preserving subdirectories
        target_path="$target_folder/$relative_path"

        # Ensure the target directory exists
        mkdir -p "$(dirname "$target_path")"

        # Move the file
        mv "$file_path" "$target_path"
    done

    echo "Moved all .smali files from $folder_name to $target_folder"
}


Patch_Framework () {

    jar_util d 'framework.jar' fw 0 10 || return 1
    FRAMEWORK_DIR="$dir/jar_temp/framework.jar.out"

    $patch "$FRAMEWORK_DIR" || return 1

    max_dex=1
    while IFS= read -r dex_dir; do
        dex_name=$(basename "$dex_dir")
        if [[ "$dex_name" == "classes.dex.out" ]]; then
            dex_num=1
        else
            dex_num="${dex_name#classes}"
            dex_num="${dex_num%.dex.out}"
            [[ "$dex_num" =~ ^[0-9]+$ ]] || continue
        fi
        (( dex_num > max_dex )) && max_dex=$dex_num
    done < <(find "$FRAMEWORK_DIR" -maxdepth 1 -type d -name "classes*.dex.out" | LC_ALL=C sort)

    new_dex=$((max_dex + 1))
    new_dex_folder="$FRAMEWORK_DIR/classes$new_dex.dex.out"
    mkdir -p "$new_dex_folder" || return 1

    mvsml "AndroidKeyStoreSpi.smali" "$new_dex_folder" >/dev/null || return 1
    mvsml "Instrumentation.smali" "$new_dex_folder" >/dev/null || return 1
    mvsml "AndroidKeyStoreKeyPairGeneratorSpi.smali" "$new_dex_folder" >/dev/null || return 1
    mvsml "ApplicationPackageManager.smali" "$new_dex_folder" >/dev/null || return 1
    mvsml "Settings\$NameValueCache.smali" "$new_dex_folder" >/dev/null || return 1

    cp -rf "$dir/bin/package/KouseiPatcher/smali/." "$new_dex_folder/" || return 1
    jar_util a 'framework.jar' fw 0 10 || return 1
}

Patch_services () {

    jar_util d 'services.jar' fw 0 10 || return 1
    $patch "$dir/jar_temp/services.jar.out" --services || return 1
    jar_util a 'services.jar' fw 0 10 || return 1
}

Patch_Framework || exit 1
Patch_services || exit 1
