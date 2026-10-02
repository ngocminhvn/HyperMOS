#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

MAIN_FOLDER="$work_dir/build/baserom/images"
APKEDITOR=(java -jar "$work_dir/bin/apktool/apke.jar")
REPO_URL="https://github.com/ngocminhvn/HyperMOS"

mods "Adding Github entry to main Settings"

isSettings=$(find "$MAIN_FOLDER" -type f -name "Settings.apk" -print -quit)
if [[ -z "$isSettings" || ! -f "$isSettings" ]]; then
  info "Settings Github: Settings.apk not found, skipped"
  exit 0
fi

isSettingsDIR=$(dirname "$isSettings")
rm -rf "$work_dir/apk_temp"
mkdir -p "$work_dir/apk_temp/final"

"${APKEDITOR[@]}" d -t raw -f -no-dex-debug \
  -i "$isSettings" \
  -o "$work_dir/apk_temp/isSettings.apk.out" >/dev/null 2>&1

target="$work_dir/apk_temp/isSettings.apk.out/resources/package_1/res/xml/settings_headers.xml"
if [[ ! -f "$target" ]]; then
  target=$(find "$work_dir/apk_temp/isSettings.apk.out" -type f \
    -path '*/res/xml/settings_headers.xml' -print -quit)
fi

if [[ -z "${target:-}" || ! -f "$target" ]]; then
  info "Settings Github: settings_headers.xml not found, skipped"
  rm -rf "$work_dir/apk_temp"
  exit 0
fi

TARGET_XML="$target" REPO_URL="$REPO_URL" python3 <<'PY'
from pathlib import Path
import os
import sys
import xml.etree.ElementTree as ET

path = Path(os.environ["TARGET_XML"])
repo = os.environ["REPO_URL"]

ANDROID_URI = "http://schemas.android.com/apk/res/android"
A = f"{{{ANDROID_URI}}}"
ET.register_namespace("android", ANDROID_URI)

try:
    tree = ET.parse(path)
except Exception as exc:
    print(f"cannot parse settings_headers.xml: {exc}", file=sys.stderr)
    sys.exit(2)

root = tree.getroot()
children = list(root)

def is_header(node):
    return node.tag == "header" or str(node.tag).endswith("}header")

def make_github_header():
    header = ET.Element("header", {
        A + "id": "@+id/hypermos_github",
        A + "icon": "@drawable/ic_settings_development",
        A + "title": "Github",
    })
    ET.SubElement(header, "intent", {
        A + "action": "android.intent.action.VIEW",
        A + "data": repo,
    })
    return header

# If the source already contains the ProjectZK customization entry, replace it
# in-place so the row stays at exactly the same position.
zk_index = None
for i, node in enumerate(children):
    if is_header(node) and node.get(A + "fragment") == "zk.lab.zkMods":
        zk_index = i
        break

if zk_index is not None:
    root.remove(children[zk_index])
    root.insert(zk_index, make_github_header())
else:
    # Idempotent build: do not create a second entry.
    for node in list(root):
        if is_header(node) and node.get(A + "id") == "@+id/hypermos_github":
            break
    else:
        # ZKOS places its customization row just before the separator/Wi-Fi
        # section. Mirror that placement on the stock HyperOS Settings layout.
        children = list(root)
        wifi_index = None
        for i, node in enumerate(children):
            if not is_header(node):
                continue
            for child in list(node):
                if (child.tag == "intent" or str(child.tag).endswith("}intent")) and \
                   child.get(A + "action") == "android.settings.WIFI_SETTINGS":
                    wifi_index = i
                    break
            if wifi_index is not None:
                break

        if wifi_index is None:
            print("Wi-Fi header not found; refusing to guess insertion point", file=sys.stderr)
            sys.exit(3)

        insert_index = wifi_index
        if wifi_index > 0:
            prev = children[wifi_index - 1]
            if is_header(prev) and not prev.attrib and len(list(prev)) == 0:
                insert_index = wifi_index - 1

        root.insert(insert_index, make_github_header())

tree.write(path, encoding="utf-8", xml_declaration=True)

# Verify the exact row and URL exist after modification.
verify = ET.parse(path).getroot()
matches = []
for node in list(verify):
    if not is_header(node):
        continue
    if node.get(A + "id") != "@+id/hypermos_github":
        continue
    intent = next((c for c in list(node)
                   if c.tag == "intent" or str(c.tag).endswith("}intent")), None)
    if intent is not None and \
       intent.get(A + "action") == "android.intent.action.VIEW" and \
       intent.get(A + "data") == repo:
        matches.append(node)

if len(matches) != 1:
    print(f"Github row verification failed: {len(matches)} matches", file=sys.stderr)
    sys.exit(4)
PY

Settings=$(basename "$isSettings")
"${APKEDITOR[@]}" b -f \
  -i "$work_dir/apk_temp/isSettings.apk.out" \
  -o "$work_dir/apk_temp/final/$Settings" >/dev/null 2>&1

if [[ ! -s "$work_dir/apk_temp/final/$Settings" ]]; then
  error "Settings Github: rebuild failed"
  exit 1
fi

rm -rf "$isSettingsDIR"/*
cp -f "$work_dir/apk_temp/final/$Settings" "$isSettingsDIR/$Settings"

rm -rf "$work_dir/apk_temp"
mods "Settings Github -> Done"
