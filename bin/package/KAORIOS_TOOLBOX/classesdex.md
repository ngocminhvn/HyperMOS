## 1. Nhánh Sinh Chứng Chỉ Phần Mềm (`GEN` Mode) Bỏ Quên Dữ Liệu PIF

### Đối tượng
- **Class / File Smali:** `com.kousei.framework.e0` (`android.security.kaorios.KaoriosHooks`)
- **Vị trí bytecode:** Nhánh `:cond_1c3` trong phương thức tạo cặp khóa và chứng chỉ phần mềm.

### Phân tích cơ chế & lỗi
- **Mục đích thiết kế:** Khi các tiến trình dịch vụ Google (GMS / Google Play Store) kích hoạt kiểm tra tính toàn vẹn (Play Integrity), hệ thống yêu cầu sinh cặp khóa KeyPair và chuỗi chứng thực X.509 attestation. Kaorios can thiệp bằng chế độ `GEN` (Software KeyPair Generation) để tự ký chuỗi chứng chỉ giả lập.
- **Lỗi logic trong bytecode:**
  - Trong nhánh `:cond_1c3`, `e0` chỉ truy vấn trực tiếp thuộc tính phần cứng của ROM thông qua các hàm đọc thuộc tính:
    - `SystemProperties.get("ro.product.brand_for_attestation", Build.BRAND)`
    - `SystemProperties.get("ro.product.device_for_attestation", Build.DEVICE)`
    - `SystemProperties.get("ro.product.name_for_attestation", Build.PRODUCT)`
    - `SystemProperties.get("ro.product.manufacturer_for_attestation", Build.MANUFACTURER)`
    - `SystemProperties.get("ro.product.model_for_attestation", Build.MODEL)`
  - Trong khi đó, module `com.kousei.framework.o` đã có sẵn hàm `o.c()` chuyên phân giải file `pif.json` sang bảng ánh xạ các thẻ ASN.1 X.509 attestation (`0x2c6..0x2cd`):
    - `0x2c6`: Brand
    - `0x2c7`: Device
    - `0x2c8`: Product
    - `0x2cc`: Manufacturer
    - `0x2cd`: Model
  - Hàm `o.c()` này chỉ được tác giả gọi trong nhánh Leaf Hack (`o.smali`), **hoàn toàn bị bỏ quên trong nhánh `GEN` (`e0.smali`)**.
- **Hệ quả:** Dù người dùng đã cài đặt hồ sơ giả lập (Pixel 6a / Pixel 7...) vào `pif.json`, chuỗi chứng chỉ X.509 attestation tạo ra vẫn mang định danh thiết bị gốc từ ROM (`Xiaomi`, `haotian`, `2410DPN6CC`).

---

## 2. Cờ Giả Lập Play Store Bị Tắt & Thiếu Nhóm Thuộc Tính Attestation

### Đối tượng
- **Class / File Smali:** `com.kousei.framework.j0` (`android.security.kaorios.PlayIntegritySpoofService`)
- **Vị trí bytecode:** Hàm khởi tạo `<init>`, hàm nạp cấu hình `d()` và phương thức inject thuộc tính `k()`.

### Phân tích cơ chế & lỗi
- **Cờ `mSpoofVendingProfile` (trường `j0->k:Z`) mặc định sai:**
  - Trường `k:Z` điều khiển việc nạp các trường `Build.BRAND`, `Build.DEVICE`, `Build.MODEL`, `Build.FINGERPRINT` vào tiến trình Google Play Store (`com.android.vending`).
  - Trong cả hàm `<init>` và hàm reset cấu hình `d()`, cờ này đều bị gán mặc định là `false` (`0`).
  - Nếu file `pif.json` không có trường khai báo thủ công `spoofVendingProfile: "1"` (hoặc `"true"`), tiến trình Play Store hoàn toàn không áp dụng dữ liệu PIF mà tiếp tục đọc trực tiếp cấu hình gốc của thiết bị.
- **Bỏ sót nhóm thuộc tính `*_for_attestation` trong native overlay:**
  - Phương thức `k()` của `j0` chịu trách nhiệm ghi đè các system properties trong bộ nhớ tiến trình.
  - Bytecode chỉ inject các khóa cơ bản: `ro.product.brand`, `ro.product.device`, `ro.product.model`, `ro.product.manufacturer`, `ro.product.name`.
  - Bytecode **hoàn toàn không ghi đè nhóm thuộc tính attestation**:
    - `ro.product.brand_for_attestation`
    - `ro.product.device_for_attestation`
    - `ro.product.model_for_attestation`
    - `ro.product.manufacturer_for_attestation`
    - `ro.product.name_for_attestation`
- **Hệ quả:** Khi Google Play Store truy vấn định danh hệ thống qua các API cấp thấp hoặc thuộc tính attestation chuyên biệt, hệ thống trả về giá trị gốc của thiết bị, gây lệch thông tin giữa kết quả kiểm tra và hồ sơ giả lập.
