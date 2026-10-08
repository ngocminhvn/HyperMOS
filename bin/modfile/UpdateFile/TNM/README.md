# TNM Bridge (HyperMOS)

ROM cài `tnm-bridge` vào phân vùng đang dùng cho TNM Hosts
(`/system_ext/bin` hoặc `/product/bin`).
Đây chỉ là **launcher** khi được gọi với root; không có init service,
daemon, UID 0 cho APK hay poll/background loop.

- Cổng lệnh: `tnm-bridge status|protocol|capabilities|call ...`
- Backend thực thi thuộc bản **APK TNM đã ký**, nằm ở
  `/data/adb/tnm/bin/tnmctl`; APK đồng bộ khi mở và được cấp `su`.
- ROM launcher kiểm tra UID root, owner và permission của backend.
- Không cho truyền shell tùy ý qua launcher.
- Cập nhật/tăng capability backend: cập nhật APK TNM, không build ROM.
- Thay đổi quyền privileged, SELinux, framework/init ROM: vẫn cần bản
  ROM/OTA mới khi cần.

Trên các HyperMOS chưa có launcher mới, TNM Kotlin client sử dụng trực tiếp
cùng backend dưới `/data/adb/tnm`; không yêu cầu flash mới chỉ để thử
backend mới.

Trên thiết bị kiểm tra bằng `su -c '/product/bin/tnm-bridge status'`
hoặc đường dẫn `/system_ext/bin/tnm-bridge` tương ứng.
Đừng gọi script này như một build step: nó được lưu không có đuôi `.sh`
vì `insupdate.sh` quét các file `*.sh` trong thư mục UpdateFile.
