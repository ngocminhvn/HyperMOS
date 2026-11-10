#!/usr/bin/env bash
set -euo pipefail

# Kaorios Toolbox v2.0.6.2 for HyperMOS.
# script/ is byte-for-byte upstream and does the hook work and verification:
#   framework.jar : patch-framework-a17-artifact.sh (payload import + callers)
#   services.jar  : patch-services-a17-artifact.sh  (ComputerEngine + SystemServer)
# This file only wires them into the ROM and adds the HyperMOS-only extras
# (A17 Build spoof, static Secure Flag, native PIF libs, Toolbox APK).
# Kaorios CorePatch is intentionally not run; HyperMOS CorePatch runs before this.

work_dir=$(pwd)
source "$work_dir/functions.sh"

K="$work_dir/bin/package/KAORIOS_TOOLBOX"
S="$K/script"
MOD_TOOL="$K/mod/kaorios_mod.py"
BAKSMALI="$work_dir/bin/apktool/baksmaliv2.jar"
SMALI="$work_dir/bin/apktool/smaliv2.jar"
IMAGES="$work_dir/build/baserom/images"

# Pinned v2.0.6.2 release assets (SHA256SUMS of the release).
declare -A PIN=(
  [app/classes.dex]=b9f5ed61f71adfe90825ace660e44604753f7a99e2da4a98532d6f7b7955c530
  [app/KaoriosToolbox.apk]=b5ba9152cc5d3c1403166222309f56797f6bbd54379eb0f976bef5700db0e0f5
  [app/lib/arm64-v8a/libkaoripif.so]=01545baca35c0b2f95a78d7a27d4a1f632b97a66114e6ba1cc87474c687c0d84
  [app/lib/arm64-v8a/libkaoripif_diagnostic.so]=33437268198b6f8dda461fb975eeb266d4b23a505ad1585d9819b4d02305416b
  [app/lib/armeabi-v7a/libkaoripif.so]=153ebe54d3b0ec3e4835521c5c172ec0c4f7ea10c6cb36eecdda6065ea9b7edc
  [app/lib/armeabi-v7a/libkaoripif_diagnostic.so]=dd491cbabfec08853ed76213b260ba286b1aa7217b361cdb8381b18aade32088
)

die() { error "KAORIOS: $*"; exit 1; }

is_on() {
  case "${1,,}" in
    1|true|yes|on) return 0 ;;
    0|false|no|off) return 1 ;;
    *) die "invalid boolean: $1" ;;
  esac
}

# config.json -> KAORIOS_* switches; an already exported variable wins.
config_values=$(python3 "$MOD_TOOL" config "$K/config.json") || exit 1
while IFS='=' read -r name value; do
  [[ -n "$name" && ! -v "$name" ]] && printf -v "$name" '%s' "$value"
done <<< "$config_values"

is_on "$KAORIOS_MASTER" || { mods "Kaorios Toolbox disabled by config"; exit 0; }

ANDROID_VER=$(tr -d ' \r\n' < "$work_dir/bin/ddevice/androidver.txt")
SDK_LEVEL=$(tr -d ' \r\n' < "$work_dir/bin/ddevice/sdkLevel.txt")
SMALI_API="$SDK_LEVEL"
case "$SMALI_API" in 36|37) SMALI_API=34 ;; esac
case "$ANDROID_VER" in 15|16|17) ;; *) die "unsupported Android version: $ANDROID_VER" ;; esac
[[ "$SDK_LEVEL" =~ ^[0-9]+$ ]] || die "invalid SDK level: $SDK_LEVEL"

for cmd in java python3 unzip zip sha256sum find sort xargs; do
  command -v "$cmd" >/dev/null 2>&1 || die "missing host tool: $cmd"
done
for f in "$BAKSMALI" "$SMALI" "$S/patch-framework-a17-artifact.sh" "$S/patch-services-a17-artifact.sh" \
         "$S/kaorios_patcher.py" "$K/app/com.kousei.kaorios.xml"; do
  [[ -f "$f" ]] || die "missing file: $f"
done
for rel in "${!PIN[@]}"; do
  [[ "$(sha256sum "$K/$rel" | cut -d' ' -f1)" == "${PIN[$rel]}" ]] || die "pinned payload changed: $rel"
