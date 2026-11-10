# AGENTS.md — Quy tắc bắt buộc cho AI agent làm việc với HyperMOS

> Đọc tài liệu này **trước khi phân tích, sửa, commit hoặc push** vào repository.
> Áp dụng cho toàn bộ mã nguồn, script build ROM, patch framework/APK, tài liệu và GitHub Actions.
> Đây là các **ràng buộc mặc định**; chỉ được làm khác khi chủ repository yêu cầu **rõ ràng cho tác vụ cụ thể**.
> Nếu thiếu dữ liệu để bảo đảm an toàn, hãy dừng ở phần chưa chắc chắn, báo rủi ro và không tự ý chọn phương án nguy hiểm.

## 1. Chỉnh sửa APK / Smali: tuyệt đối không tự ký lại

### Nguyên tắc bất biến

1. **Không ký lại APK sau khi chỉnh sửa Smali/DEX/resources.** Không dùng `apksigner sign`, `jarsigner`, `signapk`, testkey, debug key, khóa tự tạo, khóa của ROM khác hay thao tác thay thế certificate. Không tự đổi sang một cơ chế ký khác để làm build pass.
2. **Giữ danh tính của APK gốc từ ROM đang xử lý**, nhất là ứng dụng hệ thống/priv-app như `MiuiSystemUI.apk`, `SecurityCenter.apk` và các app Xiaomi khác. Không thay APK bằng bản đã ký khác, không lấy APK từ ROM/thiết bị khác để ghi đè trừ khi được yêu cầu rõ ràng và đã kiểm tra tương thích.
3. Ưu tiên cách chỉnh sửa **tối thiểu, đúng DEX/method cần vá**, theo cơ chế raw APK/Smali và bảo toàn metadata mà HyperMOS đang dùng; không giải mã/biên dịch lại toàn bộ APK nếu không cần.
4. Các mục **không thuộc phạm vi vá phải được giữ nguyên** hết mức có thể, gồm:
   - `AndroidManifest.xml`, package name, versionCode/versionName, sharedUserId, SDK/uses-feature, authorities, component declarations, permission và privileged-app identity.
   - `resources.arsc`, assets, native libraries và dữ liệu khác không được yêu cầu sửa.
   - Dấu vết danh tính ký gốc như `META-INF/` (v1), thông tin certificate, APK Signing Block (v2/v3 nếu có) và cấu trúc ZIP mà cơ chế sửa hiện tại cần giữ.
   - Entry name/order, phương thức nén, alignment, timestamp/ZIP metadata khi công cụ có thể bảo toàn; đường dẫn phân vùng, quyền file, owner/group, `fs_config`, SELinux file context và các metadata đóng gói ROM có liên quan.
5. **Không coi việc giữ metadata hoặc giữ signing block là chữ ký còn hợp lệ.** Khi byte APK thay đổi, chữ ký APK v2/v3 thông thường sẽ **không còn xác minh mật mã được**, dù certificate và signing block gốc vẫn hiện diện. Không ghi báo cáo “signature valid” chỉ vì metadata/certificate khớp.
6. Nếu ROM sử dụng cơ chế CorePatch/kiểm tra chữ ký đã có để chấp nhận APK hệ thống bị vá, phải **xác nhận đường tương thích đó thực sự được bật và áp dụng đúng phiên bản ROM**. CorePatch không biến chữ ký đã hỏng thành chữ ký hợp lệ và không thay thế việc kiểm tra an toàn trước khi flash.
7. Nếu không có cách bảo toàn danh tính APK và cơ chế nạp/kiểm tra tương thích đã được chứng minh: **không thay APK gốc**. Trả về lỗi rõ ràng hoặc giữ nguyên APK theo hành vi an toàn hiện có; không ký lại để “chữa” lỗi.
8. Không tự ý xóa toàn bộ `META-INF`, signing block, thay package name, thay certificate, sửa `sharedUserId`, bỏ quyền privileged, thay manifest hàng loạt hoặc tắt các kiểm tra bảo mật ngoài phạm vi được yêu cầu.

### Tham khảo trong repository

- `bin/modfile/UpdateFile/InfoChanger/update.sh`: xử lý `MiuiSystemUI.apk` theo chữ ký method, bỏ qua APK không tương thích thay vì vá mù.
- `bin/modfile/UpdateFile/SecurityCountdown/update.sh`: kiểm tra certificate Xiaomi, giữ dữ liệu ký gốc và chỉ vá khi method khớp; tài liệu trong script cũng nêu rõ **DEX thay đổi làm digest v2/v3 mất hiệu lực**, cần cơ chế CorePatch tương ứng.
- `bin/package/NOTIFICATION_FIX/A17/PowerKeeper.sh`: có quy trình giữ identity/metadata của APK gốc; việc giữ identity không được diễn giải thành đã ký lại thành công.

**Quy tắc áp dụng:** học cách *giữ nguyên APK gốc khi không tương thích* và *bảo toàn metadata* từ các đường vá hiện có; **không được lấy các quy trình có ký lại ở nơi khác trong repo làm ngoại lệ để ký lại APK được yêu cầu vá Smali**.

### Kiểm tra trước khi chấp nhận bản vá APK

- Xác nhận đúng file APK, phân vùng và tên package; ghi nhận identity/certificate/metadata gốc trước khi thao tác.
- Kiểm tra đúng class, method, chữ ký hàm, register/DEX; chỉ thay phần cần thiết; tránh trùng hook.
- So sánh các mục không được sửa của APK gốc và APK đầu ra; kiểm tra cấu trúc archive, DEX và metadata ROM.
- Phân biệt minh bạch: **patch thành công**, **APK kiểm tra cấu trúc pass**, **APK có chữ ký mật mã hợp lệ**, **ROM build pass**, **thiết bị boot pass** là các mức kiểm chứng khác nhau.
- Nếu chưa kiểm thử trên thiết bị, phải ghi rõ chưa xác nhận boot/runtime, không suy diễn từ log build.

