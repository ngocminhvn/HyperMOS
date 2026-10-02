#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

MAIN_FOLDER="$work_dir/build/baserom/images"
APKEDITOR="java -jar $work_dir/bin/apktool/apke.jar"
REPO_URL="https://github.com/ngocminhvn/HyperMOS"

mods "Adding HyperMOS GitHub entry"

isSettings=$(find "$MAIN_FOLDER" -type f -name "Settings.apk" -print -quit)
if [[ -z "$isSettings" || ! -f "$isSettings" ]]; then
  info "Settings ROM Information: Settings.apk not found, skipped"
  exit 0
fi

isSettingsDIR=$(dirname "$isSettings")
rm -rf "$work_dir/apk_temp"
mkdir -p "$work_dir/apk_temp/final"

"$APKEDITOR" d -t raw -f -no-dex-debug \
  -i "$isSettings" \
  -o "$work_dir/apk_temp/isSettings.apk.out" >/dev/null 2>&1

target=$(find "$work_dir/apk_temp/isSettings.apk.out" -type f \
  -path '*/res/xml/my_device_settings.xml' -print -quit)

if [[ -z "$target" || ! -f "$target" ]]; then
  info "Settings ROM Information: my_device_settings.xml not found, skipped"
  rm -rf "$work_dir/apk_temp"
  exit 0
fi

if grep -q 'android:key="hypermos_github"' "$target"; then
  info "Settings ROM Information: HyperMOS GitHub entry already exists"
else
  TARGET_XML="$target" REPO_URL="$REPO_URL" python3 <<'PY'
from pathlib import Path
import os
import sys

path = Path(os.environ["TARGET_XML"])
repo = os.environ["REPO_URL"]
text = path.read_text(encoding="utf-8")

marker = "</PreferenceScreen>"
if marker not in text:
    print("PreferenceScreen closing tag not found", file=sys.stderr)
    sys.exit(2)

entry = f"""
    <com.android.settingslib.miuisettings.preference.Preference
        android:key="hypermos_github"
        android:title="HyperMOS"
        android:summary="github.com/ngocminhvn/HyperMOS"
        app:showRightArrow="true">
        <intent
            android:action="android.intent.action.VIEW"
            android:data="{repo}" />
    </com.android.settingslib.miuisettings.preference.Preference>
"""

text = text.replace(marker, entry + "\n" + marker, 1)
path.write_text(text, encoding="utf-8")
PY
fi

Settings=$(basename "$isSettings")
"$APKEDITOR" b -f \
  -i "$work_dir/apk_temp/isSettings.apk.out" \
  -o "$work_dir/apk_temp/final/$Settings" >/dev/null 2>&1

if [[ ! -s "$work_dir/apk_temp/final/$Settings" ]]; then
  error "Settings ROM Information: rebuild failed"
  exit 1
fi

rm -rf "$isSettingsDIR"/*
cp -f "$work_dir/apk_temp/final/$Settings" "$isSettingsDIR/$Settings"

rm -rf "$work_dir/apk_temp"
mods "HyperMOS GitHub entry -> Done"
