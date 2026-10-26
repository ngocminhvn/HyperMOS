# Android 16 notification policy

- **China:** The current `CN/frameworkpatcher_cn_a16.py` and
  `CN/PowerKeeper.sh` patches remain active and unchanged.
- **Xiaomi.eu:** The entire EU Global303/Taiwan303 nine-method notification and
  cloud port has been removed. Stock EU A16 framework/PowerKeeper policy is
  retained by this step. No GMS, Greeze, Doze, wakelock or network exceptions
  are added.
- **Historical ZK reference:** `A16/EU/backupzk.zip` is retained. When an
  EU build runs, the dispatcher safely extracts this archive to
  `build/references/zk_eu/` and writes `_unpack_manifest.json`.
  The unpacked reference is **not installed into the ROM**, and its scripts
  are never executed.
- CorePatch, Kaorios, TNM, Android 17 and China paths are unchanged.

No actual EU ROM build is claimed by this policy change.
