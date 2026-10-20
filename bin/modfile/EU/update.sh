#!/usr/bin/env bash
# Xiaomi.eu-only app cleanup. Never run against China or Global source ROMs.
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
source_file="$work_dir/bin/ddevice/rom_source.txt"
[[ -s "$source_file" ]] || { error "EU: missing rom_source.txt"; exit 1; }
[[ "$(tr -d '\r\n' < "$source_file")" == "xiaomi_eu" ]] || {
    error "EU: refused to apply EU cleanup to a non-Xiaomi.eu ROM"
    exit 1
}

images="$work_dir/build/baserom/images"
[[ -d "$images/product/priv-app" ]] || { error "EU: extracted product/priv-app missing"; exit 1; }

# For any Xiaomi.eu device, restore the native codename in mod_device.
# E.g. haotian_xiaomieu_global -> haotian; mondrian_xiaomieu_eea_global -> mondrian.
# Remove only the four specified EU metadata keys; values may vary per build.
# Work only on extracted EU images, never on China builds or runtime properties.
eu_prop="$images/mi_ext/etc/build.prop"
if [[ -L "$eu_prop" ]]; then
    error "EU: refusing symlinked mi_ext build.prop"
    exit 1
fi
if [[ -f "$eu_prop" ]]; then
    sed -E -i \
        -e 's/^(ro\.product\.mod_device=)([[:alnum:]_.-]+)_xiaomieu(_[[:alnum:]_.-]+)?$/\1\2/' \
        -e '/^ro\.build\.host=xiaomi\.eu$/d' \
        -e '/^ro\.xiaomi\.developerid=/d' \
        -e '/^ro\.xiaomi\.eu\.ota_device=/d' \
        -e '/^ro\.xiaomi\.eu\.version\.code_time=/d' \
        "$eu_prop" || { error "EU: failed to clean mi_ext build.prop"; exit 1; }
fi

# Remove only these exact Xiaomi.eu app containers, in standard partition
# app locations. Never match substrings or touch other preinstalled apps.
components=(XiaomiEUExt XiaomiEUInject MiuiExtraPhoto)
app_roots=(
    "$images/product/priv-app" "$images/product/app"
    "$images/system_ext/priv-app" "$images/system_ext/app"
    "$images/mi_ext/priv-app" "$images/mi_ext/app"
    "$images/system/system/priv-app" "$images/system/system/app"
    "$images/system/priv-app" "$images/system/app"
)

for app_root in "${app_roots[@]}"; do
    [[ -d "$app_root" && ! -L "$app_root" ]] || continue
    for component in "${components[@]}"; do
        target="$app_root/$component"
        if [[ -L "$target" || ( -e "$target" && ! -d "$target" ) ]]; then
            error "EU: unexpected app container type: $target"
            exit 1
        fi
        if [[ -d "$target" ]]; then
            rm -rf -- "$target" || { error "EU: cannot remove $target"; exit 1; }
            [[ ! -e "$target" && ! -L "$target" ]] || {
                error "EU: removal verification failed: $target"
                exit 1
            }
            mods "EU: removed ${target#"$images"/}"
        fi
    done
done
