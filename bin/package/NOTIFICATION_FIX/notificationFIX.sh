WORK_DIR=$(pwd)
source $WORK_DIR/functions.sh

# Android 16 uses separate CN/ and EU/ notification patch directories.
# Never port China-only FrameworkPatcher, notification DEX or EU donor PowerKeeper.
rom_source_file="$WORK_DIR/bin/ddevice/rom_source.txt"
if [[ -s "$rom_source_file" ]]; then
    rom_source="$(tr -d '\r\n' < "$rom_source_file")"
    if [[ "$rom_source" == "xiaomi_eu" ]]; then
        # Xiaomi.eu: donor-verified ZK304 notification policy and guarded PowerKeeper method port.
        if [[ "$(tr -d '\r\n' < "$WORK_DIR/bin/ddevice/androidver.txt")" == "16" ]]; then
            bash "$WORK_DIR/bin/package/NOTIFICATION_FIX/A16/EU/ContentCatcher_EU.sh" || exit 1
            # Donor methods compile, but EU309 source PowerKeeper.apk did not
            # pass the original-package signature check in production build.
            # Preserve EU APK by default rather than ship an unverified APK.
            if [[ "${HYPERMOS_EU_ZK304_PK_EXPERIMENTAL:-0}" == "1" ]]; then
                bash "$WORK_DIR/bin/package/NOTIFICATION_FIX/A16/EU/PowerKeeper_ZK.sh" || exit 1
            else
                warn "EU ZK304 PowerKeeper port NOT applied: original EU APK verification blocked full ROM build; preserving stock APK"
            fi
        fi
        exit 0
    fi
fi

info "PATCH 4/6: Notification"
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
    bash "$WORK_DIR/bin/package/NOTIFICATION_FIX/A16/CN/FrameworkPatcher.sh" || exit 1
    bash "$WORK_DIR/bin/package/NOTIFICATION_FIX/A16/CN/PowerKeeper.sh" || exit 1
    # Keep the stock Android 16 MiuiSystemUI.apk untouched.
elif [[ $AndroidVER == "17" ]];then
    bash $WORK_DIR/bin/package/NOTIFICATION_FIX/PowerKeeper.sh
    bash $WORK_DIR/bin/package/NOTIFICATION_FIX/A17/SystemUI.sh
fi

fi
