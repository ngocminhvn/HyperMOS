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
# FONT OVERRIDE: ưu tiên SF Pro (font hệ thống iPhone), fallback Bauhaus
# ======================================================================
FONT_SOURCE="$work_dir/bin/modfile/UpdateFile/Fonts/HyperOS"
SYS_TARGET="$work_dir/build/baserom/images/system/system/fonts"
PROD_TARGET="$work_dir/build/baserom/images/product/fonts"

# Không commit/phân phối SF Pro từ nguồn khác tại đây.
# Chỉ cần tự đặt file đã có quyền sử dụng vào:
#   bin/modfile/UpdateFile/Fonts/HyperOS/SFPro.ttf
if [ -f "$FONT_SOURCE/SFPro.ttf" ]; then
    PRIMARY_FONT="$FONT_SOURCE/SFPro.ttf"
    PRIMARY_FONT_NAME="SFPro.ttf"
else
    PRIMARY_FONT="$FONT_SOURCE/Bauhaus.ttf"
    PRIMARY_FONT_NAME="Bauhaus.ttf"
    mods "SFPro.ttf not found, fallback to Bauhaus.ttf"
fi

copy_primary_font_from_list() {
    local list_file="$1"
    local target_dir="$2"
    local label="$3"

    [ -f "$list_file" ] || return 0
    [ -f "$PRIMARY_FONT" ] || {
        mods "Primary font not found, skip $label font override"
        return 0
    }

    mkdir -p "$target_dir"
    mods "Applying $PRIMARY_FONT_NAME using $(basename "$list_file")"

    while IFS= read -r target_name || [ -n "$target_name" ]; do
        target_name=$(printf '%s' "$target_name" | tr -d '\r' | xargs)
        [[ -z "$target_name" || "$target_name" =~ ^# ]] && continue

        cp -f "$PRIMARY_FONT" "$target_dir/$target_name"
        echo " -> [Font $label] $PRIMARY_FONT_NAME -> $target_name"
    done < "$list_file"
}

# HyperOS 3 / Android 16
if [[ $rom_os == "OS3" ]] && [[ $androidVer -le "16" ]]; then
    mods "Force processing iPhone-style Font List for OS3..."
    copy_primary_font_from_list "$FONT_SOURCE/system_fonts.list" "$SYS_TARGET" "System"
    copy_primary_font_from_list "$FONT_SOURCE/product_fonts.list" "$PROD_TARGET" "Product"
fi

# HyperOS 4 / Android 17
if [[ $rom_os == "OS4" ]] && [[ $androidVer -le "17" ]]; then
    mods "Force processing iPhone-style Font List for OS4..."
    copy_primary_font_from_list "$FONT_SOURCE/system_fonts.list" "$SYS_TARGET" "System"
    copy_primary_font_from_list "$FONT_SOURCE/product_fonts.list" "$PROD_TARGET" "Product"
fi

# ======================================================================
