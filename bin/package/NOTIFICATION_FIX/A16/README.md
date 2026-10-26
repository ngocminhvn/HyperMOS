# Android 16 notification patches

- China: existing FrameworkPatcher/PowerKeeper paths unchanged.
- Xiaomi.eu: `EU/zk_patch.py` ports selected original ZK304
  NotificationManager, Greeze/Doze and PowerKeeper methods into stock EU
  JAR/APK, then applies the seven behavior differences common to the
  Global303/Taiwan303 PowerKeeper DEX. Required ZK donor DEX files under
  `EU/class/` remain `miui-services/classes.dex` and `powerkeeper/classes.dex`.
- Global/Taiwan layer: cloud update receiver and server selection (remove EU
  XOpt-only gate), InternationalAdapter static defaults, PowerModeAdapter maps,
  Sleep Mode UI fallback and DynamicTurboPower region gate. These are scoped
  structural method edits, *not* a whole Global/Taiwan APK or tablet swap.
- Taiwan-only `PadSleepModeController` changes are skipped on phones. ZK/EU
  `GmsObserver`, original EU `KillProcessController.setUidState(IZ)V` and
  original EU `InternationalPolicyManager.getImportantApps()` stay protected.
- The Global/Taiwan edits require matching EU smali patterns and fail the
  build if incompatible. The resulting code is not claimed to be globally
  byte-for-byte identical, and runtime policy/cloud data must be tested.
- `miui-services/classes2.dex` is omitted because it contains none of the
  classes targeted by the EU method-level port.
- The EU directory contains only **one script and two DEX files**.
  No ZIP, Zstandard, JSON manifest, SHA donor checks, duplicate test scripts,
  daemon or resident service. Input DEX structure, method ABI, DEX assembly
  and non-DEX APK member integrity are still checked.
- Editing PowerKeeper DEX invalidates the original APK signature. Boot,
  notifications and battery need verification on-device.
