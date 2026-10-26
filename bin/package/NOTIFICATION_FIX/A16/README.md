# Android 16 notification policy

- **China:** Current `CN/frameworkpatcher_cn_a16.py` and
  `CN/PowerKeeper.sh` remain active and unchanged.
- **Xiaomi.eu:** No EU notification, PowerKeeper, AppOps, Greeze or wakelock
  patch is invoked by the EU dispatcher. Stock EU behavior is retained here.
- **ZK reference:** The extracted contents of former `backupzk.zip` are
  stored at their original paths under `A16/EU/`, including `ZK304/`.
  The ZIP is deleted, and the files are only references: none is run or
  installed during EU ROM builds.
- CorePatch, Kaorios, TNM and other Android versions remain unchanged.
