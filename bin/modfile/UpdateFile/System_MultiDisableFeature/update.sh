work_dir=$(pwd)
source $work_dir/functions.sh
rom_os=$(cat $work_dir/bin/ddevice/rom_os.txt)
regionTYPE=$(cat $work_dir/bin/ddevice/device_type.txt)
androidVER=$(cat $work_dir/bin/ddevice/androidver.txt)
# EU keeps its existing values when no change is needed; China behavior is unchanged.
rom_source_file="$work_dir/bin/ddevice/rom_source.txt"
rom_source=""
if [[ -s "$rom_source_file" ]]; then
    rom_source="$(tr -d '\r\n' < "$rom_source_file")"
fi
BuildProp1="$work_dir/build/baserom/images/system/system/build.prop"
BuildProp2="$work_dir/build/baserom/images/product/etc/build.prop"
BuildProp3="$work_dir/build/baserom/images/system_ext/etc/build.prop"
BuildProp4="$work_dir/build/baserom/images/vendor/build.prop"


disable_memory_extenstion() {
    mods "Disable Memory Ext"
    BuildProp1="$work_dir/build/baserom/images/system/system/build.prop"
	BuildProp2="$work_dir/build/baserom/images/product/etc/build.prop"
	BuildProp3="$work_dir/build/baserom/images/system_ext/etc/build.prop"
	BuildProp4="$work_dir/build/baserom/images/vendor/build.prop"
    sed -i "s/persist.miui.extm.enable=1/persist.miui.extm.enable=0/g" $BuildProp1
	sed -i "s/persist.miui.extm.enable=1/persist.miui.extm.enable=0/g" $BuildProp2
	sed -i "s/persist.miui.extm.enable=1/persist.miui.extm.enable=0/g" $BuildProp3
	sed -i "s/persist.miui.extm.enable=1/persist.miui.extm.enable=0/g" $BuildProp4
}

disable_privapp_control_enforce () {
    mods "Disable priv-app control enforce"
    BuildProp1="$work_dir/build/baserom/images/system/system/build.prop"
	BuildProp2="$work_dir/build/baserom/images/product/etc/build.prop"
	BuildProp3="$work_dir/build/baserom/images/system_ext/etc/build.prop"
	BuildProp4="$work_dir/build/baserom/images/vendor/build.prop"
	sed -i "s/ro.control_privapp_permissions=enforce/ro.control_privapp_permissions=/g" $BuildProp1
	sed -i "s/ro.control_privapp_permissions=enforce/ro.control_privapp_permissions=/g" $BuildProp2
	sed -i "s/ro.control_privapp_permissions=enforce/ro.control_privapp_permissions=/g" $BuildProp3
    sed -i "s/ro.control_privapp_permissions=enforce/ro.control_privapp_permissions=/g" $BuildProp4
}

disable_privapp_control_disable () {
    mods "Disable priv-app control disable"
    BuildProp1="$work_dir/build/baserom/images/system/system/build.prop"
	BuildProp2="$work_dir/build/baserom/images/product/etc/build.prop"
	BuildProp3="$work_dir/build/baserom/images/system_ext/etc/build.prop"
	BuildProp4="$work_dir/build/baserom/images/vendor/build.prop"
	sed -i "s/ro.control_privapp_permissions=disable/ro.control_privapp_permissions=/g" $BuildProp1
	sed -i "s/ro.control_privapp_permissions=disable/ro.control_privapp_permissions=/g" $BuildProp2
	sed -i "s/ro.control_privapp_permissions=disable/ro.control_privapp_permissions=/g" $BuildProp3
    sed -i "s/ro.control_privapp_permissions=disable/ro.control_privapp_permissions=/g" $BuildProp4
}

# Remove over volume alert
echo "audio.safemedia.bypass=true" >> build/baserom/images/product/etc/build.prop
echo "audio.safemedia.force=false" >> build/baserom/images/product/etc/build.prop
echo "audio.safemedia.csd.force=false" >> build/baserom/images/product/etc/build.prop

recoveryimg="$work_dir/build/baserom/images/recovery.img"
if [ -f $recoveryimg ]; then
 rm -rf $recoveryimg
else
 mods "No Found recovery.img!Skipping..."
fi

fix_themereset() {
    InitRC1=$(find $work_dir/build/baserom/images -type f -name "init.rc")
    mods "Fix theme reset"
    sed -i '/on boot/a\'$'\n''    chmod 0731 \/data\/system\/theme' $InitRC1
    mods "Done"
}

# Avoid rewriting stock Xiaomi.eu prop files when these operations are no-ops.
# Future EU versions with a matching value still receive the requested patch.
eu_has_prop_value() {
    local needle="$1" prop
    for prop in "$BuildProp1" "$BuildProp2" "$BuildProp3" "$BuildProp4"; do
        if [[ -f "$prop" ]] && grep -Fxq -- "$needle" "$prop"; then
            return 0
        fi
    done
    return 1
}

if [[ "$rom_source" != "xiaomi_eu" ]] || eu_has_prop_value 'persist.miui.extm.enable=1'; then
    disable_memory_extenstion
else
    mods "EU: Memory Extension already disabled/absent; skip build.prop rewrite"
fi

if [[ "$rom_source" != "xiaomi_eu" ]] || eu_has_prop_value 'ro.control_privapp_permissions=enforce'; then
    disable_privapp_control_enforce
else
    mods "EU: no priv-app enforce setting; skip build.prop rewrite"
fi

if [[ "$rom_source" != "xiaomi_eu" ]] || eu_has_prop_value 'ro.control_privapp_permissions=disable'; then
    disable_privapp_control_disable
else
    mods "EU: no priv-app disable setting; skip build.prop rewrite"
fi

fix_themereset