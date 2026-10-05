#!/usr/bin/env bash
set -euo pipefail

# HyperMOS integration for Kaorios Toolbox v2.0.6.0.
# Intentionally DOES NOT implement Kaorios FLAG_SECURE or CorePatch.
# HyperMOS owns those patches already.
#
# Applied Kaorios features (per the upstream Patch_Guide_2.0.6.0_VI):
#   - process/context initialisation (ActivityThread + Instrumentation);
#   - Play Integrity / keybox keystore hooks;
#   - ApplicationPackageManager.hasSystemFeature(...) spoof;
#   - SystemServer initialisation;
#   - ComputerEngine package visibility + installer-source hooks;
#   - SettingsProvider.call()/query() per-app Settings spoof;
#   - Settings$NameValueCache dev-status hook (hide Developer options / ADB);
#   - Android 17 Build / Build$VERSION spoof (Android 17 only, like upstream).
# Skipped on purpose: FLAG_SECURE, CorePatch, and SELinux policy mutation.
# The upstream AdvancedPolicy SELinux checker is kept for diagnostics only.

work_dir=$(pwd)
source "$work_dir/functions.sh"

KAORIOS_DIR="$work_dir/bin/package/KAORIOS_TOOLBOX"
SCRIPT_DIR="$KAORIOS_DIR/script"
PATCHER="$SCRIPT_DIR/kaorios_patcher.py"
BAKSMALI="$work_dir/bin/apktool/baksmaliv2.jar"
SMALI="$work_dir/bin/apktool/smaliv2.jar"
DRIVER_DEX="$KAORIOS_DIR/classes.dex"
TOOLBOX_APK="$KAORIOS_DIR/KaoriosToolbox.apk"
PERMISSION_XML="$KAORIOS_DIR/app/com.kousei.kaorios.xml"
VALIDATE_KEYBOX="$SCRIPT_DIR/validate_keybox.py"
DEVSTATUS_PATCHER="$SCRIPT_DIR/patch-settings-namevaluecache.py"
BUILD_SPOOF_VERIFIER="$SCRIPT_DIR/verify-build-spoof-a17.py"
CONFIG="$KAORIOS_DIR/config.sh"

if [[ ! -f "$CONFIG" ]]; then
  error "KAORIOS: missing config: $CONFIG"
  exit 1
fi
# shellcheck source=/dev/null
source "$CONFIG"

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
  KAORIOS_ENABLE_SETTINGS_SPOOF \
  KAORIOS_ENABLE_DEVSTATUS \
  KAORIOS_ENABLE_BUILD_SPOOF \
  KAORIOS_INSTALL_TOOLBOX \
  KAORIOS_VALIDATE_KEYBOX \
  KAORIOS_DEVSTATUS_STRICT; do
  validate_bool "$flag"
done

if ! is_enabled "$KAORIOS_MASTER"; then
  mods "Kaorios Toolbox disabled by config"
  exit 0
fi

export KAORIOS_ENABLE_HIDDEN_APP KAORIOS_ENABLE_INSTALLER_SOURCE

framework_callsite_features_enabled() {
  is_enabled "$KAORIOS_ENABLE_ACTIVITY_THREAD" ||
  is_enabled "$KAORIOS_ENABLE_INSTRUMENTATION" ||
  is_enabled "$KAORIOS_ENABLE_KEYBOX" ||
  is_enabled "$KAORIOS_ENABLE_SYSTEM_FEATURE_SPOOF"
}

services_features_enabled() {
  is_enabled "$KAORIOS_ENABLE_SYSTEM_SERVER" ||
  is_enabled "$KAORIOS_ENABLE_HIDDEN_APP" ||
  is_enabled "$KAORIOS_ENABLE_INSTALLER_SOURCE"
}

framework_driver_needed() {
  framework_callsite_features_enabled ||
  services_features_enabled ||
  is_enabled "$KAORIOS_ENABLE_SETTINGS_SPOOF" ||
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
  services_features_enabled ||
  is_enabled "$KAORIOS_ENABLE_SETTINGS_SPOOF"
}

