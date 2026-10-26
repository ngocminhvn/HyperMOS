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
- **PowerKeeper:** The EU A16 path ports only four audited Global303
  cloud/region methods to EU309 `PowerKeeper.apk` while preserving non-DEX
  data and all other EU methods. The APK's original digital signature is
  invalidated by this DEX change; build and runtime verification are required.
  No PerfHook or thermal/Doze/GMS wakelock bypass is introduced.
- **Compatibility:** No change to CorePatch/Kaorios, TNM, China A16
  notification handling or A17. `backupzk.zip` stays as historical
  reference.

EU309 vs Global303 DEX findings and remaining runtime test limitations:
`EU/README.md`.
