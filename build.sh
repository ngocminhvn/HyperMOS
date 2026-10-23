baserom="$1"
repo_name="$2"
prefix_id="$3"
builder_id="$4"
work_dir=$(pwd)
# Import functions
tools_dir=${work_dir}/bin/$(uname)/$(uname -m)export PATH=$(pwd)/bin/$(uname)/$(uname -m)/:$PATH
chmod 777 ${work_dir}/bin/*
chmod 777 ${work_dir}/bin/Linux/x86_64/*
source $work_dir/functions.sh
if [[ $(git branch --show-current) == "beta" ]]; then
    polyxver="$(cat Version)"
	status="Development"
else
    polyxver="$(cat Version)"
	status="Official"
fi

check unzip aria2c 7z 7zz zip java zipalign python3 zstd bc xmlstarlet aapt

rm -rf $work_dir/out
rm -rf $work_dir/build

phase "1/4 Download and inspect base ROM"
python3 $work_dir/notify.py download "$repo_name" "$baserom" "$prefix_id" "$builder_id"
source "$work_dir/bin/ddevice/getROM.sh" "$baserom" || exit 1
rom_source="$(tr -d '\r\n' < "$work_dir/bin/ddevice/rom_source.txt")"
info "Detected ROM source: $rom_source"

phase "2/4 Extract base ROM"
python3 $work_dir/notify.py unpack "$repo_name" "$baserom" "$prefix_id" "$builder_id"
if unzip -l ${baserom} | grep -q "payload.bin"; then
    baserom_type="payload"
    echo $baserom_type > $work_dir/bin/ddevice/romtype.txt
    unpack "Found payload.bin file"
    super_list="vendor mi_ext odm odm_dlkm system system_dlkm vendor_dlkm product product_dlkm system_ext mi_product"
    unpack "ROM validation passed."
elif unzip -l ${baserom} | grep -q "br$";then
    baserom_type="br"
    echo $baserom_type > $work_dir/bin/ddevice/romtype.txt
    super_list="system vendor product odm system_ext mi_ext"
    unpack "Found broli file"
    unpack "ROM validation passed."
elif unzip -l ${baserom} | grep -q "images/super.img*"; then
    unpack "Found super.img.* files"
    is_base_rom_eu=true
    baserom_type="eu_super"
    echo "$baserom_type" > "$work_dir/bin/ddevice/romtype.txt"
    unpack "ROM validation passed."
else
    error "Unpack failed"
    exit 1
fi

rm -rf app
rm -rf tmp
rm -rf config
rm -rf build/baserom/
find . -type d -name 'miui_*' | xargs rm -rf

unpack "Files cleaned up."
mkdir -p build/baserom/images/

# Extract partitions
if [[ ${baserom_type} == 'payload' ]]; then
    unpack "Extracting files payload.bin..."
    unzip ${baserom} payload.bin -d build/baserom >/dev/null 2>&1 || error "Extracting payload.bin error"
    unpack "File payload.bin extracted."
elif [[ ${baserom_type} == 'br' ]];then
    unpack "Extracting files *.new.dat.br"
    unzip ${baserom} -d build/baserom >/dev/null 2>&1 || error "Extracting new.dat.br error"
    unpack "File new.dat.br extracted."
elif [[ "${is_base_rom_eu:-false}" == "true" ]]; then
    unpack "Extracting files from BASEROM [super.img]"
    if ! unzip "$baserom" 'images/*' -d build/baserom >/dev/null 2>&1; then
        error "EU: extracting fastboot images from ZIP failed"
        exit 1
    fi

    # GitHub Actions installs android-sdk-libsparse-utils (/usr/bin/simg2img).
    # The bundled bin/Linux/x86_64/simg2img takes PATH precedence but needs
    # libc++.so, which is absent on ubuntu-latest (build #162).
    simg2img_bin="/usr/bin/simg2img"
    if [[ ! -x "$simg2img_bin" ]]; then
        error "EU: system simg2img unavailable (install android-sdk-libsparse-utils)"
        exit 1
    fi

    # Enumerate numbered chunks in numeric order and require a complete run.
    mapfile -d '' -t super_chunks < <(
        find build/baserom/images -maxdepth 1 -type f \
            -regextype posix-extended -regex '.*/super\.img\.[0-9]+' -print0 |
            sort -zV
    )
    (( ${#super_chunks[@]} > 0 )) || {
        error "EU: no numbered super.img chunks extracted"
        exit 1
    }
    for index in "${!super_chunks[@]}"; do
        [[ "${super_chunks[$index]}" == "build/baserom/images/super.img.$index" ]] || {
            error "EU: missing or unordered super.img chunk $index"
            exit 1
        }
    done

    unpack "Converting ${#super_chunks[@]} sparse super.img chunks with system simg2img"
    raw_super="build/baserom/super.img"
    if ! "$simg2img_bin" "${super_chunks[@]}" "$raw_super" || [[ ! -s "$raw_super" ]]; then
        error "EU: failed to convert sparse super.img (no partial input will be removed)"
        exit 1
    fi
    rm -f -- "${super_chunks[@]}"
    unpack "[super.img] extracted."

    # Some fastboot packages also split cust.img; convert with the same
    # verified system tool and never delete chunks before success.
    if [[ -f build/baserom/images/cust.img.0 ]]; then
        mapfile -d '' -t cust_chunks < <(
            find build/baserom/images -maxdepth 1 -type f \
                -regextype posix-extended -regex '.*/cust\.img\.[0-9]+' -print0 |
                sort -zV
        )
        for index in "${!cust_chunks[@]}"; do
            [[ "${cust_chunks[$index]}" == "build/baserom/images/cust.img.$index" ]] || {
                error "EU: missing cust.img chunk $index"
                exit 1
            }
        done
        if ! "$simg2img_bin" "${cust_chunks[@]}" build/baserom/images/cust.img ||
           [[ ! -s build/baserom/images/cust.img ]]; then
            error "EU: failed to convert sparse cust.img"
            exit 1
        fi
        rm -f -- "${cust_chunks[@]}"
    fi
fi

if [[ ${baserom_type} == 'payload' ]]; then
    unpack "Unpacking payload.bin"
    payload-extract extract -o build/baserom/images/ build/baserom/payload.bin >/dev/null 2>&1 || error "Unpacking payload.bin failed"    
elif [[ ${baserom_type} == 'br' ]];then
    super_list=$(cat build/baserom/dynamic_partitions_op_list | grep "add " | awk '{ print $2 }')
    unpack "Unpacking new.dat.br"
        for brotlipart in ${super_list}; do 
            brotli -d build/baserom/$brotlipart.new.dat.br >/dev/null 2>&1
            python3 $work_dir/bin/Linux/x86_64/sdat2img.py build/baserom/$brotlipart.transfer.list build/baserom/$brotlipart.new.dat build/baserom/images/$brotlipart.img >/dev/null 2>&1
            rm -rf build/baserom/$brotlipart.new.dat* build/baserom/$brotlipart.transfer.list build/baserom/$brotlipart.patch.*
        done
elif [[ ${is_base_rom_eu} == true ]];then
    unpack "Unpacking BASEROM [super.img]"
    # lpunpack --info may output no JSON/table even for valid EU super metadata.
    # Read the actual liblp partition names, as verified in the EU audit action.
    eu_partition_list="$work_dir/build/baserom/eu-partitions.txt"
    python3 "$work_dir/bin/ddevice/list_super_partitions.py" \
        "$work_dir/bin/lpunpack.py" "$work_dir/build/baserom/super.img" \
        > "$eu_partition_list" || { error "EU: unable to read super partition metadata"; exit 1; }
    mapfile -t eu_partitions < "$eu_partition_list"
    (( ${#eu_partitions[@]} > 0 )) || { error "EU: no super partitions found"; exit 1; }
    super_list=""
    for i in "${eu_partitions[@]}"; do
        # Ignore inactive slot; preserve original partition names for the repacker.
        [[ "$i" != *_b ]] || continue
        part_name="${i%_a}"
        if [[ -f "build/baserom/images/${part_name}.img" ]]; then
            error "EU: duplicate logical partition $part_name"
            exit 1
        fi
        python3 "$work_dir/bin/lpunpack.py" -p "$i" \
            "$work_dir/build/baserom/super.img" "$work_dir/build/baserom/images" >/dev/null || {
                error "EU: failed extracting logical partition $i"
                exit 1
            }
        [[ -s "build/baserom/images/${i}.img" ]] || {
            error "EU: extracted $i is missing/empty"
            exit 1
        }
        if [[ "$i" != "$part_name" ]]; then
            mv "build/baserom/images/${i}.img" "build/baserom/images/${part_name}.img" || exit 1
        fi
        super_list="$super_list $part_name"
    done
    [[ -n "$super_list" ]] || { error "EU: no active super partitions"; exit 1; }
fi

for part in ${super_list}; do
    extract_partition $work_dir/build/baserom/images/${part}.img $work_dir/build/baserom/images
    PACK_TYPE=$(cat $work_dir/bin/ddevice/fstype.txt)
done
echo $device_f > $work_dir/bin/ddevice/device_f.txt
echo $device_f > $work_dir/bin/script2flash/META-INF/CNAME
getvar=$(cat $work_dir/bin/ddevice/device_f.txt)

rm -rf config

if [ -f $work_dir/${baserom}.zip ]; then
    rm -rf ${baserom}.zip
fi

rm -rf build/baserom/payload.bin
rm -rf build/baserom/images/super.img
if [[ "${is_base_rom_eu:-false}" == "true" ]]; then
    # Original super is no longer needed once its partitions are fully extracted.
    rm -f -- "$work_dir/build/baserom/super.img"
    info "EU: released raw source super.img after partition extraction"
fi

# Reclaim space after extracting an 8+ GiB Xiaomi.eu URL download.
# Never delete a user-supplied local ZIP.
if [[ "$rom_source" == "xiaomi_eu" && "${eu_rom_downloaded:-0}" == "1" ]]; then
    rm -f -- "$work_dir/$baserom"
    info "EU: removed downloaded source archive after successful extraction"
fi

phase "3/4 Apply HyperMOS modifications"
mods "Gathering device information"

bash $work_dir/bin/ddevice/fetchINFO.sh

android_version="$(tr -d ' \r\n' < "$work_dir/bin/ddevice/androidver.txt")"
case "$android_version" in
    15|16|17) ;;
    *)
        error "Unsupported Android version: $android_version (supported: 15, 16, 17)"
        exit 1
        ;;
esac

# Gửi thông báo đang Build với đầy đủ Codename và Version
python3 $work_dir/notify.py build "$repo_name" "$baserom" "$prefix_id" "$builder_id"

bash $work_dir/bin/ddevice/DEBLOAT/debloat.sh || exit 1
info "Done"

# Only Xiaomi.eu gets dedicated cleanup. Shared/China mod order is unchanged.
if [[ "$rom_source" == "xiaomi_eu" ]]; then
    bash "$work_dir/bin/modfile/EU/update.sh" || exit 1
fi

bash $work_dir/bin/modfile/ModApp/OS3/insmod.sh || exit 1
bash $work_dir/bin/modfile/Universal/insfile.sh || exit 1
bash $work_dir/bin/modfile/UpdateFile/insupdate.sh || exit 1
bash $work_dir/bin/package/patchpackage.sh || exit 1

if [[ "$rom_source" == "xiaomi_eu" ]]; then
    bash "$work_dir/bin/modfile/EU/verify.sh" || exit 1
fi

# Preserve vendor/ODM thermal and performance policy.
# Xiaomi.eu A16 carries the byte-exact Global303 PowerKeeper DEX, with all
# original EU APK non-DEX members and META-INF preserved (not re-signed).
if [[ "$rom_source" == "xiaomi_eu" && "$android_version" == "16" ]]; then
    info "EU A16: Global303 PowerKeeper DEX + original EU resources/META-INF, no signing"
fi

find "$work_dir/build/baserom/images/" -exec touch -t 200901010000.00 {} + 2> /dev/null || true
ok "ROM modification stage completed"

