# LiteGapps17 — China ROM Android 17 / API 37 / arm64

**Thư mục này chỉ giữ phần khác biệt so với Android 16.**
Các tệp APK/XML/DER trùng byte và Maps framework JAR nằm trong `../Gapps/`.
Sau khi hợp nhất hai lớp, toàn bộ 65 file A17 vẫn được xác thực bằng SHA-256 theo `inventory.json`.

- `sources.json`: 13 ZIP SourceForge đã tải và xác minh trước đây (Core + 12 addon). Addon Maps được **lưu thông tin để truy xuất**, không cài Maps APK.
- `inventory.json`: 65 đường dẫn payload và SHA-256; những đường dẫn nằm ở `Gapps/` được tra cứu chung, những đường dẫn khác lấy từ `LiteGapps17/`.
- `stage.py`: xác minh đủ hai lớp, sao chép file vào ROM và dùng `Gapps/maps/com.google.android.maps.jar` cho `product/framework/`.
- `update.sh`: chỉ chạy trên China Android 17, không tải lại ZIP trong lúc build.

Nguồn: [Core A17 01/10/2026](https://sourceforge.net/projects/litegapps/files/litegapps/arm64/37/core/2026-10-01/), [addon API 37](https://sourceforge.net/projects/litegapps/files/addon/arm64/37/).

```bash
git lfs pull
python3 bin/modfile/Universal/LiteGapps/validate.py 17
python3 bin/modfile/Universal/LiteGapps/LiteGapps17/stage.py --verify-repo
```

Không lấy GmsCore/Phonesky/GSF hoặc XML riêng A16 làm nguồn A17. Không cài `Maps.apk`; chỉ dùng JAR framework Maps chung. Chưa kiểm chứng boot A17 thực tế.
