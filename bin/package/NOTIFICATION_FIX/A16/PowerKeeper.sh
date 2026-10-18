#!/usr/bin/env bash
# HAOTIAN Android 16: install the exact uploaded EU DEX on Xiaomi's stock APK.
# Original manifest/resources/assets/JNI and META-INF are preserved.
# NOTE: changing DEX invalidates the Xiaomi cryptographic APK signature.
set -euo pipefail
work_dir="$(pwd)"
source "$work_dir/functions.sh"
image_root="$work_dir/build/baserom/images"
base_dir="$work_dir/bin/package/NOTIFICATION_FIX/A16"
report_dir="$work_dir/build/reports/powerkeeper-a16"
tmp="$work_dir/apk_temp/powerkeeper-eu-dex"
delta="$base_dir/eu-powerkeeper-from-ryu.zst"
reference="$base_dir/tnm-perfhook-source.dex"

[[ -s "$delta" && -s "$reference" ]] || { error "PowerKeeper: EU patch/reference missing"; exit 1; }
[[ "$(git -C "$work_dir" hash-object "$delta")" == "8176d0aa5bf72c1437d42f70a34e0f412933e846" ]] || {
  error "PowerKeeper: EU delta source mismatch"; exit 1;
}
[[ "$(git -C "$work_dir" hash-object "$reference")" == "1b5a46ea3f9ead44a5467584e15dddd7ba4b0555" ]] || {
  error "PowerKeeper: compressed-EU reference source mismatch"; exit 1;
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

# Compression reference is the historical RYU source DEX, used ONLY as a
# zstd dictionary. Restored output is exactly the uploaded EU DEX, not RYU.
zstd -d -f -q --patch-from="$reference" "$delta" -o "$tmp/classes.dex"
eu_hash="$(sha256sum "$tmp/classes.dex" | cut -d ' ' -f1)"
[[ "$eu_hash" == "ad30c2d2aa6d474c1b975bce8fb0f8816fc4dafe19fc825ff23022a5016f73ae" ]] || {
  error "PowerKeeper: restored EU DEX checksum mismatch"; exit 1;
}

# Port only seven original ZKOS-matched build flag decisions into EU DEX.
# No RYU methods, ZK classes, thermal changes or broad international spoof.
zk_source="$base_dir/classes.dex"
[[ "$(git -C "$work_dir" hash-object "$zk_source")" == "f229fb0a5c67d41a55310a119ef64b18a86d6c04" ]] || {
  error "PowerKeeper: ZK reference DEX changed unexpectedly"; exit 1;
}
python3 "$base_dir/eu_zk_scoped_gates.py" \
  --eu "$tmp/classes.dex" --zk-reference "$zk_source" \
  --output "$tmp/eu-scoped.dex" --report "$report_dir/eu-scoped-gates.json"
scoped_hash="$(sha256sum "$tmp/eu-scoped.dex" | cut -d ' ' -f1)"
[[ "$scoped_hash" == "64efd5ef111c27b7040c6d89054b72bef9e01d5363075dd348098e866fa6e2f1" ]] || {
  error "PowerKeeper: scoped EU DEX output is not the verified reference"; exit 1;
}

# Build a temporary source wrapper, then transplant only classes.dex.
python3 "$base_dir/powerkeeper.py" prepare-donor \
  --stock-apk "$apk" --dex-file "$tmp/eu-scoped.dex" --output "$tmp/eu-wrapper.apk"
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

python3 - "$tmp/PowerKeeper.aligned.apk" "$scoped_hash" "$report_dir" "$base_hash" "$eu_hash" <<'PYEU'
import hashlib, json, sys, zipfile
from pathlib import Path
apk = Path(sys.argv[1])
expected_dex_sha, report_dir, base_sha, eu_source_sha = sys.argv[2], Path(sys.argv[3]), sys.argv[4], sys.argv[5]
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
    "eu_scoped_dex_sha256": expected_dex_sha,
    "zk_verified_gate_changes_only": 7,
    "other_eu_methods_untouched": True,
    "device_properties_or_thermal_rewritten": False,
    "final_apk_sha256": hashlib.sha256(apk.read_bytes()).hexdigest(),
    "source_ryu_used_as_compression_reference_only": True,
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
mods "PowerKeeper: EU DEX + seven ZK-referenced gates, no RYU PerfHook"
patch "PowerKeeper: stock non-DEX + v1 metadata preserved; changed DEX has invalid original cryptographic signature"
