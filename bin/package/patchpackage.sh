work_dir=$(pwd)
source $work_dir/functions.sh

phase "System patch stage"
target_dir="$work_dir/bin/package/"

# HyperMOS owns signature/CorePatch/FLAG_SECURE first.
info "PATCH 1/5: CorePatch / signature"
bash $target_dir/COREPATCH/update.sh
info "PATCH 2/5: AVB"
bash "$target_dir/DISABLE_AVB/DISABLEavb.sh" || exit 1
info "PATCH 3/5: Notification"
bash $target_dir/NOTIFICATION_FIX/notificationFIX.sh

# Kaorios must see the final framework/services state from the patches above.
# It only adds Kaorios v2.0.6.0 hooks; it does not duplicate FLAG_SECURE/CorePatch.
info "PATCH 4/5: Kaorios Toolbox"
if ! bash "$target_dir/KAORIOS_TOOLBOX/patch.sh"; then
  error "KAORIOS: patch failed; aborting package stage"
  exit 1
fi

# MiCTS works on the tested #63 base without CTS_NATIVE framework/launcher patching.
# Keep stock framework/MiuiHome behavior here to avoid unnecessary CTS hooks.

info "PATCH 5/5: Refresh rate"
bash $target_dir/RefreshRate/1hz.sh
ok "System patch stage completed"
