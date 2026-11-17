#!/usr/bin/env bash
# ==============================================================================
# HyperLight Launcher Patches for HyperMOS (MiuiHome.apk)
# ==============================================================================
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"

base="$work_dir/bin/modfile/ModApp/HyperLight/Launcher"
images="$work_dir/build/baserom/images"
rom_os="$(tr -d '\r\n' < "$work_dir/bin/ddevice/rom_os.txt" 2>/dev/null || true)"
android_ver="$(tr -d '\r\n' < "$work_dir/bin/ddevice/androidver.txt" 2>/dev/null || true)"

case "$rom_os/$android_ver" in
    OS3/16|OS4/17) ;;
    *)
        mods "HyperLight/Launcher: skip unsupported ROM generation ($rom_os / A$android_ver)"
        exit 0
        ;;
esac

# 1. Điều kiện bắt buộc: Chỉ chạy khi Kashi Launcher TẮT để tránh xung đột
kashi_cfg="$work_dir/bin/modfile/ModApp/Kashi/config_reader.py"
if [[ -f "$kashi_cfg" ]]; then
    kashi_launcher_enabled="$(python3 "$kashi_cfg" is_enabled launcher "$rom_os" 2>/dev/null || echo 0)"
    if [[ "$kashi_launcher_enabled" == "1" ]]; then
        mods "HyperLight/Launcher: Kashi launcher mod is active ($rom_os); skipping HyperLight Launcher mod"
        exit 0
    fi
fi

# 2. Tìm file MiuiHome.apk trong baserom
mapfile -d '' -t matches < <(
    find "$images" -type f \( -name 'MiuiHome.apk' -o -name 'MiuiHomeT.apk' \) -print0
)
if (( ${#matches[@]} == 0 )); then
    mods "HyperLight/Launcher: no MiuiHome APK found in baserom; skipping"
    exit 0
fi
target="${matches[0]}"

# Flutter/native launchers may have no DEX; Smali hooks cannot work there.
if ! unzip -Z1 "$target" | grep -Eq '^classes([0-9]+)?\\.dex"$work_dir/bin/apktool/apke.jar"
[[ -s "$editor" ]] || { error "HyperLight/Launcher: APKEditor ($editor) missing"; exit 1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mods "HyperLight/Launcher: Unpacking $(basename "$target")..."
if ! java -jar "$editor" d -t raw -f -no-dex-debug \
    -i "$target" -o "$tmp/home" >"$tmp/unpack.log" 2>&1; then
    error "HyperLight/Launcher: Failed to decode MiuiHome APK"
    tail -n 30 "$tmp/unpack.log" >&2
    exit 1
fi

mods "HyperLight/Launcher: Applying patches..."
patch_args=(--unpacked "$tmp/home")
if [[ "$rom_os" == "OS4" ]]; then
    patch_args+=(--skip-device-level)
fi
if ! python3 "$base/patch.py" "${patch_args[@]}" >"$tmp/patch.log" 2>&1; then
    warn "HyperLight/Launcher: Patches not compatible; keeping original APK"
    cat "$tmp/patch.log" >&2
    exit 0
fi
cat "$tmp/patch.log"

mods "HyperLight/Launcher: Rebuilding $(basename "$target")..."
if ! java -jar "$editor" b -t raw -f -i "$tmp/home" -o "$tmp/out.apk" \
    >"$tmp/build.log" 2>&1; then
    error "HyperLight/Launcher: Modified MiuiHome could not be assembled"
    tail -n 30 "$tmp/build.log" >&2
    exit 1
fi

[[ -s "$tmp/out.apk" ]] || {
    error "HyperLight/Launcher: Output APK missing"
    exit 1
}

unzip -tqq "$tmp/out.apk" || {
    error "HyperLight/Launcher: Corrupted output APK"
    exit 1
}

install -m 0644 "$tmp/out.apk" "$target"
rm -rf "$(dirname "$target")/oat"

mods "HyperLight/Launcher: Successfully integrated patches into $(basename "$target")"
; then
    mods "HyperLight/Launcher: no classes.dex in $(basename "$target"); skipping Smali-based Anim-Curve/Big Folder safely"
    exit 0
fi

editor="$work_dir/bin/apktool/apke.jar"
[[ -s "$editor" ]] || { error "HyperLight/Launcher: APKEditor ($editor) missing"; exit 1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mods "HyperLight/Launcher: Unpacking $(basename "$target")..."
if ! java -jar "$editor" d -t raw -f -no-dex-debug \
    -i "$target" -o "$tmp/home" >"$tmp/unpack.log" 2>&1; then
    error "HyperLight/Launcher: Failed to decode MiuiHome APK"
    tail -n 30 "$tmp/unpack.log" >&2
    exit 1
fi

mods "HyperLight/Launcher: Applying patches..."
if ! python3 "$base/patch.py" --unpacked "$tmp/home" >"$tmp/patch.log" 2>&1; then
    warn "HyperLight/Launcher: Patches not compatible; keeping original APK"
    cat "$tmp/patch.log" >&2
    exit 0
fi
cat "$tmp/patch.log"

mods "HyperLight/Launcher: Rebuilding $(basename "$target")..."
if ! java -jar "$editor" b -t raw -f -i "$tmp/home" -o "$tmp/out.apk" \
    >"$tmp/build.log" 2>&1; then
    error "HyperLight/Launcher: Modified MiuiHome could not be assembled"
    tail -n 30 "$tmp/build.log" >&2
    exit 1
fi

[[ -s "$tmp/out.apk" ]] || {
    error "HyperLight/Launcher: Output APK missing"
    exit 1
}

unzip -tqq "$tmp/out.apk" || {
    error "HyperLight/Launcher: Corrupted output APK"
    exit 1
}

install -m 0644 "$tmp/out.apk" "$target"
rm -rf "$(dirname "$target")/oat"

mods "HyperLight/Launcher: Successfully integrated patches into $(basename "$target")"
