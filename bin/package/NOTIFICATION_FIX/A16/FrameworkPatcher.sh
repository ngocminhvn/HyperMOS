#!/usr/bin/env bash
# A16 CN notification-only port: FrameworksForge/FrameworkPatcher.
# CorePatch retains signature and FLAG_SECURE; PowerKeeper stays separate.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
source "$work_dir/bin/package/COREPATCH/helper.sh"
WORK_DIR="$work_dir"
TOOLS_DIR="$work_dir/bin/apktool"
API_LEVEL=36
jar="$work_dir/build/baserom/images/system_ext/framework/miui-services.jar"
decoded="$work_dir/miui-services_decompile"
output="$work_dir/miui-services_patched.jar"
report="$work_dir/build/reports/frameworkpatcher-a16/notification-gates.json"
if [ ! -s "$jar" ]; then
  echo "[FRAMEWORKPATCHER A16] ERROR: missing miui-services.jar" >&2
  exit 1
fi
init_env
ensure_tools
# Never replace the ROM JAR until all patch/compile/ZIP checks have passed.
trap 'rm -rf "$decoded" "$work_dir/miui-services" "$output"' EXIT
decompile_jar "$jar" >/dev/null
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/frameworkpatcher_cn_a16.py" \
  "$decoded" --report "$report"
recompile_jar "$jar" >/dev/null
if [ ! -s "$output" ] || ! unzip -t "$output" >/dev/null 2>&1; then
  echo "[FRAMEWORKPATCHER A16] ERROR: rebuilt miui-services.jar invalid" >&2
  exit 1
fi
mv -f "$output" "$jar"
log "[FRAMEWORKPATCHER A16] CN notification port complete (CorePatch / EU filter unchanged)"
