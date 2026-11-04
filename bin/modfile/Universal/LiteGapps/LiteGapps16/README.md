# LiteGapps16 — China ROM Android 16

Dữ liệu dùng chung nằm ở `../Gapps/` (APK/XML/DER có **cùng nội dung** với A17 và Maps framework JAR).
Thư mục `LiteGapps16/` **chỉ** chứa dữ liệu riêng của Android 16; không chuyển APK khác phiên bản sang đây.

- `update.sh`: kiểm tra GApps, áp dụng `Gapps/` trước, sau đó phần riêng A16, rồi vá Enhanced Keyboard như cũ.
- `validate-sysconfig.py`: kiểm tra XML đặc thù A16, gồm ZK permissions và không cài Maps APK.
- `product/` và `system_ext/`: các APK/XML khác nội dung A17, hoặc chỉ có ở A16.
- `../Gapps/maps/com.google.android.maps.jar`: framework Maps duy nhất dùng cho cả hai bản.

```bash
python3 bin/modfile/Universal/LiteGapps/validate.py 16
python3 bin/modfile/Universal/LiteGapps/LiteGapps16/validate-sysconfig.py
```

**Lưu ý:** LiteGapps16 đã có một số XML tùy chỉnh HyperMOS không phải cấu hình SourceForge nguyên bản. Không tự đồng bộ sang A17. Giữ nguyên patch `MIUIFrequentPhrase.apk`.
