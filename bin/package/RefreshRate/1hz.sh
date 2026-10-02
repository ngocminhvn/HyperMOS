#!/usr/bin/env bash
work_dir=$(pwd)
ANDROID_DEVICE=$(cat "$work_dir/bin/ddevice/device_f.txt" 2>/dev/null)
feature_dir="$work_dir/build/baserom/images/product/etc/device_features"

# Preserve the device stock Smart FPS / LTPO behavior.
# Do not inject or overwrite support_smart_fps, smart_fps_value, 90 Hz or 120 Hz.
# Only add a 1 Hz entry when a device feature XML already exposes 60 Hz and lacks 1 Hz.
if [[ -d "$feature_dir" ]]; then
    shopt -s nullglob
    for gfFile in "$feature_dir"/*.xml; do
        if grep -q '<item>60</item>' "$gfFile" && ! grep -q '<item>1</item>' "$gfFile"; then
            sed -i '/<item>60<\/item>/a\        <item>1</item>' "$gfFile"
            echo "Added 1Hz entry to ${ANDROID_DEVICE:-device}: $(basename "$gfFile")"
        fi

        if grep -q 'support_smart_fps' "$gfFile" || grep -q 'smart_fps_value' "$gfFile"; then
            echo "Preserved stock Smart FPS / LTPO config: $(basename "$gfFile")"
        fi
    done
    shopt -u nullglob
fi
