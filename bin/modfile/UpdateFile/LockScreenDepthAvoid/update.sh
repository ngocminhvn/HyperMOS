#!/usr/bin/env bash
# ==============================================================================
# LockScreenDepthAvoid Patch for HyperMOS (MiuiAod.apk / MIUIAod.apk)
# ==============================================================================
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"

base="$work_dir/bin/modfile/UpdateFile/LockScreenDepthAvoid"
images="$work_dir/build/baserom/images"
rom_os="$(tr -d '\r\n' < "$work_dir/bin/ddevice/rom_os.txt" 2>/dev/null || true)"
android_ver="$(tr -d '\r\n' < "$work_dir/bin/ddevice/androidver.txt" 2>/dev/null || true)"

case "$rom_os/$android_ver" in
    OS3/16|OS4/17) ;;
    *)
        mods "LockScreenDepthAvoid: skip unsupported ROM generation ($rom_os / A$android_ver)"
        exit 0
        ;;
esac

mapfile -d '' -t matches < <(
    find "$images" -type f \( -name 'MiuiAod.apk' -o -name 'MIUIAod.apk' \) -print0
)
if (( ${#matches[@]} == 0 )); then
    mods "LockScreenDepthAvoid: no MiuiAod APK found in baserom; skipping"
    exit 0
fi
target="${matches[0]}"

editor="$work_dir/bin/apktool/apke.jar"
[[ -s "$editor" ]] || { error "LockScreenDepthAvoid: APKEditor ($editor) missing"; exit 1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mods "LockScreenDepthAvoid: Unpacking $(basename "$target")..."
if ! java -jar "$editor" d -t raw -f -no-dex-debug \
    -i "$target" -o "$tmp/aod" >"$tmp/unpack.log" 2>&1; then
    error "LockScreenDepthAvoid: Failed to decode AOD APK"
    tail -n 30 "$tmp/unpack.log" >&2
    exit 1
fi

mods "LockScreenDepthAvoid: Applying patch..."
if ! python3 "$base/patch.py" --unpacked "$tmp/aod" >"$tmp/patch.log" 2>&1; then
    warn "LockScreenDepthAvoid: Patch not compatible; keeping original APK"
    cat "$tmp/patch.log" >&2
    exit 0
fi
cat "$tmp/patch.log"

mods "LockScreenDepthAvoid: Rebuilding $(basename "$target")..."
if ! java -jar "$editor" b -t raw -f -i "$tmp/aod" -o "$tmp/out.apk" \
    >"$tmp/build.log" 2>&1; then
    error "LockScreenDepthAvoid: Modified AOD could not be assembled"
    tail -n 30 "$tmp/build.log" >&2
    exit 1
fi

[[ -s "$tmp/out.apk" ]] || {
    error "LockScreenDepthAvoid: Output APK missing"
    exit 1
}

unzip -tqq "$tmp/out.apk" || {
    error "LockScreenDepthAvoid: Corrupted output APK"
    exit 1
}

install -m 0644 "$tmp/out.apk" "$target"
rm -rf "$(dirname "$target")/oat"

mods "LockScreenDepthAvoid: Successfully integrated into $(basename "$target")"
