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
# Entries in APPLIST.txt may be either directory names (handled above)
# or Android package names. For package names, read APK manifests and delete
# matching app containers regardless of how the ROM names those directories.
declare -A debloat_packages=()
for debloat_app in "${debloat_apps[@]}"; do
    [[ "$debloat_app" == *.* ]] && debloat_packages["$debloat_app"]=1
done

if (( ${#debloat_packages[@]} > 0 )); then
    app_roots=()
    for partition in system system_ext product mi_ext mi_product vendor odm; do
        for base in "build/baserom/images/$partition" "build/baserom/images/$partition/system"; do
            for kind in app priv-app data-app; do
                [[ -d "$base/$kind" ]] && app_roots+=("$base/$kind")
            done
        done
    done

    if (( ${#app_roots[@]} > 0 )); then
        mapfile -d '' -t apk_files < <(find "${app_roots[@]}" -type f -name '*.apk' -print0)
        for apk in "${apk_files[@]}"; do
            [[ -f "$apk" ]] || continue
            package_name="$(aapt dump badging "$apk" 2>/dev/null |
                sed -n "s/^package: name='\([^']*\)'.*/\1/p" | head -n 1)"
            [[ -n "$package_name" && -n "${debloat_packages[$package_name]:-}" ]] || continue

            for app_root in "${app_roots[@]}"; do
                [[ "$apk" == "$app_root/"* ]] || continue
                relative_apk="${apk#"$app_root/"}"
                if [[ "$relative_apk" == */* ]]; then
                    app_path="$app_root/${relative_apk%%/*}"
                else
                    app_path="$apk"
                fi
                info "Removing package: $package_name -> $app_path"
                rm -rf -- "$app_path"
                break
            done
        done
    fi
fi

info "Debloat Done"

