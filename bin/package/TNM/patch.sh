#!/usr/bin/env bash
# Always-on Android 16 TNM App Privacy patch. Gate unsupported layouts before editing framework.jar.
set -euo pipefail

work_dir="$(pwd)"
source "$work_dir/functions.sh"
base="$work_dir/bin/package/TNM"
images="$work_dir/build/baserom/images"
baksmali="$work_dir/bin/apktool/baksmaliv2.jar"
smali="$work_dir/bin/apktool/smaliv2.jar"
android_version="$(tr -d '\r\n' < "$work_dir/bin/ddevice/androidver.txt")"
marker_relative="system/system/etc/tnm/app-privacy-v1"
marker="$images/$marker_relative"

if [[ "$android_version" != "16" ]]; then
  info "TNM App Privacy: Android $android_version is outside the verified A16 scope; skipped"
  exit 0
fi
for file in "$baksmali" "$smali" "$base/patch_app_privacy.py" "$base/TnmAppPrivacy.smali"; do
  [[ -s "$file" ]] || { error "TNM App Privacy: missing $file"; exit 1; }
done
for executable in java python3 unzip zip cmp; do
  command -v "$executable" >/dev/null || { error "TNM App Privacy: missing $executable"; exit 1; }
done

framework="$images/system/system/framework/framework.jar"
if [[ ! -s "$framework" ]]; then
  info "TNM App Privacy: canonical framework.jar is absent; skipped without image changes"
  exit 0
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/raw" "$tmp/apm" "$tmp/helper/android/app" "$tmp/built"
unzip -j -o "$framework" 'classes*.dex' -d "$tmp/raw" >/dev/null
shopt -s nullglob
dexes=("$tmp/raw"/classes*.dex)
shopt -u nullglob
[[ "${#dexes[@]}" -gt 0 ]] || { info "TNM App Privacy: framework has no DEX; skipped"; exit 0; }

found=0
apm_dex=""
for dex in "${dexes[@]}"; do
  out="$tmp/apm/$(basename "$dex")"
  java -jar "$baksmali" d -a 36 "$dex" -o "$out" >/dev/null
  if [[ -f "$out/android/app/ApplicationPackageManager.smali" ]]; then
    found=$((found + 1))
    apm_dex="$dex"
    apm_out="$out"
  else
    rm -rf "$out"
  fi
done
if [[ "$found" -ne 1 ]]; then
  info "TNM App Privacy: expected one ApplicationPackageManager, found $found; skipped"
  exit 0
fi

apm="$apm_out/android/app/ApplicationPackageManager.smali"
if grep -q 'Landroid/app/TnmAppPrivacy;' "$apm"; then
  [[ -s "$marker" ]] || { error "TNM App Privacy: hook exists without capability marker"; exit 1; }
  info "TNM App Privacy: existing verified hook retained"
  exit 0
fi
if grep -q 'ProjectRYUHook;->\(shouldHideAppList\|filterApplicationInfoList\|filterPackageInfoList\)' "$apm"; then
  info "TNM App Privacy: RYU visibility hook already owns the six APM sites; skipped"
  exit 0
fi

# The patcher validates every signature before writing its temporary smali tree.
if ! python3 "$base/patch_app_privacy.py" "$apm"; then
  info "TNM App Privacy: unsupported China/EU framework layout; skipped without image changes"
  exit 0
fi
name="$(basename "$apm_dex")"
java -jar "$smali" a -a 36 "$apm_out" -o "$tmp/built/$name"
cp "$base/TnmAppPrivacy.smali" "$tmp/helper/android/app/TnmAppPrivacy.smali"

index=1
while true; do
  if [[ "$index" -eq 1 ]]; then candidate_name="classes.dex"; else candidate_name="classes${index}.dex"; fi
  unzip -Z1 "$framework" | grep -Fxq "$candidate_name" || break
  index=$((index + 1))
done
if [[ "$index" -eq 1 ]]; then helper_name="classes.dex"; else helper_name="classes${index}.dex"; fi
java -jar "$smali" a -a 36 "$tmp/helper" -o "$tmp/built/$helper_name"

cp "$framework" "$tmp/framework.candidate.jar"
(
  cd "$tmp/built"
  zip -q -0 "$tmp/framework.candidate.jar" "$name" "$helper_name"
)
unzip -tq "$tmp/framework.candidate.jar" >/dev/null
verify="$tmp/verify"
mkdir -p "$verify"
unzip -p "$tmp/framework.candidate.jar" "$name" > "$verify/$name"
unzip -p "$tmp/framework.candidate.jar" "$helper_name" > "$verify/$helper_name"
cmp -s "$tmp/built/$name" "$verify/$name" || { error "TNM App Privacy: APM DEX verification failed"; exit 1; }
cmp -s "$tmp/built/$helper_name" "$verify/$helper_name" || { error "TNM App Privacy: helper DEX verification failed"; exit 1; }
java -jar "$baksmali" list classes "$verify/$helper_name" | grep -qx 'Landroid/app/TnmAppPrivacy;' || {
  error "TNM App Privacy: helper class missing after assembly"; exit 1;
}

# Commit only after all candidate checks pass. The marker is the backend capability gate.
cp "$tmp/framework.candidate.jar" "$framework"
mkdir -p "$(dirname "$marker")"
printf '%s\n' 'schema=1' 'apis=getInstalledPackages,getInstalledApplications,getPackageInfo,getApplicationInfo,getPackageUid,getPackageGids' > "$marker"
chmod 0644 "$marker"
mods "TNM App Privacy -> A16 APM policy (schema 1, six verified APIs)"

