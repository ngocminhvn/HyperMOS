# LiteGapps — chia sẻ GApps giữa Android 16 và Android 17

```text
LiteGapps/
├── Gapps/                # 35 file y hệt nhau + Maps framework JAR
│   ├── product/
│   └── maps/com.google.android.maps.jar
├── LiteGapps16/         # Chỉ file riêng A16, update.sh, kiểm tra XML
├── LiteGapps17/         # Chỉ file riêng A17, stage.py, sources/inventory
├── validate.py          # Kiểm tra payload + Git LFS, dùng chung
└── README.md
```

## Cách hoạt động

- `Gapps/`: 35 file có **cùng Git blob SHA** ở hai bản trước khi dọn, nên nội dung hoàn toàn trùng; 6 trong số đó là APK Git LFS. Maps JAR của A16 đang được cả A16/A17 dùng cũng chuyển vào đây.
- `LiteGapps16/`: 28 file payload khác biệt A17 hoặc chỉ A16 có. Chứa GmsCore, Phonesky, GoogleServicesFramework, ZK permissions, GoogleVelvet_CTS, XML preinstall và bản vá Enhanced Keyboard.
- `LiteGapps17/`: 30 file payload riêng của A17, giữ các thành phần đúng API 37 và `inventory.json` của SourceForge.
- Khi build: **Gapps dùng chung + phiên bản tương ứng**. Không ghi đè file từ A16 sang A17. Trình kiểm tra từ chối đường dẫn trùng ở hai lớp và bắt buộc APK thật, XML hợp lệ; A17 còn kiểm tra SHA-256 của 65 file hiệu lực.
- JAR Maps duy nhất: `Gapps/maps/com.google.android.maps.jar`; được kiểm tra Git blob SHA-1 cố định và chép tới `product/framework/com.google.android.maps.jar`. **Không cài Maps.apk.**

```bash
# Sau checkout phải có Git LFS thực
python3 bin/modfile/Universal/LiteGapps/validate.py 16
python3 bin/modfile/Universal/LiteGapps/validate.py 17
```

**Không thay đổi**: điều kiện China/EU, APK/XML khác nội dung, logic bản vá bàn phím A16, nguồn ZIP A17 và build workflow chính. Chỉ dọn những file trùng nội dung. Mọi bản A17 vẫn chưa được thử boot thực tế.
