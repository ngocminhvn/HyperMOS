#!/usr/bin/env bash
# HAOTIAN Android 16: install the exact uploaded EU DEX on Xiaomi's stock APK.
# Original manifest/resources/assets/JNI and META-INF are preserved.
# NOTE: changing DEX invalidates the Xiaomi cryptographic APK signature.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
image_root="$work_dir/build/baserom/images"
base_dir="$work_dir/bin/package/NOTIFICATION_FIX/A16/CN"
report_dir="$work_dir/build/reports/powerkeeper-a16"
tmp="$work_dir/apk_temp/powerkeeper-eu-dex"
archive="$base_dir/eu-powerkeeper.dex.zst"

[[ -s "$archive" ]] || { error "PowerKeeper: EU archive missing"; exit 1; }
[[ "$(git -C "$work_dir" hash-object "$archive")" == "1d62e3b62b2df640d095b67e929039d35905bf17" ]] || {
  error "PowerKeeper: EU archive source mismatch"; exit 1;
}
command -v zstd >/dev/null || { error "PowerKeeper: missing zstd"; exit 1; }
command -v zipalign >/dev/null || { error "PowerKeeper: missing zipalign"; exit 1; }
command -v aapt >/dev/null || { error "PowerKeeper: missing aapt"; exit 1; }

