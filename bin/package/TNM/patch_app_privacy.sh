#!/usr/bin/env bash
# Android 16 TNM App Privacy: mandatory and audited on China, optional on EU/other.
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
rom_source_file="$work_dir/bin/ddevice/rom_source.txt"
[[ -s "$rom_source_file" ]] || { error "TNM App Privacy: ROM source is missing"; exit 1; }
rom_source="$(tr -d '\r\n' < "$rom_source_file")"
strict=0
case "$rom_source" in
  china) strict=1 ;;
  xiaomi_eu|other) ;;
  *) error "TNM App Privacy: invalid ROM source '$rom_source'"; exit 1 ;;
esac

fail_or_skip() {
  local message="$1"
  if [[ "$strict" == "1" ]]; then
    error "TNM App Privacy [mandatory China]: $message"
    exit 1
  fi
  info "TNM App Privacy: $message; skipped"
  exit 0
}

if [[ "$android_version" != "16" ]]; then
  fail_or_skip "Android $android_version has no validated TNM APM layout (supported: Android 16)"
fi
for file in "$baksmali" "$smali" "$base/patch_app_privacy.py" "$base/TnmAppPrivacy.smali" "$base/verify_app_privacy.py"; do
  [[ -s "$file" ]] || { error "TNM App Privacy: missing $file"; exit 1; }
done
for executable in java python3 unzip zip cmp; do
  command -v "$executable" >/dev/null || { error "TNM App Privacy: missing $executable"; exit 1; }
done

framework="$images/system/system/framework/framework.jar"
if [[ ! -s "$framework" ]]; then
  fail_or_skip "canonical framework.jar is missing"
fi

# An audit re-disassembles the *staged artifact*, rather than trusting a patch
# log or the presence of a capability marker alone.
audit_staged() {
  [[ -s "$marker" ]] || { error "TNM App Privacy: capability marker missing"; return 1; }
  grep -Fxq 'schema=1' "$marker" || { error "TNM App Privacy: wrong marker schema"; return 1; }
  grep -Fxq 'apis=getInstalledPackages,getInstalledApplications,getPackageInfo,getApplicationInfo,getPackageUid,getPackageGids' "$marker" ||
    { error "TNM App Privacy: incomplete API marker"; return 1; }
  local audit dex classes apm_dex="" helper_dex="" count_apm=0 count_helper=0
  audit="$(mktemp -d)"
  mkdir -p "$audit/raw"
  if ! unzip -j -o "$framework" 'classes*.dex' -d "$audit/raw" >/dev/null; then
    rm -rf "$audit"
    error "TNM App Privacy: cannot extract DEX for audit"
    return 1
  fi
  shopt -s nullglob
  for dex in "$audit/raw"/classes*.dex; do
    if ! classes="$(java -jar "$baksmali" list classes "$dex")"; then
      shopt -u nullglob
      rm -rf "$audit"
      error "TNM App Privacy: DEX class index unreadable"
      return 1
    fi
    if grep -Fxq 'Landroid/app/ApplicationPackageManager;' <<< "$classes"; then
      apm_dex="$dex"
      count_apm=$((count_apm + 1))
    fi
    if grep -Fxq 'Landroid/app/TnmAppPrivacy;' <<< "$classes"; then
      helper_dex="$dex"
      count_helper=$((count_helper + 1))
    fi
  done
  shopt -u nullglob
  if [[ "$count_apm" != "1" || "$count_helper" != "1" ]]; then
    rm -rf "$audit"
    error "TNM App Privacy: expected one APM and one TNM helper DEX (found $count_apm/$count_helper)"
    return 1
  fi
  mkdir -p "$audit/apm" "$audit/helper"
  if ! java -jar "$baksmali" d -a 36 "$apm_dex" -o "$audit/apm" >/dev/null ||
     ! java -jar "$baksmali" d -a 36 "$helper_dex" -o "$audit/helper" >/dev/null ||
     ! python3 "$base/verify_app_privacy.py" \
        "$audit/apm/android/app/ApplicationPackageManager.smali" \
        "$audit/helper/android/app/TnmAppPrivacy.smali"; then
    rm -rf "$audit"
    error "TNM App Privacy: DEX API hook audit failed"
    return 1
  fi
  rm -rf "$audit"
  info "TNM App Privacy: six on-disk API hooks and helper verified"
}

if [[ "${1:-}" == "--check" ]]; then
  audit_staged
  exit 0
fi
if [[ "$#" != "0" ]]; then
  error "TNM App Privacy: unsupported arguments"
  exit 2
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/raw" "$tmp/apm" "$tmp/helper/android/app" "$tmp/built"
unzip -j -o "$framework" 'classes*.dex' -d "$tmp/raw" >/dev/null
shopt -s nullglob
dexes=("$tmp/raw"/classes*.dex)
shopt -u nullglob
[[ "${#dexes[@]}" -gt 0 ]] || fail_or_skip "framework has no DEX"

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
  fail_or_skip "expected one ApplicationPackageManager, found $found"
fi

apm="$apm_out/android/app/ApplicationPackageManager.smali"
if grep -q 'Landroid/app/TnmAppPrivacy;' "$apm"; then
  [[ -s "$marker" ]] || { error "TNM App Privacy: hook exists without capability marker"; exit 1; }
  if [[ "$strict" == "1" ]]; then
    audit_staged
  fi
  info "TNM App Privacy: existing verified hook retained"
  exit 0
fi
if grep -q 'ProjectRYUHook;->\(shouldHideAppList\|filterApplicationInfoList\|filterPackageInfoList\)' "$apm"; then
  fail_or_skip "conflicting RYU visibility hook found in APM"
fi

# The patcher validates every signature before writing its temporary smali tree.
if ! python3 "$base/patch_app_privacy.py" "$apm"; then
  fail_or_skip "unsupported ApplicationPackageManager method layout"
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
if [[ "$strict" == "1" ]]; then
  audit_staged
fi
mods "TNM App Privacy -> A16 APM policy (schema 1, six verified APIs)"

