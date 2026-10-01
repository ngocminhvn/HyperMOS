#!/usr/bin/env bash
set -euo pipefail
work_dir=$(pwd)
source "$work_dir/functions.sh"
MAIN_FOLDER="$work_dir/build/baserom/images"
APKEDITOR="java -jar $work_dir/bin/apktool/apke.jar"
tmp="$work_dir/apk_temp/notification-systemui"

apk=$(find "$MAIN_FOLDER" -type f -name "MiuiSystemUI.apk" -print -quit)
[[ -n "$apk" && -f "$apk" ]] || { error "NOTIFICATION_FIX: MiuiSystemUI.apk not found"; exit 1; }
dir=$(dirname "$apk")
rm -rf "$tmp"; mkdir -p "$tmp/out" "$tmp/final"

$APKEDITOR d -t raw -f -no-dex-debug -i "$apk" -o "$tmp/out" >/dev/null
before=$(grep -RIl -e 'Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z' -e 'Lcom/miui/utils/configs/MiuiConfigs;->IS_INTERNATIONAL_BUILD:Z' "$tmp/out" --include='*.smali' | wc -l)
(( before > 0 )) || { error "NOTIFICATION_FIX: no SystemUI notification targets found"; exit 1; }

grep -RIl 'Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z' "$tmp/out" --include='*.smali' | while read -r f; do
  sed -i 's|Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z|Lmiui/os/xBuild;->IS_INTERNATIONAL_BUILD:Z|g' "$f"
done
grep -RIl 'Lcom/miui/utils/configs/MiuiConfigs;->IS_INTERNATIONAL_BUILD:Z' "$tmp/out" --include='*.smali' | while read -r f; do
  sed -i 's|Lcom/miui/utils/configs/MiuiConfigs;->IS_INTERNATIONAL_BUILD:Z|Lmiui/os/xBuild;->IS_INTERNATIONAL_BUILD:Z|g' "$f"
done

left=$(grep -RIl -e 'Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z' -e 'Lcom/miui/utils/configs/MiuiConfigs;->IS_INTERNATIONAL_BUILD:Z' "$tmp/out" --include='*.smali' | wc -l)
(( left == 0 )) || { error "NOTIFICATION_FIX: SystemUI targets remain after patch"; exit 1; }

name=$(basename "$apk")
$APKEDITOR b -f -i "$tmp/out" -o "$tmp/final/$name" >/dev/null
[[ -s "$tmp/final/$name" ]] || { error "NOTIFICATION_FIX: SystemUI rebuild failed"; exit 1; }
unzip -tq "$tmp/final/$name" >/dev/null
rm -rf "$dir/oat"
cp -f "$tmp/final/$name" "$apk"
rm -rf "$tmp"
