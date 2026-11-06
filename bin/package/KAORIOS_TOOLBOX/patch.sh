#!/usr/bin/env bash
set -euo pipefail

# Upstream code stays in script/; all HyperMOS helpers use mod/kaorios_mod.py.
# This stage installs and verifies the Kaorios hooks, including its bundled
# CorePatch implementation. No external COREPATCH package is used.

work_dir=$(pwd)
source "$work_dir/functions.sh"

KAORIOS_DIR="$work_dir/bin/package/KAORIOS_TOOLBOX"
SCRIPT_DIR="$KAORIOS_DIR/script"
MOD_DIR="$KAORIOS_DIR/mod"
MOD_TOOL="$MOD_DIR/kaorios_mod.py"
DEX_REBALANCE="$MOD_DIR/dex_rebalance.py"
PATCHER="$SCRIPT_DIR/kaorios_patcher.py"
BAKSMALI="$work_dir/bin/apktool/baksmaliv2.jar"
SMALI="$work_dir/bin/apktool/smaliv2.jar"
DRIVER_DEX="$KAORIOS_DIR/app/classes.dex"
TOOLBOX_APK="$KAORIOS_DIR/app/KaoriosToolbox.apk"
PERMISSION_XML="$KAORIOS_DIR/app/com.kousei.kaorios.xml"
VALIDATE_KEYBOX="$SCRIPT_DIR/validate_keybox.py"
CONFIG="$KAORIOS_DIR/config.json"

if [[ ! -f "$CONFIG" || ! -f "$MOD_TOOL" ]]; then
  error "KAORIOS: missing config.json or its loader"
  exit 1
fi
if ! config_values=$(python3 "$MOD_TOOL" config "$CONFIG"); then
  exit 1
fi
while IFS='=' read -r config_name config_value; do
  [[ -n "$config_name" ]] || continue
  if [[ ! -v "$config_name" ]]; then
    printf -v "$config_name" '%s' "$config_value"
  fi
done <<< "$config_values"
unset config_values config_name config_value

# Map HEAD config.json keys onto #190 variable names. Keys absent from
# config.json default to true, matching #190 (all features true).
KAORIOS_MASTER="${KAORIOS_MASTER:-true}"
KAORIOS_ENABLE_ACTIVITY_THREAD="${KAORIOS_ENABLE_ACTIVITY_THREAD:-true}"
KAORIOS_ENABLE_INSTRUMENTATION="${KAORIOS_ENABLE_INSTRUMENTATION:-true}"
KAORIOS_ENABLE_SYSTEM_SERVER="${KAORIOS_ENABLE_SYSTEM_SERVER:-true}"
KAORIOS_ENABLE_SYSTEM_FEATURE_SPOOF="${KAORIOS_ENABLE_SYSTEM_FEATURE_SPOOF:-true}"
KAORIOS_VALIDATE_KEYBOX="${KAORIOS_VALIDATE_KEYBOX:-true}"
KAORIOS_INSTALL_TOOLBOX="${KAORIOS_INSTALL_TOOLBOX:-true}"
KAORIOS_DEVSTATUS_STRICT="${KAORIOS_DEVSTATUS_STRICT:-false}"
KAORIOS_ENABLE_NATIVE_PIF="${KAORIOS_ENABLE_NATIVE_PIF:-true}"

# Translate config.json names to #190 names when the loader set them.
[[ -n "${enabled:-}" ]] && KAORIOS_MASTER="$enabled"
[[ -n "${keybox:-}" ]] && KAORIOS_ENABLE_KEYBOX="$keybox"
[[ -n "${hidden_app:-}" ]] && KAORIOS_ENABLE_HIDDEN_APP="$hidden_app"
[[ -n "${installer_source:-}" ]] && KAORIOS_ENABLE_INSTALLER_SOURCE="$installer_source"
[[ -n "${devstatus:-}" ]] && KAORIOS_ENABLE_DEVSTATUS="$devstatus"
[[ -n "${build_spoof:-}" ]] && KAORIOS_ENABLE_BUILD_SPOOF="$build_spoof"
[[ -n "${secure_flag:-}" ]] && KAORIOS_ENABLE_SECURE_FLAG="$secure_flag"
[[ -n "${native_pif:-}" ]] && KAORIOS_ENABLE_NATIVE_PIF="$native_pif"

is_enabled() {
  case "${1,,}" in
    1|true|yes|on) return 0 ;;
    0|false|no|off) return 1 ;;
    *) return 2 ;;
  esac
}

validate_bool() {
  local name="$1" value="${!1}"
  case "${value,,}" in
    1|true|yes|on|0|false|no|off) ;;
    *)
      error "KAORIOS: invalid boolean $name=$value"
      exit 1
      ;;
  esac
}

for flag in \
  KAORIOS_MASTER \
  KAORIOS_ENABLE_ACTIVITY_THREAD \
  KAORIOS_ENABLE_INSTRUMENTATION \
  KAORIOS_ENABLE_KEYBOX \
  KAORIOS_ENABLE_SYSTEM_FEATURE_SPOOF \
  KAORIOS_ENABLE_SYSTEM_SERVER \
  KAORIOS_ENABLE_HIDDEN_APP \
  KAORIOS_ENABLE_INSTALLER_SOURCE \
  KAORIOS_ENABLE_DEVSTATUS \
  KAORIOS_ENABLE_BUILD_SPOOF \
  KAORIOS_ENABLE_SECURE_FLAG \
  KAORIOS_INSTALL_TOOLBOX \
  KAORIOS_VALIDATE_KEYBOX \
  KAORIOS_DEVSTATUS_STRICT \
  KAORIOS_ENABLE_NATIVE_PIF \
  KAORIOS_VERBOSE_LOG; do
  validate_bool "$flag"
done

if ! is_enabled "$KAORIOS_MASTER"; then
  mods "Kaorios Toolbox disabled by config"
  exit 0