# Pin the payloads currently reviewed in this repository.
DRIVER_GIT_BLOB="1544b86b8703d03c43244d5599eaf180b59441fd"
TOOLBOX_GIT_BLOB="671ac1357400a54adfc442c58496bd69e1d4d60c"

# Set to 1 once the dev-status hook is confirmed present in the framework smali,
# so final artifact verification knows whether that target must be checked.
NVC_APPLIED=0

ANDROID_VER=$(tr -d ' \r\n' < "$work_dir/bin/ddevice/androidver.txt")
SDK_LEVEL=$(tr -d ' \r\n' < "$work_dir/bin/ddevice/sdkLevel.txt")

case "$ANDROID_VER" in
  13|14|15|16|17) ;;
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
  require_file "$DEVSTATUS_PATCHER" "dev-status patcher"
fi
if build_spoof_enabled_for_target; then
  require_file "$BUILD_SPOOF_VERIFIER" "Build spoof verifier"
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

if framework_driver_needed; then
  verify_git_blob "$DRIVER_DEX" "$DRIVER_GIT_BLOB" "framework DEX"
fi
if is_enabled "$KAORIOS_INSTALL_TOOLBOX"; then
  verify_git_blob "$TOOLBOX_APK" "$TOOLBOX_GIT_BLOB" "Toolbox APK"
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
  if is_enabled "$KAORIOS_ENABLE_SYSTEM_SERVER"; then
    require_one_target "$root" "com/android/server/SystemServer.smali" "SystemServer"
  fi
}

require_settings_targets() {
  local root="$1"
  if is_enabled "$KAORIOS_ENABLE_SETTINGS_SPOOF"; then
    require_one_target "$root" "com/android/providers/settings/SettingsProvider.smali" "SettingsProvider"
  fi
}

find_target_file() {
  local root="$1" rel="$2" label="$3" file
  require_one_target "$root" "$rel" "$label" || return 1
  file=$(find "$root" -type f -path "*/$rel" -print -quit)
  printf '%s\n' "$file"
}

patch_target_file() {
  local root="$1" rel="$2" label="$3" mode="${4:-1}" file
  file=$(find_target_file "$root" "$rel" "$label") || return 1
  if ! python3 "$PATCHER" "$file" --android-version "$ANDROID_VER" --mode "$mode" --no-delay; then
    error "KAORIOS: patcher failed for $label"
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
        patch_target_file "$root" "com/android/server/pm/ComputerEngine.smali" "ComputerEngine" 1
      fi
      if is_enabled "$KAORIOS_ENABLE_SYSTEM_SERVER"; then
        patch_target_file "$root" "com/android/server/SystemServer.smali" "SystemServer" 1
      fi
      ;;
    settings)
      if is_enabled "$KAORIOS_ENABLE_SETTINGS_SPOOF"; then
        patch_target_file "$root" "com/android/providers/settings/SettingsProvider.smali" "SettingsProvider" 1
      fi
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
    python3 "$DEVSTATUS_PATCHER" "$root" --strict || rc=$?
  else
    python3 "$DEVSTATUS_PATCHER" "$root" || rc=$?
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

