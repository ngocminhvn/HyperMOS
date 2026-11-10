work_dir=$(pwd)
source $work_dir/functions.sh

phase "System patch stage"
target_dir="$work_dir/bin/package/"

# Only HyperMOS CorePatch runs; Kaorios CorePatch is not used. Kaorios keeps
# only its static Secure Flag bypass (KAORIOS_TOOLBOX/patch.sh).
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
# ContentExtension=false and floating-window extras apply to every ROM.
# FrameworkPatcher A16 CN alone handles its 4 coupled ProcessPolicy gates:
# ContentCatcher=false and 3 RYU=true, avoiding the historical 3/4 mismatch.
info "PATCH 1/5: HyperMOS CorePatch"
# China A16 defers only its coupled ProcessPolicy gate to FrameworkPatcher.
# Xiaomi.eu still preserves its other Gboard and regional policy variables.
rom_source_file="$work_dir/bin/ddevice/rom_source.txt"
if [[ -s "$rom_source_file" ]] &&
   [[ "$(tr -d '\r\n' < "$rom_source_file")" == "xiaomi_eu" ]]; then
  HYPERMOS_DEFER_A16_CN_PROCESSPOLICY=0 \
  HYPERMOS_PRESERVE_EU_FRAMEWORK=1 \
    bash "$target_dir/COREPATCH/update.sh" || exit 1
else
  HYPERMOS_DEFER_A16_CN_PROCESSPOLICY=1 \
    bash "$target_dir/COREPATCH/update.sh" || exit 1
fi
info "PATCH 2/5: AVB"
bash "$target_dir/DISABLE_AVB/DISABLEavb.sh" || exit 1
info "PATCH 3/5: Notification fix"
bash "$target_dir/NOTIFICATION_FIX/notificationFIX.sh" || exit 1

# Toolbox hooks and Secure Flag run after HyperMOS CorePatch.
info "PATCH 4/5: Kaorios Toolbox"
if ! bash "$target_dir/KAORIOS_TOOLBOX/patch.sh"; then
  error "KAORIOS: patch failed; aborting package stage"
  exit 1
fi

# TNM owns mandatory post-fs property reporting and China-mandatory App
# Privacy. On EU/other, TNM preserves the previous compatibility-gated opt-out.
info "PATCH 5/5: TNM (post-fs + China-mandatory App Privacy)"
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


# Keep CorePatch / Kaorios output unmodified by MiCTS. MiCTS is only an APK
# installed separately through Universal/downloadapp on Android 16.

ok "System patch stage completed"

