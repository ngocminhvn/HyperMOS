work_dir=$(pwd)
source $work_dir/functions.sh
tools_dir=${work_dir}/bin/$(uname)/$(uname -m)export PATH=$(pwd)/bin/$(uname)/$(uname -m)/:$PATH
super_list="vendor mi_ext odm odm_dlkm system system_dlkm vendor_dlkm product product_dlkm system_ext"
os_type=$(cat $work_dir/bin/ddevice/os_type.txt)
base_rom_code=$(cat $work_dir/bin/ddevice/base_rom_code.txt)
androidVER=$(cat $work_dir/bin/ddevice/androidver.txt)
rom_os=$(cat $work_dir/bin/ddevice/rom_os.txt)
regionTYPE=$(cat $work_dir/bin/ddevice/device_type.txt)
device_code=$(cat $work_dir/bin/ddevice/device_f.txt)
getvar=$(cat $work_dir/bin/ddevice/device_f.txt)
PACK_TYPE=$(cat $work_dir/bin/ddevice/fstype.txt)


if [[ $(git branch --show-current) == "beta" ]]; then
    polyxver="$(cat Version)"
	status="Development"
else
    polyxver="$(cat Version)"
	status="Official"
fi

if [[ $rom_os == "MIUI" ]];then
    os_type="MIUI"
else
    os_type="HyperOS"
fi

phase "4/4 Repack partitions and super image"

#Generate Super.img
superSize=$(bash $work_dir/bin/getSuperSize.sh $getvar)
repack $superSize
repack "Super image size: ${superSize}"
repack "Packing super.img"

# mkfs.erofs already uses CPU internally. Two concurrent partition packers
# are a better default on GitHub's 4-core hosted runner than four competing jobs.
PACK_JOBS="${PACK_JOBS:-2}"
if ! [[ "$PACK_JOBS" =~ ^[0-9]+$ ]] || [ "$PACK_JOBS" -lt 1 ]; then
    PACK_JOBS=1
fi
CPU_JOBS="$(nproc)"
if [ "$PACK_JOBS" -gt "$CPU_JOBS" ]; then
    PACK_JOBS="$CPU_JOBS"
fi
if [ "$PACK_JOBS" -gt 4 ]; then
    PACK_JOBS=4
fi

pack_partition() {
    local pname="$1"
    local part_dir="$work_dir/build/baserom/images/$pname"
    local config_dir="$work_dir/build/baserom/images/config"
    local thisSize
    local addSize

    [ -d "$part_dir" ] || return 0

    thisSize=$(du -sb "$part_dir" | awk '{print $1}')
    if [[ "$androidVER" == "12" ]]; then
        case "$pname" in
            odm) addSize=104217728 ;;
            system) addSize=114217728 ;;
            vendor) addSize=104217728 ;;
            system_ext) addSize=104217728 ;;
            product) addSize=104217728 ;;
            *) addSize=8054432 ;;
        esac
    else
        case "$pname" in
            mi_ext) addSize=100000000 ;;
            odm) addSize=100000000 ;;
            system) addSize=100000000 ;;
            vendor) addSize=100000000 ;;
            system_ext) addSize=100000000 ;;
            product) addSize=100000000 ;;
            *) addSize=8054432 ;;
        esac
    fi

    thisSize=$((thisSize + addSize))

    python3 "$work_dir/bin/fix_selinux.py"         "$part_dir"         "$config_dir/${pname}_fs_config"         "$config_dir/${pname}_file_contexts" >/dev/null 2>&1 || {
            error "SELinux config generation failed for [${pname}]"
            return 1
        }

    if [[ "$PACK_TYPE" == "EXT" ]]; then
        make_ext4fs -J -T "$(date +%s)"             -S "$config_dir/${pname}_file_contexts"             -l "$thisSize"             -C "$config_dir/${pname}_fs_config"             -L "$pname"             -a "$pname"             "$work_dir/build/baserom/images/${pname}.img"             "$part_dir" >/dev/null 2>&1 || {
                error "Packing [${pname}] as EXT failed"
                return 1
            }
    elif [[ "$PACK_TYPE" == "EROFS" ]]; then
        mkfs.erofs --quiet -zlz4hc,9             --mount-point "$pname"             --fs-config-file="$config_dir/${pname}_fs_config"             --file-contexts="$config_dir/${pname}_file_contexts"             "$work_dir/build/baserom/images/${pname}.img"             "$part_dir" >/dev/null 2>&1 || {
                error "Packing [${pname}] as EROFS failed"
                return 1
            }
    else
        error "Unable to handle filesystem type: $PACK_TYPE"
        return 1
    fi

    if [ -s "$work_dir/build/baserom/images/${pname}.img" ]; then
        repack "Packing [${pname}.img] success"
        return 0
    fi

    error "Packing [${pname}] failed: output image missing or empty"
    return 1
}

