#!/usr/bin/env bash
# ==============================================================================
# HyperLight SystemUI Patches for HyperMOS
# ==============================================================================
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"

base="$work_dir/bin/modfile/ModApp/HyperLight/SystemUI"
images="$work_dir/build/baserom/images"
rom_os="$(tr -d '\r\n' < "$work_dir/bin/ddevice/rom_os.txt" 2>/dev/null || true)"
android_ver="$(tr -d '\r\n' < "$work_dir/bin/ddevice/androidver.txt" 2>/dev/null || true)"

case "$rom_os/$android_ver" in
    OS3/16|OS4/17) ;;
    *)
        mods "HyperLight/SystemUI: skip unsupported ROM generation ($rom_os / A$android_ver)"
        exit 0
        ;;
esac

[[ -d "$images/system_ext" ]] || {
    mods "HyperLight/SystemUI: system_ext partition not found; skipping"
    exit 0
}

mapfile -d '' -t matches < <(
    find "$images" -type f -name 'MiuiSystemUI.apk' -print0
)
if (( ${#matches[@]} != 1 )); then
    mods "HyperLight/SystemUI: expected one MiuiSystemUI APK, found ${#matches[@]}; skipping"
    exit 0
fi
target="${matches[0]}"

editor="$work_dir/bin/apktool/apke.jar"
[[ -s "$editor" ]] || { error "HyperLight/SystemUI: APKEditor ($editor) missing"; exit 1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mods "HyperLight/SystemUI: Unpacking MiuiSystemUI.apk..."
if ! java -jar "$editor" d -t raw -f -no-dex-debug \
    -i "$target" -o "$tmp/systemui" >"$tmp/unpack.log" 2>&1; then
    error "HyperLight/SystemUI: Failed to decode MiuiSystemUI"
    tail -n 30 "$tmp/unpack.log" >&2
    exit 1
fi

mods "HyperLight/SystemUI: Applying patches..."
if ! python3 "$base/patch.py" --unpacked "$tmp/systemui" >"$tmp/patch.log" 2>&1; then
    warn "HyperLight/SystemUI: Patches not compatible; keeping original APK"
    cat "$tmp/patch.log" >&2
    exit 0
fi
cat "$tmp/patch.log"

mods "HyperLight/SystemUI: Rebuilding MiuiSystemUI.apk..."
if ! java -jar "$editor" b -t raw -f -i "$tmp/systemui" -o "$tmp/MiuiSystemUI.apk" \
    >"$tmp/build.log" 2>&1; then
    error "HyperLight/SystemUI: Modified MiuiSystemUI could not be assembled"
    tail -n 30 "$tmp/build.log" >&2
    exit 1
fi

[[ -s "$tmp/MiuiSystemUI.apk" ]] || {
    error "HyperLight/SystemUI: Output APK missing"
    exit 1
}

unzip -tqq "$tmp/MiuiSystemUI.apk" || {
    error "HyperLight/SystemUI: Corrupted output APK"
    exit 1
}

# Preserve raw identity & packaging metadata, replace target and clean oat cache
install -m 0644 "$tmp/MiuiSystemUI.apk" "$target"
rm -rf "$(dirname "$target")/oat"

mods "HyperLight/SystemUI: Successfully integrated patches into MiuiSystemUI"
