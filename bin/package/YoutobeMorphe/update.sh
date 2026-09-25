#!/bin/bash
# Dừng script ngay lập tức nếu có bất kỳ lệnh nào bị lỗi
set -e 

# ==========================================
# Tích hợp YouTube Morphe (j-hc module)
# ==========================================
work_dir=$(pwd) 
source $work_dir/functions.sh
YT_MORPHE_DIR="$work_dir/bin/package/YoutobeMorphe"
Morphe_ZIP="$YT_MORPHE_DIR/YTMorphe_module.zip"
TMP_Morphe="$YT_MORPHE_DIR/Morphe_tmp"

# Khai báo đường dẫn đến công cụ trong thư mục bin/apktool
APKTOOL_JAR="$work_dir/bin/apktool/apktool.jar"
APKSIGNER_JAR="$work_dir/bin/apktool/apksigner.jar"

# Cấu hình versionCode muốn thay đổi (Bạn hãy sửa con số này)
NEW_VERSION_CODE="2147483647" 

# Kiểm tra phân vùng product của ROM (độc lập hoặc gộp trong system)
if [[ -d "$work_dir/build/baserom/images/product/product" ]]; then
    ROM_PRODUCT_DIR="$work_dir/build/baserom/images/product/product"
elif [[ -d "$work_dir/build/baserom/images/product" && ! -L "$work_dir/build/baserom/images/product" ]]; then
    ROM_PRODUCT_DIR="$work_dir/build/baserom/images/product"
else
    # Fallback an toàn: bỏ qua symlink 'product' và cài trực tiếp vào system
    ROM_PRODUCT_DIR="$work_dir/build/baserom/images/system/system"
fi

# ==========================================
# Tự động tìm và tải YTMorphe_module.zip
# ==========================================
mkdir -p "$YT_MORPHE_DIR"
mods "Fetching the latest YouTube module from j-hc/revanced-magisk-module..."

# Lấy danh sách các bản releases gần đây, lọc link có chứa "youtube-morphe-module" và ".zip", lấy kết quả mới nhất
LATEST_URL=$(curl -s https://api.github.com/repos/j-hc/revanced-magisk-module/releases | grep "browser_download_url" | grep -i "youtube-morphe-module" | grep "\.zip" | head -n 1 | cut -d '"' -f 4)

if [[ -n "$LATEST_URL" ]]; then
    info "Found matching release: $LATEST_URL"
    info "Downloading..."
    curl -f -L -o "$Morphe_ZIP" "$LATEST_URL"
else
    error "Could not find any recent release containing the YouTube Morphe module."
    exit 1 
fi
# ==========================================

mods "Integrating YouTube Morphe..."

if [[ -f "$Morphe_ZIP" ]]; then
    # Dọn dẹp thư mục tạm cũ nếu có
    rm -rf "$TMP_Morphe" && mkdir -p "$TMP_Morphe"
    
    # Giải nén module
    unzip -q "$Morphe_ZIP" -d "$TMP_Morphe"

    # Kiểm tra cấu trúc module
    if [[ -f "$TMP_Morphe/base.apk" && -d "$TMP_Morphe/stock" ]]; then
         YT_DIR="$ROM_PRODUCT_DIR/app/YouTube"
         mkdir -p "$YT_DIR"
         
         # 1. Copy toàn bộ file gốc từ thư mục stock (gồm base.apk thô và tất cả các split_*.apk)
         cp -rf "$TMP_Morphe/stock/"*.apk "$YT_DIR/"
         
         # ==========================================
         # BẮT ĐẦU QUY TRÌNH CHỈNH SỬA
         # ==========================================
         info "Decompiling base.apk using apktool (Manifest only)..."
         # Thêm -s và -r để bỏ qua classes và res, tránh lỗi aapt2
         java -jar "$APKTOOL_JAR" d -s -r "$TMP_Morphe/base.apk" -o "$TMP_Morphe/base_decoded" -f
         
         info "Modifying versionCode in AndroidManifest.xml..."
         sed -i -E 's/android:versionCode="[0-9]+"/android:versionCode="'"$NEW_VERSION_CODE"'"/g' "$TMP_Morphe/base_decoded/AndroidManifest.xml"
         
         info "Recompiling modified APK..."
         # Đóng gói thành file tạm CHƯA CĂN LỀ
         java -jar "$APKTOOL_JAR" b "$TMP_Morphe/base_decoded" -o "$TMP_Morphe/base_unaligned.apk"
         
         info "Zipaligning APK..."
         # Căn lề 4-byte (zipalign) và ném thẳng vào thư mục đích (ghi đè lên base.apk thô lúc nãy)
         zipalign -p -f 4 "$TMP_Morphe/base_unaligned.apk" "$YT_DIR/base.apk"
         
         # ==========================================
         # BẮT ĐẦU QUY TRÌNH KÝ ĐỒNG LOẠT (SIGN)
         # ==========================================
         info "Generating temporary keystore and signing ALL APKs..."
         KEYSTORE="$TMP_Morphe/temp.keystore"
         
         # Tạo một keystore tạm thời
         keytool -genkey -v -keystore "$KEYSTORE" -alias tempalias -keyalg RSA -keysize 2048 -validity 10000 -storepass password -keypass password -dname "CN=Android, O=Android, C=US" >/dev/null 2>&1
         
         # Chạy vòng lặp để ký MỌI file .apk nằm trong thư mục đích (base.apk đã zipalign và toàn bộ split_*.apk)
         for apk_file in "$YT_DIR/"*.apk; do
             java -jar "$APKSIGNER_JAR" sign --ks "$KEYSTORE" --ks-pass pass:password "$apk_file"
         done
         # ==========================================
         
         # 3. Trích xuất native libs từ app gốc (arm64-v8a)
         mkdir -p "$YT_DIR/lib/arm64"
         unzip -q -j "$TMP_Morphe/stock/base.apk" "lib/arm64-v8a/*" -d "$YT_DIR/lib/arm64/" 2>/dev/null || true
         
         info "YouTube Morphe integrated, zipaligned, and ALL splits signed successfully."
    else
         error "Invalid Morphe module structure (missing base.apk or stock/ folder)"
         exit 1 
    fi
    
    # Dọn dẹp sau khi build xong
    rm -rf "$TMP_Morphe"
    echo "YouTube Morphe integration completed successfully."
else
    error "Morphe_module.zip not found, integration failed."
    exit 1
fi