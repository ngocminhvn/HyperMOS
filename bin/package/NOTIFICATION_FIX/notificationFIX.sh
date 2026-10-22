WORK_DIR=$(pwd)
source $WORK_DIR/functions.sh

# Android 16 is routed to a single version-specific entrypoint. The two
# policy variants remain separate inside the version directory.
source_file="$WORK_DIR/bin/ddevice/rom_source.txt"
rom_source=""
if [[ -s "$source_file" ]]; then
    rom_source="$(tr -d '\r\n' < "$source_file")"
fi
android_version="$(tr -d '\r\n' < "$WORK_DIR/bin/ddevice/androidver.txt")"
region_type="$(tr -d '\r\n' < "$WORK_DIR/bin/ddevice/device_type.txt")"
if [[ "$android_version" == "16" ]]; then
    if [[ "$rom_source" == "xiaomi_eu" || "$region_type" != *"Global"* ]]; then
        bash "$WORK_DIR/bin/package/NOTIFICATION_FIX/A16/patch.sh" || exit 1
    else
        warn "No Support Global ROM! Skipping notification fix..."
    fi
    exit 0
fi
# Xiaomi.eu non-A16 builds do not borrow China-only methods/donors.
if [[ "$rom_source" == "xiaomi_eu" ]]; then
    exit 0
fi

info "Notification policy: Android $android_version"
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
elif [[ $AndroidVER == "17" ]];then
    bash "$WORK_DIR/bin/package/NOTIFICATION_FIX/A17/patch.sh" || exit 1
fi

fi
