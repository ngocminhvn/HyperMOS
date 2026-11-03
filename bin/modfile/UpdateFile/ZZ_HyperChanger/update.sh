#!/usr/bin/env bash
# HyperChanger: optional, fail-closed lock-screen charge information integration.
set -euo pipefail

work_dir=$(pwd)
source "$work_dir/functions.sh"

base="$work_dir/bin/modfile/UpdateFile/ZZ_HyperChanger"
images="$work_dir/build/baserom/images"
rom_os="$(tr -d '\r\n' < "$work_dir/bin/ddevice/rom_os.txt")"
android_ver="$(tr -d '\r\n' < "$work_dir/bin/ddevice/androidver.txt")"

# Only Android 16 / HyperOS 3 is considered by this patch.
if [[ "$rom_os" != "OS3" || "$android_ver" != "16" ]]; then
    mods "HyperChanger: skip unsupported ROM generation ($rom_os / A$android_ver)"
    exit 0
fi
[[ -d "$images/system_ext" ]] || {
    mods "HyperChanger: no system_ext; feature unavailable"
    exit 0
}

mapfile -d '' -t matches < <(
    find "$images" -type f -name 'MiuiSystemUI.apk' -print0
)
if (( ${#matches[@]} != 1 )); then
    mods "HyperChanger: expected one SystemUI APK, found ${#matches[@]}; skip"
    exit 0
fi
target="${matches[0]}"
marker="$images/system_ext/etc/tnm/hyperchanger-v1"

# Never advertise an unsupported or unverified patch to the TNM app.
rm -f "$marker"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
editor="$work_dir/bin/apktool/apke.jar"
[[ -s "$editor" ]] || { error "HyperChanger: APKEditor missing"; exit 1; }

mods "HyperChanger: inspect SystemUI method signatures"
if ! java -jar "$editor" d -t raw -f -no-dex-debug \
    -i "$target" -o "$tmp/systemui" >"$tmp/unpack.log" 2>&1; then
    error "HyperChanger: could not decode SystemUI"
    tail -n 30 "$tmp/unpack.log" >&2
    exit 1
fi

if ! python3 "$base/patch.py" --unpacked "$tmp/systemui" --sources "$base" \
    >"$tmp/patch.log" 2>&1; then
    # A different Xiaomi build keeps its original, working SystemUI.
    mods "HyperChanger: unsupported SystemUI signatures; leave original APK intact"
    tail -n 5 "$tmp/patch.log" >&2
    exit 0
fi

if ! java -jar "$editor" b -t raw -f -i "$tmp/systemui" -o "$tmp/MiuiSystemUI.apk" \
    >"$tmp/build.log" 2>&1; then
    error "HyperChanger: modified SystemUI could not be assembled"
    tail -n 30 "$tmp/build.log" >&2
    exit 1
fi

[[ -s "$tmp/MiuiSystemUI.apk" ]] || {
    error "HyperChanger: output APK missing"
    exit 1
}
python3 "$base/restore_metadata.py" \
    --base "$target" --rebuilt "$tmp/MiuiSystemUI.apk" \
    --output "$tmp/MiuiSystemUI.preserved.apk" || {
    error "HyperChanger: could not restore source APK metadata"
    exit 1
}
unzip -tqq "$tmp/MiuiSystemUI.preserved.apk" || {
    error "HyperChanger: corrupt output APK"
    exit 1
}
aapt dump badging "$tmp/MiuiSystemUI.preserved.apk" | grep -q "package: name='com.android.systemui'" || {
    error "HyperChanger: wrong output package"
    exit 1
}
python3 "$base/verify_metadata.py" \
    --base "$target" --patched "$tmp/MiuiSystemUI.preserved.apk" \
    --report "$work_dir/build/reports/hyperchanger/apk-metadata.json" || {
    error "HyperChanger: APK identity/metadata preservation check failed"
    exit 1
}

# Only publish marker after all checks and replacement have succeeded.
install -m 0644 "$tmp/MiuiSystemUI.preserved.apk" "$target"
rm -rf "$(dirname "$target")/oat"
install -d -m 0755 "$(dirname "$marker")"
printf 'schema=1\nbackend=systemui\n' > "$marker"
chmod 0644 "$marker"
mods "HyperChanger: installed (disabled by default; TNM owns configuration)"