repack "Packing partitions with up to ${PACK_JOBS} parallel jobs"
pack_failed=0
running_jobs=0

for pname in ${super_list}; do
    if [ -d "$work_dir/build/baserom/images/$pname" ]; then
        pack_partition "$pname" &
        running_jobs=$((running_jobs + 1))

        if [ "$running_jobs" -ge "$PACK_JOBS" ]; then
            wait -n || pack_failed=1
            running_jobs=$((running_jobs - 1))
        fi
    fi
done

while [ "$running_jobs" -gt 0 ]; do
    wait -n || pack_failed=1
    running_jobs=$((running_jobs - 1))
done

if [ "$pack_failed" -ne 0 ]; then
    error "One or more partition repack jobs failed."
    exit 1
fi

# #99 contained an unsigned PowerKeeper which Android never registered.
# Verify the ACTUAL PowerKeeper bytes and APK V2/V3 signature inside the
# packed system_ext.img before creating super.img or uploading a ROM.
# Isolated RYU test branch only: this verification must fail closed.
if [[ "$androidVER" == "16" ]]; then
    repack "RYU PowerKeeper: verify signed APK inside packed system_ext.img"
    if ! bash "$work_dir/bin/package/NOTIFICATION_FIX/A16/verify_packed_powerkeeper.sh" \
        "$work_dir" "$PACK_TYPE"; then
        error "RYU PowerKeeper packed-image signature audit FAILED; stop ROM build"
        exit 1
    fi
    repack "RYU PowerKeeper: packed-image signature audit PASS"
fi

if grep -q "ro.build.ab_update=true" build/baserom/images/vendor/build.prop;  then
    is_ab_device=true
else
    is_ab_device=false

fi

# Pack super.img
if [[ "$is_ab_device" == false ]]; then
    repack "Packing super.img for A-only device"
    GROUP_SIZE=$((superSize - 268435456))   
    lpargs="-F --output build/baserom/images/super.img --metadata-size 65536 --super-name super --metadata-slots 2 --block-size 4096 --device super:$superSize --group=qti_dynamic_partitions:$GROUP_SIZE"
    
    for pname in ${super_list}; do
        if [ -f "build/baserom/images/${pname}.img" ]; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                subsize=$(stat -f%z "build/baserom/images/${pname}.img")
            else
                subsize=$(du -sb "build/baserom/images/${pname}.img" | awk '{print $1}')
            fi
            repack "Super sub-partition [$pname] size: [$subsize]"
            lpargs="$lpargs --partition ${pname}:readonly:${subsize}:qti_dynamic_partitions --image ${pname}=build/baserom/images/${pname}.img"
        fi
    done

else
    repack "Packing super.img for V-AB device"
    
    GROUP_SIZE=$((superSize - 268435456))   # 256MB margin - Fix for error -22
    
    lpargs="-F --sparse --virtual-ab --output $work_dir/build/baserom/images/super.img --metadata-size 65536 --super-name super --metadata-slots 3 --block-size 4096 --device super:$superSize --group=qti_dynamic_partitions_a:$GROUP_SIZE --group=qti_dynamic_partitions_b:$GROUP_SIZE"
    
    for pname in ${super_list}; do
        if [ -f "build/baserom/images/${pname}.img" ]; then
            subsize=$(du -sb "build/baserom/images/${pname}.img" | awk '{print $1}')
            repack "Super sub-partition [$pname] size: [$subsize]"
            lpargs="$lpargs --partition ${pname}_a:readonly:${subsize}:qti_dynamic_partitions_a --image ${pname}_a=build/baserom/images/${pname}.img --partition ${pname}_b:readonly:0:qti_dynamic_partitions_b"
        fi
    done
fi

# Run lpmake
if [[ "$lpargs" != *"--partition "* ]]; then
    repack "Error: No partitions to pack into super.img (Partition table must have at least one entry)."
    exit 1
fi
lpmake $lpargs

if [ -f "$work_dir/build/baserom/images/super.img" ]; then
    repack "Successfully packed super.img."
else
    repack "Unable to pack super.img."
    exit 1
fi

for pname in ${super_list}; do
    rm -rf "$work_dir/build/baserom/images/${pname}.img" 2>/dev/null
done

find "$work_dir/build" -exec touch -t 200901010000.00 {} + 2> /dev/null || true
ok "Partition and super image repack completed"