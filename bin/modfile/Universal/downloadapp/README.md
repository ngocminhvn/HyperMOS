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
- Trên Android 16, build tự tải **MiCTS_2.6.apk** từ release chính thức `parallelcc/MiCTS` nếu không có APK MiCTS cục bộ, kiểm tra SHA-256 `4680d24112fbf0d7ff5bbc055b760f2d67173d7d5879ec5411540d5caa7a97b8`, rồi đưa vào `/product/data-app/`. APK cục bộ cũng phải trùng SHA-256 này.
- Chỉ cài MiCTS như app có thể gỡ; **không** bật lại MiCTS framework/DEX hook, không vá `services.jar` hay `miui-services.jar`.
- Với Android khác 16, nếu thư mục không có APK thì build tự bỏ qua.
