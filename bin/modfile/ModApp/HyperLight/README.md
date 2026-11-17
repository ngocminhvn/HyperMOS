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
└── AOD/                    # Các bản vá nhắm vào MiuiAod.apk
    ├── update.sh
    └── patch.py
```

## Chi tiết các bản vá theo thành phần

### 1. `SystemUI/` (`MiuiSystemUI.apk`)
- **`LockScreenNotificationKeep`**: Giữ thông báo trên màn hình khóa sau khi mở khóa (`mHasShownAfterUnlock -> false` trong `NotificationFilterController`).
- **`LockScreenNotificationShowAll`**: Cho phép hiển thị mọi thông báo ngoài màn hình khóa (`canShowOnKeyguard() -> true` trong `ExpandedNotification`).
- **`LockScreenStackSink`**: Cho phép danh sách thông báo hạ thấp tự nhiên, bỏ qua ràng buộc co cụm của cảm biến vân tay quang học `GXZW_SENSOR` trong `KeyguardPanelViewController`.
- **`LockScreenClockTop`**: Khóa thông báo mặc định neo sát bên dưới đồng hồ khóa (`calculateKeyguardNotifTop -> bounds.top` và `invokeSuspend$getTargetTop -> bounds.top`), không bị chìm xuống đáy màn hình khóa.
- **`NotificationGroupDisable`**: Vô hiệu hóa gom nhóm thông báo (`ExpandedNotification` override `isGroup() -> false` và `getGroupKey() -> getKey()`), thả toàn bộ thông báo độc lập riêng rẽ ở cấp `ROOT_ENTRY`, không bị ẩn/mất bất kỳ thông báo nào.
- **`NotificationGroupStack`**: Cấu trúc tối ưu thẻ xếp chồng khi hiển thị danh sách thông báo trong `NotificationChildrenContainer`.
- **`LockScreenDepthAvoid (SystemUI)`**: Vô hiệu hóa hàm `updateAvoidStatus()` trong `KeyguardDepthInteractor` để giữ nguyên hiệu ứng chiều sâu hình nền khi có thông báo.
- **`LockScreenPinKeyUnblur`**: Gỡ bỏ hoàn toàn lớp mờ và tối đằng sau bàn phím PIN (ép `bouncerShowingFraction` về `0.0f` trong `KeyguardPanelViewController`), giúp nhìn rõ hình nền khóa khi nhập mã PIN.
- **`LockScreenPinKeyGlass`**: Áp dụng hiệu ứng kính mờ phần cứng (`MiViewBlurMode`) trực tiếp lên từng phím số `NumPadKey`.
- **`LockScreenBlurButton`**: Áp dụng hiệu ứng kính mờ phần cứng (`MiViewBlurMode`) cho 2 nút tròn phím tắt (đèn pin & camera) trên màn hình khóa trong `DefaultShortcutsSection`.
- **`LockScreenMusicCapsule`**: Cho phép hiển thị thẻ nhạc Focus Media Capsule (`canShowFocusMediaState -> 1` trong `NotificationSettingsManager`) và thao tác vuốt thẻ media trên màn hình khóa.

### 2. `AOD/` (`MiuiAod.apk`)
- **`LockScreenDepthAvoid (AOD)`**: Gỡ bỏ giới hạn chiều sâu hình nền khóa. Nâng ngưỡng tỉ lệ che đồng hồ từ `0.2` (20%) lên `1.0` (100%) trong `Threshold`, ép `HierarchyImageAvoidController.isHierarchyEnable -> true`, `WallpaperInfo.getSupportSubject -> true` để bất kỳ hình nền nào cũng kích hoạt được hiệu ứng Depth 3D.
- **`LockScreenBlurButton (AOD)`**: Fallback hỗ trợ hiệu ứng kính mờ cho 2 nút phím tắt trong `ShortcutViewLayoutController` nếu có trên các bản AOD đặc thù.

## Nguyên tắc an toàn
- Sử dụng `apke.jar` đóng gói theo chế độ raw DEX/Smali.
- **Tuyệt đối không ký lại APK** sau khi sửa để bảo toàn metadata và chứng chỉ hệ thống gốc (tuân thủ `AGENTS.md`).
- Nếu chữ ký method không khớp trên một bản ROM lạ, script giữ nguyên file APK gốc và không làm hỏng tiến trình build ROM.
