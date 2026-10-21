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
# Detect Xiaomi media by the actual package name from APK's AndroidManifest,
# not the source ROM's naming convention. Applies to all ROM sources.
# fadeltd/xiaomi-debloater: com.miui.player and com.miui.videoplayer;
# retain the EU-only alternate com.miui.video target from earlier rules.
# aapt is already installed by the official ROM build workflow.
if ! command -v aapt >/dev/null 2>&1; then
    error "Media debloat: aapt is required for exact APK package detection"
    exit 1
fi

media_package_from_apk() {
    aapt dump badging "$1" 2>/dev/null |
        sed -n "s/^package: name='\([^']*\)'.*/\1/p" | head -n 1
}

images_root="$WORK_DIR/build/baserom/images"
media_app_roots=()
for partition in system system_ext product mi_ext mi_product vendor odm; do
    for base in "$images_root/$partition" "$images_root/$partition/system"; do
        for kind in app priv-app data-app; do
            [[ -d "$base/$kind" ]] && media_app_roots+=("$base/$kind")
        done
    done
done

media_scanned=0
media_unreadable=0
media_removed=0
if (( ${#media_app_roots[@]} > 0 )); then
    # Snapshot candidates before deleting containers (NUL-safe paths).
    mapfile -d '' -t media_apks < <(
        find "${media_app_roots[@]}" -type f -iname '*.apk' -print0
    )

    for apk in "${media_apks[@]}"; do
        [[ -f "$apk" ]] || continue
        ((media_scanned+=1))
        package_name="$(media_package_from_apk "$apk")"
        if [[ -z "$package_name" ]]; then
            ((media_unreadable+=1))
            continue
        fi

        case "$package_name" in
            com.miui.player|com.miui.videoplayer)
                # Xiaomi Music & Mi Video: remove on China, EU, Global, etc.
                ;;
            com.miui.video)
                # Alternate Mi Video package remains EU-only.
                [[ "$EU_DEBLOAT" == "1" ]] || continue
                ;;
            *) continue ;;
        esac

        for app_root in "${media_app_roots[@]}"; do
            [[ "$apk" == "$app_root/"* ]] || continue
            relative_apk="${apk#"$app_root/"}"
            if [[ "$relative_apk" == */* ]]; then
                container="$app_root/${relative_apk%%/*}"
                [[ -d "$container" ]] || break

                # Remove the entire app container only when EVERY APK inside
                # declares the same package. Otherwise abort safely instead
                # of deleting another application's APK or shared resources.
                mapfile -d '' -t container_apks < <(
                    find "$container" -type f -iname '*.apk' -print0
                )
                for sibling in "${container_apks[@]}"; do
                    sibling_package="$(media_package_from_apk "$sibling")"
                    if [[ "$sibling_package" != "$package_name" ]]; then
                        error "Media debloat: mixed/unreadable package in $container ($sibling); not deleting"
                        exit 1
                    fi
                done
                info "Media debloat [${EU_DEBLOAT}]: $package_name -> removing $container"
                rm -rf -- "$container" || exit 1
            else
                info "Media debloat [${EU_DEBLOAT}]: $package_name -> removing $apk"
                rm -f -- "$apk" || exit 1
            fi
            ((media_removed+=1))
            break
        done
    done
fi
info "Media debloat: scanned=$media_scanned unreadable=$media_unreadable removed=$media_removed (EU=$EU_DEBLOAT)"

info "Debloat Done"

