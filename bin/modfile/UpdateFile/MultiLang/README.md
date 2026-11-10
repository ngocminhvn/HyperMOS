# MultiLang — HyperMOS China OS3 / OS4

Dựa trên cơ chế MultiLang của [BEACHEADVN/nothingsvn_xiaomi-stocktoolbuild](https://github.com/BEACHEADVN/nothingsvn_xiaomi-stocktoolbuild/tree/main/bin/modfile/UpdateFile/MultiLang): chỉ chép APK overlay có sẵn vào `product/overlay/`, không biên dịch lại APK hay vá framework/JAR.

## Cấu trúc tối giản

```text
MultiLang/
├── README.md
├── update.sh
├── OS3/
│   └── updatesource/   # 67 file Nothings.*.apk
└── OS4/
    └── updatesource/   # 79 file Vni.*.apk
```

`bin/modfile/UpdateFile/insupdate.sh` gọi **duy nhất** `MultiLang/update.sh` trong lúc build. Script này kiểm tra loại ROM, sau đó sử dụng cùng một lệnh copy cho cả hai phiên bản:

- OS3 China: `OS3/updatesource/*.apk` → `build/baserom/images/product/overlay/`.
- OS4 China (Android 17): `OS4/updatesource/*.apk` → cùng vị trí.
- Xiaomi.eu và ROM không phải China: bỏ qua, vì đã có bản dịch riêng.

Không tự chọn codename/phiên bản OTA, không hợp nhất XML, không kiểm tra SHA-256 theo bản ROM và không động đến các JAR. Các APK đang được lưu trong Git được sao chép nguyên byte.

## Cập nhật APK

Chỉ thay các APK đã biên dịch sẵn trong đúng `OS3/updatesource/` hoặc `OS4/updatesource/`. Workflow `.github/workflows/test-multilang-os4.yml` kiểm tra số lượng, cấu trúc tối giản, APK OS4 đã ký và thử copy cả OS3/OS4. Không cần script nhập, đồng bộ hoặc xây overlay trong hai thư mục OS.

Các file nguồn XML, script dịch/kiểm tra và tài liệu thí nghiệm cũ đã được dọn khỏi **working tree** để tránh nhầm chúng là một phần của build ROM; chúng vẫn có thể truy xuất ở Git history trước commit dọn dẹp.

**Lưu ý:** Việc copy thành công không chứng minh overlay đã kích hoạt đúng trên điện thoại. Với OS4, cần xác minh `cmd overlay list`, `idmap2`, logcat và thực tế máy khởi động bình thường.
