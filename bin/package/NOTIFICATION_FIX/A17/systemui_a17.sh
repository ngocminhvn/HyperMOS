#!/usr/bin/env bash
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"

base="$work_dir/bin/package/NOTIFICATION_FIX/A17"
tools="$work_dir/bin/apktool"
images="$work_dir/build/baserom/images"
framework="$images/system/system/framework/framework.jar"

mapfile -d '' -t apks < <(find "$images/system_ext" -type f -name MiuiSystemUI.apk -print0)
(( ${#apks[@]} == 1 )) || { error "A17 channel defaults: expected one MiuiSystemUI.apk"; exit 1; }
apk="${apks[0]}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Target the unique DEX containing the settings manager.
target_dex=""
while read -r dex; do
  java -jar "$tools/baksmaliv2.jar" list classes "$apk/$dex" > "$tmp/classes"
  if grep -Fxq 'Lcom/miui/systemui/notification/NotificationSettingsManager;' "$tmp/classes"; then
    [[ -z "$target_dex" ]] || { error "A17 channel defaults: duplicate settings manager"; exit 1; }
    target_dex="$dex"
  fi
done < <(unzip -Z1 "$apk" | awk '/^classes([2-9]|[1-9][0-9]+)?\.dex$/')
[[ -n "$target_dex" ]] || { error "A17 channel defaults: settings manager missing"; exit 1; }

java -jar "$tools/baksmaliv2.jar" d --api 34 "$apk/$target_dex" -o "$tmp/smali"
result="$(python3 "$base/systemui_a17.py" "$tmp/smali")"
if [[ "$result" == "already patched" ]]; then
  info "A17 channel defaults already patched"
  exit 0
fi

# Verify the actual built framework has the existing CorePatch integrity hook.
while read -r dex; do
  java -jar "$tools/baksmaliv2.jar" d --api 34 \
    --classes 'Landroid/util/apk/ApkSigningBlockUtils;' "$framework/$dex" -o "$tmp/framework"
  [[ ! -s "$tmp/framework/android/util/apk/ApkSigningBlockUtils.smali" ]] || break
done < <(unzip -Z1 "$framework" | awk '/^classes([2-9]|[1-9][0-9]+)?\.dex$/')
python3 "$base/systemui_a17.py" "$tmp/framework/android/util/apk/ApkSigningBlockUtils.smali" --corepatch

java -jar "$tools/smaliv2.jar" a --api 34 "$tmp/smali" -o "$tmp/$target_dex"
python3 "$base/systemui_a17.py" "$apk" --repack "$tmp/$target_dex" "$tmp/MiuiSystemUI.apk"

# The caller installs the fully staged APK only after the other patches pass.
install -m 0644 "$tmp/MiuiSystemUI.apk" "$1"
printf '%s\n' "$apk" > "$2"
