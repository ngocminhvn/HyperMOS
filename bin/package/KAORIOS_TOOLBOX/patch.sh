#!/usr/bin/env bash
set -euo pipefail

# HyperMOS integration for Kaorios Toolbox.
# Upstream-owned scripts are vendored byte-for-byte from Kaorios upstream.
# MOD-only behavior is kept outside those files in mod-kaorios-adapter.py.
# Upstream script snapshot: 8c752fd2692ee9e469433cc2e6e2f0ee8bf54cd4
# The package driver applies Kaorios CorePatch immediately before this stage.
# This stage adds Toolbox hooks and MOD-local static FLAG_SECURE bypasses.
#
# Applied Kaorios features (per the upstream Patch_Guide_2.0.6.1_VI):
#   - process/context initialisation (ActivityThread + Instrumentation);
#   - Play Integrity / keybox keystore hooks;
#   - ApplicationPackageManager.hasSystemFeature(...) spoof;
#   - SystemServer initialisation;
#   - ComputerEngine package visibility + installer-source hooks;
#   - Settings$NameValueCache dev-status hook (hide Developer options / ADB);
#   - Android 17 Build / Build$VERSION spoof (Android 17 only, like upstream).
# CorePatch is selected before this stage. AdvancedPolicy receives a narrowly
# scoped app-facing system_server service type using platform attributes.

work_dir=$(pwd)
source "$work_dir/functions.sh"

KAORIOS_DIR="$work_dir/bin/package/KAORIOS_TOOLBOX"
ASSET_DIR="$KAORIOS_DIR/app"
SCRIPT_DIR="$KAORIOS_DIR/script"
MOD_DIR="$KAORIOS_DIR/mod"
PATCHER="$SCRIPT_DIR/kaorios_patcher.py"
MOD_ADAPTER="$MOD_DIR/mod-kaorios-adapter.py"
DEVSTATUS_PATCHER="$MOD_DIR/patch-settings-namevaluecache.py"
BAKSMALI="$work_dir/bin/apktool/baksmaliv2.jar"
SMALI="$work_dir/bin/apktool/smaliv2.jar"
DRIVER_DEX="$ASSET_DIR/classes.dex"
TOOLBOX_APK="$ASSET_DIR/KaoriosToolbox.apk"
PERMISSION_XML="$ASSET_DIR/com.kousei.kaorios.xml"
SECURE_FLAG_PATCHER="$MOD_DIR/patch-secure-flag.py"
CONFIG="$KAORIOS_DIR/config.json"
CONFIG_LOADER="$MOD_DIR/load-config.py"
FINAL_HOOK_VERIFIER="$MOD_DIR/verify-selected-hooks.py"
ADVANCED_POLICY_SELINUX="$MOD_DIR/integrate-advanced-policy-selinux.py"

if [[ ! -f "$CONFIG" || ! -f "$CONFIG_LOADER" ]]; then
  error "KAORIOS: missing config.json or its loader"
  exit 1
fi
if ! config_values=$(python3 "$CONFIG_LOADER" "$CONFIG"); then
  exit 1
fi
while IFS='=' read -r config_name config_value; do
  [[ -n "$config_name" ]] || continue
  if [[ ! -v "$config_name" ]]; then
    printf -v "$config_name" '%s' "$config_value"
  fi
done <<< "$config_values"
unset config_values config_name config_value

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
  KAORIOS_ENABLE_COREPATCH \
  KAORIOS_INSTALL_TOOLBOX \
  KAORIOS_VERBOSE_LOG; do
  validate_bool "$flag"
done

if ! is_enabled "$KAORIOS_MASTER"; then
  mods "Kaorios Toolbox disabled by config"
  exit 0
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
  is_enabled "$KAORIOS_ENABLE_DEVSTATUS"
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
DRIVER_GIT_BLOB="33a40d7960d31c2a8c98ffaf8efb70ac96bf1e7f"
TOOLBOX_GIT_BLOB="671ac1357400a54adfc442c58496bd69e1d4d60c"

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
  require_file "$FINAL_HOOK_VERIFIER" "final hook verifier"
  require_file "$BAKSMALI" "baksmali"
  require_file "$SMALI" "smali"
fi
if system_server_hook_needed; then
  require_file "$ADVANCED_POLICY_SELINUX" "AdvancedPolicy SELinux integrator"
fi
if is_enabled "$KAORIOS_ENABLE_HIDDEN_APP" || is_enabled "$KAORIOS_ENABLE_INSTALLER_SOURCE"; then
  require_file "$MOD_ADAPTER" "MOD Kaorios adapter"
