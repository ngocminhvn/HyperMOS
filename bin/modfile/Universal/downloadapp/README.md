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


## MiCTS

HyperMOS tự stage **MiCTS v2.6** vào `/product/data-app/` để app được cài sẵn nhưng vẫn có thể gỡ.

- Upstream: `parallelcc/MiCTS`
- Release cố định: `v2.6 / MiCTS_2.6.apk`
- SHA-256: `4680d24112fbf0d7ff5bbc055b760f2d67173d7d5879ec5411540d5caa7a97b8`
- Nếu có file `MiCTS*.apk` đặt trực tiếp trong thư mục `downloadapp`, build sẽ ưu tiên file local thay vì tải release.
- Circle to Search vẫn cần Google app `com.google.android.googlequicksearchbox` được cài và hỗ trợ CTS.
