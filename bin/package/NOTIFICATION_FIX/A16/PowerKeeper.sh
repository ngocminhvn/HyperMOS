#!/usr/bin/env bash
# HAOTIAN Android 16: patch four scoped GMS/Doze gates in China stock DEX.
# No EU/RYU/ZKOS DEX transplant. Preserve all original non-DEX stock content.
# Any DEX modification invalidates the APK's original cryptographic signature.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
image_root="$work_dir/build/baserom/images"
base_dir="$work_dir/bin/package/NOTIFICATION_FIX/A16"
report_dir="$work_dir/build/reports/powerkeeper-a16"
tmp="$work_dir/apk_temp/powerkeeper-stock-scoped"

command -v zipalign >/dev/null || { error "PowerKeeper: missing zipalign"; exit 1; }
command -v aapt >/dev/null || { error "PowerKeeper: missing aapt"; exit 1; }
mapfile -d '' apks < <(find "$image_root" -type f -name PowerKeeper.apk -print0)
(( ${#apks[@]} == 1 )) || { error "PowerKeeper: exactly one China stock APK required"; exit 1; }
apk="${apks[0]}"
[[ -s "$apk" ]] || { error "PowerKeeper: missing China stock APK"; exit 1; }
badging="$(aapt dump badging "$apk")"
grep -Fq "package: name='com.miui.powerkeeper' versionCode='40200'" <<< "$badging" || {
  error "PowerKeeper: expected China stock com.miui.powerkeeper v40200"; exit 1;
}
grep -Fq "sdkVersion:'36'" <<< "$badging" || {
  error "PowerKeeper: expected Android 16 APK"; exit 1;
}

rm -rf "$tmp"
mkdir -p "$tmp" "$report_dir"
trap 'rm -rf "$tmp"' EXIT

# Validate the original Xiaomi-signed APK before any modification.
python3 "$base_dir/preserve_powerkeeper_identity.py" \
  --check-base --apk "$apk" --reference "$apk" \
  --apksigner "$work_dir/bin/apktool/apksigner.jar" \
  --report "$report_dir/stock-identity.json"

# Only the specified methods are rewritten. If the China baseline diverges,
# fail closed rather than falling back to the whole EU DEX.
python3 "$base_dir/patch_stock_powerkeeper_a16.py" patch \
  --apk "$apk" --manifest "$base_dir/powerkeeper_stock_patches.json" \
  --output "$tmp/patched.dex" --report "$report_dir/stock-scoped-gates.json"
python3 "$base_dir/patch_stock_powerkeeper_a16.py" wrap \
  --apk "$apk" --dex "$tmp/patched.dex" --output "$tmp/PowerKeeper.wrapper.apk"

# Existing ROM certificate-compatibility path; never claim the original
# Xiaomi cryptographic signature is still valid after modifying DEX.
python3 "$base_dir/preserve_powerkeeper_identity.py" \
  --base "$apk" --patched "$tmp/PowerKeeper.wrapper.apk" \
  --reference "$apk" --apksigner "$work_dir/bin/apktool/apksigner.jar" \
  --apk "$tmp/PowerKeeper.preserved.apk" \
  --report "$report_dir/stock-preserved-metadata.json"
zipalign -p -f 4 "$tmp/PowerKeeper.preserved.apk" "$tmp/PowerKeeper.aligned.apk"
zipalign -c -p 4 "$tmp/PowerKeeper.aligned.apk"
python3 "$base_dir/preserve_powerkeeper_identity.py" \
  --apk "$tmp/PowerKeeper.aligned.apk" --reference "$apk" \
  --report "$report_dir/stock-final-metadata.json"

python3 - "$tmp/PowerKeeper.aligned.apk" "$report_dir/stock-scoped-gates.json" "$report_dir/stock-dex-report.json" <<'PYSTOCK'
import hashlib, json, sys, zipfile
from pathlib import Path
apk = Path(sys.argv[1])
audit = json.loads(Path(sys.argv[2]).read_text())
with zipfile.ZipFile(apk) as z:
    if z.testzip():
        raise SystemExit("PowerKeeper: damaged rebuilt APK")
    dex = z.read("classes.dex")
    if hashlib.sha256(dex).hexdigest() != audit["patched_dex_sha256"]:
        raise SystemExit("PowerKeeper: patched stock DEX digest mismatch")
report = {
    **audit,
    "final_apk_sha256": hashlib.sha256(apk.read_bytes()).hexdigest(),
    "non_dex_members_from_xiaomi_base": True,
    "cryptographic_xiaomi_signature_valid": False,
    "requires_existing_rom_signature_policy": True
}
Path(sys.argv[3]).write_text(json.dumps(report, indent=2) + "\n")
print("[POWERKEEPER STOCK] " + json.dumps(report))
PYSTOCK

cp -f "$tmp/PowerKeeper.aligned.apk" "$apk"
rm -rf "$(dirname "$apk")/oat"
mods "PowerKeeper: China stock DEX + 4 scoped GMS/Doze gates; DisplayFrameSetting untouched"
patch "PowerKeeper: stock resources/meta retained; original cryptographic signature invalid after DEX edit"
