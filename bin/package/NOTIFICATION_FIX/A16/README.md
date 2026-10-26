# Android 16 notification patches

- China: existing FrameworkPatcher/PowerKeeper paths unchanged.
- Xiaomi.eu: `EU/zk_patch.py` selectively ports original ZK304
  NotificationManager, Greeze/Doze and PowerKeeper methods into stock EU
  JAR/APK. Original donor DEX files are under `EU/class/`:
  `miui-services/classes.dex`, `miui-services/classes2.dex`,
  `powerkeeper/classes.dex`.
- The EU directory contains only **one script and three DEX files**.
  No ZIP, Zstandard, JSON manifest, SHA donor checks, duplicate test scripts,
  daemon or resident service. Input DEX structure, method ABI, DEX assembly
  and non-DEX APK member integrity are still checked.
- Editing PowerKeeper DEX invalidates the original APK signature. Boot,
  notifications and battery need verification on-device.