fi
if framework_driver_needed; then
  require_file "$DRIVER_DEX" "framework driver DEX"
fi
if is_enabled "$KAORIOS_INSTALL_TOOLBOX"; then
  require_file "$TOOLBOX_APK" "Toolbox APK"
  require_file "$PERMISSION_XML" "Toolbox privapp permission XML"
fi
if is_enabled "$KAORIOS_ENABLE_SECURE_FLAG"; then
  require_file "$SECURE_FLAG_PATCHER" "Secure Flag patcher"
fi

if archive_patch_needed; then
  for cmd in java python3 unzip zip git sha256sum find sort xargs; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      error "KAORIOS: missing host tool: $cmd"
      exit 1
    fi
  done
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
  java -jar "$SMALI" a --api "$SDK_LEVEL" "$src" -o "$out"
  [[ -s "$out" ]]
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
  if ! python3 "$PATCHER" "$file" --android-version "$ANDROID_VER" --mode "$mode" --no-delay \
    >"$patch_log" 2>&1; then
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
  if ! python3 "$MOD_ADAPTER" "$file" \
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
        python3 "$SECURE_FLAG_PATCHER" "$root" --archive services
      fi
      ;;
    miui-services)
      python3 "$SECURE_FLAG_PATCHER" "$root" --archive miui-services
      ;;
    *)
      error "KAORIOS: unknown patch kind: $kind"
      return 1
      ;;
  esac
}

rebuild_changed_dexes() {
  local smali_root="$1" snapshot="$2" built="$3"
  local dir name before after changed=0
  rm -rf "$built"
  mkdir -p "$built"
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
      run_smali "$dir" "$built/${name%.out}"
      info "KAORIOS: rebuilt changed DEX ${name%.out}"
      changed=$((changed + 1))
    fi
  done
  shopt -u nullglob
  if (( changed == 0 )); then
    info "KAORIOS: no owner DEX changed; final candidate verification will decide validity"
  fi
}

next_dex_name() {
  local raw="$1" dex base n max=0
  shopt -s nullglob
  for dex in "$raw"/classes*.dex; do
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

# Per-app "hide Developer options / ADB" using the 2060 dev-status patcher.
# 2060 patcher does NOT have Settings$NameValueCache in its mode-1 targets,
# so calling it via patch_target_file fails with "not in target list".
# Use mod/patch-settings-namevaluecache.py instead, like 2060 patch.sh did.
# Unsupported layout (rc=3) only warns, it does not abort the build.
apply_devstatus_patch() {
  local root="$1" rc=0
  if ! is_enabled "$KAORIOS_ENABLE_DEVSTATUS" || [[ "${KAORIOS_SKIP_DEVSTATUS:-0}" == "1" ]]; then
    info "KAORIOS: dev-status (Developer options/ADB) patch disabled"
    return 0
  fi
  if [[ ! -f "$DEVSTATUS_PATCHER" ]]; then
    error "KAORIOS: missing dev-status patcher: $DEVSTATUS_PATCHER"
    return 1
  fi
  python3 "$DEVSTATUS_PATCHER" "$root" || rc=$?
  case "$rc" in
    0)
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
  if ! unzip -tq "$candidate" >/dev/null; then
    error "KAORIOS: invalid rebuilt archive: $candidate"
    return 1
  fi
}