fi
if is_enabled "$KAORIOS_ENABLE_NATIVE_PIF" && ! is_enabled "$KAORIOS_ENABLE_INSTRUMENTATION"; then
  error "KAORIOS: Native PIF requires the Instrumentation context hook"
  exit 1
fi

framework_callsite_features_enabled() {
  is_enabled "$KAORIOS_ENABLE_ACTIVITY_THREAD" ||
  is_enabled "$KAORIOS_ENABLE_INSTRUMENTATION" ||
  is_enabled "$KAORIOS_ENABLE_KEYBOX" ||
  is_enabled "$KAORIOS_ENABLE_SYSTEM_FEATURE_SPOOF"
}

services_features_enabled() {
  is_enabled "$KAORIOS_ENABLE_SYSTEM_SERVER" ||
  is_enabled "$KAORIOS_ENABLE_HIDDEN_APP" ||
  is_enabled "$KAORIOS_ENABLE_INSTALLER_SOURCE" ||
  is_enabled "$KAORIOS_ENABLE_SECURE_FLAG"
}

system_server_hook_needed() {
  is_enabled "$KAORIOS_ENABLE_SYSTEM_SERVER"
}

services_driver_needed() {
  is_enabled "$KAORIOS_ENABLE_SYSTEM_SERVER" ||
  is_enabled "$KAORIOS_ENABLE_HIDDEN_APP" ||
  is_enabled "$KAORIOS_ENABLE_INSTALLER_SOURCE"
}

framework_driver_needed() {
  framework_callsite_features_enabled ||
  services_driver_needed ||
  is_enabled "$KAORIOS_ENABLE_DEVSTATUS" ||
  is_enabled "$KAORIOS_ENABLE_NATIVE_PIF"
}

build_spoof_enabled_for_target() {
  [[ "$ANDROID_VER" == "17" ]] && is_enabled "$KAORIOS_ENABLE_BUILD_SPOOF"
}

framework_archive_needed() {
  framework_driver_needed || build_spoof_enabled_for_target
}

archive_patch_needed() {
  framework_archive_needed ||
  services_features_enabled
}

# Pin both reviewed v2.0.6.1 release payloads. Updating either asset requires an
# explicit integration update instead of silently changing a ROM build.
DRIVER_GIT_BLOB="acb9cc9be8a2d73ed9380f30e029b0ae1657c4b3"
TOOLBOX_GIT_BLOB="182c355137aa6cb8f0bb2942ad3e95ec88514960"

# Set to 1 once the dev-status hook is confirmed present in the framework smali,
# so final artifact verification knows whether that target must be checked.
NVC_APPLIED=0

ANDROID_VER=$(tr -d ' \r\n' < "$work_dir/bin/ddevice/androidver.txt")
SDK_LEVEL=$(tr -d ' \r\n' < "$work_dir/bin/ddevice/sdkLevel.txt")

case "$ANDROID_VER" in
  15|16|17) ;;
  *)
    error "KAORIOS: unsupported Android version: $ANDROID_VER"
    exit 1
    ;;
esac

if [[ ! "$SDK_LEVEL" =~ ^[0-9]+$ ]]; then
  error "KAORIOS: invalid SDK level: $SDK_LEVEL"
  exit 1
fi

require_file() {
  local path="$1" label="$2"
  if [[ ! -f "$path" ]]; then
    error "KAORIOS: missing $label: $path"
    exit 1
  fi
}

if archive_patch_needed; then
  require_file "$PATCHER" "patcher"
  require_file "$BAKSMALI" "baksmali"
  require_file "$SMALI" "smali"
  require_file "$DEX_REBALANCE" "DEX reference validation / rebalance helper"
fi
if is_enabled "$KAORIOS_ENABLE_HIDDEN_APP" || is_enabled "$KAORIOS_ENABLE_INSTALLER_SOURCE"; then
  require_file "$MOD_TOOL" "Kaorios MOD helper"
fi
if framework_driver_needed; then
  require_file "$DRIVER_DEX" "framework driver DEX"
fi
if is_enabled "$KAORIOS_INSTALL_TOOLBOX"; then
  require_file "$TOOLBOX_APK" "Toolbox APK"
  require_file "$PERMISSION_XML" "Toolbox privapp permission XML"
fi
if is_enabled "$KAORIOS_VALIDATE_KEYBOX"; then
  require_file "$VALIDATE_KEYBOX" "keybox validator"
fi
if is_enabled "$KAORIOS_ENABLE_DEVSTATUS"; then
  require_file "$MOD_TOOL" "Kaorios MOD helper"
fi
if is_enabled "$KAORIOS_ENABLE_SECURE_FLAG"; then
  require_file "$MOD_TOOL" "Kaorios MOD helper"
fi
if build_spoof_enabled_for_target; then
  require_file "$MOD_TOOL" "Kaorios MOD helper"
fi

if archive_patch_needed; then
  for cmd in java python3 unzip zip git sha256sum find sort xargs; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      error "KAORIOS: missing host tool: $cmd"
      exit 1
    fi
  done
elif is_enabled "$KAORIOS_VALIDATE_KEYBOX"; then
  command -v python3 >/dev/null 2>&1 || {
    error "KAORIOS: missing host tool: python3"
    exit 1
  }
fi

verify_git_blob() {
  local file="$1" expected="$2" label="$3" actual
  actual=$(git hash-object "$file")
  if [[ "$actual" != "$expected" ]]; then
    error "KAORIOS: $label payload hash changed: $actual (expected $expected)"
    exit 1
  fi
  info "KAORIOS: verified pinned $label payload"
}

if is_enabled "$KAORIOS_INSTALL_TOOLBOX"; then
  verify_git_blob "$TOOLBOX_APK" "$TOOLBOX_GIT_BLOB" "Toolbox APK"
fi
if framework_driver_needed; then
  verify_git_blob "$DRIVER_DEX" "$DRIVER_GIT_BLOB" "framework driver DEX"
fi

TEMP_ROOT="$work_dir/jar_temp/kaorios-v2060"
rm -rf "$TEMP_ROOT"
mkdir -p "$TEMP_ROOT"
cleanup() {
  rm -rf "$TEMP_ROOT"
}
trap cleanup EXIT

