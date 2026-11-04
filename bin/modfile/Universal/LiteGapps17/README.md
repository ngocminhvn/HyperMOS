# LiteGapps17 — Android 17 / API 37 / arm64

Bộ GApps dành cho **China ROM Android 17**. Xiaomi.eu/Global được bỏ qua,
Android 16 dùng `LiteGapps16/` riêng. APK/JAR/XML/DER đã được lấy từ
SourceForge, kiểm tra SHA-256 và commit qua **Git LFS** tại `product/` và
`system_ext/`; ROM build **không tải lại ZIP**.

## Nguồn đã được đối chiếu

- Core (01/10/2026): https://sourceforge.net/projects/litegapps/files/litegapps/arm64/37/core/2026-10-01/
- Addon (API 37): https://sourceforge.net/projects/litegapps/files/addon/arm64/37/
- `sources.json`: đường dẫn và SHA-256 của 13 ZIP (Core + 12 addon).
- `inventory.json`: SHA-256 của **66 file được trích xuất** và mã băm
  `sources.json`. Cả danh sách được kiểm tra trước khi đưa file vào ROM.
- Các addon đã chọn: Common, GmsCore, GoogleServicesFramework, PlayStore,
  GoogleExtShared, ConfigUpdater, AndroidAuto, GoogleKeyboard, Gmail,
  GoogleSearch, Maps, GoogleDialer.

## Cách build và kiểm tra

```bash
# Phải checkout Git LFS trước, không dùng các file pointer 130 byte.
git lfs pull
python3 bin/modfile/Universal/litegapps_validate.py 17
python3 bin/modfile/Universal/LiteGapps17/stage.py --verify-repo
```

`update.sh` gọi `stage.py` để **chỉ** sao chép file đã có từ Git LFS
vào `build/baserom/images/`; không dùng mạng hoặc chạy installer Magisk.

**Khác biệt được giữ lại so với A16**: Maps APK thay vì maps JAR; A17 có
GoogleDialer/Calendar/Contacts Sync và SearchSelector, còn A16 có
`GoogleVelvet_CTS.apk`, ZK permissions, XML preinstall và vá
`MIUIFrequentPhrase.apk`. Không sao chép những thành phần riêng A16 vào A17.
Không dùng chung binary Android 16 để thay thế binary Android 17.

Workflow đồng bộ tạm thời đã được dọn sau khi Git LFS upload thành công.
Giữ `sources.json`, `inventory.json` để truy xuất nguồn gốc.
Khi cần cập nhật phiên bản GApps phải tạo manifest mới và xác thực các
file thực tế rồi mới chỉnh inventory, không ghi đè bằng bản A16.

Chưa kiểm chứng boot thực tế trên ROM China Android 17.
