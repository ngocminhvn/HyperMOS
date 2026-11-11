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

---

## 3. Thuật Toán Ký EC Theo Đúng Curve của Keybox (`o.h`)

- **Class / File Smali:** `com.kousei.framework.o` (hàm `b(PrivateKey)`, `e(Certificate[], String[])`, và helper mới `h(String, PrivateKey)`)
- **Nguyên nhân:** `o.b` gán cứng `"SHA256withECDSA"` cho mọi khóa EC, còn `o.e` sao chép `leaf.getSigAlgName()` của khóa thiết bị gốc thay vì đối chiếu curve của Private Key trong Keybox (ví dụ P-384 dùng `SHA384withECDSA`, P-521 dùng `SHA512withECDSA`).
- **Cách vá:** Thêm `o.h(String, PrivateKey)` kiểm tra `ECKey.getParams().getCurve().getField().getFieldSize()` (`<=256` -> `SHA256withECDSA`, `<=384` -> `SHA384withECDSA`, `>384` -> `SHA512withECDSA`), dùng cho cả chế độ `GEN` và Leaf Hack.

---

## 4. Tự Động Nâng Cấp Google Hardware Attestation Root Hết Hạn (`g0.k`)

- **Class / File Smali:** `com.kousei.framework.g0` (gọi `g0.k(ArrayList)` ngay sau khi `g0.d(...)` sắp xếp chuỗi chứng chỉ và trước khi `g0.i(...)` kiểm tra chữ ký).
- **Nguyên nhân:** Keybox cũ đi kèm thiết bị chứa chứng chỉ Google Hardware Attestation Root đời cũ (cùng khóa công khai `f92009e853b6b045`) đã hết hạn vào ngày `2026-05-24`. Các trình kiểm tra khắt khe sẽ từ chối chuỗi chứng chỉ nếu giữ nguyên chứng chỉ gốc đã hết hạn.
- **Cách vá:** Kiểm tra phần tử root cuối chuỗi; nếu có cùng `PublicKey.getEncoded()` nhưng khác `Certificate.getEncoded()` với Google Hardware Attestation Root hiện hành (`2022-03-20` – `2042-03-15`), tự động thay thế chứng chỉ root mới trước khi lưu vào `f0`.
