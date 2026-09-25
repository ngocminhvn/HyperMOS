work_dir=$(pwd)
source $work_dir/functions.sh
rom_os=$(cat $work_dir/bin/ddevice/rom_os.txt)
regionTYPE=$(cat $work_dir/bin/ddevice/device_type.txt)
androidVER=$(cat $work_dir/bin/ddevice/androidver.txt)
MAIN_FOLDER="$work_dir/build/baserom/images"

isSTOCKVault=$(find "$MAIN_FOLDER" -type d \( -name "MIUIGlobalMinusScreenWidget" -o -name "MIUIGlobalMinusScreen" -o -name "MIUIPersonalAssistantT" -o -name "MIUIPersonalAssistant" -o -name "PersonalAssistant" -o -name "MIUIPersonalAssistantPhoneMIUI15" -o -name "MIUIPersonalAssistantPhoneOS2NoBeta" -o -name "MIUIPersonalAssistantPhoneOS2" -o -name "PersonalAssistant" -o -name "MIUIPersonalAssistantPhoneMIUI15" -o -name "MIUIPersonalAssistantPhoneOS2NoBeta" -o -name "MIUIPersonalAssistantPhoneOS3" -o -name "PersonalAssistant" -o -name "MIUIPersonalAssistantPhoneMIUI15" -o -name "MIUIPersonalAssistantPhoneOS2NoBeta" -o -name "MIUIPersonalAssistantOS3" \))

if [[ $androidVER == "16" ]]; then
    rm -rf $isSTOCKVault
    mkdir -p $work_dir/build/baserom/images/product/priv-app/MIUIPersonalAssistant
    cp -rf $work_dir/bin/modfile/Appmod/appvault/MIUIPersonalAssistant/*.apk $work_dir/build/baserom/images/product/priv-app/MIUIPersonalAssistant/
    mkdir -p $work_dir/build/baserom/images/product/priv-app/MIUIPersonalAssistant/lib/arm64
    unzip -q -j "$work_dir/build/baserom/images/product/priv-app/MIUIPersonalAssistant/"*.apk "lib/arm64-v8a/*" -d "$work_dir/build/baserom/images/product/priv-app/MIUIPersonalAssistant/lib/arm64/" 2>/dev/null || true
    cp -rf $work_dir/bin/modfile/Appmod/appvault/permissions/privapp_whitelist_com.miui.personalassistant.xml $work_dir/build/baserom/images/product/etc/permissions/
    mods "Modify Appvault Done"
else
    echo "Lỗi quá trình mod Appvault"
    exit 1
fi