#!/usr/bin/env bash
# RYU-compatible HAOTIAN A16 test PowerKeeper:
# keep stock classes, patch verified GMS gates and conditional UID policy,
# and import pinned original PerfHook classes with dependency checks.
# This is a TEST branch build, not an assertion of on-device parity.
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"
MAIN_FOLDER="$work_dir/build/baserom/images"
APKEDITOR="java -jar $work_dir/bin/apktool/apke.jar"
tmp="$work_dir/apk_temp/notification-ryu-policy-audit"

patch "PowerKeeper A16 -> RYU selective GMS gate + stock policy validation"
apk=$(find "$MAIN_FOLDER" -type f -name PowerKeeper.apk -print -quit)
[[ -n "$apk" && -s "$apk" ]] || { error "RYU_TEST: PowerKeeper.apk missing"; exit 1; }

# The input remains genuine Xiaomi stock. The output preserves Xiaomi v1
# certificate metadata and relies on the existing ROM verifier bypass.
mapfile -d '' inputs < <(find "$MAIN_FOLDER" -type f -name PowerKeeper.apk -print0)
(( ${#inputs[@]} == 1 )) || { error "RYU_TEST: expected exactly one PowerKeeper"; exit 1; }
apk="${inputs[0]}"
ryu_apk="${RYU_POWERKEEPER_APK:-}"
[[ -n "$ryu_apk" && -s "$ryu_apk" ]] || { error "RYU_TEST: pinned RYU reference required"; exit 1; }
mapfile -d '' frameworks < <(find "$MAIN_FOLDER" -type f -name framework.jar -print0)
(( ${#frameworks[@]} == 1 )) || { error "RYU_TEST: expected one patched framework.jar"; exit 1; }
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/verify_powerkeeper_rom_verifier.py" \
  --framework "${frameworks[0]}" --baksmali "$work_dir/bin/apktool/baksmali.jar"
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/preserve_powerkeeper_identity.py" \
  --check-base --apk "$apk" --reference "$ryu_apk" \
  --apksigner "$work_dir/bin/apktool/apksigner.jar"
rm -rf "$tmp"
mkdir -p "$tmp"
trap 'rm -rf "$tmp"' EXIT

# Decode the base APK to validate compatibility before selective edits and rebuild.
if ! $APKEDITOR d -t raw -f -no-dex-debug -i "$apk" -o "$tmp/out" >/dev/null; then
  error "RYU_TEST: Could not decode base PowerKeeper.apk"
  exit 1
fi

# TNM RYU FULL mode: replace the APK's entire executable class/method set
# with original, pinned RYUOS PowerKeeper DEX at build time, rather than a
# selective PerfHook/GMS/UID patch. Keep the stock manifest and resources.
# RYU's two absent framework entrypoints are adapted while still in smali.
if [[ "${TNM_RYU_POWERKEEPER_MODE:-full-donor-dex}" == "full-donor-dex" ]]; then
  donor_sha="7783b8581deeaf2c39d4fdf04d68a724b9f9c2d0fdf2604b866b399efca27108"
  echo "$donor_sha  $ryu_apk" | sha256sum -c - || {
    error "RYU FULL: donor APK hash mismatch"
    exit 1
  }
  if ! $APKEDITOR d -t raw -f -no-dex-debug -i "$ryu_apk" -o "$tmp/source-ryu" >/dev/null; then
    error "RYU FULL: could not decode original RYU PowerKeeper"
    exit 1
  fi
  python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/ryu_full_powerkeeper_a16.py" \
    --stock-root "$tmp/out" --donor-root "$tmp/source-ryu" \
    --stock-apk "$apk" --donor-apk "$ryu_apk" \
    --report "$tmp/ryu-full-port.json" || {
    error "RYU FULL: original DEX transfer failed"
    exit 1
  }
  mkdir -p "$tmp/final"
  if ! $APKEDITOR b -f -i "$tmp/out" -o "$tmp/final/PowerKeeper.apk" >/dev/null; then
    error "RYU FULL: Xiaomi APK resources repack failed"
    exit 1
  fi
  python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/rebuild_powerkeeper_dex.py" \
    --decoded "$tmp/out" --apk "$tmp/final/PowerKeeper.apk" \
    --smali-jar "$work_dir/bin/apktool/smaliv2.jar" --api 36 || {
    error "RYU FULL: all donor DEX could not be assembled"
    exit 1
  }
  python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/verify_ryu_uid_policy_apk.py" \
    --apk "$tmp/final/PowerKeeper.apk"
  python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/verify_perfhook_apk.py" \
    --apk "$tmp/final/PowerKeeper.apk" --report "$tmp/ryu-full-port.json"
  command -v zipalign >/dev/null || { error "RYU FULL: zipalign missing"; exit 1; }
  identity="$work_dir/bin/package/NOTIFICATION_FIX/A16/preserve_powerkeeper_identity.py"
  python3 "$identity" --base "$apk" --patched "$tmp/final/PowerKeeper.apk" \
    --reference "$ryu_apk" --apksigner "$work_dir/bin/apktool/apksigner.jar" \
    --apk "$tmp/final/PowerKeeper.preserved.apk" \
    --report "$tmp/certificate-identity.json"
  zipalign -p -f 4 "$tmp/final/PowerKeeper.preserved.apk" "$tmp/final/PowerKeeper.aligned.apk"
  zipalign -c -p 4 "$tmp/final/PowerKeeper.aligned.apk"
  python3 "$identity" --apk "$tmp/final/PowerKeeper.aligned.apk" \
    --reference "$ryu_apk" --report "$tmp/final-identity.json"
  python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/verify_ryu_uid_policy_apk.py" \
    --apk "$tmp/final/PowerKeeper.aligned.apk"
  python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/verify_perfhook_apk.py" \
    --apk "$tmp/final/PowerKeeper.aligned.apk" --report "$tmp/ryu-full-port.json"
  report_dir="$work_dir/build/reports/powerkeeper-a16"
  mkdir -p "$report_dir"
  cp "$tmp/ryu-full-port.json" "$report_dir/ryu-full-port.json"
  cp "$tmp/certificate-identity.json" "$report_dir/certificate-identity.json"
  cp "$tmp/final-identity.json" "$report_dir/final-identity.json"
  apk_dir=$(dirname "$apk")
  cp -f "$tmp/final/PowerKeeper.aligned.apk" "$apk"
  rm -rf "$apk_dir/oat"
  mods "PowerKeeper: ALL RYUOS donor DEX methods + Xiaomi original APK resources; no runtime hook"
  patch "PowerKeeper A16 full RYU DEX compiled and staged (device runtime not tested)"
  exit 0
fi
[[ "${TNM_RYU_POWERKEEPER_MODE:-}" == "selective" ]] || {
  error "Unknown TNM_RYU_POWERKEEPER_MODE (use full-donor-dex or selective)"
  exit 1
}

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
# Port the two missing RYU ABI declarations before compiling any DEX.
# The controller call path is already verified; do not replace other classes.
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/ryu_uid_policy_a16.py" \
  --ryu "$tmp/source-ryu" --stock "$tmp/out" \
  --report "$tmp/uid-policy-port.json" || {
  error "RYU UID POLICY: interface/AppRuleChecker synchronization failed"
  exit 1
}

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
# APKEditor raw-mode ignores newly changed smali/com code. Compile every
# decoded DEX explicitly and replace the preserved original DEX binary.
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/rebuild_powerkeeper_dex.py" \
  --decoded "$tmp/out" \
  --apk "$tmp/final/PowerKeeper.apk" \
  --smali-jar "$work_dir/bin/apktool/smaliv2.jar" --api 36 || {
  error "RYU PERFHOOK: patched PowerKeeper DEX compilation/repacking failed"
  exit 1
}
unzip -tq "$tmp/final/PowerKeeper.apk" >/dev/null
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/verify_ryu_uid_policy_apk.py" \
  --apk "$tmp/final/PowerKeeper.apk" || {
  error "RYU UID POLICY: compiled DEX missing interface or implementation"
  exit 1
}
# APKEditor may silently ignore newly created dex directories. Assert the
# class definitions are genuinely present in the final binary, not only smali.
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/verify_perfhook_apk.py" \
  --apk "$tmp/final/PowerKeeper.apk" --report "$tmp/perfhook-port.json" || {
  error "RYU PERFHOOK: compiled APK is missing required original classes"
  exit 1
}

