# Android 16 Xiaomi.eu — Global303 policy profile (main)

Scope: `rom_source=xiaomi_eu`, Android 16, SDK 36. The Xiaomi.eu ROM
continues to supply all framework JARs, vendor/ODM resources, thermal files
and APK resources. Global donor: Xiaomi 15 (dada) OS3.0.303.0.WOCMIXM.
Target: Xiaomi 15 Pro (haotian) Xiaomi.eu.

The audited Global303 vs unmodified EU JAR comparison found identical
normalized executable methods in BroadcastQueueModernStubImpl (53),
GreezeManagerService (317), DeviceIdleControllerStubImpl (10) and
KillProcessController (23). It is **not** necessary or safe to replace
whole JARs, their class inventories or EU-only callbacks.

Active EU A16 behavior:
- Skip the ZK304 NotificationManager static initializer, Greeze,
  InternationalPolicyManager, ProcessManager and Doze method transplants.
- Keep the unmodified EU/Global-equivalent Broadcast/Greeze/Doze paths.
- Skip HyperMOS ContentCatcher=false rewriting for EU A16; retain
  the original Xiaomi.eu implementation.
- Replace *only* original EU PowerKeeper `classes.dex` with the byte-for-byte
  Global303 `classes.dex`. The two donors have the same 2,953 classes and
  17,818 executable method definitions; Global has seven known changes
  relative to the unmodified EU APK, primarily cloud/region policy.
- Keep every non-DEX member of the original EU APK byte-for-byte, including
  manifest, resources, assets, native libraries and META-INF files.
  Zipalign is retained; APK is **not** signed. Preserving original signature
  *files* does not make the changed APK's cryptographic signature valid.
- Do not alter Kaorios, TNM, signature patch routing, UI, or vendor thermal.

Donor acquisition: the pin-global-a16 workflow on this commit snapshots a
SHA256-verified donor into `bin/package/GLOBAL_A16/global-powerkeeper.dex.zst`.
Before that pin commit exists, builds can fetch the archived extraction from
GitHub Actions. Actions artifacts expire; builds **fail** rather than silently
ship EU/ZK policies if neither pinned blob nor a verified artifact is available.
If a pin fails, rerun `dump-dada-global.yml`, then run the pin workflow.

Checks: APK package/version/minSdk, donor SHA, executable method inventory,
non-DEX preservation, output DEX and ZIP consistency. No heavy suite or
cross-device resource ID migration is claimed.

Risk: Global DEX on EU resources may still have untested runtime dependencies.
Build success cannot prove boot, notification parity, temperature or standby
power. Keep a backup and compare heat/FCM on device against HyperMOS #181.
