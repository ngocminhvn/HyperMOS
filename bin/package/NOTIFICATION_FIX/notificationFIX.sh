WORK_DIR=$(pwd)
source $WORK_DIR/functions.sh

# Xiaomi.eu already provides its own notification/PowerKeeper behavior.
# Never port China-only FrameworkPatcher, notification DEX or EU donor PowerKeeper.
rom_source_file="$WORK_DIR/bin/ddevice/rom_source.txt"
if [[ -s "$rom_source_file" ]]; then
    rom_source="$(tr -d '\r\n' < "$rom_source_file")"
    if [[ "$rom_source" == "xiaomi_eu" ]]; then
        exit 0
    fi
fi

AndroidVER=$(cat $WORK_DIR/bin/ddevice/androidver.txt)
regionTYPE=$(cat $WORK_DIR/bin/ddevice/device_type.txt)

if [[ $regionTYPE == *"Global"* ]]; then
warn "No Support Global ROM!Skipping..."
else
patch "Start Notification FIX..."
if [[ $AndroidVER == "13" ]];then
    bash $WORK_DIR/bin/package/NOTIFICATION_FIX/A13/patchMIUIFramework.sh
    bash $WORK_DIR/bin/package/NOTIFICATION_FIX/A13/patchMIUIServices.sh
    bash $WORK_DIR/bin/package/NOTIFICATION_FIX/A13/PowerKeeper.sh
elif [[ $AndroidVER == "14" ]];then
    bash $WORK_DIR/bin/package/NOTIFICATION_FIX/A14/patchMIUIFramework.sh
    bash $WORK_DIR/bin/package/NOTIFICATION_FIX/A14/patchMIUIServices.sh
    bash $WORK_DIR/bin/package/NOTIFICATION_FIX/A14/PowerKeeper.sh
elif [[ $AndroidVER == "15" ]];then
    bash $WORK_DIR/bin/package/NOTIFICATION_FIX/A15/SystemUI.sh
    bash $WORK_DIR/bin/package/NOTIFICATION_FIX/PowerKeeper.sh
elif [[ $AndroidVER == "16" ]];then
    # FrameworkPatcher A16 CN notification gates are kept separate from COREPATCH.
    bash "$WORK_DIR/bin/package/NOTIFICATION_FIX/A16/FrameworkPatcher.sh" || exit 1
    bash "$WORK_DIR/bin/package/NOTIFICATION_FIX/A16/PowerKeeper.sh" || exit 1
    # Keep the stock Android 16 MiuiSystemUI.apk untouched.
elif [[ $AndroidVER == "17" ]];then
    bash $WORK_DIR/bin/package/NOTIFICATION_FIX/PowerKeeper.sh
    bash $WORK_DIR/bin/package/NOTIFICATION_FIX/A17/SystemUI.sh
fi

fi
