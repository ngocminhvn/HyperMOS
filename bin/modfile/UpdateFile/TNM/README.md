# TNM Bridge (HyperMOS)

ROM cài `tnm-bridge` vào phân vùng đang dùng cho TNM Hosts
(`/system_ext/bin` hoặc `/product/bin`).
Đây chỉ là **launcher** khi được gọi với root; không có init service,
daemon, UID 0 cho APK hay poll/background loop.

- Cổng lệnh: `tnm-bridge status|protocol|capabilities|call ...`
- Backend thực thi thuộc bản **APK TNM đã ký**, nằm ở
  `/data/adb/tnm/bin/tnmctl`; APK đồng bộ khi mở và được cấp `su`.
- ROM launcher kiểm tra UID root, owner và permission của backend.
- Không cho truyền shell tùy ý qua launcher.
- Cập nhật/tăng capability backend: cập nhật APK TNM, không build ROM.
- Thay đổi quyền privileged, SELinux, framework/init ROM: vẫn cần bản
  ROM/OTA mới khi cần.

Trên các HyperMOS chưa có launcher mới, TNM Kotlin client sử dụng trực tiếp
cùng backend dưới `/data/adb/tnm`; không yêu cầu flash mới chỉ để thử
backend mới.

Trên thiết bị kiểm tra bằng `su -c '/product/bin/tnm-bridge status'`
hoặc đường dẫn `/system_ext/bin/tnm-bridge` tương ứng.
Đừng gọi script này như một build step: nó được lưu không có đuôi `.sh`
vì `insupdate.sh` quét các file `*.sh` trong thư mục UpdateFile.


## TNMFramework v1 - TNM experimental ROM

An on-demand root-only adapter at `/system_ext/bin/tnm-frameworkctl` reads
EU-DEX PowerKeeper on Xiaomi APK base and Android services; it is not a daemon or Binder service.
The independent `tnm-cpuctl` handles CPU limits only when requested.
RYU PerfHook has been retired entirely, so its thermal/global/per-app game
profile commands are unsupported and never execute even if an old helper
remains on a dirty-flashed device. Xiaomi vendor/ODM thermal protection stays
active; effective display FPS is not inferred from Settings alone.

## Android-first TNM permissions (Android 16)

The preinstalled `com.android.trinhngocminh` privileged APK receives
`WRITE_SECURE_SETTINGS`, `POWER_SAVER`, `REBOOT` and
`GET_APP_OPS_STATS` through its existing partition-local
`privapp-permissions-tnm.xml` allowlist.

- Legacy `projectryu_thermal_*` Settings keys may remain in Android data,
  but no RYU PerfHook observer is installed or serviced by PowerKeeper.
  Independent supported Android settings can still use authorized permissions.
- CPU/GPU sysfs readback, Private DNS, refresh controls, battery saver,
  normal/recovery reboot, and AppOps inspection use the app UID wherever
  granted/accessible, with truthful unavailable states.
- `GET_APP_OPS_STATS` permits inspection, **not** unrestricted AppOps writes.
  Do not whitelist `MANAGE_APP_OPS_MODES` or
  `GRANT_RUNTIME_PERMISSIONS` on the assumption that privileged placement
  grants signature-only permissions; they require the platform's authorized
  signer or role.
- Hosts bind-mount, privileged kernel changes and denied AppOps mutations
  still use the on-demand root bridge. No persistent service or permissive
  SELinux policy is introduced.
- An APK update cannot grant new system permissions by itself. Rebuild/flash
  a compatible HyperMOS image to enable rootless third-party AppOps inspection.
