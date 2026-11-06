# HyperOS 4 China — Vietnamese overlays (Android 17)

## Cách hoạt động mới: biên dịch một lần, dùng chung nhiều máy

- **Action riêng:** `Prebuild OS4 Vietnamese Overlays` nhận URL ROM China OS4 Android 17, giải nén APK nền (không chạy bất kỳ bản vá/mod ROM nào), dùng 281 XML tiếng Việt trong `Vietnamese/main` để tạo các APK RRO. APK được zipalign, ký, xác minh và commit vào `updatesource/<ROM version>/`.
- **Build ROM hằng ngày:** `MultiLang/OS4/update.sh` **không biên dịch XML**. Chỉ chọn thư mục `updatesource/<ROM version>/`, kiểm tra SHA-256 và ZIP, rồi copy các APK vào `product/overlay/HyperMOS-OS4-VI`. Nếu ROM có `product/overlay/config/config.xml`, bổ sung cấu hình enabled/immutable cho overlay mà không xóa các cấu hình cũ.
- **Không có thư mục thiết bị:** Ví dụ ROM `OS4.0.0.17.XOBCNXM` và `OS4.0.0.17.XOCCNXM` dùng chung bộ `updatesource/OS4.0.0.17/`. Chỉ số phiên bản số quyết định thư mục. *Một ROM tham chiếu* được dùng để tạo overlay cho phiên bản đó; bộ APK dự định dùng chung cho mọi thiết bị chạy cùng phiên bản.
- **OS3 giữ nguyên:** 67 APK RRO ở `OS3/updatesource/` không thay đổi.

### Tạo bộ APK

Vào **GitHub Actions → Prebuild OS4 Vietnamese Overlays → Run workflow**, nhập đường dẫn ZIP ROM China OS4 Android 17. Action chạy `build.sh` ở chế độ `HYPERMOS_OS4_VI_PREBUILD=1` nên dừng ngay sau bước giải nén và kiểm tra OS, không chạy mod ROM, không repack và không xuất ROM. Sau đó chạy `package_prebuilt.py` và commit các APK cùng `manifest.json` (SHA-256) vào `main`.

Trong thư mục `updatesource/OS4.0.0.17/` sẽ có `manifest.json` và các `HyperMOS.OS4.VI.*.apk`. Muốn cập nhật bộ dịch cho phiên bản đó chỉ cần chạy lại Action, các file sẽ được thay thế.

### Kiểm tra sau khi flash

```sh
adb shell cmd overlay list --user 0
adb shell cmd overlay list --user current
adb shell getprop persist.sys.locale
adb logcat -b all | grep -iE 'idmap|OverlayManager'
```

**Lưu ý về tương thích:** Dùng chung một bộ APK theo phiên bản ROM không chứng minh tính tương thích với mọi máy. Các bản OEM cùng số phiên bản vẫn có thể khác resource ID, target package hoặc overlayable policy. Action chỉ xác minh bằng ROM tham chiếu; cần thử `idmap2` và giao diện thực tế trên các thiết bị khác. Nếu chưa có bộ overlay của phiên bản đang build, bước MultiLang OS4 dừng rõ ràng thay vì tự sinh APK hoặc âm thầm báo đã có tiếng Việt. Bộ overlay mới không thay, không ký lại Settings/SystemUI/framework-res gốc.
