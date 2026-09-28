#!/bin/bash
# Dừng script ngay lập tức nếu có bất kỳ lệnh nào bị lỗi
set -e 

# ==========================================
# Tích hợp YouTube Morphe (j-hc module)
# ==========================================
work_dir=$(pwd) 
source $work_dir/functions.sh
YT_MORPHE_DIR="$work_dir/bin/modfile/Universal/YouTubeMorphe"
Morphe_ZIP="$YT_MORPHE_DIR/YTMorphe_module.zip"
TMP_Morphe="$YT_MORPHE_DIR/Morphe_tmp"

# Khai báo đường dẫn đến công cụ trong thư mục bin/apktool
APKTOOL_JAR="$work_dir/bin/apktool/apktool.jar"
APKSIGNER_JAR="$work_dir/bin/apktool/apksigner.jar"

# Cấu hình versionCode muốn thay đổi (Bạn hãy sửa con số này)
NEW_VERSION_CODE="2147483647" 

# Tìm đúng root của phân vùng product sau khi ROM được extract.
# Payload ROM của Xiaomi thường nằm trực tiếp ở images/product/.
ROM_PRODUCT_DIR=""
for candidate in \
    "$work_dir/build/baserom/images/product" \
    "$work_dir/build/baserom/images/product/product" \
    "$work_dir/build/baserom/images/system/system/product"
do
    if [[ -d "$candidate" ]]; then
        ROM_PRODUCT_DIR="$candidate"
        break
    fi
done

if [[ -z "$ROM_PRODUCT_DIR" ]]; then
    error "Could not locate the product partition root."
    exit 1
fi

info "Product partition root: $ROM_PRODUCT_DIR"

# ==========================================
# Tự động tìm và tải YTMorphe_module.zip
# ==========================================
mkdir -p "$YT_MORPHE_DIR"
mods "Fetching the latest YouTube module from j-hc/revanced-magisk-module..."

# Lấy danh sách các bản releases gần đây, lọc link có chứa "youtube-morphe-module" và ".zip", lấy kết quả mới nhất
LATEST_URL=$(curl -fsSL --retry 4 --retry-delay 3 \
    "https://api.github.com/repos/j-hc/revanced-magisk-module/releases?per_page=20" \
    | jq -r '[.[].assets[]? | select(.name | test("^youtube-morphe-module-.*\\.zip$"; "i")) | .browser_download_url][0] // empty')

if [[ -n "$LATEST_URL" ]]; then
    info "Found matching release: $LATEST_URL"
    info "Downloading..."
    rm -f "$Morphe_ZIP"
    curl -fL --retry 4 --retry-delay 3 --connect-timeout 30 -o "$Morphe_ZIP" "$LATEST_URL"
else
    error "Could not find any recent release containing the YouTube Morphe module."
    exit 1 
fi
# ==========================================

mods "Integrating YouTube Morphe..."

