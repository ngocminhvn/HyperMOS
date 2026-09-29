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
    rm -rf "$TMP_Morphe"
    mkdir -p "$TMP_Morphe"

    # Validate the module layout before extraction.
    if ! unzip -l "$Morphe_ZIP" | grep -qE '(^|[[:space:]])base\.apk$' || \
       ! unzip -l "$Morphe_ZIP" | grep -qE '(^|[[:space:]])stock/base\.apk$'; then
        error "Downloaded Morphe ZIP does not contain the expected root-module structure."
        exit 1
    fi

    unzip -q "$Morphe_ZIP" -d "$TMP_Morphe"

    if [[ -f "$TMP_Morphe/base.apk" && -d "$TMP_Morphe/stock" ]]; then
        YT_DIR="$ROM_PRODUCT_DIR/app/YouTube"
        mkdir -p "$YT_DIR"

        # Keep the exact APK set produced by j-hc/Morphe.
        # Do NOT decode/rebuild resources: recent YouTube APKs contain MCC
        # qualifiers such as values-mcc1001 that older aapt/apktool rejects.
        cp -rf "$TMP_Morphe/stock/"*.apk "$YT_DIR/"
        cp -f "$TMP_Morphe/base.apk" "$YT_DIR/base.apk"

        # Sanity-check the patched base before repacking product.img.
        if ! aapt dump badging "$YT_DIR/base.apk" 2>/dev/null | head -n1 | grep -q "package: name='com.google.android.youtube'"; then
            error "Morphe base.apk is not a valid com.google.android.youtube package."
            exit 1
        fi

        MORPHE_VERSION=$(aapt dump badging "$YT_DIR/base.apk" 2>/dev/null | head -n1 | sed -n "s/.*versionName='\([^']*\)'.*/\1/p")
        info "Using upstream Morphe APK directly (version: ${MORPHE_VERSION:-unknown})."

        # Extract native libraries from the matching stock base.
        mkdir -p "$YT_DIR/lib/arm64"
        unzip -q -j "$TMP_Morphe/stock/base.apk" "lib/arm64-v8a/*" -d "$YT_DIR/lib/arm64/" 2>/dev/null || true

        info "YouTube Morphe integrated into $YT_DIR without apktool rebuild or re-signing."
    else
        error "Invalid Morphe module structure (missing base.apk or stock/ folder)"
        exit 1
    fi

    rm -rf "$TMP_Morphe"
else
    error "Morphe_module.zip not found, integration failed."
    exit 1
fi
