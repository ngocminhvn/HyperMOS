#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

MAIN_FOLDER="$work_dir/build/baserom/images"
APKEDITOR="java -jar $work_dir/bin/apktool/apke.jar"
tmp="$work_dir/apk_temp/notification-powerkeeper"

patch "PowerKeeper A16 (PenguinOS + HyperMOS)"

apk=$(find "$MAIN_FOLDER" -type f -name "PowerKeeper.apk" -print -quit)
[[ -n "$apk" && -f "$apk" ]] || { error "NOTIFICATION_FIX: PowerKeeper.apk not found"; exit 1; }

dir=$(dirname "$apk")
rm -rf "$tmp"
mkdir -p "$tmp/out" "$tmp/final"

$APKEDITOR d -t raw -f -no-dex-debug -i "$apk" -o "$tmp/out" >/dev/null

# PenguinOS A16 notification behavior:
# MilletConfig follows the MIUI path instead of the China-only international flag.
millet_smali=$(find "$tmp/out" -type f -name 'MilletConfig.smali' -print -quit)
[[ -n "$millet_smali" && -f "$millet_smali" ]] || {
  error "NOTIFICATION_FIX: MilletConfig.smali not found"
  exit 1
}

if ! grep -q 'Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z' "$millet_smali"; then
  error "NOTIFICATION_FIX: PenguinOS MilletConfig target not found"
  exit 1
fi

sed -i 's|Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z|Lmiui/os/Build;->IS_MIUI:Z|g' "$millet_smali"

if grep -q 'Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z' "$millet_smali"; then
  error "NOTIFICATION_FIX: PenguinOS MilletConfig patch verification failed"
  exit 1
fi

mods "PowerKeeper MilletConfig -> PenguinOS IS_MIUI"

# HyperMOS FCM v2:
# Enforce GMS in MILLET_NO_RESTRICT_APP once when PowerKeeper starts.
app_smali=$(find "$tmp/out" -type f -name 'PowerKeeperApplication.smali' -print -quit)
[[ -n "$app_smali" && -f "$app_smali" ]] || {
  error "NOTIFICATION_FIX: PowerKeeperApplication.smali not found"
  exit 1
}

APP_SMALI="$app_smali" python3 <<'PY'
import os
import re
import sys

path = os.environ["APP_SMALI"]
with open(path, "r", encoding="utf-8") as fh:
    text = fh.read()

class_m = re.search(r"(?m)^\.class\b[^\n]*\s+(L[^;]+;)\s*$", text)
if not class_m:
    print("PowerKeeperApplication class descriptor not found", file=sys.stderr)
    sys.exit(25)

klass = class_m.group(1)
helper_name = "hypermosEnforceGmsMillet"

if f"->{helper_name}()V" not in text:
    oncreate = re.search(
        r"(?ms)^\.method\b[^\n]*\bonCreate\(\)V\s*$.*?^\.end method\s*$",
        text,
    )
    if not oncreate:
        print("PowerKeeperApplication.onCreate()V not found", file=sys.stderr)
        sys.exit(26)

    method = oncreate.group(0)
    super_call = re.search(
        r"(?m)^(\s*invoke-super\s+\{p0\},\s+Landroid/app/Application;->onCreate\(\)V\s*)$",
        method,
    )
    if not super_call:
        # Xiaomi may inherit through an intermediate Application subclass.
        super_call = re.search(
            r"(?m)^(\s*invoke-super\s+\{p0\},\s+L[^;]+;->onCreate\(\)V\s*)$",
            method,
        )
    if not super_call:
        print("PowerKeeperApplication super.onCreate() call not found", file=sys.stderr)
        sys.exit(27)

    call = (
        super_call.group(1)
        + f"\n\n    invoke-direct {{p0}}, {klass}->{helper_name}()V"
    )
    method = method[:super_call.start()] + call + method[super_call.end():]
    text = text[:oncreate.start()] + method + text[oncreate.end():]

    helper = f"""

.method private {helper_name}()V
    .locals 4

    invoke-virtual {{p0}}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v0

    const-string v1, "MILLET_NO_RESTRICT_APP"
    invoke-static {{v0, v1}}, Landroid/provider/Settings$System;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2

    invoke-static {{v2}}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z
    move-result v3
    if-nez v3, :hypermos_boot_millet_empty

    const-string v1, "com.google.android.gms"
    invoke-virtual {{v2, v1}}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v3
    if-nez v3, :hypermos_boot_millet_done

    const-string v1, ",com.google.android.gms"
    invoke-virtual {{v2, v1}}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    goto :hypermos_boot_millet_write

:hypermos_boot_millet_empty
    const-string v2, "com.google.android.gms"

:hypermos_boot_millet_write
    const-string v1, "MILLET_NO_RESTRICT_APP"
    invoke-static {{v0, v1, v2}}, Landroid/provider/Settings$System;->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z

:hypermos_boot_millet_done
    return-void
.end method
"""
    text = text.rstrip() + helper + "\n"

