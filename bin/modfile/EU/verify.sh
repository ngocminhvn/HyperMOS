#!/usr/bin/env bash
# Verify EU-only app removals after all shared/China mod stages.
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
source_file="$work_dir/bin/ddevice/rom_source.txt"
[[ -s "$source_file" ]] || { error "EU: rom_source.txt missing"; exit 1; }
[[ "$(tr -d '\r\n' < "$source_file")" == "xiaomi_eu" ]] || {
    error "EU verification invoked for non-Xiaomi.eu source"
    exit 1
}

images="$work_dir/build/baserom/images"
components=(XiaomiEUExt XiaomiEUInject MiuiExtraPhoto)
app_roots=(
    "$images/product/priv-app" "$images/product/app"
    "$images/system_ext/priv-app" "$images/system_ext/app"
    "$images/mi_ext/priv-app" "$images/mi_ext/app"
    "$images/system/system/priv-app" "$images/system/system/app"
    "$images/system/priv-app" "$images/system/app"
)

for app_root in "${app_roots[@]}"; do
    for component in "${components[@]}"; do
        target="$app_root/$component"
        [[ ! -e "$target" && ! -L "$target" ]] || {
            error "EU: $component reintroduced by later mod at ${target#"$images"/}"
            exit 1
        }
    done
done

# Verify metadata cleanup after every later mod, not just at cleanup time.
eu_prop="$images/mi_ext/etc/build.prop"
if [[ -L "$eu_prop" ]]; then
    error "EU: symlinked mi_ext build.prop in final ROM"
    exit 1
fi
if [[ -f "$eu_prop" ]] && grep -Eq \
    '^ro\.product\.mod_device=[^[:space:]]*_xiaomieu[^[:space:]]*$|^ro\.build\.host=xiaomi\.eu from the shared/China mod pipeline.
[[ -s "$images/product/priv-app/MiuiHome/MiuiHome.apk" ]] || {
    error "EU: Kashi MiuiHome missing from final ROM"
    exit 1
}
 "$eu_prop"; then
    error "EU: Xiaomi.eu-only mi_ext metadata reintroduced by a later mod"
    exit 1
fi

# Keep the user-selected Kashi launcher from the shared/China mod pipeline.
[[ -s "$images/product/priv-app/MiuiHome/MiuiHome.apk" ]] || {
    error "EU: Kashi MiuiHome missing from final ROM"
    exit 1
}
