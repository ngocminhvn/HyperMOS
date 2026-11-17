# SystemUI_HideMobileTypeOnWifi

Ẩn biểu tượng loại mạng di động (4G/5G/LTE) trên thanh trạng thái khi đã kết nối mạng Wi-Fi hoặc khi tắt mạng di động theo cơ chế của VSTeam:

1. **MiuiOperatorCustomizedPolicy.smali**:
   - Ép trường cờ `Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z` thành `true` để áp dụng chính sách hiển thị biểu tượng theo chuẩn Quốc tế (Global).
2. **Resource string override**:
   - Thay thế chuỗi resource literal `"config_status_bar_show_mobile_type_when_wifi_on"` thành `"vsteam"` trong tất cả các file smali, vô hiệu hóa việc ép hiển thị icon mạng di động của ROM China.
3. **MiuiCellularIconVM*.smali**:
   - Tìm tất cả các file smali ViewModel liên quan đến icon sóng di động chứa từ khóa `combine` và `IS_INTERNATIONAL_BUILD`, ép `IS_INTERNATIONAL_BUILD:Z` thành `true` để icon loại mạng tự động ẩn khi Wi-Fi được kết nối.
