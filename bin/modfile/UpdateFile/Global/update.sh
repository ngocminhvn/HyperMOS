work_dir=$(pwd)
MAIN_FOLDER="$work_dir/build/baserom/images"
source $work_dir/functions.sh
device_code=$(cat $work_dir/bin/ddevice/device_f.txt)
regionTYPE=$(cat $work_dir/bin/ddevice/device_type.txt)
rom_os=$(cat $work_dir/bin/ddevice/rom_os.txt)
androidVER=$(cat $work_dir/bin/ddevice/androidver.txt)

if [[ $regionTYPE == *"Global"* ]]; then 
  #Adding Mods
  mods "Adding Some Mod For Global"
  rm -rf $work_dir/build/baserom/images/product/etc/precust_theme/theme/.data
  cp -rf $work_dir/bin/modfile/UpdateFile/Global/CircleToSearchOverlay.apk $work_dir/build/baserom/images/product/overlay/
  cp -rf $work_dir/bin/modfile/UpdateFile/Global/Gemini $work_dir/build/baserom/images/product/priv-app/
  cp -rf $work_dir/bin/modfile/UpdateFile/Global/MiuiCalendar $work_dir/build/baserom/images/product/priv-app/

  # Keep ColorOS Control Center clean on OS3: do not overlay MIUISystemUIPlugin.
  if [[ $rom_os == "OS3" ]]; then
    mods "OS3: skip Nothings.MiuiSystemUIPlugin overlay to avoid overriding ColorOS Control Center"
    rm -f $work_dir/build/baserom/images/product/overlay/Nothings.MiuiSystemUIPlugin.apk
  else
    cp -rf $work_dir/bin/modfile/UpdateFile/Global/Nothings.MiuiSystemUIPlugin.apk $work_dir/build/baserom/images/product/overlay/
  fi

  cp -rf $work_dir/bin/modfile/UpdateFile/Global/Nothings.MiuiSystemUI.apk $work_dir/build/baserom/images/product/overlay/
  cp -rf $work_dir/bin/modfile/UpdateFile/Global/Nothings.HyperPhoneSystemUI.apk $work_dir/build/baserom/images/product/overlay/
  #Fix icon
fi
