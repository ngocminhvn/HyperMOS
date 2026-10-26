# Xiaomi.eu A16: stock notification/power policy

The Global303/Taiwan303 port and all EU-specific PowerKeeper,
AppOps and NotificationFilterHelper smali patch scripts are removed.
The EU dispatcher now only extracts `backupzk.zip` as an offline reference.

- Original backup: `backupzk.zip` (unchanged, never installed).
- Reproducible unpacker: `unpack_backupzk.py`.
- Extraction destination during EU build: `build/references/zk_eu/`.
- Member inventory and SHA-256 are recorded in
  `build/references/zk_eu/_unpack_manifest.json`.
- No ZK or RYU code is enabled merely by unpacking. Original EU
  JARs and `PowerKeeper.apk` stay unchanged by NOTIFICATION_FIX.
- China notification policy remains separate.

To unpack in a local working copy:
```bash
python3 bin/package/NOTIFICATION_FIX/A16/EU/unpack_backupzk.py \
  --archive bin/package/NOTIFICATION_FIX/A16/EU/backupzk.zip \
  --output bin/package/NOTIFICATION_FIX/A16/EU/zk_extracted
```
