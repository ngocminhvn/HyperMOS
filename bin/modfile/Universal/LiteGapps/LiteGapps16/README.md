# LiteGapps16 — Android 16 (China)

Dữ liệu dùng chung với A17 nằm ở `../Gapps/`. Thư mục này chỉ giữ
những APK/XML/JAR khác phiên bản, các tệp riêng Android 16 và script build.

- **Không cài Gmail**: `PrebuiltGmail.apk` đã được xóa khỏi `Gapps/`.
  `update.sh` cũng loại thư mục `product/app/PrebuiltGmail` nếu tồn tại trong ROM gốc.
- **Bắt buộc trên A16 và A17**: `GoogleVelvet_CTS.apk`, `Velvet.apk`
  (đều ở `../Gapps/product/priv-app/`) và `../Gapps/maps/com.google.android.maps.jar`.
- **Riêng A16**: GmsCore, Phonesky, GoogleServicesFramework, XML quyền/ZK,
  XML preinstall, và vá Enhanced Keyboard của `MIUIFrequentPhrase.apk`.
- Trình kiểm tra chung chặn thiếu CTS/Velvet/Maps JAR, Gmail xuất hiện trở lại,
  con trỏ Git LFS chưa hydrate hoặc APK/XML sai định dạng.

Kiểm tra:

```sh
python3 bin/modfile/Universal/LiteGapps/validate.py 16
python3 bin/modfile/Universal/LiteGapps/LiteGapps16/validate-sysconfig.py
```

Bản gốc A16 vẫn có một số XML tùy chỉnh HyperMOS; không tự mang qua A17.