# Keep the Xiaomi certificate identity; never sign this UID 1000 app with
# the repository Android/testkey. Reuse pinned original RYU v1 metadata and
# the unmodified stock manifest/resources. This is not a valid Xiaomi re-sign.
command -v zipalign >/dev/null || { error "RYU_TEST: zipalign missing"; exit 1; }
preserved="$tmp/final/PowerKeeper.preserved.apk"
aligned="$tmp/final/PowerKeeper.aligned.apk"
identity="$work_dir/bin/package/NOTIFICATION_FIX/A16/preserve_powerkeeper_identity.py"
python3 "$identity" --base "$apk" --patched "$tmp/final/PowerKeeper.apk" \
  --reference "$ryu_apk" --apksigner "$work_dir/bin/apktool/apksigner.jar" \
  --apk "$preserved" --report "$tmp/certificate-identity.json"
zipalign -p -f 4 "$preserved" "$aligned"
zipalign -c -p 4 "$aligned"
python3 "$identity" --apk "$aligned" --reference "$ryu_apk" \
  --report "$tmp/final-identity.json"
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/verify_ryu_uid_policy_apk.py" --apk "$aligned"
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/verify_perfhook_apk.py" \
  --apk "$aligned" --report "$tmp/perfhook-port.json"
report_dir="$work_dir/build/reports/powerkeeper-a16"
mkdir -p "$report_dir"
cp -f "$tmp/certificate-identity.json" "$report_dir/certificate-identity.json"
cp -f "$tmp/final-identity.json" "$report_dir/final-identity.json"
cp -f "$tmp/uid-policy-port.json" "$report_dir/uid-policy-port.json"
cp -f "$tmp/perfhook-port.json" "$report_dir/perfhook-port.json"
apk_dir=$(dirname "$apk")
cp -f "$aligned" "$apk"
cmp -s "$aligned" "$apk"
rm -rf "$apk_dir/oat"
mods "PowerKeeper: patched GMS/UID/PerfHook; Xiaomi certificate retained, v1 ROM bypass required"
patch "PowerKeeper A16 RYU compiled and staged (device runtime not tested)"
