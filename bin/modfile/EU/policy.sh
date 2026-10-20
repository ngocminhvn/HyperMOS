#!/usr/bin/env bash
# Xiaomi.eu-only skip policy. Sourced by the existing mod dispatchers.
# Everything NOT listed here continues through the normal China/shared mod flow.
eu_is_source() {
    local source_file="$(pwd)/bin/ddevice/rom_source.txt"
    [[ -s "$source_file" ]] &&
        [[ "$(tr -d '\r\n' < "$source_file")" == "xiaomi_eu" ]]
}

eu_skip_mod() {
    # Argument: path RELATIVE to bin/modfile, with no leading slash.
    # Preserve Xiaomi.eu-provided Google stack, translations, framework
    # region policies, GPS and notification SystemUI instead of CN patching.
    case "$1" in
        Universal/gmsservices/update.sh|\
        Universal/gmsservices16/update.sh|\
        UpdateFile/MultiLang/update.sh|\
        UpdateFile/Settings_GoogleShowUpCN/update.sh|\
        UpdateFile/Framework_FixDelayPowerMenu/update.sh|\
        UpdateFile/Framework_FixDevicePolicy/update.sh|\
        UpdateFile/Provisions_RegionPatch/update.sh|\
        UpdateFile/GPS_Fix/update.sh|\
        UpdateFile/SystemUI_NotificationColorIcon/update.sh|\
        UpdateFile/Settings_FixNotificationHistory/update.sh|\
        UpdateFile/System_MultiDisableFeature/update.sh)
            return 0 ;;
    esac
    return 1
}

eu_preserve_google_debloat() {
    # Names come from bin/ddevice/DEBLOAT/APPLIST.txt.
    # Keep original EU Google apps and update services. Do NOT blanket-disable
    # debloat: other entries still use the unchanged China list and logic.
    case "$1" in
        Gmail2|GoogleOne|GoogleOne_arm64|Maps|PlayAutoInstallStubApp|\
        GoogleNews_xxhdpi|GoogleNews_xxxhdpi|GoogleNews|Drive|Meet|Photos|\
        YTMusic|YouTube|HealthConnectStub|PersonalSafety|\
        GooglePlayServicesUpdater|GoogleNews|Duo|CalendarGoogle|\
        CalendarGoogle_arm64|CalendarGoogle_xxhdpi|CalendarGoogle_xxxhdpi)
            return 0 ;;
    esac
    return 1
}
