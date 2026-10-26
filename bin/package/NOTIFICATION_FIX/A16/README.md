# Android 16 notification policy

- **China:** Current `CN/frameworkpatcher_cn_a16.py` and
  `CN/PowerKeeper.sh` remain active, unchanged.
- **Xiaomi.eu:** No notification, PowerKeeper, GMS, AppOps, Greeze or
  wakelock fixes are applied by this path. Its original stock JAR/APK
  behavior is retained.
- **ZK reference:** Files extracted from the historical `backupzk.zip`
  are stored under `EU/zk_extracted/`; they are for source comparison only.
  The ZIP archive and build-time unpacker are removed.
- CorePatch, Kaorios, TNM and other Android versions are unchanged.