verify_framework_final() {
  local root="$1"
  require_framework_targets "$root"
  verify_hook "$root" "android/app/ActivityThread.smali"     'KaoriosHook;->initActivityThread(Ljava/lang/Object;)V' "ActivityThread init"
  verify_hook "$root" "android/app/Instrumentation.smali"     'KaoriosHook;->initContext(Landroid/content/Context;)V' "Instrumentation initContext"
  verify_hook "$root" "android/app/ApplicationPackageManager.smali"     'KaoriosHook;->hasSystemFeature(Ljava/lang/String;I)Ljava/lang/Boolean;' "system feature spoof"
  verify_hook "$root" "android/security/keystore2/AndroidKeyStoreKeyPairGeneratorSpi.smali"     'KaoriosHook;->initGenerateSoftwareKeyPair' "Play Integrity/keybox keypair hook"
  verify_hook "$root" "android/security/keystore2/AndroidKeyStoreSpi.smali"     'KaoriosHook;->CertificateChainIfNeeded' "Play Integrity/keybox certificate hook"

  require_one_target "$root" "android/security/kaorios/KaoriosHook.smali" "KaoriosHook framework driver"
  verify_hook "$root" "android/security/kaorios/KaoriosHook.smali" \
    'initGenerateSoftwareKeyPair(Ljava/lang/Object;)Ljava/security/KeyPair;' "driver keypair implementation"
  verify_hook "$root" "android/security/kaorios/KaoriosHook.smali" \
    'CertificateChainIfNeeded([Ljava/security/cert/Certificate;)[Ljava/security/cert/Certificate;' "driver certificate implementation"
  verify_hook "$root" "android/security/kaorios/KaoriosHook.smali" \
    'hasSystemFeature(Ljava/lang/String;I)Ljava/lang/Boolean;' "driver system-feature implementation"
  verify_hook "$root" "android/security/kaorios/KaoriosHook.smali" \
    'filterSettingsCall(Ljava/lang/String;Ljava/lang/String;)Landroid/os/Bundle;' "driver Settings call implementation"
  verify_hook "$root" "android/security/kaorios/KaoriosHook.smali" \
    'filterSettingsQueryResult(Landroid/database/Cursor;Landroid/net/Uri;Ljava/lang/String;[Ljava/lang/String;)Landroid/database/Cursor;' "driver Settings query implementation"
  verify_hook "$root" "android/security/kaorios/KaoriosHook.smali" \
    'initSystemServer()V' "driver SystemServer implementation"
  verify_hook "$root" "android/security/kaorios/KaoriosHook.smali" \
    'shouldHideAppListForCaller(ILjava/lang/String;I)Z' "driver app-visibility implementation"
  verify_hook "$root" "android/security/kaorios/KaoriosHook.smali" \
    'shouldHideDevStatusFromNameValueCache(Landroid/content/ContentResolver;Ljava/lang/String;I)Z' "driver dev-status implementation"

  # AdvancedPolicy Binder payload is only required by the Android 17 path.
  # Android 13-16 still verify the caller/callee hooks, but must not fail just
  # because the pinned v2.0.6.0 driver omits AdvancedPolicyService/Snapshot.
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
    info "KAORIOS: framework hook verifier passed (AdvancedPolicy check skipped on Android $ANDROID_VER)"
  fi

  # Android 17 is the only generation with the Kaorios Build spoof.
  if [[ "$ANDROID_VER" == "17" ]]; then
    python3 "$BUILD_SPOOF_VERIFIER" "$root" >/dev/null || {
      error "KAORIOS: final verification failed: Android 17 Build spoof"
      return 1
    }
    info "KAORIOS: Android 17 Build/Build\$VERSION spoof verified"
  fi

  # Only assert the dev-status hook when this build actually injected it.
  if (( NVC_APPLIED == 1 )); then
    python3 "$DEVSTATUS_PATCHER" "$root" --verify-only --verify-roundtrip >/dev/null || {
      error "KAORIOS: final verification failed: dev-status (Developer options/ADB) hook"
      return 1
    }
    info "KAORIOS: dev-status (Developer options/ADB) hook verified"
  fi

  info "KAORIOS: framework hooks verified (Play Integrity/keybox + system feature spoof)"
}

verify_services_final() {
  local root="$1"
  require_services_targets "$root"
  verify_hook "$root" "com/android/server/pm/ComputerEngine.smali"     'KaoriosHook;->shouldHideAppListForCaller' "ComputerEngine app visibility"
  verify_hook "$root" "com/android/server/SystemServer.smali"     'KaoriosHook;->initSystemServer()V' "SystemServer init"
  python3 "$SCRIPT_DIR/verify-services-a17-hooks.py" "$root" >/dev/null || {
    error "KAORIOS: final verification failed: services hook verifier"
    return 1
  }
  python3 "$SCRIPT_DIR/verify-systemserver-a17-hooks.py" "$root" >/dev/null || {
    error "KAORIOS: final verification failed: SystemServer hook verifier"
    return 1
  }
  info "KAORIOS: services hooks verified"
}

