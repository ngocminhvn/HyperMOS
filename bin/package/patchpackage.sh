work_dir=$(pwd)
source $work_dir/functions.sh

phase "System patch stage"
target_dir="$work_dir/bin/package/"

# HyperMOS owns signature/CorePatch/FLAG_SECURE first.
# FrameworkPatcher A16 CN handles 4 ProcessPolicy gates: ContentCatcher=false
# and 3 RYU=true; do not consume a source read before notification stage.
# Standalone CorePatch and Global builds retain their original behavior.
info "PATCH 1/6: CorePatch / signature"
# China defers its ProcessPolicy gate to NOTIFICATION_FIX/FrameworkPatcher.
# Xiaomi.eu skips that stage, so CorePatch must handle its gate itself.
rom_source_file="$work_dir/bin/ddevice/rom_source.txt"
if [[ -s "$rom_source_file" ]] &&
   [[ "$(tr -d '\r\n' < "$rom_source_file")" == "xiaomi_eu" ]]; then
  info "EU: preserve original Gboard, NotificationFilterHelper and ProcessPolicy while applying CorePatch"
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
info "PATCH 4/6: Notification"
bash $target_dir/NOTIFICATION_FIX/notificationFIX.sh || exit 1

# Kaorios must see the final framework/services state from the patches above.
# It only adds Kaorios hooks; it does not duplicate FLAG_SECURE/CorePatch.
info "PATCH 5/6: Kaorios Toolbox"
if ! bash "$target_dir/KAORIOS_TOOLBOX/patch.sh"; then
  error "KAORIOS: patch failed; aborting package stage"
  exit 1
fi

# MiCTS patches services.jar DEX only; no app APKs or overlays.
info "PATCH 6/6: MiCTS native services.jar"
bash "$target_dir/MiCTS/update.sh" || exit 1

ok "System patch stage completed"

