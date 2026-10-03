#!/usr/bin/env bash
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

MAIN_FOLDER="$work_dir/build/baserom/images"
APKEDITOR="java -jar $work_dir/bin/apktool/apke.jar"
tmp="$work_dir/apk_temp/notification-powerkeeper"

patch "PowerKeeper A16 (VSTeam notification behavior)"

apk=$(find "$MAIN_FOLDER" -type f -name "PowerKeeper.apk" -print -quit)
[[ -n "$apk" && -f "$apk" ]] || { error "NOTIFICATION_FIX: PowerKeeper.apk not found"; exit 1; }

dir=$(dirname "$apk")
rm -rf "$tmp"
mkdir -p "$tmp/out" "$tmp/final"

$APKEDITOR d -t raw -f -no-dex-debug -i "$apk" -o "$tmp/out" >/dev/null

# Keep the existing HyperMOS international-behavior patch. This is separate
# from the VSTeam kill wrapper below.
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

# VSTeam PowerKeeper 4.2.00 does not call ProcessManager.kill() directly.
# Its 13 original call sites are redirected to:
#   com.android.vsteam.Toolbox.kill(ProcessConfig) -> false
#
# Reproduce that behavior locally inside PowerKeeper instead of importing the
# whole VSTeam framework. Keeping a real helper method preserves move-result
# and caller branch semantics at every call site.
OLD_KILL='Lmiui/process/ProcessManager;->kill(Lmiui/process/ProcessConfig;)Z'
NEW_KILL='Lcom/hypermos/notification/PowerKeeperCompat;->kill(Lmiui/process/ProcessConfig;)Z'

kill_count=$(SMALI_ROOT="$tmp/out" OLD_KILL="$OLD_KILL" NEW_KILL="$NEW_KILL" python3 <<'PY'
from pathlib import Path
import os
import sys

root = Path(os.environ["SMALI_ROOT"])
old = os.environ["OLD_KILL"]
new = os.environ["NEW_KILL"]

count = 0
for path in root.rglob("*.smali"):
    text = path.read_text(encoding="utf-8")
    n = text.count(old)
    if n:
        path.write_text(text.replace(old, new), encoding="utf-8")
        count += n

if count < 1:
    print("0")
    sys.exit(3)

print(count)
PY
) || {
  error "NOTIFICATION_FIX: no ProcessManager.kill(ProcessConfig) call sites found"
  exit 1
}

if [[ "$kill_count" -ne 13 ]]; then
  warn "PowerKeeper kill-site count is $kill_count (verified VSTeam 4.2.00 has 13)"
fi

helper_root=$(find "$tmp/out" -maxdepth 1 -type d -name 'smali*' | sort | head -n 1)
[[ -n "$helper_root" && -d "$helper_root" ]] || {
  error "NOTIFICATION_FIX: no smali directory found for helper injection"
  exit 1
}

helper_dir="$helper_root/com/hypermos/notification"
helper_file="$helper_dir/PowerKeeperCompat.smali"
mkdir -p "$helper_dir"

cat > "$helper_file" <<'SMALI'
.class public final Lcom/hypermos/notification/PowerKeeperCompat;
.super Ljava/lang/Object;

.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static kill(Lmiui/process/ProcessConfig;)Z
    .locals 1

    const/4 v0, 0x0

    return v0
.end method
SMALI

if grep -RIlq "$OLD_KILL" "$tmp/out" --include='*.smali'; then
  error "NOTIFICATION_FIX: direct ProcessManager.kill(ProcessConfig) calls remain"
  exit 1
fi

helper_refs=$(grep -RhoF "$NEW_KILL" "$tmp/out" --include='*.smali' | wc -l)
if [[ "$helper_refs" -ne "$kill_count" ]]; then
  error "NOTIFICATION_FIX: helper redirect verification failed ($helper_refs/$kill_count)"
  exit 1
fi

mods "PowerKeeper VSTeam kill wrapper -> $kill_count call sites"

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