verify_settings_final() {
  local root="$1" file
  require_settings_targets "$root"
  file=$(find "$root" -type f -path '*/com/android/providers/settings/SettingsProvider.smali' -print -quit)
  grep -Fq -- 'KaoriosHook;->filterSettingsCall' "$file" || {
    error "KAORIOS: SettingsProvider call() spoof hook missing"
    return 1
  }
  if grep -Fq -- 'query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;' "$file"; then
    grep -Fq -- 'KaoriosHook;->filterSettingsQueryResult' "$file" || {
      error "KAORIOS: SettingsProvider query() exists but query spoof hook is missing"
      return 1
    }
  fi
  python3 "$SCRIPT_DIR/verify-settingsprovider-a17-hooks.py" "$root" >/dev/null || {
    error "KAORIOS: final verification failed: SettingsProvider hook verifier"
    return 1
  }
  info "KAORIOS: Settings spoof hooks verified"
}

verify_candidate() {
  local candidate="$1" kind="$2" root="$3"
  local raw="$root/verify-raw" smali="$root/verify-smali"
  extract_all_dex "$candidate" "$raw"
  disassemble_all "$raw" "$smali"
  case "$kind" in
    framework) verify_framework_final "$smali" ;;
    services) verify_services_final "$smali" ;;
    settings) verify_settings_final "$smali" ;;
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
      ensure_no_existing_driver "$smali"
      ;;
    services) require_services_targets "$smali" ;;
    settings) require_settings_targets "$smali" ;;
  esac

  snapshot_hashes "$smali" "$snapshot"

  # mode 3 = hooks + Build spoof (Android 17 only). Every other artifact and
  # generation uses mode 1 (hooks only); the Build spoof starts at Android 17.
  local patch_mode=1
  if [[ "$kind" == "framework" && "$ANDROID_VER" == "17" ]]; then
    patch_mode=3
    info "KAORIOS: Android 17 framework - applying hooks + Build spoof (mode 3)"
  fi

  if ! python3 "$PATCHER" "$smali" --android-version "$ANDROID_VER" --mode "$patch_mode" --no-delay; then
    error "KAORIOS: patcher failed for $kind"
    return 1
  fi

  # Optional per-app "hide Developer options / ADB" hook. Runs before the DEX
  # rebuild so the modified file is assembled into the artifact.
  if [[ "$kind" == "framework" ]]; then
    apply_devstatus_patch "$smali" || return 1
  fi

  rebuild_changed_dexes "$smali" "$snapshot" "$built"

  if [[ "$kind" == "framework" ]]; then
    local driver_name
    driver_name=$(next_dex_name "$raw")
    cp -f "$DRIVER_DEX" "$built/$driver_name"
    info "KAORIOS: framework driver staged as $driver_name"
  fi

  update_archive_dexes "$artifact" "$built" "$candidate"
  verify_candidate "$candidate" "$kind" "$root"

  cp -f "$candidate" "$artifact"
  info "KAORIOS: installed verified $kind artifact"
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

mods "Kaorios Toolbox v2.0.6.0 (hooks + keybox + Settings/feature spoof + hide Developer options; HyperMOS owns FLAG_SECURE/CorePatch)"

FRAMEWORK_JAR=$(find_unique_artifact   "framework.jar"   "$work_dir/build/baserom/images/system/system/framework/framework.jar")
SERVICES_JAR=$(find_unique_artifact   "services.jar"   "$work_dir/build/baserom/images/system/system/framework/services.jar")
SETTINGS_PROVIDER=$(find_unique_artifact "SettingsProvider.apk" "")

validate_optional_keybox_input

patch_archive "$FRAMEWORK_JAR" framework
patch_archive "$SERVICES_JAR" services
patch_archive "$SETTINGS_PROVIDER" settings
install_toolbox

mods "Kaorios Toolbox done: Play Integrity/keybox hooks + Settings spoof + system feature spoof + hide Developer options/ADB"
