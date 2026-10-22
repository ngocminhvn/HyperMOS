work_dir=$(pwd)
source $work_dir/functions.sh

phase "System patch stage"
target_dir="$work_dir/bin/package/"

# CorePatch owns only the build-time signature bypass. The Kaorios MOD layer
# exclusively owns the static Secure Flag implementation.
# shellcheck source=/dev/null
source "$target_dir/KAORIOS_TOOLBOX/config.sh"
case "${KAORIOS_ENABLE_COREPATCH,,}" in
  1|true|yes|on) export COREPATCH_DISABLE_SIGNATURE_VERIFICATION=1 ;;
  0|false|no|off) export COREPATCH_DISABLE_SIGNATURE_VERIFICATION=0 ;;
  *) error "KAORIOS: invalid boolean KAORIOS_ENABLE_COREPATCH=$KAORIOS_ENABLE_COREPATCH"; exit 1 ;;
esac
# FrameworkPatcher A16 CN handles 4 ProcessPolicy gates: ContentCatcher=false
# and 3 RYU=true; do not consume a source read before notification stage.
# Standalone CorePatch and Global builds retain their original behavior.
info "PATCH 1/6: CorePatch / signature"
# China defers its ProcessPolicy gate to NOTIFICATION_FIX/FrameworkPatcher.
# Xiaomi.eu skips that stage and preserves its existing Gboard / notification / ProcessPolicy code.
rom_source_file="$work_dir/bin/ddevice/rom_source.txt"
if [[ -s "$rom_source_file" ]] &&
   [[ "$(tr -d '\r\n' < "$rom_source_file")" == "xiaomi_eu" ]]; then
  HYPERMOS_DEFER_A16_CN_PROCESSPOLICY=0 \
  HYPERMOS_PRESERVE_EU_FRAMEWORK=1 \
    bash "$target_dir/COREPATCH/update.sh" || exit 1
else
  HYPERMOS_DEFER_A16_CN_PROCESSPOLICY=1 bash "$target_dir/COREPATCH/update.sh" || exit 1
fi
info "PATCH 2/6: AVB"
bash "$target_dir/DISABLE_AVB/DISABLEavb.sh" || exit 1
info "PATCH 3/6: LOCK TNM post-fs integration"
bash "$target_dir/LOCK/update.sh" || exit 1
info "PATCH 4/6: Notification fix"
bash "$target_dir/NOTIFICATION_FIX/notificationFIX.sh" || exit 1

# Kaorios must see the framework/services state from the patches above.
# It adds static FLAG_SECURE bypasses while CorePatch handles signatures.
info "PATCH 5/6: Kaorios Toolbox"
if ! bash "$target_dir/KAORIOS_TOOLBOX/patch.sh"; then
  error "KAORIOS: patch failed; aborting package stage"
  exit 1
fi

# Enabled by default. The patcher still skips unsupported layouts before changing
# framework.jar. Set TNM_ENABLE_APP_PRIVACY=0 only for an explicit opt-out build.
info "PATCH 6/6: TNM App Privacy (compatibility-gated)"
if [[ "${TNM_ENABLE_APP_PRIVACY:-1}" == "1" ]]; then
  bash "$target_dir/TNM/patch.sh" || exit 1
else
  info "TNM App Privacy: disabled explicitly with TNM_ENABLE_APP_PRIVACY=0"
fi


# Keep CorePatch / Kaorios output unmodified by MiCTS. MiCTS is only an APK
# installed separately through Universal/downloadapp on Android 16.

ok "System patch stage completed"

