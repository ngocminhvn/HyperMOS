work_dir=$(pwd) 
source $work_dir/functions.sh

# Define ROM infomation
androidVer=$(cat $work_dir/bin/ddevice/androidver.txt)
rom_os=$(cat $work_dir/bin/ddevice/rom_os.txt)
deviceTYPE=$(cat $work_dir/bin/ddevice/device_type.txt)
MAIN_FOLDER="$work_dir/build/baserom/images"


mods "Fix Fonts"
if [[ $deviceTYPE == "China" ]];then
    if [[ $rom_os == "MIUI" ]];then
        mods "Detect MIUI!Adding..."
        cp -rf $work_dir/bin/modfile/UpdateFile/Fonts/MIUI/fonts.xml $work_dir/build/baserom/images/system/system/etc/
        cp -rf $work_dir/bin/modfile/UpdateFile/Fonts/MIUI/*.ttf $work_dir/build/baserom/images/system/system/fonts/
    elif [[ $rom_os == "OS1" ]] && [[ $androidVer -le "13" ]];then
        mods "Detect HyperOS A13!Adding..."
		rm $work_dir/build/baserom/images/system/system/fonts/MiSansLatinVF.ttf
		rm $work_dir/build/baserom/images/system/system/fonts/MiSansVF.ttf
		rm $work_dir/build/baserom/images/system/system/fonts/MiSansVF_Overlay.ttf
        cp -rf $work_dir/bin/modfile/UpdateFile/Fonts/HyperOS/*.ttf $work_dir/build/baserom/images/system/system/fonts/
	elif [[ $rom_os == "OS1" ]] && [[ $androidVer -le "14" ]];then
        mods "Detect HyperOS!Adding..."
		rm $work_dir/build/baserom/images/system/system/fonts/MiSansLatinVF.ttf
		rm $work_dir/build/baserom/images/system/system/fonts/MiSansVF.ttf
		rm $work_dir/build/baserom/images/system/system/fonts/MiSansVF_Overlay.ttf
        cp -rf $work_dir/bin/modfile/UpdateFile/Fonts/HyperOS/*.ttf $work_dir/build/baserom/images/system/system/fonts/
		cp -rf $work_dir/bin/modfile/UpdateFile/Fonts/HyperOS/A14/*.ttf $work_dir/build/baserom/images/product/fonts/
	elif [[ $rom_os == "OS2" ]] && [[ $androidVer -le "14" ]];then
        mods "Detect HyperOS!Adding..."
		rm $work_dir/build/baserom/images/system/system/fonts/MiSansLatinVF.ttf
		rm $work_dir/build/baserom/images/system/system/fonts/MiSansVF.ttf
		rm $work_dir/build/baserom/images/system/system/fonts/MiSansVF_Overlay.ttf
        cp -rf $work_dir/bin/modfile/UpdateFile/Fonts/HyperOS/*.ttf $work_dir/build/baserom/images/system/system/fonts/
		cp -rf $work_dir/bin/modfile/UpdateFile/Fonts/HyperOS/A14/*.ttf $work_dir/build/baserom/images/product/fonts/
	elif [[ $rom_os == "OS2" ]] && [[ $androidVer -le "15" ]];then
        mods "Detect HyperOS!Adding..."
		rm $work_dir/build/baserom/images/system/system/fonts/MiSansLatinVF.ttf
		rm $work_dir/build/baserom/images/system/system/fonts/MiSansVF.ttf
		rm $work_dir/build/baserom/images/system/system/fonts/MiSansVF_Overlay.ttf
        cp -rf $work_dir/bin/modfile/UpdateFile/Fonts/HyperOS/*.ttf $work_dir/build/baserom/images/system/system/fonts/
		cp -rf $work_dir/bin/modfile/UpdateFile/Fonts/HyperOS/A14/*.ttf $work_dir/build/baserom/images/product/fonts/
	elif [[ $rom_os == "OS3" ]] && [[ $androidVer -le "16" ]];then
        mods "Detect HyperOS!Adding..."
		rm $work_dir/build/baserom/images/system/system/fonts/MiSansLatinVF.ttf
		rm $work_dir/build/baserom/images/system/system/fonts/MiSansVF.ttf
		rm $work_dir/build/baserom/images/system/system/fonts/MiSansVF_Overlay.ttf
        cp -rf $work_dir/bin/modfile/UpdateFile/Fonts/HyperOS/*.ttf $work_dir/build/baserom/images/system/system/fonts/
		cp -rf $work_dir/bin/modfile/UpdateFile/Fonts/HyperOS/A14/*.ttf $work_dir/build/baserom/images/product/fonts/
    fi
else
mods "Global ROM!No Adding..."
fi
mods "Done"
# ======================================================================
# FONT OVERRIDE: SF Pro
# ======================================================================
FONT_SOURCE="$work_dir/bin/modfile/UpdateFile/Fonts/HyperOS"
SYS_TARGET="$work_dir/build/baserom/images/system/system/fonts"
PROD_TARGET="$work_dir/build/baserom/images/product/fonts"
PRIMARY_FONT="$FONT_SOURCE/SF-Pro.ttf"

copy_primary_font_from_list() {
    local list_file="$1"
    local target_dir="$2"
    local failed=0

    [ -f "$list_file" ] || return 1
    [ -f "$PRIMARY_FONT" ] || return 1
    mkdir -p "$target_dir" || return 1

    while IFS= read -r target_name || [ -n "$target_name" ]; do
        target_name=$(printf '%s' "$target_name" | tr -d '\r' | xargs)
        [[ -z "$target_name" || "$target_name" =~ ^# ]] && continue
        cp -f "$PRIMARY_FONT" "$target_dir/$target_name" >/dev/null 2>&1 || failed=1
    done < "$list_file"

    return "$failed"
}

apply_sfpro() {
    local failed=0
    copy_primary_font_from_list "$FONT_SOURCE/system_fonts.list" "$SYS_TARGET" || failed=1
    copy_primary_font_from_list "$FONT_SOURCE/product_fonts.list" "$PROD_TARGET" || failed=1

    if [ "$failed" -eq 0 ]; then
        mods "Font SF Pro: OK"
    else
        mods "Font SF Pro: ERROR"
        return 1
    fi
}

if { [[ $rom_os == "OS3" ]] && [[ $androidVer -le "16" ]]; } || \
   { [[ $rom_os == "OS4" ]] && [[ $androidVer -le "17" ]]; }; then
    apply_sfpro
fi

# ======================================================================