if [[ -f "$Morphe_ZIP" ]]; then
    # Dọn dẹp thư mục tạm cũ nếu có
    rm -rf "$TMP_Morphe" && mkdir -p "$TMP_Morphe"
    
    # Kiểm tra ZIP trước khi giải nén. Module j-hc root phải có base.apk và stock/base.apk.
    if ! unzip -l "$Morphe_ZIP" | grep -qE '(^|[[:space:]])base\.apk
    if [[ -f "$TMP_Morphe/base.apk" && -d "$TMP_Morphe/stock" ]]; then
         YT_DIR="$ROM_PRODUCT_DIR/app/YouTube"
         mkdir -p "$YT_DIR"
         
         # 1. Copy toàn bộ file gốc từ thư mục stock
         cp -rf "$TMP_Morphe/stock/"*.apk "$YT_DIR/"
         
         # ==========================================
         # BẮT ĐẦU QUY TRÌNH CHỈNH SỬA VÀ KÝ APK
         # ==========================================
         info "Decompiling base.apk using apktool..."
         java -jar "$APKTOOL_JAR" d "$TMP_Morphe/base.apk" -o "$TMP_Morphe/base_decoded" -f
         
         info "Modifying versionCode in AndroidManifest.xml..."
         # Sử dụng sed để thay thế chuỗi versionCode cũ bằng giá trị mới
         sed -i -E 's/android:versionCode="[0-9]+"/android:versionCode="'"$NEW_VERSION_CODE"'"/g' "$TMP_Morphe/base_decoded/AndroidManifest.xml"
         
         info "Recompiling modified APK..."
         java -jar "$APKTOOL_JAR" b "$TMP_Morphe/base_decoded" -o "$TMP_Morphe/base_rebuilt.apk"
         
         info "Generating temporary keystore and signing APK..."
         KEYSTORE="$TMP_Morphe/temp.keystore"
         # Tạo một keystore tạm thời bằng keytool để phục vụ cho apksigner
         keytool -genkey -v -keystore "$KEYSTORE" -alias tempalias -keyalg RSA -keysize 2048 -validity 10000 -storepass password -keypass password -dname "CN=Android, O=Android, C=US" >/dev/null 2>&1
         
         # Ký APK bằng apksigner
         java -jar "$APKSIGNER_JAR" sign --ks "$KEYSTORE" --ks-pass pass:password "$TMP_Morphe/base_rebuilt.apk"
         # ==========================================
         
         # 2. Ghi đè file base_rebuilt.apk (đã sửa mã và ký) vào thư mục đích
         cp -rf "$TMP_Morphe/base_rebuilt.apk" "$YT_DIR/base.apk"
         
         # 3. Trích xuất native libs từ app gốc (arm64-v8a)
         mkdir -p "$YT_DIR/lib/arm64"
         unzip -q -j "$TMP_Morphe/stock/base.apk" "lib/arm64-v8a/*" -d "$YT_DIR/lib/arm64/" 2>/dev/null || true
         
         info "YouTube Morphe integrated into $YT_DIR with updated versionCode."
    else
         error "Invalid Morphe module structure (missing base.apk or stock/ folder)"
         exit 1 
    fi
    
    # Dọn dẹp sau khi build xong
    rm -rf "$TMP_Morphe"
else
    error "Morphe_module.zip not found, integration failed."
    exit 1
fi
 || \
       ! unzip -l "$Morphe_ZIP" | grep -qE 'stock/base\.apk
    if [[ -f "$TMP_Morphe/base.apk" && -d "$TMP_Morphe/stock" ]]; then
         YT_DIR="$ROM_PRODUCT_DIR/app/YouTube"
         mkdir -p "$YT_DIR"
         
         # 1. Copy toàn bộ file gốc từ thư mục stock
         cp -rf "$TMP_Morphe/stock/"*.apk "$YT_DIR/"
         
         # ==========================================
         # BẮT ĐẦU QUY TRÌNH CHỈNH SỬA VÀ KÝ APK
         # ==========================================
         info "Decompiling base.apk using apktool..."
         java -jar "$APKTOOL_JAR" d "$TMP_Morphe/base.apk" -o "$TMP_Morphe/base_decoded" -f
         
         info "Modifying versionCode in AndroidManifest.xml..."
         # Sử dụng sed để thay thế chuỗi versionCode cũ bằng giá trị mới
         sed -i -E 's/android:versionCode="[0-9]+"/android:versionCode="'"$NEW_VERSION_CODE"'"/g' "$TMP_Morphe/base_decoded/AndroidManifest.xml"
         
         info "Recompiling modified APK..."
         java -jar "$APKTOOL_JAR" b "$TMP_Morphe/base_decoded" -o "$TMP_Morphe/base_rebuilt.apk"
         
         info "Generating temporary keystore and signing APK..."
         KEYSTORE="$TMP_Morphe/temp.keystore"
         # Tạo một keystore tạm thời bằng keytool để phục vụ cho apksigner
         keytool -genkey -v -keystore "$KEYSTORE" -alias tempalias -keyalg RSA -keysize 2048 -validity 10000 -storepass password -keypass password -dname "CN=Android, O=Android, C=US" >/dev/null 2>&1
         
         # Ký APK bằng apksigner
         java -jar "$APKSIGNER_JAR" sign --ks "$KEYSTORE" --ks-pass pass:password "$TMP_Morphe/base_rebuilt.apk"
         # ==========================================
         
         # 2. Ghi đè file base_rebuilt.apk (đã sửa mã và ký) vào thư mục đích
         cp -rf "$TMP_Morphe/base_rebuilt.apk" "$YT_DIR/base.apk"
         
         # 3. Trích xuất native libs từ app gốc (arm64-v8a)
         mkdir -p "$YT_DIR/lib/arm64"
         unzip -q -j "$TMP_Morphe/stock/base.apk" "lib/arm64-v8a/*" -d "$YT_DIR/lib/arm64/" 2>/dev/null || true
         
         info "YouTube Morphe integrated into $YT_DIR with updated versionCode."
    else
         error "Invalid Morphe module structure (missing base.apk or stock/ folder)"
         exit 1 
    fi
    
    # Dọn dẹp sau khi build xong
    rm -rf "$TMP_Morphe"
