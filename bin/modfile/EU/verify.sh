#!/usr/bin/env bash
# Verify the two EU-only app removals after all shared/China mod stages.
# Preserve MiuiExtraPhoto: it is not a removal target.
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
components=(XiaomiEUExt XiaomiEUInject)
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

# Keep the user-selected Kashi launcher from the shared/China mod pipeline.
[[ -s "$images/product/priv-app/MiuiHome/MiuiHome.apk" ]] || {
    error "EU: Kashi MiuiHome missing from final ROM"
    exit 1
}
