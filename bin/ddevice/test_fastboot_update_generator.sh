#!/usr/bin/env bash
# Fast, no-device preflight for the HyperMOS no-wipe fastboot updater.
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
generator="$repo_root/bin/ddevice/genInstall.sh"
packager="$repo_root/uploadROM.sh"
bash -n "$generator"
bash -n "$packager"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin/ddevice" "$tmp/bin/script2flash"
cp "$generator" "$tmp/bin/ddevice/genInstall.sh"
printf 'haotian\n' > "$tmp/bin/ddevice/device_code.txt"
printf 'Xiaomi 15 Pro\n' > "$tmp/bin/ddevice/name_devices.txt"
printf 'OS3\n' > "$tmp/bin/ddevice/rom_os.txt"
printf 'OS3.0.308.0.WOBCNXM\n' > "$tmp/bin/ddevice/base_rom_code.txt"
printf 'China\n' > "$tmp/bin/ddevice/device_type.txt"
printf '16\n' > "$tmp/bin/ddevice/androidver.txt"
printf '1.3PS\n' > "$tmp/Version"
(cd "$tmp" && bash bin/ddevice/genInstall.sh >/dev/null)
flash="$tmp/bin/script2flash/FLASH.bat"
update="$tmp/bin/script2flash/UPDATE_NO_WIPE.bat"
test -s "$flash"
test -s "$update"
grep -Fq 'set "EXPECTED_DEVICE=haotian"' "$flash"
grep -Fq 'if /I "%~1"=="--no-wipe" (' "$flash"
grep -Fq 'set "WIPE_DATA=0"' "$flash"
grep -Fq 'if "%WIPE_DATA%"=="1" (' "$flash"
grep -Fq '"%FASTBOOT%" flash super "super\super.img"' "$flash"
grep -Fq 'call "%~dp0FLASH.bat" --no-wipe' "$update"
grep -Fq 'cp -f "$work_dir/bin/script2flash/UPDATE_NO_WIPE.bat"' "$packager"
if grep -Eiq '(^|[[:space:]])(erase|format|lock|relock)[[:space:]]+(userdata|metadata|bootloader)' "$update"; then
    echo "[ERROR] no-wipe entrypoint contains a destructive operation" >&2
    exit 1
fi
echo "[PASS] fastboot update: haotian target, explicit no-wipe, no lock/erase, super.img packaging"