else
    error "Morphe_module.zip not found, integration failed."
    exit 1
fi
; then
         error "Downloaded Morphe ZIP does not contain the expected root-module structure."
         exit 1
    fi

    # Giải nén module
    unzip -q "$Morphe_ZIP" -d "$TMP_Morphe"

    # Kiểm tra cấu trúc module
    if [[ -f "$TMP_Morphe/base.apk" && -d "$TMP_Morphe/stock" ]]; then
         YT_DIR="$ROM_PRODUCT_DIR/app/YouTube"
         mkdir -p "$YT_DIR"
         
         # 1. Copy toàn bộ file gốc từ thư mục stock
         cp -rf "$TMP_Morphe/stock/"*.apk "$YT_DIR/"
         
         # ==========================================
         # BẮT ĐẦU QUY TRÌNH CHỈNH SỬA VÀ KÝ APK
         # ==========================================
         info "Decompiling base.apk using apktool..."
         java -jar "$APKTOOL_JAR" d "$TMP_Morphe/base.apk" -o "$TMP_Morphe/base_decoded" -f
         
         info "Modifying versionCode in AndroidManifest.xml..."
         # Sử dụng sed để thay thế chuỗi versionCode cũ bằng giá trị mới
         sed -i -E 's/android:versionCode="[0-9]+"/android:versionCode="'"$NEW_VERSION_CODE"'"/g' "$TMP_Morphe/base_decoded/AndroidManifest.xml"
         
         info "Recompiling modified APK..."
         java -jar "$APKTOOL_JAR" b "$TMP_Morphe/base_decoded" -o "$TMP_Morphe/base_rebuilt.apk"
         
         info "Generating temporary keystore and signing APK..."
         KEYSTORE="$TMP_Morphe/temp.keystore"
         # Tạo một keystore tạm thời bằng keytool để phục vụ cho apksigner
         keytool -genkey -v -keystore "$KEYSTORE" -alias tempalias -keyalg RSA -keysize 2048 -validity 10000 -storepass password -keypass password -dname "CN=Android, O=Android, C=US" >/dev/null 2>&1
         
         # Ký APK bằng apksigner
         java -jar "$APKSIGNER_JAR" sign --ks "$KEYSTORE" --ks-pass pass:password "$TMP_Morphe/base_rebuilt.apk"
         # ==========================================
         
         # 2. Ghi đè file base_rebuilt.apk (đã sửa mã và ký) vào thư mục đích
         cp -rf "$TMP_Morphe/base_rebuilt.apk" "$YT_DIR/base.apk"
         
         # 3. Trích xuất native libs từ app gốc (arm64-v8a)
         mkdir -p "$YT_DIR/lib/arm64"
         unzip -q -j "$TMP_Morphe/stock/base.apk" "lib/arm64-v8a/*" -d "$YT_DIR/lib/arm64/" 2>/dev/null || true
         
         info "YouTube Morphe integrated into $YT_DIR with updated versionCode."
    else
         error "Invalid Morphe module structure (missing base.apk or stock/ folder)"
         exit 1 
    fi
    
    # Dọn dẹp sau khi build xong
    rm -rf "$TMP_Morphe"
else
    error "Morphe_module.zip not found, integration failed."
    exit 1
fi
