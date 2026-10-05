work_dir=$(pwd)
source $work_dir/functions.sh

mods "Add Package..."
target_dir="$work_dir/bin/package/"

# HyperMOS owns signature/CorePatch/FLAG_SECURE first.
bash $target_dir/COREPATCH/update.sh
bash $target_dir/DISABLE_AVB/DISABLEavb.sh
bash $target_dir/NOTIFICATION_FIX/notificationFIX.sh

# Kaorios must see the final framework/services state from the patches above.
# It only adds Kaorios v2.0.6.0 hooks; it does not duplicate FLAG_SECURE/CorePatch.
if ! bash "$target_dir/KAORIOS_TOOLBOX/patch.sh"; then
  error "KAORIOS: patch failed; aborting package stage"
  exit 1
fi

bash $target_dir/RefreshRate/1hz.sh
if ! bash "$target_dir/ResetProp/update.sh"; then
  error "Fake Lock: validation or installation failed; aborting package stage"
  exit 1
fi
mods "Add Package Done"
