#!/usr/bin/env bash
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
src="$work_dir/bin/modfile/UpdateFile/MultiLang/OS4/Vietnamese/main"
for file in \
  "Settings.apk/res/values-vi/strings.xml" \
  "MiuiSystemUI.apk/res/values-vi/strings.xml" \
  "framework-res.apk/res/values-vi/strings.xml"; do
  [[ -s "$src/$file" ]] || { error "MultiLang OS4: missing XML: $file"; exit 1; }
done
# XML is not a compiled, signed Android translation overlay.
mods "MultiLang OS4: XML verified; APK/RRO localization not implemented yet"
