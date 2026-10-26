# EU309: Global303/Taiwan303 scoped notification policy

- China (A16): existing scoped CN FrameworkPatcher and PowerKeeper policy unchanged.
- Xiaomi.eu (A16): apply **nine** common Global303/Taiwan303-vs-EU309 method differences:
  - PowerKeeper: 4 cloud/region selection methods (`CloudUpdateReceiver.onReceive`,
    `LocalUpdateUtils.getCloudServer`, `setServerConfigurations`, `f.h.c`).
  - `miui-services.jar`: 3 `AppOpsServiceStubImpl` methods; change only
    `AppOpsUtils.isXOptMode` gate to `Build.IS_INTERNATIONAL_BUILD`.
  - `miui-framework.jar`: 2 `NotificationFilterHelper` methods;
    restore Xiaomi Global/Taiwan system notification lists, including XMSF.
- No Global/Taiwan cross-device JAR/APK is installed wholesale. GMS Observer,
  Greeze, Millet, Doze, thermal, KillProcessController and EU's 18 map apps
  are left unchanged; unrelated framework and device-specific differences remain EU.
- EU `backupzk.zip` is comparison-only and is not used by builds.
- Modifying `PowerKeeper.apk` classes.dex invalidates its original
  cryptographic signature even with original manifest and META-INF retained;
  **boot/package-scan/FCM/temperature tests are required**. No fix is guaranteed.
- `gms_control` and other existing PowerKeeper settings in `/data` are not
  cleared or overwritten by these code changes; cloud may still set them.
- Other Android versions, China fixes, CorePatch and Kaorios are not changed.

Sources: Xiaomi.eu EU309 HAOTIAN; DADA Global303 and Taiwan303
`OS3.0.303.0.WOCTWXM` (Actions #40283622450). This is a scoped
source-backed experiment rather than a proven FCM workaround.