done
info "KAORIOS: verified pinned v2.0.6.2 payloads (Android $ANDROID_VER, smali API $SMALI_API)"

TEMP_ROOT="$work_dir/jar_temp/kaorios-v2062"
rm -rf "$TEMP_ROOT"; mkdir -p "$TEMP_ROOT"
trap 'rm -rf "$TEMP_ROOT"' EXIT

find_jar() {  # name [optional]
  local m=()
  while IFS= read -r -d '' p; do m+=("$p"); done < <(find "$IMAGES" -type f -name "$1" -print0)
  if (( ${#m[@]} > 1 )) || { (( ${#m[@]} == 0 )) && [[ -z "${2:-}" ]]; }; then
    die "expected ${2:+at most }one $1, found ${#m[@]}"
  fi
  (( ${#m[@]} )) && printf '%s\n' "${m[0]}" || true
}

dex_disassemble() {  # jar out_root
  local jar="$1" out="$2" dex
  rm -rf "$out"; mkdir -p "$out/dex"
  unzip -j -o -q "$jar" 'classes*.dex' -d "$out/dex"
  for dex in "$out"/dex/classes*.dex; do
    java -jar "$BAKSMALI" d --api "$SMALI_API" "$dex" -o "$out/smali/$(basename "$dex").out"
  done
}

tree_hash() { (cd "$1" && find . -type f -print0 | sort -z | xargs -0 sha256sum) | sha256sum | cut -d' ' -f1; }

# Extra pass: disassemble all DEX, run $2 on the smali root, rebuild only the
# changed DEX, repack, re-disassemble the candidate and run $3 on it.
smali_pass() {  # jar patch_fn verify_fn
  local jar="$1" patch_fn="$2" verify_fn="$3" root="$TEMP_ROOT/pass" dir name
  local -A before=()
  dex_disassemble "$jar" "$root"
  for dir in "$root"/smali/*.out; do before[$(basename "$dir")]=$(tree_hash "$dir"); done
  "$patch_fn" "$root/smali"
  mkdir -p "$root/built"
  for dir in "$root"/smali/*.out; do
    name=$(basename "$dir")
    [[ "$(tree_hash "$dir")" == "${before[$name]}" ]] && continue
    java -jar "$SMALI" a --api "$SMALI_API" "$dir" -o "$root/built/${name%.out}"
    [[ -s "$root/built/${name%.out}" ]] || die "smali produced no ${name%.out}"
  done
  cp -f "$jar" "$root/candidate.zip"
  if compgen -G "$root/built/classes*.dex" >/dev/null; then
    (cd "$root/built" && zip -q -0 "$root/candidate.zip" classes*.dex)
  fi
  unzip -tq "$root/candidate.zip" >/dev/null
  dex_disassemble "$root/candidate.zip" "$root/verify"
  "$verify_fn" "$root/verify/smali" || die "final verification failed: $verify_fn"
  cp -f "$root/candidate.zip" "$jar"
}

one_file() {  # root relative_path
  local m=()
  while IFS= read -r -d '' p; do m+=("$p"); done < <(find "$1" -type f -path "*/$2" -print0)
  (( ${#m[@]} == 1 )) || die "expected exactly one $2, found ${#m[@]}"
  printf '%s\n' "${m[0]}"
}

# Android 17 Build/Build$VERSION spoof (upstream mode 2). Re-running on the
# patched tree is the verifier: upstream reports "already patched" or fails.
build_spoof() {
  local rel
  for rel in android/os/Build.smali 'android/os/Build$VERSION.smali'; do
    python3 -I "$S/kaorios_patcher.py" "$(one_file "$1" "$rel")" --android-version 17 --mode 2 --no-delay \
      >"$TEMP_ROOT/build-spoof.log" 2>&1 || { tail -n 60 "$TEMP_ROOT/build-spoof.log" >&2; return 1; }
  done
}

secure_flag_patch()  { python3 "$MOD_TOOL" secure-flag "$1" --archive "$SECURE_ARCHIVE"; }
secure_flag_verify() { python3 "$MOD_TOOL" secure-flag "$1" --archive "$SECURE_ARCHIVE" --check-only >/dev/null; }

hooks_pass() {  # kind jar extra_args...
  local kind="$1" jar="$2"; shift 2
  local out="$TEMP_ROOT/$kind.jar"
  bash "$S/patch-$kind-a17-artifact.sh" --input "$jar" --output "$out" \
    --baksmali "$BAKSMALI" --smali "$SMALI" --api "$SDK_LEVEL" --smali-api "$SMALI_API" "$@" \
    >"$TEMP_ROOT/$kind.log" 2>&1 || { tail -n 80 "$TEMP_ROOT/$kind.log" >&2; die "$kind hook pipeline failed"; }
  cp -f "$out" "$jar"
  info "KAORIOS: $kind.jar hooks applied and artifact-verified"
}

mods "Kaorios Toolbox upstream 2.0.6.2 integration (Kaorios CorePatch not used)"

FRAMEWORK_JAR=$(find_jar framework.jar)
SERVICES_JAR=$(find_jar services.jar)

hooks_pass framework "$FRAMEWORK_JAR" --kaorios-dex "$K/app/classes.dex"
if [[ "$ANDROID_VER" == "17" ]] && is_on "$KAORIOS_ENABLE_BUILD_SPOOF"; then
  smali_pass "$FRAMEWORK_JAR" build_spoof build_spoof
  info "KAORIOS: Android 17 Build/Build\$VERSION spoof applied and verified"
fi

hooks_pass services "$SERVICES_JAR"
if is_on "$KAORIOS_ENABLE_SECURE_FLAG"; then
  SECURE_ARCHIVE=services
  smali_pass "$SERVICES_JAR" secure_flag_patch secure_flag_verify
  MIUI_SERVICES_JAR=$(find_jar miui-services.jar optional)
  if [[ -n "$MIUI_SERVICES_JAR" ]]; then
    SECURE_ARCHIVE=miui-services
    smali_pass "$MIUI_SERVICES_JAR" secure_flag_patch secure_flag_verify
  else
    info "KAORIOS: miui-services.jar not present; Xiaomi Secure Flag bypass skipped"
  fi
  info "KAORIOS: static Secure Flag bypasses applied and verified"
fi

# Upstream KaoriosPifInstaller loads /system_ext/lib[64]/libkaoripif.so and
# PifNative loads libkaoripif_diagnostic.so from the system library search path.
if is_on "$KAORIOS_ENABLE_NATIVE_PIF"; then
  for abi in arm64-v8a:lib64 armeabi-v7a:lib; do
    dst_dir="$IMAGES/system_ext/${abi##*:}"
    if [[ "${abi##*:}" == "lib64" ]]; then
      mkdir -p "$dst_dir"
    elif [[ ! -d "$dst_dir" ]]; then
      warn "KAORIOS: $dst_dir missing; 32-bit Native PIF skipped"
      continue
    fi
    for lib in libkaoripif.so libkaoripif_diagnostic.so; do
      src="$K/app/lib/${abi%%:*}/$lib"
      cp -f "$src" "$dst_dir/$lib"
      chmod 0644 "$dst_dir/$lib"
      patch_file_context system_ext "/system_ext/${abi##*:}/$lib" "u:object_r:system_lib_file:s0"
    done
  done
  info "KAORIOS: Native PIF libraries installed to system_ext"
fi

app_dir="$IMAGES/system_ext/priv-app/KaoriosToolbox"
perm_dir="$IMAGES/system_ext/etc/permissions"
[[ -d "$IMAGES/system_ext" ]] || die "system_ext partition directory missing"
mkdir -p "$app_dir" "$perm_dir"
cp -f "$K/app/KaoriosToolbox.apk" "$app_dir/KaoriosToolbox.apk"
cp -f "$K/app/com.kousei.kaorios.xml" "$perm_dir/com.kousei.kaorios.xml"
chmod 0644 "$app_dir/KaoriosToolbox.apk" "$perm_dir/com.kousei.kaorios.xml"
info "KAORIOS: Toolbox installed as system_ext priv-app"

mods "Kaorios Toolbox done"