run_baksmali() {
  local dex="$1" out="$2"
  rm -rf "$out"
  mkdir -p "$out"
  java -jar "$BAKSMALI" d --api "$SDK_LEVEL" "$dex" -o "$out"
}

run_smali() {
  local src="$1" out="$2"
  rm -f "$out"
  java -jar "$SMALI" a --api "$SDK_LEVEL" "$src" -o "$out" || return 1
  [[ -s "$out" ]] || {
    echo "[DEX ERROR] smali produced an empty output: $out" >&2
    return 1
  }
  # A zero exit code is insufficient when method_ids exceeds the 16-bit DEX
  # limit. Reject the generated file *before* replacing the original JAR DEX.
  python3 "$DEX_REBALANCE" check-file "$out"
}

tree_hash() {
  local root="$1"
  (
    cd "$root"
    find . -type f -print0 | sort -z | xargs -0 sha256sum
  ) | sha256sum | awk '{print $1}'
}

extract_all_dex() {
  local archive="$1" raw="$2"
  rm -rf "$raw"
  mkdir -p "$raw"
  unzip -j -o "$archive" 'classes*.dex' -d "$raw" >/dev/null
  compgen -G "$raw/classes*.dex" >/dev/null || {
    error "KAORIOS: no classes*.dex in $archive"
    return 1
  }
}

disassemble_all() {
  local raw="$1" smali_root="$2" dex
  rm -rf "$smali_root"
  mkdir -p "$smali_root"
  shopt -s nullglob
  for dex in "$raw"/classes*.dex; do
    run_baksmali "$dex" "$smali_root/$(basename "$dex").out"
  done
  shopt -u nullglob
}

snapshot_hashes() {
  local root="$1" file="$2" dir
  : > "$file"
  shopt -s nullglob
  for dir in "$root"/classes*.dex.out; do
    printf '%s|%s\n' "$(basename "$dir")" "$(tree_hash "$dir")" >> "$file"
  done
  shopt -u nullglob
}

old_hash() {
  local snapshot="$1" name="$2"
  awk -F'|' -v n="$name" '$1==n {print $2; exit}' "$snapshot"
}

require_one_target() {
  local root="$1" rel="$2" label="$3"
  local matches=()
  while IFS= read -r -d '' p; do matches+=("$p"); done < <(find "$root" -type f -path "*/$rel" -print0)
  if (( ${#matches[@]} != 1 )); then
    error "KAORIOS: expected exactly one $label ($rel), found ${#matches[@]}"
    return 1
  fi
}

require_framework_targets() {
  local root="$1"
  if is_enabled "$KAORIOS_ENABLE_ACTIVITY_THREAD"; then
    require_one_target "$root" "android/app/ActivityThread.smali" "ActivityThread"
  fi
  if is_enabled "$KAORIOS_ENABLE_INSTRUMENTATION"; then
    require_one_target "$root" "android/app/Instrumentation.smali" "Instrumentation"
  fi
  if is_enabled "$KAORIOS_ENABLE_SYSTEM_FEATURE_SPOOF"; then
    require_one_target "$root" "android/app/ApplicationPackageManager.smali" "ApplicationPackageManager"
  fi
  if is_enabled "$KAORIOS_ENABLE_KEYBOX"; then
    require_one_target "$root" "android/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi.smali" "AndroidKeyStoreKeyPairGeneratorSpi"
    require_one_target "$root" "android/security/keystore2/AndroidKeyStoreSpi.smali" "AndroidKeyStoreSpi"
  fi
  if build_spoof_enabled_for_target; then
    require_one_target "$root" "android/os/Build.smali" "Build"
    require_one_target "$root" 'android/os/Build$VERSION.smali' 'Build$VERSION'
  fi
}

require_services_targets() {
  local root="$1"
  if is_enabled "$KAORIOS_ENABLE_HIDDEN_APP" || is_enabled "$KAORIOS_ENABLE_INSTALLER_SOURCE"; then
    require_one_target "$root" "com/android/server/pm/ComputerEngine.smali" "ComputerEngine"
  fi
  if system_server_hook_needed; then
    require_one_target "$root" "com/android/server/SystemServer.smali" "SystemServer"
  fi
  if is_enabled "$KAORIOS_ENABLE_SECURE_FLAG"; then
    require_one_target "$root" "com/android/server/devicepolicy/DevicePolicyCacheImpl.smali" "DevicePolicyCacheImpl"
  fi
}

require_miui_services_targets() {
  local root="$1"
  require_one_target "$root" "com/android/server/wm/WindowManagerServiceImpl.smali" "WindowManagerServiceImpl"
}

find_target_file() {
  local root="$1" rel="$2" label="$3" file
  require_one_target "$root" "$rel" "$label" || return 1
  file=$(find "$root" -type f -path "*/$rel" -print -quit)
  printf '%s\n' "$file"
}

patch_target_file() {
  local root="$1" rel="$2" label="$3" mode="${4:-1}" file patch_log
  file=$(find_target_file "$root" "$rel" "$label") || return 1
  patch_log="$TEMP_ROOT/kaorios-patcher.log"
  if ! python3 "$PATCHER" "$file" --android-version "$ANDROID_VER" --mode "$mode" --no-delay >"$patch_log" 2>&1; then
    error "KAORIOS: patcher failed for $label"
    tail -n 100 "$patch_log" >&2 || true
    return 1
  fi
  if is_enabled "$KAORIOS_VERBOSE_LOG"; then
    cat "$patch_log"
  else
    info "KAORIOS: patched $label"
  fi
}

patch_computer_engine() {
  local root="$1" file
  file=$(find_target_file "$root" "com/android/server/pm/ComputerEngine.smali" "ComputerEngine") || return 1
  if ! python3 "$MOD_TOOL" adapter "$file" \
    --hidden-app "$KAORIOS_ENABLE_HIDDEN_APP" \
    --installer-source "$KAORIOS_ENABLE_INSTALLER_SOURCE"; then
    error "KAORIOS: MOD adapter failed for ComputerEngine"
    return 1
  fi
}

patch_selected_targets() {
  local kind="$1" root="$2"
  case "$kind" in
    framework)
      if is_enabled "$KAORIOS_ENABLE_ACTIVITY_THREAD"; then
        patch_target_file "$root" "android/app/ActivityThread.smali" "ActivityThread" 1
      fi
      if is_enabled "$KAORIOS_ENABLE_INSTRUMENTATION"; then
        patch_target_file "$root" "android/app/Instrumentation.smali" "Instrumentation" 1
      fi
      if is_enabled "$KAORIOS_ENABLE_SYSTEM_FEATURE_SPOOF"; then
        patch_target_file "$root" "android/app/ApplicationPackageManager.smali" "ApplicationPackageManager" 1
      fi
      if is_enabled "$KAORIOS_ENABLE_KEYBOX"; then
        patch_target_file "$root" "android/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi.smali" "AndroidKeyStoreKeyPairGeneratorSpi" 1
        patch_target_file "$root" "android/security/keystore2/AndroidKeyStoreSpi.smali" "AndroidKeyStoreSpi" 1
      fi
      if build_spoof_enabled_for_target; then
        info "KAORIOS: Android 17 Build spoof enabled"
        patch_target_file "$root" "android/os/Build.smali" "Build" 2
        patch_target_file "$root" 'android/os/Build$VERSION.smali' 'Build$VERSION' 2
      fi
      if is_enabled "$KAORIOS_ENABLE_DEVSTATUS"; then
        apply_devstatus_patch "$root" || return 1
      fi
      ;;
    services)
      if is_enabled "$KAORIOS_ENABLE_HIDDEN_APP" || is_enabled "$KAORIOS_ENABLE_INSTALLER_SOURCE"; then
        patch_computer_engine "$root"
      fi
      if system_server_hook_needed; then
        patch_target_file "$root" "com/android/server/SystemServer.smali" "SystemServer" 1
      fi
      if is_enabled "$KAORIOS_ENABLE_SECURE_FLAG"; then
        python3 "$MOD_TOOL" secure-flag "$root" --archive services
      fi
      ;;
    miui-services)
      python3 "$MOD_TOOL" secure-flag "$root" --archive miui-services
      ;;
    *)
      error "KAORIOS: unknown patch kind: $kind"
      return 1
      ;;
  esac
}

