#!/usr/bin/env bash
# ==============================================================================
# HyperLight AOD Patches for HyperMOS (MiuiAod.apk)
# ==============================================================================
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"

base="$work_dir/bin/modfile/ModApp/HyperLight/AOD"
images="$work_dir/build/baserom/images"
rom_os="$(tr -d '\r\n' < "$work_dir/bin/ddevice/rom_os.txt" 2>/dev/null || true)"
android_ver="$(tr -d '\r\n' < "$work_dir/bin/ddevice/androidver.txt" 2>/dev/null || true)"

case "$rom_os/$android_ver" in
    OS3/16|OS4/17) ;;
    *)
        mods "HyperLight/AOD: skip unsupported ROM generation ($rom_os / A$android_ver)"
        exit 0
        ;;
esac

mapfile -d '' -t matches < <(
    find "$images" -type f \( -name 'MiuiAod.apk' -o -name 'MIUIAod.apk' \) -print0
)
if (( ${#matches[@]} == 0 )); then
    mods "HyperLight/AOD: no MiuiAod APK found in baserom; skipping"
    exit 0
fi
target="${matches[0]}"

editor="$work_dir/bin/apktool/apke.jar"
[[ -s "$editor" ]] || { error "HyperLight/AOD: APKEditor ($editor) missing"; exit 1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mods "HyperLight/AOD: Unpacking $(basename "$target")..."
if ! java -jar "$editor" d -t raw -f -no-dex-debug \
    -i "$target" -o "$tmp/aod" >"$tmp/unpack.log" 2>&1; then
    error "HyperLight/AOD: Failed to decode AOD APK"
    tail -n 30 "$tmp/unpack.log" >&2
    exit 1
fi

mods "HyperLight/AOD: Applying patches..."
if ! python3 "$base/patch.py" --unpacked "$tmp/aod" >"$tmp/patch.log" 2>&1; then
    warn "HyperLight/AOD: Patches not compatible; keeping original APK"
    cat "$tmp/patch.log" >&2
    exit 0
fi
cat "$tmp/patch.log"

mods "HyperLight/AOD: Rebuilding $(basename "$target")..."
if ! java -jar "$editor" b -t raw -f -i "$tmp/aod" -o "$tmp/out.apk" \
    >"$tmp/build.log" 2>&1; then
    error "HyperLight/AOD: Modified AOD could not be assembled"
    tail -n 30 "$tmp/build.log" >&2
    exit 1
fi

[[ -s "$tmp/out.apk" ]] || {
    error "HyperLight/AOD: Output APK missing"
    exit 1
}

unzip -tqq "$tmp/out.apk" || {
    error "HyperLight/AOD: Corrupted output APK"
    exit 1
}

install -m 0644 "$tmp/out.apk" "$target"
rm -rf "$(dirname "$target")/oat"

mods "HyperLight/AOD: Successfully integrated patches into $(basename "$target")"
