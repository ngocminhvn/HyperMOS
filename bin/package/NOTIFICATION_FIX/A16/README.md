# HyperMOS Android 16: China and Xiaomi.eu notification policies

Entry point: `bin/package/NOTIFICATION_FIX/A16/patch.sh`.

- **China:** The existing `CN/frameworkpatcher_cn_a16.py` and
  `CN/PowerKeeper.sh` behavior is unchanged.
- **Xiaomi.eu:** The notification/power methods audited against
  DADA Global303 are already bytecode-equivalent in the original EU309
  `miui-services.jar`. The old custom FCM Autostart/Greeze/GMS-wakelock
  exceptions are no longer applied. The stock EU implementations are
  retained instead of transplanting a cross-device JAR.
- **Independent patch:** The existing
  `ProcessPolicy.updateContentCatcherWhitelist()` override stays in
  `EU/ryu_policy.json`. Other previously removed RYU policy overrides
  remain removed.
- **APK:** EU `PowerKeeper.apk` is left completely unmodified; this
  does not enable PerfHook or make any thermal/Doze changes.
- **Compatibility:** No change to CorePatch/Kaorios, TNM, China A16
  notification handling or A17. `backupzk.zip` stays as historical
  reference.

EU309 vs Global303 DEX findings and remaining runtime test limitations:
`EU/README.md`.
