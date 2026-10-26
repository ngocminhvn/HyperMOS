# HyperMOS Android 16 notification/power policy

Entry point: `bin/package/NOTIFICATION_FIX/A16/patch.sh`.

- **China:** Keep existing `CN/frameworkpatcher_cn_a16.py` and `CN/PowerKeeper.sh` behavior.
- **Xiaomi.eu:** Skip the entire A16 notification/power fix path. Do not rebuild
  `miui-services.jar`, modify `PowerKeeper.apk`, patch GMS/FCM/Doze/Greeze,
  or import donor Global303/RYU/ZK methods in this step.
- **Unrelated components:** Common CorePatch/Kaorios, TNM, China notification
  handling and Android 17 behavior are left unchanged. On EU, CorePatch keeps
  its existing `HYPERMOS_PRESERVE_EU_FRAMEWORK=1` behavior.
- **Reference:** `EU/backupzk.zip` is retained but never used by the build.

The old EU Global303 cloud port, RYU ContentCatcher override and obsolete
EU FCM test-module workflow were removed. Await a Taiwan ROM extraction
artifact before the next EU-vs-Taiwan comparison.
