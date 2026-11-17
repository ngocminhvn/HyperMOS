# HyperLight Mods for HyperMOS

Bộ mod chuyển hóa các tính năng từ **HyperLight** vào trực tiếp các ứng dụng hệ thống của ROM HyperMOS trong quá trình build, được phân loại theo từng thành phần/ứng dụng mục tiêu.

## Cấu trúc thư mục

```text
bin/modfile/ModApp/HyperLight/
├── update.sh               # Dispatcher điều phối toàn bộ mod HyperLight
├── README.md               # Tài liệu tổng quan
├── SystemUI/               # Các bản vá nhắm vào MiuiSystemUI.apk
│   ├── update.sh
│   └── patch.py
├── AOD/                    # Các bản vá nhắm vào MiuiAod.apk
│   ├── update.sh
│   └── patch.py
└── Launcher/               # Các bản vá nhắm vào MiuiHome.apk (chạy khi Kashi Launcher tắt)
    ├── update.sh
    └── patch.py
```

## Chi tiết các bản vá theo thành phần

### 1. `SystemUI/` (`MiuiSystemUI.apk`)
- **`LockScreenNotificationKeep`**: Giữ thông báo trên màn hình khóa sau khi mở khóa (`mHasShownAfterUnlock -> false` trong `NotificationFilterController`).
- **`LockScreenNotificationShowAll`**: Cho phép hiển thị mọi thông báo ngoài màn hình khóa (`canShowOnKeyguard() -> true` trong `ExpandedNotification`).
- **`LockScreenStackSink`**: Cho phép danh sách thông báo hạ thấp tự nhiên, bỏ qua ràng buộc co cụm của cảm biến vân tay quang học `GXZW_SENSOR` trong `KeyguardPanelViewController`.
- **`NotificationGroupDisable`**: Vô hiệu hóa gộp nhóm thông báo, hiển thị từng thông báo độc lập như Android thuần (`GroupMemberManagerLegacy` / `GroupMembershipManagerImpl`).
- **`NotificationGroupStack`**: Cấu trúc xếp chồng thẻ 3D cho các thông báo nhóm (`NotificationChildrenContainer`).
- **`LockScreenDepthAvoid (SystemUI)`**: Vô hiệu hóa hàm `updateAvoidStatus()` trong `KeyguardPanelViewController` để tránh ẩn hiệu ứng chiều sâu khi có thông báo.
- **`LockScreenPinKeyUnblur`**: Gỡ bỏ hoàn toàn lớp mờ và tối đằng sau bàn phím PIN (ép `bouncerShowingFraction` về `0.0f` trong `KeyguardPanelViewController`), giúp nhìn rõ hình nền khóa khi nhập mã PIN.
- **`LockScreenPinKeyGlass`**: Hỗ trợ vẽ nền kính mờ cho các phím số PIN trong `NumPadKey`.
- **`LockScreenMusicCapsule`**: Hỗ trợ tối ưu thẻ media và vuốt ẩn thẻ nhạc trên màn hình khóa trong `MiuiMediaHeaderView`.

### 2. `AOD/` (`MiuiAod.apk`)
- **`LockScreenDepthAvoid (AOD)`**: Gỡ bỏ giới hạn chiều sâu hình nền khóa. Nâng ngưỡng tỉ lệ che đồng hồ từ `0.2` (20%) lên `1.0` (100%) trong `Threshold`, ép `HierarchyImageAvoidController.isHierarchyEnable -> true`, `WallpaperInfo.getSupportSubject -> true` để bất kỳ hình nền nào cũng kích hoạt được hiệu ứng Depth 3D.
- **`LockScreenBlurButton`**: Hỗ trợ nền mờ kính `MiGlass` cho 2 nút phím tắt (đèn pin & camera) ngoài màn hình khóa trong `ShortcutViewLayoutController`.

### 3. `Launcher/` (`MiuiHome.apk`)
> [!IMPORTANT]
> **Điều kiện thực thi:** Chỉ kích hoạt khi mod **Kashi Launcher đang TẮT** trong `kashi.jsonc` (để tránh ghi đè hoặc xung đột với RustLauncherMod của Kashi).
- **Phân biệt & Mở khóa `DeviceLevelUtils`:**
  - Phân biệt profile kiểm tra cấu hình thiết bị trước khi can thiệp (whitelist, folme level, simple animation restrictions).
  - Ép cấu hình Flagship Cấp độ 2 (`getDeviceLevel -> 2`, `isHighLevelDeviceByDefault -> true`, `isHighAnimationRate -> true`, `isUseWallpaperAnim -> true`).
  - Tắt hoàn toàn `isUseSimpleAnim`, `isUseSimpleOpenCloseAnim`, `isLowLevelDevice` để mọi dòng máy đều có hoạt ảnh bung mở ứng dụng đầy đủ và mượt mà nhất.
- **Đường cong hoạt ảnh mở/đóng App (`Anim-Curve` kiểu iOS):** Tinh chỉnh thông số phản hồi cử chỉ vuốt về Home và đường cong gia tốc trong `Utilities` & `FolmeSpringRegistry`.
- **Tùy biến Thư mục lớn & Màn hình đa nhiệm:** Kích hoạt `fastBlurWhenEnterRecents` (làm mờ tức thì tránh tụt khung hình khi vào đa nhiệm), tùy biến bán kính mờ Recents và tối ưu layout thư mục lớn.

## Nguyên tắc an toàn
- Sử dụng `apke.jar` đóng gói theo chế độ raw DEX/Smali.
- Tuyệt đối **không ký lại APK** để bảo toàn danh tính và metadata ký gốc của Xiaomi (tuân thủ `AGENTS.md`).
- Hỗ trợ cơ chế fail-safe: Nếu chữ ký method không khớp trên một bản ROM lạ, script giữ nguyên file APK gốc và không làm hỏng tiến trình build ROM.