rebuild_changed_dexes() {
  local smali_root="$1" snapshot="$2" built="$3" kind="$4" raw="$5"
  local dir name before after changed=0 log
  local overflow_root="$built-overflow"
  rm -rf "$built" "$overflow_root"
  mkdir -p "$built" "$overflow_root"
  log="$TEMP_ROOT/smali-$kind.log"

  shopt -s nullglob
  for dir in "$smali_root"/classes*.dex.out; do
    name=$(basename "$dir")
    before=$(old_hash "$snapshot" "$name")
    after=$(tree_hash "$dir")
    if [[ -z "$before" ]]; then
      error "KAORIOS: missing pre-patch hash for $name"
      return 1
    fi
    if [[ "$before" != "$after" ]]; then
      if ! run_smali "$dir" "$built/${name%.out}" >"$log" 2>&1; then
        # Android 17's framework DEX can be at the 16-bit reference limit.
        # Move complete non-bootstrap class families into a fresh DEX, retaining
        # every class and every enabled Kaorios hook. Reject all other errors.
        if [[ "$kind" != "framework" || "$ANDROID_VER" != "17" ]] ||
           ! grep -Eq 'Unsigned short value out of range|DexIndexOverflowException|Too many (method|field|type) references|method_ids=[0-9]+ exceeds DEX limit|field_ids=[0-9]+ exceeds DEX limit|type_ids=[0-9]+ exceeds DEX limit' "$log"; then
          cat "$log" >&2
          error "KAORIOS: failed rebuilding ${name%.out}"
          return 1
        fi
        warn "KAORIOS: ${name%.out} exceeded the DEX instruction reference limit; rebalancing"
        local overflow_dir="$overflow_root/${name%.out}"
        local attempt recovered=0
        mkdir -p "$overflow_dir"
        for attempt in {1..12}; do
          if ! python3 "$DEX_REBALANCE" relocate "$dir" "$overflow_dir"; then
            error "KAORIOS: unable to rebalance ${name%.out} safely"
            return 1
          fi
          if run_smali "$dir" "$built/${name%.out}" >"$log" 2>&1; then
            recovered=1
            info "KAORIOS: reference overflow resolved in ${name%.out} (attempt $attempt)"
            break
          fi
          if ! grep -Eq 'Unsigned short value out of range|DexIndexOverflowException|Too many (method|field|type) references|method_ids=[0-9]+ exceeds DEX limit|field_ids=[0-9]+ exceeds DEX limit|type_ids=[0-9]+ exceeds DEX limit' "$log"; then
            cat "$log" >&2
            error "KAORIOS: non-overflow error during DEX rebalance"
            return 1
          fi
        done
        if (( recovered == 0 )); then
          cat "$log" >&2
          error "KAORIOS: reference overflow unresolved after 12 safe relocations"
          return 1
        fi
      fi
      info "KAORIOS: rebuilt changed DEX ${name%.out}"
      changed=$((changed + 1))
    fi
  done
  shopt -u nullglob

  # Allocate additional DEXes only when necessary, without colliding with
  # original DEX names. The Kaorios driver gets the next free slot after these.
  shopt -s nullglob
  for dir in "$overflow_root"/*; do
    [[ -d "$dir" ]] || continue
    name=$(next_dex_name "$raw" "$built")
    if ! run_smali "$dir" "$built/$name" >"$log" 2>&1; then
      cat "$log" >&2
      error "KAORIOS: failed building overflow class family $name"
      return 1
    fi
    info "KAORIOS: preserved relocated framework classes in $name"
  done
  shopt -u nullglob

  if (( changed == 0 )); then
    info "KAORIOS: no owner DEX changed; final candidate verification will decide validity"
  fi
}
next_dex_name() {
  local raw="$1" dex base n max=0
  shopt -s nullglob
  local root
  for root in "$@"; do
    for dex in "$root"/classes*.dex; do
    base=$(basename "$dex")
    if [[ "$base" == "classes.dex" ]]; then
      n=1
    elif [[ "$base" =~ ^classes([0-9]+)\.dex$ ]]; then
      n="${BASH_REMATCH[1]}"
    else
      continue
    fi
    (( n > max )) && max=$n
    done
  done
  shopt -u nullglob
  n=$((max + 1))
  if (( n == 1 )); then
    printf 'classes.dex\n'
  else
    printf 'classes%d.dex\n' "$n"
  fi
}

ensure_no_existing_driver() {
  local smali_root="$1"
  local matches=()
  while IFS= read -r -d '' p; do matches+=("$p"); done < <(find "$smali_root" -type f -path '*/android/security/kaorios/KaoriosHook.smali' -print0)
  if (( ${#matches[@]} != 0 )); then
    error "KAORIOS: framework already contains KaoriosHook; refusing duplicate framework driver"
    return 1
  fi
}

# Per-app "hide Developer options / ADB". Upstream documents this target as an
# optional, per-ROM patch, so unsupported layouts can warn or fail via config.
# Legacy KAORIOS_SKIP_DEVSTATUS / KAORIOS_STRICT_DEVSTATUS remain accepted.
apply_devstatus_patch() {
  local root="$1" rc=0
  if ! is_enabled "$KAORIOS_ENABLE_DEVSTATUS" || [[ "${KAORIOS_SKIP_DEVSTATUS:-0}" == "1" ]]; then
    info "KAORIOS: dev-status (Developer options/ADB) patch disabled"
    return 0
  fi
  if is_enabled "$KAORIOS_DEVSTATUS_STRICT" || [[ "${KAORIOS_STRICT_DEVSTATUS:-0}" == "1" ]]; then
    python3 "$MOD_TOOL" devstatus "$root" --strict || rc=$?
  else
    python3 "$MOD_TOOL" devstatus "$root" || rc=$?
  fi
  case "$rc" in
    0)
      NVC_APPLIED=1
      info "KAORIOS: Settings\$NameValueCache dev-status hook applied"
      ;;
    3)
      warn "KAORIOS: Settings\$NameValueCache layout unsupported; dev-status hook not applied"
      ;;
    *)
      error "KAORIOS: dev-status patcher failed (rc=$rc)"
      return 1
      ;;
  esac
  return 0
}

