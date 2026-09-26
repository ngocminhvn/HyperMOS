work_dir=$(pwd)
source $work_dir/functions.sh
RCLONE_CONFIG_GDRIVE="$work_dir/rclone.conf"
if [ -z "$RCLONE_TOKEN_PATH" ]; then
    echo "Lỗi: Không tìm thấy biến môi trường RCLONE_TOKEN_PATH!"
    exit 1
fi

echo "Đang tải rclone.conf từ Secret URL..."
curl -sL "$RCLONE_TOKEN_PATH" -o "$RCLONE_CONFIG_GDRIVE"

if [ ! -s "$RCLONE_CONFIG_GDRIVE" ]; then
    echo "Lỗi: Không thể tải rclone.conf!"
    exit 1
fi
GDRIVE_REMOTE="github"
GDRIVE_FOLDER="HyperOS_ROM" 
os_type=$(cat $work_dir/bin/ddevice/os_type.txt)
base_rom_code=$(cat $work_dir/bin/ddevice/base_rom_code.txt)
androidVER=$(cat $work_dir/bin/ddevice/androidver.txt)
rom_os=$(cat $work_dir/bin/ddevice/rom_os.txt)
regionTYPE=$(cat $work_dir/bin/ddevice/device_type.txt)
device_code=$(cat $work_dir/bin/ddevice/device_code.txt)
baserom_type=$(cat $work_dir/bin/ddevice/romtype.txt)
device_f=$(cat $work_dir/bin/ddevice/device_f.txt)


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

repack "Generating flashing script"
if [[ ${baserom_type} == 'payload' ]]; then
    mkdir -p $work_dir/out/${os_type}_${device_code}_${base_rom_code}/images/
    mkdir -p $work_dir/out/${os_type}_${device_code}_${base_rom_code}/super/
	mv -f $work_dir/build/baserom/images/super.img $work_dir/out/${os_type}_${device_code}_${base_rom_code}/super/
    mv -f $work_dir/build/baserom/images/*.img $work_dir/out/${os_type}_${device_code}_${base_rom_code}/images/
elif [[ ${baserom_type} == 'br' ]]; then
    mkdir -p $work_dir/out/${os_type}_${device_code}_${base_rom_code}/images/
    mv -f $work_dir/build/baserom/firmware-update/* $work_dir/out/${os_type}_${device_code}_${base_rom_code}/images/
    mv -f $work_dir/build/baserom/images/super.img $work_dir/out/${os_type}_${device_code}_${base_rom_code}/super/
fi

cp -rf $work_dir/bin/script2flash/cust.img $work_dir/out/${os_type}_${device_code}_${base_rom_code}/images/ 2>/dev/null || true
cp -rf $work_dir/bin/script2flash/*.install $work_dir/out/${os_type}_${device_code}_${base_rom_code}/

find out/${os_type}_${device_code}_${base_rom_code} |xargs touch
pushd out/${os_type}_${device_code}_${base_rom_code}/ || exit
zip -r ${os_type}_${device_code}_${base_rom_code}.zip ./*
mv ${os_type}_${device_code}_${base_rom_code}.zip ../
popd || exit
hash=$(md5sum out/${os_type}_${device_code}_${base_rom_code}.zip |head -c 5)
mv out/${os_type}_${device_code}_${base_rom_code}.zip out/${os_type}_${polyxver}_${device_code}_${base_rom_code}_${hash}_${status}.zip
repack "Build completed"    
repack "Output: "
repack "$(pwd)/out/${os_type}_${polyxver}_${device_code}_${base_rom_code}_${hash}_${status}.zip"
upload "Uploading"
output_file="out/${os_type}_${polyxver}_${device_code}_${base_rom_code}_${hash}_${status}.zip"
echo "${os_type}_${polyxver}_${device_code}_${base_rom_code}_${hash}_${status}.zip" > $work_dir/bin/ddevice/output_zip.txt

if [[ $rom_os == "MIUI" ]];then
    uploaddir="MIUI"
else
    uploaddir="HyperOS"
fi


rclone -v --config="$RCLONE_CONFIG_GDRIVE" copy "$output_file" "$GDRIVE_REMOTE:$GDRIVE_FOLDER/${uploaddir}/${polyxver}/${device_code}/" \
    --drive-chunk-size 128M \
    --tpslimit 4 \
    --retries 3 \
    --timeout 15m \
    --contimeout 15m || {
    upload "Lỗi khi upload file lên Google Drive!"
    exit 1
}
remote_file_path="$GDRIVE_REMOTE:$GDRIVE_FOLDER/${uploaddir}/${polyxver}/${device_code}/$(basename "$output_file")"
share_link=$(rclone --config="$RCLONE_CONFIG_GDRIVE" link "$remote_file_path")
mkdir -p bin/ddevice
echo "$share_link" > bin/ddevice/rom_link.txt

upload "Clean Workflow.."
rm -rf $work_dir/out
rm -rf $work_dir/build

upload "Build ${os_type}_${polyxver} for ${device_code} successfull!"