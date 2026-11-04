# LiteGapps16 — Android 16 / arm64

Bộ GApps **đã tùy chỉnh** của HyperMOS dành cho ROM China Android 16.
Không dùng cho Android 17 hoặc Xiaomi.eu/Global. Giữ nguyên các APK/XML/JAR
hiện có; đây là bản có những khác biệt riêng, **không có manifest nguồn
SourceForge + SHA-256** để chứng minh toàn bộ file là bản gốc.

- Payload: `product/`, `system_ext/`, `maps/com.google.android.maps.jar`.
- `GoogleVelvet_CTS.apk`, `google-zk-permissions.xml` và các XML
  `preinstalled-packages-product-pixel-*` là khác biệt dành riêng A16.
- Không thêm Maps APK; dùng Maps framework JAR như trước.
- `update.sh` vẫn vá `MIUIFrequentPhrase.apk` (Enhanced Keyboard) theo
  cách hiện có ở Android 16. Không tự chuyển bản vá đó sang Android 17.
- `validate-sysconfig.py` giữ bộ kiểm tra cấu hình chuyên biệt A16.
- `litegapps_validate.py` dùng chung kiểm tra APK thật (không phải con trỏ
  Git LFS), XML hợp lệ và file bắt buộc, không ghi sửa dữ liệu.

Kiểm tra sau khi đã tải Git LFS:

```bash
python3 bin/modfile/Universal/litegapps_validate.py 16
python3 bin/modfile/Universal/LiteGapps16/validate-sysconfig.py
```

Bản A17 được đóng gói riêng từ SourceForge API 37 và giữ nguyên khác biệt
nền tảng; **không đồng bộ byte-for-byte giữa hai Android version**.
