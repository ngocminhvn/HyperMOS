# Android 16 notification patches

- China: existing FrameworkPatcher/PowerKeeper paths unchanged.
- Xiaomi.eu: `EU/zk_patch.py` selectively ports original ZK304
  NotificationManager, Greeze/Doze and PowerKeeper methods into stock EU
  JAR/APK. Required donor DEX files under `EU/class/` are:
  `miui-services/classes.dex` and `powerkeeper/classes.dex`.
- `miui-services/classes2.dex` is omitted because it contains none of the
  classes targeted by the EU method-level port.
- The EU directory contains only **one script and two DEX files**.
  No ZIP, Zstandard, JSON manifest, SHA donor checks, duplicate test scripts,
  daemon or resident service. Input DEX structure, method ABI, DEX assembly
  and non-DEX APK member integrity are still checked.
- Editing PowerKeeper DEX invalidates the original APK signature. Boot,
  notifications and battery need verification on-device.