# Verify both the startup call and helper exist exactly once.
if text.count(f"{klass}->{helper_name}()V") != 1:
    print("boot-time MILLET call verification failed", file=sys.stderr)
    sys.exit(28)
if text.count(f".method private {helper_name}()V") != 1:
    print("boot-time MILLET helper verification failed", file=sys.stderr)
    sys.exit(29)
if '"MILLET_NO_RESTRICT_APP"' not in text or '"com.google.android.gms"' not in text:
    print("boot-time MILLET constants missing", file=sys.stderr)
    sys.exit(30)

with open(path, "w", encoding="utf-8") as fh:
    fh.write(text)
PY

mods "PowerKeeper MILLET -> boot-time GMS enforce"

# 2) Disable only PowerKeeper's dedicated GMS firewall/DNS controller.
#    Do not disable generic PowerKeeper, DeviceIdle, Millet or Greezer.
gms_smali=$(find "$tmp/out" -type f -path '*/com/miui/powerkeeper/utils/GmsObserver.smali' -print -quit)
[[ -n "$gms_smali" && -f "$gms_smali" ]] || {
  error "NOTIFICATION_FIX: GmsObserver.smali not found"
  exit 1
}

GMS_SMALI="$gms_smali" python3 <<'PY'
import os
import re
import sys

path = os.environ["GMS_SMALI"]
with open(path, "r", encoding="utf-8") as fh:
    text = fh.read()

m = re.search(
    r"(?ms)^(\.method\b[^\n]*\bisGmsControlEnabled\(\)Z\s*$).*?^\.end method\s*$",
    text,
)
if not m:
    print("GmsObserver.isGmsControlEnabled()Z not found", file=sys.stderr)
    sys.exit(30)

replacement = (
    m.group(1)
    + "\n    .locals 1\n\n"
      "    # HyperMOS: never enable Xiaomi's dedicated GMS firewall/DNS limiter.\n"
      "    const/4 v0, 0x0\n"
      "    return v0\n"
      ".end method"
)

text = text[:m.start()] + replacement + text[m.end():]

check = re.search(
    r"(?ms)^\.method\b[^\n]*\bisGmsControlEnabled\(\)Z\s*$.*?^\.end method\s*$",
    text,
)
if not check or "const/4 v0, 0x0" not in check.group(0):
    print("GmsObserver patch verification failed", file=sys.stderr)
    sys.exit(31)

with open(path, "w", encoding="utf-8") as fh:
    fh.write(text)
PY

mods "PowerKeeper GmsObserver -> dedicated GMS limiter disabled"

name=$(basename "$apk")
$APKEDITOR b -f -i "$tmp/out" -o "$tmp/final/$name" >/dev/null

[[ -s "$tmp/final/$name" ]] || {
  error "NOTIFICATION_FIX: PowerKeeper rebuild failed"
  exit 1
}

unzip -tq "$tmp/final/$name" >/dev/null

rm -rf "$dir/oat"
cp -f "$tmp/final/$name" "$apk"
rm -rf "$tmp"

patch "PowerKeeper A16 -> Done"
