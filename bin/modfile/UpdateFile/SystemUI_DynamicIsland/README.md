# SystemUI_DynamicIsland

Loại bỏ toàn bộ giới hạn của tính năng Dynamic Island (Focus Notification / Thông báo tiêu điểm) trên HyperOS nền China theo cơ chế của VSTeam:

1. **MiuiSystemUI.apk**:
   - `NotificationSettingsManager.smali`:
     - Method `canShowFocus()` ép trả về `true` (1).
     - Field `USE_WHITE_LISTS:Z` chuyển sang `false` (loại bỏ danh sách trắng giới hạn ứng dụng, cho phép mọi app bên thứ ba kích hoạt Focus Notification).
     - Field `Constants;->IS_INTERNATIONAL:Z` và `MiuiConfigs;->IS_INTERNATIONAL_BUILD:Z` chuyển sang `true`.
2. **MIUISystemUIPlugin.apk** (nếu có trong ROM):
   - `NotificationSettingsManager.smali`:
     - Method `canCustomFocus()` ép trả về `true` (1).
   - `FocusNotificationController.smali`:
     - Field `NotificationUtil;->IS_INTERNATIONAL_BUILD:Z` chuyển sang `true`.
