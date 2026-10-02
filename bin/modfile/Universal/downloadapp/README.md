# downloadapp

Đặt các file APK cần cài sẵn trực tiếp trong thư mục này.

Ví dụ:

```text
bin/modfile/Universal/downloadapp/
├── update.sh
├── App1.apk
└── App2.apk
```

Khi build ROM, các APK sẽ được đưa vào `/product/data-app/` để HyperOS cài như ứng dụng có thể gỡ cài đặt ở lần khởi động đầu tiên.

- Không đưa APK vào `/system/app`, `/system/priv-app`, `/product/app` hoặc `/product/priv-app`.
- Chỉ hỗ trợ APK đơn; không hỗ trợ split APK/APKS/XAPK.
- Nếu thư mục không có APK, build sẽ tự bỏ qua.
