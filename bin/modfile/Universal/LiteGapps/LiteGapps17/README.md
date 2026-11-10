# LiteGapps17 — Android 17 / API 37 / arm64 (China)

Chỉ chứa những file khác với A16. Những APK/XML/DER có nội dung giống nhau
nằm ở `../Gapps/`. Trình kiểm tra xác thực SHA-256 của 65 file hiệu lực
(gồm Gapps chung và dữ liệu riêng A17) theo `inventory.json`.

- **Loại Gmail và Maps APK**: không cài `PrebuiltGmail.apk` hoặc `Maps.apk`.
  Hai addon này vẫn được liệt kê trong `sources.json` làm lịch sử tải
  SourceForge; **không phải danh sách APK thực sự được cài vào ROM**.
- **Yêu cầu cả hai bản**: `GoogleVelvet_CTS.apk`, `Velvet.apk` và
  `com.google.android.maps.jar` lấy từ `../Gapps/`.
- `GoogleVelvet_CTS.apk` là **file gốc A16 được chia sẻ theo yêu cầu**, không
  phải APK CTS A17 trên SourceForge; SHA-256 được ghim vào trình kiểm tra.
  Tương thích và khả năng boot A17 **chưa được xác nhận**; dung lượng thêm
  khoảng 305 MB vào image so với bản A17 trước đó.
- `stage.py` chỉ dùng file Git LFS đã xác minh, xóa thư mục PrebuiltGmail
  nếu có từ ROM gốc, cài CTS/Velvet và chép Maps JAR tới
  `product/framework/com.google.android.maps.jar`.

Nguồn gốc gói A17 được ghi ở `sources.json` (Core 01/10/2026 + 12 addon
đã tải ở lần đồng bộ ban đầu), cùng checksum của bản đã giải nén ở
`inventory.json`.

```sh
git lfs pull
python3 bin/modfile/Universal/LiteGapps/validate.py 17
python3 bin/modfile/Universal/LiteGapps/LiteGapps17/stage.py --verify-repo
```

Chưa thử flash/boot trên ROM China Android 17. A16/A17 vẫn giữ GmsCore,
Phonesky, GSF và các XML có nội dung khác nhau ở thư mục riêng.
