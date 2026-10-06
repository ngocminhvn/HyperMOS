work_dir=$(pwd)
source $work_dir/functions.sh

phase "System patch stage"
target_dir="$work_dir/bin/package/"

# HyperMOS owns signature/CorePatch/FLAG_SECURE first.
info "PATCH 1/6: CorePatch / signature"
bash $target_dir/COREPATCH/update.sh
info "PATCH 2/6: AVB"
bash "$target_dir/DISABLE_AVB/DISABLEavb.sh" || exit 1
info "PATCH 3/6: Notification"
bash $target_dir/NOTIFICATION_FIX/notificationFIX.sh

# Kaorios must see the final framework/services state from the patches above.
# It only adds Kaorios v2.0.6.0 hooks; it does not duplicate FLAG_SECURE/CorePatch.
info "PATCH 4/6: Kaorios Toolbox"
if ! bash "$target_dir/KAORIOS_TOOLBOX/patch.sh"; then
  error "KAORIOS: patch failed; aborting package stage"
  exit 1
fi

# FK_LOCK owns cross-partition identity normalization and the early runtime
# locked-state view. Keep it separate from Kaorios so it can be tested alone.
info "PATCH 5/6: FK_LOCK"
if ! bash "$target_dir/FK_LOCK/update.sh"; then
  error "FK_LOCK: validation or installation failed; aborting package stage"
  exit 1
fi

# MiCTS works on the tested #63 base without CTS_NATIVE framework/launcher patching.
# Keep stock framework/MiuiHome behavior here to avoid unnecessary CTS hooks.

info "PATCH 6/6: Refresh rate"
bash $target_dir/RefreshRate/1hz.sh
ok "System patch stage completed"
