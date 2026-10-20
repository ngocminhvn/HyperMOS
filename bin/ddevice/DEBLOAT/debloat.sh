WORK_DIR=$(pwd)
source $WORK_DIR/functions.sh

debloat_apps=()
while IFS= read -r line || [[ -n "$line" ]]; do
    debloat_apps+=("$line")
done < $WORK_DIR/bin/ddevice/DEBLOAT/APPLIST.txt

# Xiaomi.eu already bundles Google services and its own updater/provisioning.
# The rest of the user-selected debloat list remains active for EU as on CN.
EU_DEBLOAT=0
if [[ -s "$WORK_DIR/bin/ddevice/rom_source.txt" ]] &&
   [[ "$(tr -d '\r\n' < "$WORK_DIR/bin/ddevice/rom_source.txt")" == "xiaomi_eu" ]]; then
    EU_DEBLOAT=1
    info "Xiaomi.eu: preserve pre-installed Google apps and EU update services"
else
    rm -rf "$WORK_DIR/build/baserom/images/product/etc/auto-install"*
    rm -rf "$WORK_DIR/build/baserom/images/product/app/Updater"
    rm -rf "$WORK_DIR/build/baserom/images/product/etc/permissions/cn.google.services.xml"
fi

for debloat_app in "${debloat_apps[@]}"; do
    if [[ "$EU_DEBLOAT" == "1" ]]; then
        # Only Xiaomi.eu: keep its original GMS apps and updater, otherwise
        # the common APPLIST loop would undo the early updater preservation.
        case "$debloat_app" in
            Gmail2|GoogleOne|GoogleOne_arm64|Maps|PlayAutoInstallStubApp|\
            GoogleNews_xxhdpi|GoogleNews_xxxhdpi|GoogleNews|Drive|Meet|Photos|\
            YTMusic|YouTube|HealthConnectStub|PersonalSafety|\
            GooglePlayServicesUpdater|Duo|CalendarGoogle|\
            CalendarGoogle_arm64|CalendarGoogle_xxhdpi|CalendarGoogle_xxxhdpi|\
            Updater|MIUISystemAppUpdater)
                info "Xiaomi.eu: keep original Google/updater app: $debloat_app"
                continue
                ;;
        esac
    fi
    # Find the app directory in both system and product directories
    app_dirs=$(find build/baserom/images/system/ -type d -name "*$debloat_app*" 2>/dev/null)
    app_dirs2=$(find build/baserom/images/product/ -type d -name "*$debloat_app*" 2>/dev/null)
    app_dirs3=$(find build/baserom/images/mi_ext -type d -name "*$debloat_app*" 2>/dev/null)
    # Combine the directories into one list
    all_app_dirs=($app_dirs $app_dirs2 $app_dirs3)

    for app_dir in "${all_app_dirs[@]}"; do
        # Check if the directory exists before removing
        if [[ -d "$app_dir" ]]; then
            info "Removing directory: $app_dir"
            rm -rf "$app_dir"
        fi
    done
done
info "Debloat Done"