mapfile -d '' apks < <(find "$image_root" -type f -name PowerKeeper.apk -print0)
(( ${#apks[@]} == 1 )) || { error "PowerKeeper: exactly one stock Xiaomi APK required"; exit 1; }
apk="${apks[0]}"
[[ -s "$apk" ]] || { error "PowerKeeper: empty base APK"; exit 1; }
badging="$(aapt dump badging "$apk")"
grep -Fq "package: name='com.miui.powerkeeper' versionCode='40200'" <<< "$badging" || {
  error "PowerKeeper: base APK must match EU v4.2.00 package and versionCode"; exit 1;
}
grep -Fq "sdkVersion:'36'" <<< "$badging" || {
  error "PowerKeeper: base APK is not Android 16"; exit 1;
}

rm -rf "$tmp"
mkdir -p "$tmp" "$report_dir"
trap 'rm -rf "$tmp"' EXIT
base_hash="$(sha256sum "$apk" | cut -d ' ' -f1)"
python3 "$base_dir/preserve_powerkeeper_identity.py" \
  --check-base --apk "$apk" --reference "$apk" \
  --apksigner "$work_dir/bin/apktool/apksigner.jar" \
  --report "$report_dir/stock-identity.json"

# Standalone EU DEX archive: no RYU DEX or external compression dictionary.
zstd -d -f -q "$archive" -o "$tmp/classes.dex"
eu_hash="$(sha256sum "$tmp/classes.dex" | cut -d ' ' -f1)"
[[ "$eu_hash" == "ad30c2d2aa6d474c1b975bce8fb0f8816fc4dafe19fc825ff23022a5016f73ae" ]] || {
  error "PowerKeeper: restored EU DEX checksum mismatch"; exit 1;
}

# Apply the same seven previously audited gates without carrying ZKOS DEX.
# Six method identities, EU/ZK gate counts and SHA pins live in a small JSON
# manifest. Exact EU input and resulting DEX hashes are both verified.
gate_manifest="$base_dir/gate_reference_a16.json"
[[ -s "$gate_manifest" ]] || { error "PowerKeeper: gate audit manifest missing"; exit 1; }
python3 "$base_dir/eu_scoped_gates.py" \
  --eu "$tmp/classes.dex" --gate-manifest "$gate_manifest" \
  --output "$tmp/eu-scoped.dex" --report "$report_dir/eu-scoped-gates.json"
scoped_hash="$(sha256sum "$tmp/eu-scoped.dex" | cut -d ' ' -f1)"
[[ "$scoped_hash" == "64efd5ef111c27b7040c6d89054b72bef9e01d5363075dd348098e866fa6e2f1" ]] || {
  error "PowerKeeper: scoped EU DEX output is not the verified reference"; exit 1;
}

# Install the verified seven-gate EU DEX directly, with no additional
# ActiveStateController Smali rewrite or injected GMS Millet allowlist.
installed_dex="$tmp/eu-scoped.dex"
installed_hash="$scoped_hash"

# Build a temporary source wrapper, then transplant only classes.dex.
python3 "$base_dir/powerkeeper.py" prepare-donor \
  --stock-apk "$apk" --dex-file "$installed_dex" --output "$tmp/eu-wrapper.apk"
python3 "$base_dir/preserve_powerkeeper_identity.py" \
  --base "$apk" --patched "$tmp/eu-wrapper.apk" \
  --reference "$apk" --apksigner "$work_dir/bin/apktool/apksigner.jar" \
  --apk "$tmp/PowerKeeper.preserved.apk" \
  --report "$report_dir/eu-preserved-metadata.json"

zipalign -p -f 4 "$tmp/PowerKeeper.preserved.apk" "$tmp/PowerKeeper.aligned.apk"
zipalign -c -p 4 "$tmp/PowerKeeper.aligned.apk"
python3 "$base_dir/preserve_powerkeeper_identity.py" \
  --apk "$tmp/PowerKeeper.aligned.apk" --reference "$apk" \
  --report "$report_dir/eu-final-metadata.json"

python3 - "$tmp/PowerKeeper.aligned.apk" "$installed_hash" "$report_dir" "$base_hash" "$eu_hash" "$scoped_hash" <<'PYEU'
import hashlib, json, sys, zipfile
from pathlib import Path
apk = Path(sys.argv[1])
expected_dex_sha, report_dir, base_sha, eu_source_sha, scoped_dex_sha = sys.argv[2], Path(sys.argv[3]), sys.argv[4], sys.argv[5], sys.argv[6]
with zipfile.ZipFile(apk) as archive:
    if archive.testzip():
        raise SystemExit("PowerKeeper: invalid final ZIP")
    dex = archive.read("classes.dex")
    if hashlib.sha256(dex).hexdigest() != expected_dex_sha:
        raise SystemExit("PowerKeeper: final APK does not contain EU DEX")
report = {
    "donor": "original_uploaded_eu_powerkeeper_v4.2.00",
    "base_apk_sha256": base_sha,
    "eu_source_dex_sha256": eu_source_sha,
    "eu_scoped_dex_sha256": scoped_dex_sha,
    "installed_eu_scoped_dex_sha256": expected_dex_sha,
    "gms_millet_extension_enabled": False,
    "dealNoRestrictApp_untouched": True,
    "ActiveStateController_enable_untouched": True,
    "new_background_worker": False,
    "historically_zk_verified_gate_changes_only": 7,
    "zk_reference_dex_required_at_build": False,
    "other_eu_methods_untouched_outside_seven_gates": True,
    "device_properties_or_thermal_rewritten": False,
    "final_apk_sha256": hashlib.sha256(apk.read_bytes()).hexdigest(),
    "eu_source_standalone_zstd": True,
    "ryu_perfhook_imported": False,
    "zkos_dex_imported": False,
    "non_dex_members_from_xiaomi_base": True,
    "cryptographic_xiaomi_signature_valid": False,
    "requires_existing_rom_signature_policy": True,
    "runtime_tested": False
}
(report_dir / "eu-dex-report.json").write_text(json.dumps(report, indent=2) + "\n")
print("[POWERKEEPER EU] " + json.dumps(report))
PYEU

cp -f "$tmp/PowerKeeper.aligned.apk" "$apk"
rm -rf "$(dirname "$apk")/oat"
mods "PowerKeeper: EU DEX + seven audited gates; no injected GMS Millet exemption"
patch "PowerKeeper: stock non-DEX + v1 metadata preserved; changed DEX has invalid original cryptographic signature"

