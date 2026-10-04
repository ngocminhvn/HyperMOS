#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

androidVER="$(cat "$work_dir/bin/ddevice/androidver.txt")"
[[ "$androidVER" == "16" ]] || {
  info "SystemUI Notification Global: Android $androidVER -> skipped"
  exit 0
}

MAIN_FOLDER="$work_dir/build/baserom/images"
APKEDITOR="java -jar $work_dir/bin/apktool/apke.jar"
tmp="$work_dir/apk_temp/systemui-notification-global"

apk=$(find "$MAIN_FOLDER" -type f -name "MiuiSystemUI.apk" -print -quit)
[[ -n "$apk" && -f "$apk" ]] || {
  error "SystemUI Notification Global: MiuiSystemUI.apk not found"
  exit 1
}

dir=$(dirname "$apk")
rm -rf "$tmp"
mkdir -p "$tmp/out" "$tmp/final"

mods "SystemUI: disabling China notification folding"
$APKEDITOR d -t raw -f -no-dex-debug -i "$apk" -o "$tmp/out" >/dev/null

SYSTEMUI_OUT="$tmp/out" python3 <<'PY'
from pathlib import Path
import os
import re
import sys

root = Path(os.environ["SYSTEMUI_OUT"])
scheduler_files = list(root.glob("smali*/com/android/systemui/statusbar/notification/collection/coordinator/FoldCoordinator.smali"))
util_files = list(root.glob("smali*/com/android/systemui/statusbar/notification/utils/NotificationUtil.smali"))

patched_scheduler = 0
patched_writer = 0

# Block the fold scheduler. This prevents both immediate fold and the historical
# timeout that can later move notifications into "More notifications".
for path in scheduler_files:
    text = path.read_text(encoding="utf-8")
    methods = list(re.finditer(
        r"(?ms)^\.method\b[^\n]*\bscheduleHistoryNotification\([^\n]*\)V\s*$.*?^\.end method\s*$",
        text,
    ))
    if not methods:
        continue
    for m in reversed(methods):
        method = m.group(0)
        if "hypermos_no_notification_fold" in method:
            continue
        lines = method.splitlines()
        reg_idx = next(
            (i for i, line in enumerate(lines)
             if line.strip().startswith(".locals") or line.strip().startswith(".registers")),
            None,
        )
        if reg_idx is None:
            print("FoldCoordinator register directive missing", file=sys.stderr)
            sys.exit(71)
        lines[reg_idx + 1:reg_idx + 1] = [
            "",
            "    # hypermos_no_notification_fold",
            "    return-void",
        ]
        replacement = "\n".join(lines)
        text = text[:m.start()] + replacement + text[m.end():]
        patched_scheduler += 1
    path.write_text(text, encoding="utf-8")

# Force NotificationUtil.setFold(..., false) while preserving the method body,
# so any old/already-scheduled caller also cannot mark an entry folded.
for path in util_files:
    text = path.read_text(encoding="utf-8")
    methods = list(re.finditer(
        r"(?ms)^\.method\b[^\n]*\bsetFold\([^\n]*\)V\s*$.*?^\.end method\s*$",
        text,
    ))
    for m in reversed(methods):
        method = m.group(0)
        if "hypermos_force_unfold" in method:
            continue
        header = method.splitlines()[0]
        sig_m = re.search(r"setFold\((.*)\)V", header)
        if not sig_m:
            continue
        desc = sig_m.group(1)

        # Parse parameter descriptors to locate the final boolean parameter.
        params = []
        i = 0
        while i < len(desc):
            start = i
            while i < len(desc) and desc[i] == '[':
                i += 1
            if i >= len(desc):
                break
            if desc[i] == 'L':
                end = desc.find(';', i)
                if end < 0:
                    print("invalid setFold descriptor", file=sys.stderr)
                    sys.exit(72)
                i = end + 1
            else:
                i += 1
            params.append(desc[start:i])

        if not params or params[-1] != 'Z':
            continue

        static_method = " static " in f" {header} "
        p_index = 0 if static_method else 1
        for d in params[:-1]:
            p_index += 2 if d in ('J', 'D') else 1
        bool_reg = f"p{p_index}"

        lines = method.splitlines()
        reg_idx = next(
            (i for i, line in enumerate(lines)
             if line.strip().startswith(".locals") or line.strip().startswith(".registers")),
            None,
        )
        if reg_idx is None:
            print("NotificationUtil.setFold register directive missing", file=sys.stderr)
            sys.exit(73)
        lines[reg_idx + 1:reg_idx + 1] = [
            "",
            "    # hypermos_force_unfold",
            f"    const/4 {bool_reg}, 0x0",
        ]
        replacement = "\n".join(lines)
        text = text[:m.start()] + replacement + text[m.end():]
        patched_writer += 1
    path.write_text(text, encoding="utf-8")

if patched_scheduler == 0 and patched_writer == 0:
    # Some OS3 SystemUI builds do not contain the OS4 fold pipeline. In that case
    # there is nothing to patch and the build remains valid.
    print("HyperMOS: fold pipeline not present on this MiuiSystemUI; skipped")
else:
    print(f"HyperMOS notification fold: scheduler={patched_scheduler} writer={patched_writer}")
PY

name=$(basename "$apk")
$APKEDITOR b -f -i "$tmp/out" -o "$tmp/final/$name" >/dev/null

[[ -s "$tmp/final/$name" ]] || {
  error "SystemUI Notification Global: rebuild failed"
  exit 1
}
unzip -tq "$tmp/final/$name" >/dev/null

rm -rf "$dir/oat"
cp -f "$tmp/final/$name" "$apk"
rm -rf "$tmp"

mods "SystemUI China notification fold -> Done"
