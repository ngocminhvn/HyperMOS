#!/usr/bin/env bash
# RYU-compatible baseline for A16 PowerKeeper.
# Preserve all stock APK classes and implement only two verified RYU GMS
# gates in the existing GmsObserver. RYU-only PerfHook classes/resources are
# deliberately excluded; this stays restricted to the HAOTIAN test branch.
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"
MAIN_FOLDER="$work_dir/build/baserom/images"
APKEDITOR="java -jar $work_dir/bin/apktool/apke.jar"
tmp="$work_dir/apk_temp/notification-ryu-policy-audit"

patch "PowerKeeper A16 -> RYU selective GMS gate + stock policy validation"
apk=$(find "$MAIN_FOLDER" -type f -name PowerKeeper.apk -print -quit)
[[ -n "$apk" && -s "$apk" ]] || { error "RYU_TEST: PowerKeeper.apk missing"; exit 1; }

rm -rf "$tmp"
mkdir -p "$tmp"
trap 'rm -rf "$tmp"' EXIT

# Decode only to verify compatibility; the artifact itself is NOT rebuilt.
if ! $APKEDITOR d -t raw -f -no-dex-debug -i "$apk" -o "$tmp/out" >/dev/null; then
  error "RYU_TEST: Could not decode base PowerKeeper.apk"
  exit 1
fi

RYU_AUDIT_DIR="$tmp/out" python3 <<'PY'
import os
import re
import sys
from pathlib import Path

root = Path(os.environ["RYU_AUDIT_DIR"])
def find_one(name):
    found = list(root.rglob(name))
    if len(found) != 1:
        raise RuntimeError(f"{name}: expected one class; found {len(found)}")
    return found[0].read_text(encoding="utf-8")

def method_body(src, name, proto):
    pattern = rf"(?ms)^\.method\b[^\n]*\b{re.escape(name)}{re.escape(proto)}\s*$.*?^\.end method\s*$"
    found = re.findall(pattern, src)
    if len(found) != 1:
        raise RuntimeError(f"{name}{proto}: expected exactly one method; got {len(found)}")
    return found[0]

try:
    kill = find_one("KillProcessController.smali")
    state = method_body(kill, "setUidState", "(IZ)V")
    # Xiaomi stock has the rule-checker field but does NOT yet invoke
    # ProcessManager.kill in setUidState(). RYU adds a conditional call.
    if "mKillProcessAppRuleChecker:Lcom/miui/powerkeeper/PowerKeeperInterface$l;" not in kill:
        raise RuntimeError("Xiaomi UID checker field missing")
    for required in ("ProcessManager;->isLockedApplication", "checkAppOnWindowsStatus",
                     "PowerKeeperManager;->getCurrentIME"):
        if required not in state:
            raise RuntimeError("Unexpected Xiaomi setUidState layout: " + required)

    observer = find_one("GmsObserver.smali")
    gms = method_body(observer, "isGmsControlEnabled", "()Z")
    # RYU keeps a real control method, not HyperMOS's forced-constant stub.
    instructions = [
        line.strip() for line in gms.splitlines()
        if line.strip() and not line.lstrip().startswith((".", "#", ":"))
    ]
    if len(instructions) < 6:
        raise RuntimeError("GmsObserver control unexpectedly collapsed to a short stub")

    app = find_one("PowerKeeperApplication.smali")
    method_body(app, "onCreate", "()V")
    if "hypermosEnforceGmsMillet" in app:
        raise RuntimeError("boot-time MILLET forcing is already baked into base APK")

    private_classes = list(root.rglob("PerfHook.smali"))
    if any("projectryu" in p.as_posix().lower() for p in private_classes):
        raise RuntimeError("Unexpected ProjectRYU proprietary PerfHook already in base")
except RuntimeError as exc:
    print(f"[RYU_TEST] FAIL: {exc}", file=sys.stderr)
    sys.exit(1)
print("[RYU_TEST] PASS: stock checker field and guarded setUidState path present")
print("[RYU_TEST] PASS: stock GmsObserver control retained")
print("[RYU_TEST] PASS: no HyperMOS forced MILLET helper")
print("[RYU_TEST] PowerKeeper base validated; only RYU GMS + UID checker methods will be patched")
PY

# RYU PowerKeeper differences verified against the actual RYU HAOTIAN APK:
# GmsObserver.<init> and updateGoogleSync use IS_RYU_BUILD instead of the
# Xiaomi international-build flag. Reproduce its enabled outcome ONLY
# inside those two methods. Do not alter isGmsControlEnabled() or kill paths.
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/ryu_gms_observer_a16.py" "$tmp/out" || {
  error "RYU_TEST: GmsObserver gate parity failed"
  exit 1
}

# Port the RYUOS conditional UID-kill policy without replacing the APK.
# The checker field already exists in Xiaomi's PowerKeeper; only these two
# methods differ in RYU. Fail fast on any unknown base-bytecode layout.
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/ryu_killprocess_a16.py" "$tmp/out" || {
  error "RYU_TEST: KillProcessController parity failed"
  exit 1
}

# Install original RYU HAOTIAN PerfHook and its dependency closure from the
# validated user-supplied RYU APK. Do not distribute its smali in git/artifacts.
# One-time activation matches RYU PowerKeeperApplication.onCreate.
ryu_apk="${RYU_POWERKEEPER_APK:-}"
[[ -n "$ryu_apk" && -s "$ryu_apk" ]] || {
  error "RYU PERFHOOK: verified original RYU PowerKeeper APK is required"
  exit 1
}
ryu_sha="7783b8581deeaf2c39d4fdf04d68a724b9f9c2d0fdf2604b866b399efca27108"
echo "$ryu_sha  $ryu_apk" | sha256sum -c - || {
  error "RYU PERFHOOK: original APK SHA256 does not match verified reference"
  exit 1
}
if ! $APKEDITOR d -t raw -f -no-dex-debug -i "$ryu_apk" -o "$tmp/source-ryu" >/dev/null; then
  error "RYU PERFHOOK: original RYU APK decompile failed"
  exit 1
fi
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/ryu_perfhook_port.py" \
  --ryu "$tmp/source-ryu" --stock "$tmp/out" \
  --report "$tmp/perfhook-port.json" || {
  error "RYU PERFHOOK: class dependency or startup hook incompatible"
  exit 1
}

mkdir -p "$tmp/final"
if ! $APKEDITOR b -f -i "$tmp/out" -o "$tmp/final/PowerKeeper.apk" >/dev/null; then
  error "RYU_TEST: selective PowerKeeper APK recompile failed"
  exit 1
fi
[[ -s "$tmp/final/PowerKeeper.apk" ]] || { error "RYU_TEST: empty PowerKeeper output"; exit 1; }
unzip -tq "$tmp/final/PowerKeeper.apk" >/dev/null

# Same APKEditor replacement path used by stable HyperMOS notification patch.
# Signature/Android package-manager acceptance still needs on-device testing.
apk_dir=$(dirname "$apk")
rm -rf "$apk_dir/oat"
cp -f "$tmp/final/PowerKeeper.apk" "$apk"
mods "RYU PowerKeeper: GmsObserver + KillProcessController + original RYU PerfHook"
patch "PowerKeeper A16 RYU GMS + conditional UID kill -> Done"