verify_candidate() {
  local candidate="$1" kind="$2"
  local verify_root="$TEMP_ROOT/$kind/final"
  local verify_raw="$verify_root/raw" verify_smali="$verify_root/smali"
  local verifier_args=("$verify_smali" --script-dir "$SCRIPT_DIR")

  extract_all_dex "$candidate" "$verify_raw"
  disassemble_all "$verify_raw" "$verify_smali"

  case "$kind" in
    framework)
      if is_enabled "$KAORIOS_ENABLE_ACTIVITY_THREAD"; then verifier_args+=(--target activity_thread); fi
      if is_enabled "$KAORIOS_ENABLE_INSTRUMENTATION"; then verifier_args+=(--target instrumentation); fi
      if is_enabled "$KAORIOS_ENABLE_SYSTEM_FEATURE_SPOOF"; then verifier_args+=(--target system_feature); fi
      if is_enabled "$KAORIOS_ENABLE_KEYBOX"; then
        verifier_args+=(--target keypair --target keystore)
      fi
      if is_enabled "$KAORIOS_ENABLE_DEVSTATUS"; then verifier_args+=(--target devstatus); fi
      if build_spoof_enabled_for_target; then verifier_args+=(--target build --target build_version); fi
      if framework_driver_needed; then
        verifier_args+=(--require-driver)
      fi
      if system_server_hook_needed; then verifier_args+=(--require-advanced-policy); fi
      python3 "$FINAL_HOOK_VERIFIER" "${verifier_args[@]}"
      ;;
    services)
      python3 "$FINAL_HOOK_VERIFIER" "${verifier_args[@]}"
      if is_enabled "$KAORIOS_ENABLE_HIDDEN_APP" || is_enabled "$KAORIOS_ENABLE_INSTALLER_SOURCE"; then
        local computer_engine
        computer_engine=$(find_target_file "$verify_smali" "com/android/server/pm/ComputerEngine.smali" "ComputerEngine") || return 1
        python3 "$MOD_ADAPTER" "$computer_engine" \
          --hidden-app "$KAORIOS_ENABLE_HIDDEN_APP" \
          --installer-source "$KAORIOS_ENABLE_INSTALLER_SOURCE" --check-only
      fi
      if system_server_hook_needed; then
        python3 "$SCRIPT_DIR/verify-systemserver-a17-hooks.py" "$verify_smali"
      fi
      if is_enabled "$KAORIOS_ENABLE_SECURE_FLAG"; then
        python3 "$SECURE_FLAG_PATCHER" "$verify_smali" --archive services --check-only
      fi
      ;;
    miui-services)
      python3 "$FINAL_HOOK_VERIFIER" "${verifier_args[@]}"
      python3 "$SECURE_FLAG_PATCHER" "$verify_smali" --archive miui-services --check-only
      ;;
    *) error "KAORIOS: unsupported verification kind: $kind"; return 1 ;;
  esac
  info "KAORIOS: verified final $kind candidate"
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

  snapshot_hashes "$smali" "$snapshot"

  patch_selected_targets "$kind" "$smali"
  rebuild_changed_dexes "$smali" "$snapshot" "$built"

  if [[ "$kind" == "framework" ]] && framework_driver_needed; then
    local driver_name
    driver_name=$(next_dex_name "$raw")
    cp -f "$DRIVER_DEX" "$built/$driver_name"
    info "KAORIOS: framework driver staged as $driver_name"
  fi

  update_archive_dexes "$artifact" "$built" "$candidate"
  verify_candidate "$candidate" "$kind"

  cp -f "$candidate" "$artifact"
  info "KAORIOS: installed patched $kind artifact"
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

integrate_advanced_policy_selinux() {
  python3 "$ADVANCED_POLICY_SELINUX" \
    --images "$work_dir/build/baserom/images" \
    --report-dir "$work_dir/build/reports/kaorios/advanced-policy-selinux"
  info "KAORIOS: AdvancedPolicy SELinux service contract integrated"
}

mods "Kaorios Toolbox upstream 2.0.6.1 integration (CorePatch is a separate preceding pass)"

info "KAORIOS config: ActivityThread=$KAORIOS_ENABLE_ACTIVITY_THREAD, Instrumentation=$KAORIOS_ENABLE_INSTRUMENTATION, Keybox=$KAORIOS_ENABLE_KEYBOX"
info "KAORIOS config: SystemFeature=$KAORIOS_ENABLE_SYSTEM_FEATURE_SPOOF, SystemServer=$KAORIOS_ENABLE_SYSTEM_SERVER, HiddenApp=$KAORIOS_ENABLE_HIDDEN_APP"
info "KAORIOS config: InstallerSource=$KAORIOS_ENABLE_INSTALLER_SOURCE, DevStatus=$KAORIOS_ENABLE_DEVSTATUS"
info "KAORIOS config: BuildSpoof=$KAORIOS_ENABLE_BUILD_SPOOF (A17 only), Toolbox=$KAORIOS_INSTALL_TOOLBOX"
info "KAORIOS config: SecureFlag=$KAORIOS_ENABLE_SECURE_FLAG, CorePatch=$KAORIOS_ENABLE_COREPATCH (separate preceding pass)"

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

if is_enabled "$KAORIOS_INSTALL_TOOLBOX"; then
  install_toolbox
fi

if system_server_hook_needed; then
  integrate_advanced_policy_selinux
fi

if ! archive_patch_needed && ! is_enabled "$KAORIOS_INSTALL_TOOLBOX"; then
  info "KAORIOS: all feature switches are OFF; nothing to do"
fi

mods "Kaorios Toolbox done with selected config"
