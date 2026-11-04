# LiteGapps — GApps chia sẻ giữa Android 16 và 17

```text
LiteGapps/
├── Gapps/                # APK/XML/DER dùng chung, GoogleVelvet_CTS, Velvet và Maps JAR
├── LiteGapps16/         # Chỉ phần riêng Android 16 + vá Enhanced Keyboard
├── LiteGapps17/         # Chỉ phần riêng Android 17 + manifest/checksum
├── validate.py          # Kiểm tra bắt buộc A16/A17
└── README.md
```

## Cấu trúc sau cập nhật

- **Gapps/**: 36 file dùng chung, gồm 34 file cùng nội dung giữa A16/A17,
  1 file `GoogleVelvet_CTS.apk` gốc A16 được chủ động chia sẻ cho A17,
  và 1 Maps framework JAR. `Velvet.apk` nằm ở đây.
- **LiteGapps16/**: 27 file payload riêng A16.
- **LiteGapps17/**: 30 file payload riêng A17.
- Mỗi ROM lấy `Gapps/` + một thư mục theo Android version.
  Các APK/XML khác nội dung không bị trộn giữa hai bản.

## Quy tắc bắt buộc

- **Không được có Gmail**: đã xóa `PrebuiltGmail.apk` khỏi repository;
  quá trình build còn xóa thư mục `product/app/PrebuiltGmail` của base ROM.
- **Bắt buộc cả A16 lẫn A17**: `GoogleVelvet_CTS.apk`, `Velvet.apk` và
  `com.google.android.maps.jar`. Hai APK ở `Gapps/product/priv-app/`,
  JAR ở `Gapps/maps/`, khi build đưa JAR vào `product/framework/`.
- CTS là **bản A16** được chia sẻ cho A17 theo yêu cầu: SHA-256
  `b8c5be9f1ffb22011fd9f393d0a871711c73e8a26bfffbee67da190e1728035f`.
  **Chưa xác minh CTS này có tương thích với Android 17 hay không.**
- Cấm Maps APK; chỉ dùng Maps JAR chung. Các nguồn Gmail/Maps trong
  `LiteGapps17/sources.json` là bản ghi nguồn ban đầu, không được cài.

Kiểm tra payload sau khi tải Git LFS:

```sh
python3 bin/modfile/Universal/LiteGapps/validate.py 16
python3 bin/modfile/Universal/LiteGapps/validate.py 17
```

Không thay đổi workflow build ROM hoặc điều kiện chỉ cài GApps lên China ROM.
