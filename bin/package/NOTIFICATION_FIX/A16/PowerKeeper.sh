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

rm -rf "$tmp"
mkdir -p "$tmp"
trap 'rm -rf "$tmp"' EXIT

# Decode the base APK to validate compatibility before selective edits and rebuild.
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

# Sign the FINAL compiled APK, not APKEditor's stale DEX output. On #99 the
# unsigned PowerKeeper was present in system_ext but absent from PackageManager.
# Use the same fixed testkey as HyperMOS InstallerX on this TEST branch only.
sign_jar="$work_dir/bin/apktool/apksigner.jar"
sign_key="$work_dir/bin/package/DISABLE_AVB/HMATools/aosp/security/testkey.pk8"
sign_cert="$work_dir/bin/package/DISABLE_AVB/HMATools/aosp/security/testkey.x509.pem"
for required in "$sign_jar" "$sign_key" "$sign_cert"; do
  [[ -s "$required" ]] || { error "RYU POWERKEEPER SIGN: missing $required"; exit 1; }
done
command -v zipalign >/dev/null || { error "RYU POWERKEEPER SIGN: zipalign missing"; exit 1; }
command -v aapt >/dev/null || { error "RYU POWERKEEPER SIGN: aapt missing"; exit 1; }

original_identity=$(aapt dump badging "$apk" |
  sed -n "s/^package: name='\\([^']*\\)' versionCode='\\([^']*\\)' versionName='\\([^']*\\)'.*/\\1|\\2|\\3/p" | head -n 1)
[[ "$original_identity" == "com.miui.powerkeeper|"* ]] || {
  error "RYU POWERKEEPER SIGN: unexpected original APK identity: $original_identity"; exit 1;
}

unsigned="$tmp/final/PowerKeeper.apk"
aligned="$tmp/final/PowerKeeper.aligned.apk"
signed="$tmp/final/PowerKeeper.signed.apk"
zipalign -p -f 4 "$unsigned" "$aligned" || {
  error "RYU POWERKEEPER SIGN: zipalign failed"; exit 1;
}
zipalign -c -p 4 "$aligned" || {
  error "RYU POWERKEEPER SIGN: aligned APK verification failed"; exit 1;
}
java -jar "$sign_jar" sign --key "$sign_key" --cert "$sign_cert" \
  --out "$signed" "$aligned" || {
  error "RYU POWERKEEPER SIGN: signing failed"; exit 1;
}
[[ -s "$signed" ]] || { error "RYU POWERKEEPER SIGN: signed APK empty"; exit 1; }
zipalign -c -p 4 "$signed" || {
  error "RYU POWERKEEPER SIGN: signed APK alignment failed"; exit 1;
}
unzip -tq "$signed" || { error "RYU POWERKEEPER SIGN: signed APK corrupted"; exit 1; }
signature_output=$(java -jar "$sign_jar" verify --verbose --print-certs \
  --min-sdk-version 36 "$signed") || {
  error "RYU POWERKEEPER SIGN: APK signature verification failed"; exit 1;
}
printf '%s\n' "$signature_output" |
  grep -Eq '^Verified using v[23] scheme \(APK Signature Scheme v[23]\): true' || {
  error "RYU POWERKEEPER SIGN: expected V2/V3 signature verification missing"; exit 1;
}
expected_cert=$(openssl x509 -in "$sign_cert" -outform DER | sha256sum | awk '{print tolower($1)}')
actual_cert=$(printf '%s\n' "$signature_output" |
  sed -n 's/^Signer #1 certificate SHA-256 digest: //p' | head -n 1 | tr -d ':' | tr '[:upper:]' '[:lower:]')
[[ -n "$expected_cert" && "$expected_cert" == "$actual_cert" ]] || {
  error "RYU POWERKEEPER SIGN: output signer differs from fixed InstallerX testkey"; exit 1;
}
signed_identity=$(aapt dump badging "$signed" |
  sed -n "s/^package: name='\\([^']*\\)' versionCode='\\([^']*\\)' versionName='\\([^']*\\)'.*/\\1|\\2|\\3/p" | head -n 1)
[[ "$signed_identity" == "$original_identity" ]] || {
  error "RYU POWERKEEPER SIGN: package/version changed: $original_identity -> $signed_identity"; exit 1;
}
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/verify_perfhook_apk.py" \
  --apk "$signed" --report "$tmp/perfhook-port.json" || {
  error "RYU POWERKEEPER SIGN: signed APK lost PerfHook DEX"; exit 1;
}
python3 "$work_dir/bin/package/NOTIFICATION_FIX/A16/verify_ryu_uid_policy_apk.py" \
  --apk "$signed" || {
  error "RYU UID POLICY: signature stage lost UID policy method definitions"
  exit 1
}
mods "RYU PowerKeeper: V2/V3 signature verified, InstallerX testkey ($actual_cert)"
apk_dir=$(dirname "$apk")
rm -rf "$apk_dir/oat"
cp -f "$signed" "$apk" || {
  error "RYU POWERKEEPER SIGN: staging signed APK failed"; exit 1;
}
cmp -s "$signed" "$apk" || {
  error "RYU POWERKEEPER SIGN: staged ROM APK differs from verified output"; exit 1;
}
mods "RYU PowerKeeper: GmsObserver + KillProcessController + original RYU PerfHook"
patch "PowerKeeper A16 RYU GMS + conditional UID kill -> Done"
