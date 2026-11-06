work_dir=$(pwd)
source $work_dir/functions.sh

phase "System patch stage"
target_dir="$work_dir/bin/package/"

# Kaorios Toolbox is the only CorePatch provider. The retired HyperMOS
# COREPATCH package must not be reintroduced as a separate static pass.
kaorios_config="$target_dir/KAORIOS_TOOLBOX/config.json"
kaorios_mod="$target_dir/KAORIOS_TOOLBOX/mod/kaorios_mod.py"
if [[ -v KAORIOS_MASTER ]]; then
  kaorios_enabled_value="$KAORIOS_MASTER"
else
  kaorios_enabled_value=$(python3 "$kaorios_mod" config "$kaorios_config" --get enabled) || exit 1
fi
case "${kaorios_enabled_value,,}" in
  1|true|yes|on) kaorios_enabled=1 ;;
  0|false|no|off) kaorios_enabled=0 ;;
  *) error "KAORIOS: invalid enabled boolean: $kaorios_enabled_value"; exit 1 ;;
esac
info "PATCH 1/4: AVB"
bash "$target_dir/DISABLE_AVB/DISABLEavb.sh" || exit 1
info "PATCH 2/4: Notification fix"
bash "$target_dir/NOTIFICATION_FIX/notificationFIX.sh" || exit 1

# The KAORIOS_TOOLBOX package is the sole CorePatch implementation.
info "PATCH 3/4: Kaorios Toolbox (bundled CorePatch)"
if ! bash "$target_dir/KAORIOS_TOOLBOX/patch.sh"; then
  error "KAORIOS: patch failed; aborting package stage"
  exit 1
fi

# TNM owns mandatory post-fs property reporting and China-mandatory App
# Privacy. On EU/other, TNM preserves the previous compatibility-gated opt-out.
# Android 17 uses SELinux permissionx nlmsg. Ubuntu 24.04's secilc does
# not support it, including when compiling *unmodified* platform CIL.
# Build upstream secilc/libsepol from checksum-pinned sources once, then
# continue normal TNM/Kaorios policy verification without disabling checks.
android_version="$(tr -d ' \\r\\n' < "$work_dir/bin/ddevice/androidver.txt")"
if [[ "$android_version" == "17" ]]; then
  info "TNM: preparing Android 17 SELinux compiler with nlmsg support"
  bash "$target_dir/TNM/install_secilc_a17.sh" || {
    error "TNM: failed to prepare verified Android 17 SELinux compiler"
    exit 1
  }
  export PATH="/usr/local/bin:$PATH"
  export HYPERMOS_SECILC_BIN="/usr/local/bin/secilc"
fi
info "PATCH 4/4: TNM (post-fs + China-mandatory App Privacy)"
bash "$target_dir/TNM/patch.sh" || exit 1

# TNM also edits split policy. Re-check the Kaorios service contract against
# the final combined policy and reject stale precompiled policy caches.
if [[ -v KAORIOS_ENABLE_SYSTEM_SERVER ]]; then
  kaorios_system_server_value="$KAORIOS_ENABLE_SYSTEM_SERVER"
else
  kaorios_system_server_value=$(python3 "$kaorios_mod" config "$kaorios_config" | \
    awk -F= '$1 == "KAORIOS_ENABLE_SYSTEM_SERVER" { print $2; exit }') || exit 1
fi
case "${kaorios_system_server_value,,}" in
  1|true|yes|on) kaorios_system_server_enabled=1 ;;
  0|false|no|off) kaorios_system_server_enabled=0 ;;
  *) error "KAORIOS: invalid SystemServer boolean: $kaorios_system_server_value"; exit 1 ;;
esac
if [[ "$kaorios_enabled" == "1" && "$kaorios_system_server_enabled" == "1" ]]; then
  # Install the managed policy block after TNM (which also edits split
  # policy) before verifying it: a check-only run here would fail with
  # "absent or duplicated" whenever no earlier stage installed the block.
  # The integrate step is idempotent (it replaces an existing managed
  # block instead of duplicating it) and deletes stale precompiled caches.
  python3 "$kaorios_mod" selinux \
    --images "$work_dir/build/baserom/images" \
    --report-dir "$work_dir/build/reports/kaorios/advanced-policy-selinux" || exit 1
  python3 "$kaorios_mod" selinux \
    --images "$work_dir/build/baserom/images" \
    --report-dir "$work_dir/build/reports/kaorios/advanced-policy-selinux-final" \
    --check || exit 1
fi


# Keep Kaorios output unmodified by MiCTS. MiCTS is only an APK
# installed separately through Universal/downloadapp on Android 16.

ok "System patch stage completed"