update_archive_dexes() {
  local original="$1" built="$2" candidate="$3"
  local dex
  cp -f "$original" "$candidate"
  shopt -s nullglob
  for dex in "$built"/classes*.dex; do
    (
      cd "$built"
      zip -q -0 "$candidate" "$(basename "$dex")"
    )
  done
  shopt -u nullglob
  unzip -tq "$candidate" >/dev/null
}

verify_hook() {
  local root="$1" rel="$2" needle="$3" label="$4"
  local file
  file=$(find "$root" -type f -path "*/$rel" -print -quit)
  if [[ -z "$file" ]] || ! grep -Fq -- "$needle" "$file"; then
    error "KAORIOS: final verification failed: $label"
    return 1
  fi
}

verify_advanced_policy_payload() {
  local root="$1"
  local rel
  for rel in \
    'android/security/kaorios/settings/IAdvancedPolicyService.smali' \
    'android/security/kaorios/settings/IAdvancedPolicyService$Stub.smali' \
    'android/security/kaorios/settings/IAdvancedPolicyService$Stub$Proxy.smali' \
    'android/security/kaorios/settings/AdvancedPolicyClient.smali' \
    'android/security/kaorios/settings/AdvancedPolicyService.smali' \
    'android/security/kaorios/settings/AdvancedPolicySnapshot.smali' \
    'android/security/kaorios/settings/ServiceManagerBridge.smali' \
    'android/security/kaorios/settings/SettingDecisionParcel.smali'; do
    require_one_target "$root" "$rel" "AdvancedPolicy payload"
  done
}

