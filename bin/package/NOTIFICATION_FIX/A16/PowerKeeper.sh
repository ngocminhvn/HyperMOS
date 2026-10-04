#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

MAIN_FOLDER="$work_dir/build/baserom/images"
APKEDITOR="java -jar $work_dir/bin/apktool/apke.jar"
tmp="$work_dir/apk_temp/notification-powerkeeper"

patch "PowerKeeper A16 (ZKOS notification behavior)"

apk=$(find "$MAIN_FOLDER" -type f -name "PowerKeeper.apk" -print -quit)
[[ -n "$apk" && -f "$apk" ]] || { error "NOTIFICATION_FIX: PowerKeeper.apk not found"; exit 1; }

dir=$(dirname "$apk")
rm -rf "$tmp"
mkdir -p "$tmp/out" "$tmp/final"

$APKEDITOR d -t raw -f -no-dex-debug -i "$apk" -o "$tmp/out" >/dev/null

# ZKOS uses its own always-enabled build flag in PowerKeeper.
# HyperMOS already provides the equivalent xBuild flag (always true), so keep
# the same behavior without importing ZKOS-specific framework classes.
mapfile -t intl_targets < <(
  grep -RIl 'Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z' "$tmp/out" --include='*.smali' || true
)

(( ${#intl_targets[@]} > 0 )) || {
  error "NOTIFICATION_FIX: no PowerKeeper international-build targets found"
  exit 1
}

for f in "${intl_targets[@]}"; do
  sed -i 's|Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z|Lmiui/os/xBuild;->IS_INTERNATIONAL_BUILD:Z|g' "$f"
done

if grep -RIlq 'Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z' "$tmp/out" --include='*.smali'; then
  error "NOTIFICATION_FIX: PowerKeeper international-build targets remain after patch"
  exit 1
fi

# Match the verified ZKOS 4.2.00 behavior in
# KillProcessController.setUidState(IZ)V:
#   stock : build ProcessConfig -> ProcessManager.kill(...) -> "stop uid="
#   ZKOS  : skip ProcessManager.kill(...)                 -> "ignore stop uid="
#
# Keep the rest of PowerKeeper (DeviceIdle/Wakelock/background policies and
# device configs) from the current base ROM instead of copying a 304 APK.
kill_smali=$(find "$tmp/out" -type f -path '*/com/miui/powerkeeper/controller/KillProcessController.smali' -print -quit)
[[ -n "$kill_smali" && -f "$kill_smali" ]] || {
  error "NOTIFICATION_FIX: KillProcessController.smali not found"
  exit 1
}

KILL_SMALI="$kill_smali" python3 <<'PY'
import os
import re
import sys

path = os.environ["KILL_SMALI"]
with open(path, "r", encoding="utf-8") as fh:
    lines = fh.readlines()

method_start = None
method_end = None

for i, line in enumerate(lines):
    if re.match(r"^\.method\b.*\bsetUidState\(IZ\)V\s*$", line.strip()):
        if method_start is not None:
            print("duplicate setUidState(IZ)V", file=sys.stderr)
            sys.exit(2)
        method_start = i

if method_start is None:
    print("setUidState(IZ)V not found", file=sys.stderr)
    sys.exit(3)

for i in range(method_start + 1, len(lines)):
    if lines[i].strip() == ".end method":
        method_end = i
        break

if method_end is None:
    print("unterminated setUidState(IZ)V", file=sys.stderr)
    sys.exit(4)

kill_sig = "Lmiui/process/ProcessManager;->kill(Lmiui/process/ProcessConfig;)Z"
method = lines[method_start:method_end + 1]

kill_rel = [
    i for i, line in enumerate(method)
    if "invoke-static" in line and kill_sig in line
]
stop_rel = [
    i for i, line in enumerate(method)
    if '"stop uid="' in line
]
already_rel = [
    i for i, line in enumerate(method)
    if '"ignore stop uid="' in line
]

# Idempotent if the input APK has already received the same ZKOS patch.
if not kill_rel and len(already_rel) == 1:
    sys.exit(0)

if len(kill_rel) != 1 or len(stop_rel) != 1:
    print(
        f"unexpected setUidState layout: kill={len(kill_rel)} stop_log={len(stop_rel)}",
        file=sys.stderr,
    )
    sys.exit(5)

kill_idx = method_start + kill_rel[0]
stop_idx = method_start + stop_rel[0]

# ZKOS removes the short ProcessConfig construction immediately preceding
# ProcessManager.kill(). Limit the search window so a changed Xiaomi layout
# fails safely instead of deleting an unrelated block.
new_idx = None
for i in range(kill_idx - 1, max(method_start, kill_idx - 8), -1):
    s = lines[i].strip()
    if s.startswith(":"):
        break
    if "new-instance" in s and "Lmiui/process/ProcessConfig;" in s:
        new_idx = i
        break

if new_idx is None:
    print("ProcessConfig construction before ProcessManager.kill() not found", file=sys.stderr)
    sys.exit(6)

# Do not cross labels/branches inside the block being removed.
for line in lines[new_idx:kill_idx + 1]:
    if line.strip().startswith(":"):
        print("label found inside ProcessConfig/kill block", file=sys.stderr)
        sys.exit(7)

lines[stop_idx] = lines[stop_idx].replace('"stop uid="', '"ignore stop uid="', 1)
del lines[new_idx:kill_idx + 1]

out = "".join(lines)

# Verify only the intended method behavior changed.
m = re.search(
    r"(?ms)^\.method\b[^\n]*\bsetUidState\(IZ\)V\s*$.*?^\.end method\s*$",
    out,
)
if not m:
    print("patched setUidState(IZ)V verification failed", file=sys.stderr)
    sys.exit(8)

patched_method = m.group(0)
if kill_sig in patched_method:
    print("ProcessManager.kill() remains in setUidState(IZ)V", file=sys.stderr)
    sys.exit(9)
if patched_method.count('"ignore stop uid="') != 1:
    print("ZKOS ignore-stop marker verification failed", file=sys.stderr)
    sys.exit(10)

with open(path, "w", encoding="utf-8") as fh:
    fh.write(out)
PY


# HyperMOS FCM v2:
# 1) Whenever PowerKeeper regenerates MILLET_NO_RESTRICT_APP, preserve its
#    generated list and append Google Play services if it is missing.
#    Millet/Greezer remains enabled for every other application.
active_smali=$(find "$tmp/out" -type f -path '*/com/miui/powerkeeper/controller/ActiveStateController.smali' -print -quit)
[[ -n "$active_smali" && -f "$active_smali" ]] || {
  error "NOTIFICATION_FIX: ActiveStateController.smali not found"
  exit 1
}

ACTIVE_SMALI="$active_smali" python3 <<'PY'
import os
import re
import sys

path = os.environ["ACTIVE_SMALI"]
with open(path, "r", encoding="utf-8") as fh:
    text = fh.read()

m = re.search(
    r"(?ms)^\.method\b[^\n]*\bdealNoRestrictApp\(\)V\s*$.*?^\.end method\s*$",
    text,
)
if not m:
    print("dealNoRestrictApp()V not found", file=sys.stderr)
    sys.exit(20)

method = m.group(0)
if "MILLET_NO_RESTRICT_APP" not in method:
    print("MILLET_NO_RESTRICT_APP not referenced in dealNoRestrictApp()", file=sys.stderr)
    sys.exit(21)

if ":hypermos_gms_millet_done" in method:
    sys.exit(0)

locals_m = re.search(r"(?m)^(\s*)\.locals\s+(\d+)\s*$", method)
if not locals_m:
    print("dealNoRestrictApp() does not use .locals", file=sys.stderr)
    sys.exit(22)

old_locals = int(locals_m.group(2))
v_key = f"v{old_locals}"
v_value = f"v{old_locals + 1}"
v_tmp = f"v{old_locals + 2}"

method = (
    method[:locals_m.start()]
    + f"{locals_m.group(1)}.locals {old_locals + 3}"
    + method[locals_m.end():]
)

lines = method.splitlines(keepends=True)
put_idx = None
resolver_reg = None

for i, line in enumerate(lines):
    if (
        "Landroid/provider/Settings$System;->putString(" in line
        and "Ljava/lang/String;Ljava/lang/String;)Z" in line
    ):
        nearby = "".join(lines[max(0, i - 12):i + 1])
        if "MILLET_NO_RESTRICT_APP" not in nearby:
            continue
        regs_m = re.search(r"\{([^}]*)\}", line)
        if not regs_m:
            continue
        regs = [x.strip() for x in regs_m.group(1).split(",")]
        if len(regs) != 3:
            continue
        resolver_reg = regs[0]
        put_idx = i
        break

if put_idx is None or resolver_reg is None:
    print("MILLET Settings.System.putString() site not found", file=sys.stderr)
    sys.exit(23)

patch = f"""
    # HyperMOS: keep GMS in Xiaomi's hidden no-restrict package set.
    const-string {v_key}, "MILLET_NO_RESTRICT_APP"
    invoke-static {{{resolver_reg}, {v_key}}}, Landroid/provider/Settings$System;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;
    move-result-object {v_value}

    invoke-static {{{v_value}}}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z
    move-result {v_tmp}
    if-nez {v_tmp}, :hypermos_gms_millet_empty

    const-string {v_key}, "com.google.android.gms"
    invoke-virtual {{{v_value}, {v_key}}}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result {v_tmp}
    if-nez {v_tmp}, :hypermos_gms_millet_done

    const-string {v_key}, ",com.google.android.gms"
    invoke-virtual {{{v_value}, {v_key}}}, Ljava/lang/String;->concat(Ljava/lang/String;)Ljava/lang/String;
    move-result-object {v_value}
    goto :hypermos_gms_millet_write

:hypermos_gms_millet_empty
    const-string {v_value}, "com.google.android.gms"

:hypermos_gms_millet_write
    const-string {v_key}, "MILLET_NO_RESTRICT_APP"
    invoke-static {{{resolver_reg}, {v_key}, {v_value}}}, Landroid/provider/Settings$System;->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z

:hypermos_gms_millet_done
"""

lines.insert(put_idx + 1, patch)
patched_method = "".join(lines)
text = text[:m.start()] + patched_method + text[m.end():]

if text.count(":hypermos_gms_millet_done") != 2:
    print("MILLET patch verification failed", file=sys.stderr)
    sys.exit(24)

with open(path, "w", encoding="utf-8") as fh:
    fh.write(text)
PY

mods "PowerKeeper MILLET -> keep com.google.android.gms no-restrict"

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