## 2. Git: làm trực tiếp trên main, không tự tạo nhánh

1. **Mặc định sửa và commit trực tiếp trên `main`. Không tạo branch mới** (kể cả `fix/*`, `test/*`, `ci/*`, backup, dispatch hoặc nhánh thử nghiệm) nếu người dùng không yêu cầu.
2. **Không tạo branch tạm chỉ để kích hoạt GitHub Actions.** Ưu tiên dùng workflow hiện có và chạy trên `main`. Không tự thêm workflow dispatch/one-shot chỉ để chạy build.
3. Khi người dùng **chủ động yêu cầu tạo nhánh**, dùng đúng tên/mục đích được yêu cầu. **Sau khi hoàn thành tác vụ và thay đổi đã được hợp nhất/giữ an toàn**, xóa ngay nhánh tạm do agent tạo nếu người dùng không yêu cầu giữ.
4. **Không xóa nhánh của người dùng, nhánh backup, nhánh còn commit chưa hợp nhất** hoặc nhánh không chắc do agent tạo. Nếu không thể xóa nhánh tạm an toàn, phải báo rõ thay vì âm thầm bỏ qua.
5. Trước mỗi lần push phải xem head hiện tại của `main` và diff; không force-push, reset lịch sử, revert hoặc xóa commit khi chưa được yêu cầu.

## 3. Không push cache, tests, verify và dữ liệu sinh ra

**Chỉ commit/push mã nguồn hoặc tài liệu thực sự cần cho thay đổi được yêu cầu.**

- **Không thêm/commit/push** file hoặc thư mục tạo chỉ để test, verify, debug, smoke test, benchmark, CI thử nghiệm, fixture, log, report, snapshot, proof-of-concept hoặc workflow dùng một lần.
- **Không commit/push cache hay sản phẩm build**: ví dụ `build/`, `out/`, `apk_temp/`, `jar_temp/`, thư mục decompile tạm, `__pycache__/`, `.pytest_cache/`, `*.pyc`, log, ROM ZIP và APK/DEX/JAR sinh ra trong quá trình thử nghiệm — trừ **artifact mã nguồn/payload thực sự thuộc dự án và được yêu cầu cập nhật**.
- Các bước kiểm tra để bảo đảm chất lượng được phép **thực hiện cục bộ hoặc trong workflow sẵn có**, nhưng **không đẩy các file test/verify và workflow test mới lên repo** chỉ để ghi nhận kết quả.
- Kiểm tra hợp lệ/không tương thích **thiết yếu trong luồng build chính** có thể nằm trong chính mã nguồn sản xuất; đây không phải lý do để tạo riêng một bộ test/verify trong repository.
- Không tự sửa, tạo thêm hoặc xóa `.github/workflows/*.yml`, **đặc biệt `.github/workflows/build.yml`**, nếu người dùng không yêu cầu. Việc sửa code thông thường không cho phép tự ý sửa workflow.
- Trước commit dùng `git status` và danh sách diff/staged files để bảo đảm **không có file phát sinh ngoài phạm vi**. Sau tác vụ, dọn file tạm do agent tạo mà không xóa payload/asset đang được track và cần cho ROM.

## 4. Ưu tiên tương thích OS3 và OS4, tránh sửa lan

- **HyperOS 3 / Android 16 đang hoạt động là baseline phải bảo toàn.** Không đổi hành vi A16 chỉ để xử lý lỗi A17 khi chưa chứng minh an toàn.
- Với **HyperOS 4 / Android 17**, đặt điều kiện theo phiên bản ở ranh giới thật sự cần khác nhau; chỉ dùng chung phần sửa, công cụ hoặc logic khi đã xác minh tương thích cả A16/A17.
- Không tắt tính năng hiện có, bỏ qua lỗi bắt buộc, bỏ xác minh policy, chuyển SELinux sang permissive, đổi AVB/CorePatch/Kaorios hoặc tháo hook chỉ để build báo xanh.
- Sửa **nguyên nhân cụ thể từ log**, ở **ít file nhất có thể**. Không đổi phiên bản công cụ, signing behavior, cấu trúc thư mục, luồng build hay cơ chế đóng gói khác nếu không liên quan.
- Mọi thay đổi framework/Smali phải lưu ý giới hạn DEX, tương thích method, dependencies, file context và khả năng bootloop. Không kết luận an toàn chỉ vì biên dịch thành công.

## 5. Cách agent báo cáo và bàn giao

1. Nêu rõ nguyên nhân lỗi, file vừa sửa và phạm vi ảnh hưởng OS3/OS4.
2. Chỉ báo **PASS** khi có kết quả tương ứng; phân biệt cú pháp/code check, patch, build, boot và runtime.
3. Nêu commit `main` và link Actions nếu thật sự đã có. Không bịa build, không hứa chạy ngầm.
4. Xác nhận **không có branch/workflow/test/cache thừa được push**; nếu có trở ngại dọn dẹp, báo trung thực.
5. Nếu yêu cầu mới mâu thuẫn với quy tắc trên, giải thích rủi ro và xin chỉ thị cụ thể, không tự phá quy tắc.

**Tóm tắt bất biến:** APK vá Smali **không được ký lại** và phải giữ identity/metadata gốc; **không tự tạo nhánh**; **không push cache, tests, verify hay workflow tạm**; **giữ OS3 ổn định**; **không tự sửa `build.yml`**.
