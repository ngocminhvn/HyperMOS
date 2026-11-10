#!/usr/bin/env bash
# SecurityCountdown: ZKOS-style stock SecurityCenter permission timer (10s -> 0s).
# Common installer for China OS3/A16 and OS4/A17; does not install Kashi's SecurityCenter.
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
base="$work_dir/bin/modfile/UpdateFile/SecurityCountdown"
images="$work_dir/build/baserom/images"
identity="$work_dir/bin/ddevice"
rom_os="$(tr -d '\r\n' < "$identity/rom_os.txt" 2>/dev/null || true)"
android_ver="$(tr -d '\r\n' < "$identity/androidver.txt" 2>/dev/null || true)"
rom_source="$(tr -d '\r\n' < "$identity/rom_source.txt" 2>/dev/null || true)"

case "$rom_os/$android_ver" in
    OS3/16|OS4/17) ;;
    *) mods "SecurityCountdown: skip $rom_os / Android $android_ver"; exit 0 ;;
esac
if [[ "$rom_source" == "xiaomi_eu" ]]; then
    mods "SecurityCountdown: preserve Xiaomi.eu SecurityCenter"
    exit 0
fi
[[ "$rom_source" == "china" ]] || {
    mods "SecurityCountdown: unsupported ROM source ($rom_source), skip"
    exit 0
}
[[ -d "$images" ]] || { error "SecurityCountdown: extracted ROM images missing"; exit 1; }

# Restrict discovery to typical stock SecurityCenter APK names, then check
# Android package identity. Never choose a partition based on a guessed path.
apk_package() {
    aapt dump badging "$1" 2>/dev/null |
        sed -n "s/^package: name='\([^']*\)'.*/\1/p" | head -n 1
}
mapfile -d '' -t candidates < <(
    find "$images" -type f \( -iname '*SecurityCenter*.apk' -o -iname '*Security*.apk' \) -print0 2>/dev/null
)
matches=()
for apk in "${candidates[@]}"; do
    [[ "$(apk_package "$apk" || true)" == "com.miui.securitycenter" ]] && matches+=("$apk")
done
if (( ${#matches[@]} != 1 )); then
    error "SecurityCountdown: expected one stock com.miui.securitycenter APK; found ${#matches[@]}"
    printf '  %s\n' "${matches[@]}" >&2
    exit 1
fi
target="${matches[0]}"
editor="$work_dir/bin/apktool/apke.jar"
signer="$work_dir/bin/apktool/apksigner.jar"
[[ -s "$editor" && -s "$signer" && -s "$base/patch.py" ]] || {
    error "SecurityCountdown: APKEditor, apksigner or patch.py missing"
    exit 1
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
if ! java -jar "$signer" verify --verbose --print-certs "$target" >"$tmp/certs.log" 2>&1; then
    error "SecurityCountdown: stock APK signature verification failed"
    tail -n 20 "$tmp/certs.log" >&2
    exit 1
fi
stock_cert="$(sed -n 's/^Signer #1 certificate SHA-256 digest: //p' "$tmp/certs.log" |
    head -n 1 | tr '[:upper:]' '[:lower:]' | tr -d ':')"
xiaomi_cert="c9009d01ebf9f5d0302bc71b2fe9aa9a47a432bba17308a3111b75d7b2149025"
if [[ "$stock_cert" != "$xiaomi_cert" ]]; then
    error "SecurityCountdown: stock APK has unexpected Xiaomi signing certificate"
    exit 1
fi

mods "SecurityCountdown: decoding stock $rom_os SecurityCenter for method verification"
if ! java -Xmx4g -jar "$editor" d -t raw -f -no-dex-debug \
    -i "$target" -o "$tmp/raw" >"$tmp/decode.log" 2>&1; then
    error "SecurityCountdown: APK decode failed"
    tail -n 25 "$tmp/decode.log" >&2
    exit 1
fi
[[ -d "$tmp/raw/signatures" ]] && \
    find "$tmp/raw/signatures" -type f -name '*.signature.info.bin' -print -quit |
        grep -q . || { error "SecurityCountdown: APKEditor lost stock signing block"; exit 1; }

# The patcher changes only the unique constant-returning protected method;
# on OS4 a different class layout must never destroy the stock APK.
if ! python3 "$base/patch.py" "$tmp/raw" >"$tmp/report.json" 2>"$tmp/patch.err"; then
    if [[ "$rom_os" == "OS4" ]]; then
        mods "SecurityCountdown OS4: unsupported method, original APK preserved"
        tail -n 5 "$tmp/patch.err" >&2
        exit 0
    fi
    error "SecurityCountdown OS3: expected countdown method absent or ambiguous"
    cat "$tmp/patch.err" >&2
    exit 1
fi

old="$(python3 - "$tmp/report.json" <<'PY'
import json,sys
report=json.load(open(sys.argv[1],encoding="utf-8"))
old=report["fragment_old_seconds"]
assert old in (0,10)
assert report["fragment_new_seconds"]==0
assert len(report["changed_files"])==(1 if old==10 else 0)
print(old)
PY
)" || { error "SecurityCountdown: invalid patch report"; exit 1; }
if [[ "$old" == "0" ]]; then
    mods "SecurityCountdown: countdown already disabled, keep original signed APK"
    exit 0
fi
if ! java -Xmx4g -jar "$editor" b -t raw -f -i "$tmp/raw" \
    -o "$tmp/SecurityCenter.apk" >"$tmp/build.log" 2>&1; then
    error "SecurityCountdown: APK rebuild failed"
    tail -n 30 "$tmp/build.log" >&2
    exit 1
fi
[[ -s "$tmp/SecurityCenter.apk" ]] && unzip -tqq "$tmp/SecurityCenter.apk" || {
    error "SecurityCountdown: APK output is missing or corrupt"
    exit 1
}
[[ "$(apk_package "$tmp/SecurityCenter.apk" || true)" == "com.miui.securitycenter" ]] || {
    error "SecurityCountdown: rebuilt Android package changed"
    exit 1
}
# Stock Xiaomi signing block is retained, but the changed DEX invalidates its
# digest. Kaorios CorePatch must remain enabled for installation at runtime.
install -m 0644 "$tmp/SecurityCenter.apk" "$target"
rm -rf "$(dirname "$target")/oat"
mods "SecurityCountdown: $rom_os / A$android_ver countdown changed 10s -> 0s"
mods "SecurityCountdown: ADB/install handler delays left untouched; Kaorios CorePatch required"
