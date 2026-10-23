work_dir=$(pwd)
source $work_dir/functions.sh

phase "System patch stage"
target_dir="$work_dir/bin/package/"

# HyperMOS and Kaorios CorePatch run separately. HyperMOS owns only its
# non-overlapping Xiaomi patches; Kaorios owns signature/downgrade and Secure Flag.
# shellcheck source=/dev/null
source "$target_dir/KAORIOS_TOOLBOX/config.sh"
case "${KAORIOS_ENABLE_COREPATCH,,}" in
  1|true|yes|on) kaorios_corepatch=1 ;;
  0|false|no|off) kaorios_corepatch=0 ;;
  *) error "KAORIOS: invalid boolean KAORIOS_ENABLE_COREPATCH=$KAORIOS_ENABLE_COREPATCH"; exit 1 ;;
esac
hypermos_corepatch_args=()
if [[ "$kaorios_corepatch" == "1" ]]; then
  hypermos_corepatch_args+=(--kaorios)
fi
# FrameworkPatcher A16 CN handles 4 ProcessPolicy gates: ContentCatcher=false
# and 3 RYU=true; do not consume a source read before notification stage.
# Standalone CorePatch and Global builds retain their original behavior.
info "PATCH 1/6: HyperMOS CorePatch (non-overlapping patches)"
# China defers its ProcessPolicy gate to NOTIFICATION_FIX/FrameworkPatcher.
# Xiaomi.eu skips that stage and preserves its existing Gboard / notification / ProcessPolicy code.
rom_source_file="$work_dir/bin/ddevice/rom_source.txt"
if [[ -s "$rom_source_file" ]] &&
   [[ "$(tr -d '\r\n' < "$rom_source_file")" == "xiaomi_eu" ]]; then
  HYPERMOS_DEFER_A16_CN_PROCESSPOLICY=0 \
  HYPERMOS_PRESERVE_EU_FRAMEWORK=1 \
    bash "$target_dir/COREPATCH/update.sh" "${hypermos_corepatch_args[@]}" || exit 1
else
  HYPERMOS_DEFER_A16_CN_PROCESSPOLICY=1 \
    bash "$target_dir/COREPATCH/update.sh" "${hypermos_corepatch_args[@]}" || exit 1
fi
info "PATCH 2/6: AVB"
bash "$target_dir/DISABLE_AVB/DISABLEavb.sh" || exit 1
info "PATCH 3/6: Notification fix"
bash "$target_dir/NOTIFICATION_FIX/notificationFIX.sh" || exit 1

# Kaorios CorePatch sees the completed HyperMOS/notification state and owns all
# signature/downgrade methods that were disabled in the first CorePatch pass.
info "PATCH 4/6: Kaorios CorePatch (signature / downgrade)"
if [[ "$kaorios_corepatch" == "1" ]]; then
  bash "$target_dir/KAORIOS_TOOLBOX/mod/corepatch.sh" || exit 1
else
  info "KAORIOS CorePatch disabled by KAORIOS_ENABLE_COREPATCH"
fi

# Toolbox hooks and Secure Flag run after Kaorios CorePatch.
info "PATCH 5/6: Kaorios Toolbox"
if ! bash "$target_dir/KAORIOS_TOOLBOX/patch.sh"; then
  error "KAORIOS: patch failed; aborting package stage"
  exit 1
fi

# TNM owns mandatory post-fs property reporting and China-mandatory App
# Privacy. On EU/other, TNM preserves the previous compatibility-gated opt-out.
info "PATCH 6/6: TNM (post-fs + China-mandatory App Privacy)"
bash "$target_dir/TNM/patch.sh" || exit 1


# Keep CorePatch / Kaorios output unmodified by MiCTS. MiCTS is only an APK
# installed separately through Universal/downloadapp on Android 16.

ok "System patch stage completed"

