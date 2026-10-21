#!/usr/bin/env bash
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
MAIN_FOLDER="$work_dir/build/baserom/images"
rom_os="$(cat "$work_dir/bin/ddevice/rom_os.txt")"
APKEDITOR="$work_dir/bin/apktool/apke.jar"

if [[ "$rom_os" != "OS3" && "$rom_os" != "OS2" && "$rom_os" != "OS1" ]]; then
    exit 0
fi

mods "Remove Region Check for HyperOS (validated)"
mapfile -d '' -t provision_apks < <(
    find "$MAIN_FOLDER" -type f -name 'Provision.apk' -print0
)
if (( ${#provision_apks[@]} == 0 )); then
    mods "RegionPatch: Provision.apk absent, preserving ROM"
    exit 0
fi
if (( ${#provision_apks[@]} != 1 )); then
    error "RegionPatch: expected one Provision.apk, found ${#provision_apks[@]}"
    exit 1
fi

original_apk="${provision_apks[0]}"
patch_tmp="$(mktemp -d "$work_dir/apk_temp.region.XXXXXX")"
trap 'rm -rf "$patch_tmp"' EXIT

if ! java -jar "$APKEDITOR" d -t raw -f -no-dex-debug \
     -i "$original_apk" -o "$patch_tmp/decoded"; then
    error "RegionPatch: cannot decompile Provision.apk; original preserved"
    exit 1
fi

# Avoid the legacy strRep.py -1-index bug: identify exactly one method
# and its own .end method BEFORE writing anything. No match means no patch.
if python3 - "$patch_tmp/decoded" <<'PY'
from pathlib import Path
import sys

root = Path(sys.argv[1])
signature = ".method public static checkVersionConsistent()Z"
matches = []
for path in root.rglob("Utils.smali"):
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    for index, line in enumerate(lines):
        if line.strip() == signature:
            matches.append((path, lines, index))

if not matches:
    print("RegionPatch: checkVersionConsistent()Z not found; safe skip")
    sys.exit(20)
if len(matches) != 1:
    print(f"RegionPatch: ambiguous method ({len(matches)} matches)", file=sys.stderr)
    sys.exit(21)

path, lines, start = matches[0]
end = None
for index in range(start + 1, len(lines)):
    value = lines[index].strip()
    if value == ".end method":
        end = index
        break
    if value.startswith(".method "):
        print("RegionPatch: malformed method boundaries", file=sys.stderr)
        sys.exit(22)
if end is None:
    print("RegionPatch: method terminator missing", file=sys.stderr)
    sys.exit(23)

replacement = (
    ".method public static checkVersionConsistent()Z\n"
    "    .registers 1\n"
    "\n"
    "    const/4 v0, 0x0\n"
    "\n"
    "    return v0\n"
    ".end method\n"
)
patched = "".join(lines[:start]) + replacement + "".join(lines[end + 1:])
path.write_text(patched, encoding="utf-8")
assert patched.count(signature) == 1
print(f"RegionPatch: safely replaced 1 method in {path.name}")
PY
then
    :
else
    result=$?
    if (( result == 20 )); then
        mods "RegionPatch: target method absent; original Provision.apk unchanged"
        exit 0
    fi
    error "RegionPatch: method check failed (exit $result); original APK preserved"
    exit 1
fi

mkdir -p "$patch_tmp/final"
rebuilt_apk="$patch_tmp/final/Provision.apk"
if ! java -jar "$APKEDITOR" b -f -i "$patch_tmp/decoded" -o "$rebuilt_apk"; then
    error "RegionPatch: failed to rebuild Provision.apk; original preserved"
    exit 1
fi
if [[ ! -s "$rebuilt_apk" ]] || ! unzip -tq "$rebuilt_apk" >/dev/null; then
    error "RegionPatch: rebuilt APK failed archive validation; original preserved"
    exit 1
fi
sudo cp -f "$rebuilt_apk" "$original_apk"
mods "RegionPatch: one method patched and APK verified; original directory contents preserved"
