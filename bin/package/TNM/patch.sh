#!/usr/bin/env bash
# TNM Hide App List — isolated Android 16 client-side PackageManager patch.
# Runs after Kaorios so pre-existing CorePatch/Kaorios changes are preserved.
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
base="$work_dir/bin/package/TNM"
images="$work_dir/build/baserom/images"
baksmali="$work_dir/bin/apktool/baksmaliv2.jar"
smali="$work_dir/bin/apktool/smaliv2.jar"
patcher="$base/patch_hide_app_list.py"
helper="$base/TnmHideAppList.smali"
android_version="$(tr -d '\r\n' < "$work_dir/bin/ddevice/androidver.txt")"

if [[ "$android_version" != "16" ]]; then
    info "TNM Hide App List: Android $android_version not covered by RYU A16 reference; skipping"
    exit 0
fi
for file in "$baksmali" "$smali" "$patcher" "$helper"; do
    [[ -s "$file" ]] || { error "TNM Hide App List: missing $file"; exit 1; }
done
for executable in java python3 unzip zip sha256sum; do
    command -v "$executable" >/dev/null || { error "TNM Hide App List: missing $executable"; exit 1; }
done
preferred="$images/system/system/framework/framework.jar"
if [[ -f "$preferred" ]]; then
    framework="$preferred"
else
    mapfile -d '' jars < <(find "$images" -type f -name framework.jar -print0)
    [[ "${#jars[@]}" -eq 1 ]] || { error "TNM Hide App List: expected one framework.jar"; exit 1; }
    framework="${jars[0]}"
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/raw" "$tmp/built" "$tmp/decompiled"
unzip -j -o "$framework" 'classes*.dex' -d "$tmp/raw" >/dev/null
shopt -s nullglob
dexes=("$tmp/raw"/classes*.dex)
shopt -u nullglob
[[ "${#dexes[@]}" -gt 0 ]] || { error "TNM Hide App List: framework has no DEX"; exit 1; }

found=0
for dex in "${dexes[@]}"; do
    name="$(basename "$dex")"
    out="$tmp/decompiled/$name"
    java -jar "$baksmali" d -a 36 "$dex" -o "$out" >/dev/null
    candidate="$out/android/app/ApplicationPackageManager.smali"
    if [[ ! -f "$candidate" ]]; then
        rm -rf "$out"
        continue
    fi
    found=$((found + 1))
    [[ "$found" -eq 1 ]] || { error "TNM Hide App List: duplicated ApplicationPackageManager"; exit 1; }
    python3 "$patcher" "$candidate"
    [[ ! -f "$out/android/app/TnmHideAppList.smali" ]] || {
        error "TNM Hide App List: helper class already present"; exit 1;
    }
    cp "$helper" "$out/android/app/TnmHideAppList.smali"
    java -jar "$smali" a -a 36 "$out" -o "$tmp/built/$name"
    [[ -s "$tmp/built/$name" ]] || { error "TNM Hide App List: smali rebuild empty"; exit 1; }
    rm -rf "$out"
done
[[ "$found" -eq 1 ]] || { error "TNM Hide App List: ApplicationPackageManager not found"; exit 1; }

cp -f "$framework" "$tmp/framework.candidate.jar"
(
    cd "$tmp/built"
    for dex in classes*.dex; do
        zip -q -0 "$tmp/framework.candidate.jar" "$dex"
    done
)
unzip -tq "$tmp/framework.candidate.jar" >/dev/null
for rebuilt in "$tmp"/built/classes*.dex; do
    name="$(basename "$rebuilt")"
    unzip -p "$tmp/framework.candidate.jar" "$name" > "$tmp/verify.dex"
    cmp -s "$rebuilt" "$tmp/verify.dex" || {
        error "TNM Hide App List: archive DEX replacement failed: $name"; exit 1;
    }
done

# Preserve the preexisting, fully patched ROM jar until all candidate checks pass.
cp -f "$tmp/framework.candidate.jar" "$framework"
mods "TNM Hide App List -> 6 verified Android 16 PackageManager call-sites in framework.jar"
