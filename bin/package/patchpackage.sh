work_dir=$(pwd)
source $work_dir/functions.sh

phase "System patch stage"
target_dir="$work_dir/bin/package/"

# HyperMOS owns signature/CorePatch/FLAG_SECURE first.
# In this full ROM pipeline FrameworkPatcher A16 CN will apply all four
# ProcessPolicy international-build gates. Avoid letting CorePatch consume one
# of those source reads before the notification stage.
# Standalone CorePatch and Global builds retain their original behavior.
info "PATCH 1/5: CorePatch / signature"
HYPERMOS_DEFER_A16_CN_PROCESSPOLICY=1 bash "$target_dir/COREPATCH/update.sh" || exit 1
info "PATCH 2/5: AVB"
bash "$target_dir/DISABLE_AVB/DISABLEavb.sh" || exit 1
info "PATCH 3/5: LOCK TNM post-fs integration"
bash "$target_dir/LOCK/update.sh" || exit 1
info "PATCH 4/5: Notification"
bash $target_dir/NOTIFICATION_FIX/notificationFIX.sh || exit 1

# Kaorios must see the final framework/services state from the patches above.
# It only adds Kaorios hooks; it does not duplicate FLAG_SECURE/CorePatch.
info "PATCH 5/5: Kaorios Toolbox"
if ! bash "$target_dir/KAORIOS_TOOLBOX/patch.sh"; then
  error "KAORIOS: patch failed; aborting package stage"
  exit 1
fi


# MiCTS works on the tested #63 base without CTS_NATIVE framework/launcher patching.
# Keep stock framework/MiuiHome behavior here to avoid unnecessary CTS hooks.

ok "System patch stage completed"