verify_framework_final() {
  local root="$1"
  require_framework_targets "$root"

  if is_enabled "$KAORIOS_ENABLE_ACTIVITY_THREAD"; then
    verify_hook "$root" "android/app/ActivityThread.smali" \
      'KaoriosHook;->initActivityThread(Ljava/lang/Object;)V' "ActivityThread init"
  fi
  if is_enabled "$KAORIOS_ENABLE_INSTRUMENTATION"; then
    verify_hook "$root" "android/app/Instrumentation.smali" \
      'KaoriosHook;->initContext(Landroid/content/Context;)V' "Instrumentation initContext"
  fi
  if is_enabled "$KAORIOS_ENABLE_SYSTEM_FEATURE_SPOOF"; then
    verify_hook "$root" "android/app/ApplicationPackageManager.smali" \
      'KaoriosHook;->hasSystemFeature(Ljava/lang/String;I)Ljava/lang/Boolean;' "system feature spoof"
  fi
  if is_enabled "$KAORIOS_ENABLE_KEYBOX"; then
    verify_hook "$root" "android/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi.smali" \
      'KaoriosHook;->initGenerateSoftwareKeyPair' "Play Integrity/keybox keypair hook"
    verify_hook "$root" "android/security/keystore2/AndroidKeyStoreSpi.smali" \
      'KaoriosHook;->CertificateChainIfNeeded' "Play Integrity/keybox certificate hook"
  fi

  if framework_driver_needed; then
    require_one_target "$root" "android/security/kaorios/KaoriosHook.smali" "KaoriosHook framework driver"

    if is_enabled "$KAORIOS_ENABLE_NATIVE_PIF"; then
      verify_hook "$root" "android/security/kaorios/KaoriosHook.smali" \
        'PifNative;->install(Landroid/content/Context;)V' "native PIF driver call"
      verify_hook "$root" "android/security/ntmanager/PifNative.smali" \
        'nativeInstall([Ljava/lang/String;[Ljava/lang/String;)Z' "native PIF JNI bridge"
    fi

    if is_enabled "$KAORIOS_ENABLE_ACTIVITY_THREAD"; then
      verify_hook "$root" "android/security/kaorios/KaoriosHook.smali" \
        'initActivityThread(Ljava/lang/Object;)V' "driver ActivityThread implementation"
    fi
    if is_enabled "$KAORIOS_ENABLE_INSTRUMENTATION"; then
      verify_hook "$root" "android/security/kaorios/KaoriosHook.smali" \
        'initContext(Landroid/content/Context;)V' "driver context implementation"
    fi
    if is_enabled "$KAORIOS_ENABLE_KEYBOX"; then
      verify_hook "$root" "android/security/kaorios/KaoriosHook.smali" \
        'initGenerateSoftwareKeyPair(Ljava/lang/Object;)Ljava/security/KeyPair;' "driver keypair implementation"
      verify_hook "$root" "android/security/kaorios/KaoriosHook.smali" \
        'CertificateChainIfNeeded([Ljava/security/cert/Certificate;)[Ljava/security/cert/Certificate;' "driver certificate implementation"
    fi
    if is_enabled "$KAORIOS_ENABLE_SYSTEM_FEATURE_SPOOF"; then
      verify_hook "$root" "android/security/kaorios/KaoriosHook.smali" \
        'hasSystemFeature(Ljava/lang/String;I)Ljava/lang/Boolean;' "driver system-feature implementation"
    fi
    if system_server_hook_needed; then
      verify_hook "$root" "android/security/kaorios/KaoriosHook.smali" \
        'initSystemServer()V' "driver SystemServer implementation"
    fi
    if is_enabled "$KAORIOS_ENABLE_HIDDEN_APP"; then
      verify_hook "$root" "android/security/kaorios/KaoriosHook.smali" \
        'shouldHideAppListForCaller(ILjava/lang/String;I)Z' "driver app-visibility implementation"
    fi
    if is_enabled "$KAORIOS_ENABLE_INSTALLER_SOURCE"; then
      verify_hook "$root" "android/security/kaorios/KaoriosHook.smali" \
        'filterInstallerPackageName(Landroid/content/ContentResolver;IILjava/lang/String;Ljava/lang/String;)Ljava/lang/String;' "driver installer-source implementation"
    fi
    if is_enabled "$KAORIOS_ENABLE_DEVSTATUS"; then
      verify_hook "$root" "android/security/kaorios/KaoriosHook.smali" \
        'shouldHideDevStatusFromNameValueCache(Landroid/content/ContentResolver;Ljava/lang/String;I)Z' "driver dev-status implementation"
    fi
    if [[ "$ANDROID_VER" == "17" ]]; then
      verify_advanced_policy_payload "$root"
    fi
  fi

  # The upstream verifier also validates the ActivityThread caller. Only run it
  # when that caller is enabled; partial configs use the targeted checks above.
  if is_enabled "$KAORIOS_ENABLE_ACTIVITY_THREAD"; then
    if [[ "$ANDROID_VER" == "17" ]]; then
      python3 "$SCRIPT_DIR/verify-framework-a17-hooks.py" "$root" >/dev/null || {
        error "KAORIOS: final verification failed: framework hook verifier"
        return 1
      }
    else
      python3 "$SCRIPT_DIR/verify-framework-a17-hooks.py" "$root" --skip-advanced-policy >/dev/null || {
        error "KAORIOS: final verification failed: framework hook verifier"
        return 1
      }
    fi
  fi

  if build_spoof_enabled_for_target; then
    python3 "$MOD_TOOL" verify-build "$root" >/dev/null || {
      error "KAORIOS: final verification failed: Android 17 Build spoof"
      return 1
    }
    info "KAORIOS: Android 17 Build/Build\$VERSION spoof verified"
  fi

  if (( NVC_APPLIED == 1 )); then
    python3 "$MOD_TOOL" devstatus "$root" --verify-only --verify-roundtrip >/dev/null || {
      error "KAORIOS: final verification failed: dev-status (Developer options/ADB) hook"
      return 1
    }
    info "KAORIOS: dev-status (Developer options/ADB) hook verified"
  fi

  info "KAORIOS: enabled framework features verified"
}

verify_services_final() {
  local root="$1" file
  require_services_targets "$root"

  if is_enabled "$KAORIOS_ENABLE_HIDDEN_APP" || is_enabled "$KAORIOS_ENABLE_INSTALLER_SOURCE"; then
    file=$(find "$root" -type f -path '*/com/android/server/pm/ComputerEngine.smali' -print -quit)
    python3 "$MOD_TOOL" adapter "$file" \
      --hidden-app "$KAORIOS_ENABLE_HIDDEN_APP" \
      --installer-source "$KAORIOS_ENABLE_INSTALLER_SOURCE" \
      --check-only >/dev/null || {
      error "KAORIOS: final verification failed: ComputerEngine hooks"
      return 1
    }
    if is_enabled "$KAORIOS_ENABLE_HIDDEN_APP"; then
      verify_hook "$root" "com/android/server/pm/ComputerEngine.smali" \
        'KaoriosHook;->shouldHideAppListForCaller' "ComputerEngine app visibility"
      python3 "$SCRIPT_DIR/verify-services-a17-hooks.py" "$root" >/dev/null || {
        error "KAORIOS: final verification failed: services hook verifier"
        return 1
      }
    fi
  fi

  if system_server_hook_needed; then
    verify_hook "$root" "com/android/server/SystemServer.smali" \
      'KaoriosHook;->initSystemServer()V' "SystemServer init"
    python3 "$SCRIPT_DIR/verify-systemserver-a17-hooks.py" "$root" >/dev/null || {
      error "KAORIOS: final verification failed: SystemServer hook verifier"
      return 1
    }
  fi

  if is_enabled "$KAORIOS_ENABLE_SECURE_FLAG"; then
    python3 "$MOD_TOOL" secure-flag "$root" --archive services --check-only >/dev/null || {
      error "KAORIOS: final verification failed: static Secure Flag bypasses"
      return 1
    }
    info "KAORIOS: static Secure Flag bypasses verified"
  fi

  info "KAORIOS: enabled services features verified"
}

