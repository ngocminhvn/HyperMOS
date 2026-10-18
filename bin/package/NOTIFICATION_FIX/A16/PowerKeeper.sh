#!/usr/bin/env bash
# HAOTIAN Android 16: preserve the signed Xiaomi PowerKeeper from the base ROM.
# EU-like conservative policy: no ZKOS DEX, RYU UID-method or PerfHook injection.
# Modifications to framework notification behavior remain separate from this APK.
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
image_root="$work_dir/build/baserom/images"
base_dir="$work_dir/bin/package/NOTIFICATION_FIX/A16"
report_dir="$work_dir/build/reports/powerkeeper-a16"

mapfile -d '' apks < <(find "$image_root" -type f -name PowerKeeper.apk -print0)
(( ${#apks[@]} == 1 )) || {
  error "PowerKeeper: expected exactly one stock Xiaomi PowerKeeper.apk"; exit 1;
}
apk="${apks[0]}"
[[ -s "$apk" ]] || { error "PowerKeeper: base APK is empty"; exit 1; }
mkdir -p "$report_dir"

before="$(sha256sum "$apk" | cut -d ' ' -f1)"
# Require a cryptographically valid, original Xiaomi-signed APK. The previous
# DEX replacement preserved certificate *files* but invalidated the signature.
python3 "$base_dir/preserve_powerkeeper_identity.py" \
  --check-base --apk "$apk" --reference "$apk" \
  --apksigner "$work_dir/bin/apktool/apksigner.jar" \
  --report "$report_dir/stock-identity.json"
after="$(sha256sum "$apk" | cut -d ' ' -f1)"
[[ "$before" == "$after" ]] || {
  error "PowerKeeper: APK changed during stock verification"; exit 1;
}

python3 - "$apk" "$report_dir/stock-identity.json" <<'PYSTOCK'
import json
import re
import sys
import zipfile
from pathlib import Path

apk = Path(sys.argv[1])
report = Path(sys.argv[2])
with zipfile.ZipFile(apk) as src:
    if len(src.namelist()) != len(set(src.namelist())) or src.testzip():
        raise SystemExit("PowerKeeper: invalid stock APK ZIP")
    dex = [name for name in src.namelist()
           if re.fullmatch(r"classes(?:[2-9]|[1-9]\d+)?\.dex", name)]
    if not dex:
        raise SystemExit("PowerKeeper: stock APK has no DEX")
data = json.loads(report.read_text(encoding="utf-8"))
data.update({
    "policy": "xiaomi_stock_eu_like",
    "dex_replaced": False,
    "apk_modified": False,
    "ryu_perfhook_imported": False,
    "zkos_dex_imported": False,
    "conditional_uid_policy": "unaltered_base_rom",
    "dex_entries": dex,
    "note": "EU-inspired stock-first integration, not verified byte-for-byte EU parity",
})
report.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
print("[POWERKEEPER] Verified original Xiaomi APK; no DEX replacement")
PYSTOCK

printf '%s\n' "$after" > "$report_dir/stock-sha256.txt"
mods "PowerKeeper: verified Xiaomi stock APK (EU-like stock policy); no ZKOS/RYU DEX or PerfHook"
patch "PowerKeeper: original signature and ROM thermal/Doze/kill policy preserved"