verify_miui_services_final() {
  local root="$1"
  require_miui_services_targets "$root"
  python3 "$MOD_TOOL" secure-flag "$root" --archive miui-services --check-only >/dev/null || {
    error "KAORIOS: final verification failed: Xiaomi static Secure Flag bypass"
    return 1
  }
  info "KAORIOS: Xiaomi static Secure Flag bypass verified"
}

verify_candidate() {
  local candidate="$1" kind="$2" root="$3"
  local raw="$root/verify-raw" smali="$root/verify-smali"
  extract_all_dex "$candidate" "$raw"
  # Fail with the actual malformed-header/reference count rather than a
  # misleading UnsupportedFileTypeException from baksmali.
  python3 "$DEX_REBALANCE" audit "$raw"
  disassemble_all "$raw" "$smali"
  case "$kind" in
    framework) verify_framework_final "$smali" ;;
    services) verify_services_final "$smali" ;;
    miui-services) verify_miui_services_final "$smali" ;;
    *) error "KAORIOS: unsupported archive kind: $kind"; return 1 ;;
  esac
}

find_unique_artifact() {
  local name="$1" preferred="$2"
  if [[ -n "$preferred" && -f "$preferred" ]]; then
    printf '%s\n' "$preferred"
    return 0
  fi
  local matches=()
  while IFS= read -r -d '' p; do matches+=("$p"); done < <(find "$work_dir/build/baserom/images" -type f -name "$name" -print0)
  if (( ${#matches[@]} != 1 )); then
    error "KAORIOS: expected one $name, found ${#matches[@]}"
    return 1
  fi
  printf '%s\n' "${matches[0]}"
}

find_optional_unique_artifact() {
  local name="$1" preferred="$2"
  if [[ -n "$preferred" && -f "$preferred" ]]; then
    printf '%s\n' "$preferred"
    return 0
  fi
  local matches=()
  while IFS= read -r -d '' p; do matches+=("$p"); done < <(find "$work_dir/build/baserom/images" -type f -name "$name" -print0)
  if (( ${#matches[@]} > 1 )); then
    error "KAORIOS: expected at most one $name, found ${#matches[@]}"
    return 1
  fi
  if (( ${#matches[@]} == 1 )); then
    printf '%s\n' "${matches[0]}"
  fi
}

patch_archive() {
  local artifact="$1" kind="$2"
  local root="$TEMP_ROOT/$kind"
  local raw="$root/raw" smali="$root/smali" snapshot="$root/before.hashes"
  local built="$root/built" candidate="$root/candidate.zip"

  rm -rf "$root"
  mkdir -p "$root"

  extract_all_dex "$artifact" "$raw"
  disassemble_all "$raw" "$smali"

  case "$kind" in
    framework)
      require_framework_targets "$smali"
      if framework_driver_needed; then
        ensure_no_existing_driver "$smali"
      fi
      ;;
    services) require_services_targets "$smali" ;;
    miui-services) require_miui_services_targets "$smali" ;;
    *) error "KAORIOS: unsupported archive kind: $kind"; return 1 ;;
  esac

  python3 "$DEX_REBALANCE" audit "$raw"
  python3 "$DEX_REBALANCE" inventory "$smali" > "$root/original.classes"
  snapshot_hashes "$smali" "$snapshot"

  patch_selected_targets "$kind" "$smali"
  rebuild_changed_dexes "$smali" "$snapshot" "$built" "$kind" "$raw"

  if [[ "$kind" == "framework" ]] && framework_driver_needed; then
    local driver_name
    driver_name=$(next_dex_name "$raw" "$built")
    cp -f "$DRIVER_DEX" "$built/$driver_name"
    info "KAORIOS: framework driver staged as $driver_name"
  fi

  update_archive_dexes "$artifact" "$built" "$candidate"
  verify_candidate "$candidate" "$kind" "$root"
  python3 "$DEX_REBALANCE" audit "$root/verify-raw"
  python3 "$DEX_REBALANCE" verify-classes "$root/original.classes" "$root/verify-smali"

  cp -f "$candidate" "$artifact"
  info "KAORIOS: installed verified $kind artifact"
}

get_system_target_dir() {
  local images="$work_dir/build/baserom/images"
  if [[ -d "$images/system/system" ]]; then
    printf '%s\n' "$images/system/system"
  elif [[ -d "$images/system" ]]; then
    printf '%s\n' "$images/system"
  else
    return 1
  fi
}

install_native_pif() {
  local sys_target
  if ! sys_target=$(get_system_target_dir); then
    warn "KAORIOS: system partition directory missing; skipping Native PIF installation"
    return 0
  fi

  local lib_src="$MOD_DIR/native_pif"
  if [[ ! -d "$lib_src" ]]; then
    error "KAORIOS: Native PIF source directory missing: $lib_src"
    return 1
  fi

  # 64-bit libraries
  local arm64_dir="$lib_src/arm64-v8a"
  local target_lib64="$sys_target/lib64"
  if [[ -d "$arm64_dir" ]]; then
    mkdir -p "$target_lib64"
    for lib in libkaoripif.so; do
      if [[ -f "$arm64_dir/$lib" ]]; then
        cp -f "$arm64_dir/$lib" "$target_lib64/$lib"
        chmod 0644 "$target_lib64/$lib"
        chown 0:0 "$target_lib64/$lib" 2>/dev/null || true
        command -v chcon >/dev/null 2>&1 && chcon u:object_r:system_lib_file:s0 "$target_lib64/$lib" 2>/dev/null || true
        patch_file_context "system" "/system/lib64/$lib" "u:object_r:system_lib_file:s0"
        patch_file_context "system" "/system/system/lib64/$lib" "u:object_r:system_lib_file:s0"
      fi
    done
    info "KAORIOS: installed 64-bit Native PIF libraries to $target_lib64"
  fi

  # 32-bit libraries
  local arm_dir="$lib_src/armeabi-v7a"
  local target_lib="$sys_target/lib"
  if [[ -d "$arm_dir" ]]; then
    mkdir -p "$target_lib"
    for lib in libkaoripif.so; do
      if [[ -f "$arm_dir/$lib" ]]; then
        cp -f "$arm_dir/$lib" "$target_lib/$lib"
        chmod 0644 "$target_lib/$lib"
        chown 0:0 "$target_lib/$lib" 2>/dev/null || true
        command -v chcon >/dev/null 2>&1 && chcon u:object_r:system_lib_file:s0 "$target_lib/$lib" 2>/dev/null || true
        patch_file_context "system" "/system/lib/$lib" "u:object_r:system_lib_file:s0"
        patch_file_context "system" "/system/system/lib/$lib" "u:object_r:system_lib_file:s0"
      fi
    done
    info "KAORIOS: installed 32-bit Native PIF libraries to $target_lib"
  fi
}

install_toolbox() {
  local sys_ext="$work_dir/build/baserom/images/system_ext"
  if [[ ! -d "$sys_ext" ]]; then
    error "KAORIOS: system_ext partition directory missing"
    return 1
  fi

  local app_dir="$sys_ext/priv-app/KaoriosToolbox"
  local perm_dir="$sys_ext/etc/permissions"
  mkdir -p "$app_dir" "$perm_dir"
  cp -f "$TOOLBOX_APK" "$app_dir/KaoriosToolbox.apk"
  cp -f "$PERMISSION_XML" "$perm_dir/com.kousei.kaorios.xml"
  chmod 0644 "$app_dir/KaoriosToolbox.apk" "$perm_dir/com.kousei.kaorios.xml"
  info "KAORIOS: Toolbox installed as system_ext priv-app"
}

validate_optional_keybox_input() {
  # Never bake an attestation private key into a public ROM repository.
  # If a builder supplies one for validation, only validate its structure.
  local keybox="${KAORIOS_KEYBOX_XML:-}"
  if [[ -z "$keybox" && -f "$KAORIOS_DIR/keybox.xml" ]]; then
    keybox="$KAORIOS_DIR/keybox.xml"
  fi
  if [[ -n "$keybox" ]]; then
    if [[ ! -f "$keybox" ]]; then
      error "KAORIOS: KAORIOS_KEYBOX_XML does not exist: $keybox"
      return 1
    fi
    python3 "$VALIDATE_KEYBOX" "$keybox" >/dev/null || {
      error "KAORIOS: supplied keybox XML failed structural validation"
      return 1
    }
    warn "KAORIOS: keybox validated but intentionally NOT embedded; import it in Toolbox at runtime"
  fi
}

mods "Kaorios Toolbox upstream 2.0.6.1 integration (bundled CorePatch)"

info "KAORIOS config: ActivityThread=$KAORIOS_ENABLE_ACTIVITY_THREAD, Instrumentation=$KAORIOS_ENABLE_INSTRUMENTATION, Keybox=$KAORIOS_ENABLE_KEYBOX"
info "KAORIOS config: SystemFeature=$KAORIOS_ENABLE_SYSTEM_FEATURE_SPOOF, SystemServer=$KAORIOS_ENABLE_SYSTEM_SERVER, HiddenApp=$KAORIOS_ENABLE_HIDDEN_APP"
info "KAORIOS config: InstallerSource=$KAORIOS_ENABLE_INSTALLER_SOURCE, DevStatus=$KAORIOS_ENABLE_DEVSTATUS"
info "KAORIOS config: BuildSpoof=$KAORIOS_ENABLE_BUILD_SPOOF (A17 only), Toolbox=$KAORIOS_INSTALL_TOOLBOX, ValidateKeybox=$KAORIOS_VALIDATE_KEYBOX"
info "KAORIOS config: SecureFlag=$KAORIOS_ENABLE_SECURE_FLAG, CorePatch=bundled"
info "KAORIOS config: NativePIF=$KAORIOS_ENABLE_NATIVE_PIF"

if is_enabled "$KAORIOS_VALIDATE_KEYBOX"; then
  validate_optional_keybox_input
fi


if framework_archive_needed; then
  FRAMEWORK_JAR=$(find_unique_artifact "framework.jar" "$work_dir/build/baserom/images/system/system/framework/framework.jar")
  patch_archive "$FRAMEWORK_JAR" framework
fi

if services_features_enabled; then
  SERVICES_JAR=$(find_unique_artifact "services.jar" "$work_dir/build/baserom/images/system/system/framework/services.jar")
  patch_archive "$SERVICES_JAR" services
fi

if is_enabled "$KAORIOS_ENABLE_SECURE_FLAG"; then
  MIUI_SERVICES_JAR=$(find_optional_unique_artifact "miui-services.jar" "$work_dir/build/baserom/images/system_ext/framework/miui-services.jar") || exit 1
  if [[ -n "$MIUI_SERVICES_JAR" ]]; then
    patch_archive "$MIUI_SERVICES_JAR" miui-services
  else
    info "KAORIOS: miui-services.jar not present; Xiaomi-specific Secure Flag bypass skipped"
  fi
fi

if is_enabled "$KAORIOS_ENABLE_NATIVE_PIF"; then
  install_native_pif
fi

if is_enabled "$KAORIOS_INSTALL_TOOLBOX"; then
  install_toolbox
fi

if ! archive_patch_needed &&
   ! is_enabled "$KAORIOS_INSTALL_TOOLBOX" &&
   ! is_enabled "$KAORIOS_ENABLE_NATIVE_PIF" &&
   ! is_enabled "$KAORIOS_VALIDATE_KEYBOX"; then
  info "KAORIOS: all feature switches are OFF; nothing to do"
fi

mods "Kaorios Toolbox done with selected config"
