# HAOTIAN ZKOS power / thermal / notification parity (Android 16)

## Actual donor evidence

- \`bin/package/NOTIFICATION_FIX/A16/classes.dex\` is the original uploaded ZKOS
  PowerKeeper DEX, pinned by Git blob
  \`f229fb0a5c67d41a55310a119ef64b18a86d6c04\`.
- The pinned DEX matches the \`classes.dex\` from the uploaded
  \`PowerKeeperZK.apk\`; this is checked prior to build.
- RYU KillProcessController methods are **not** transplanted: ZKOS owns all
  UID-kill, GMS, Greeze, Doze and notification policy. Only the 20 isolated
  RYU per-app PerfHook classes and their onCreate initializer are restored;
  they are moved under the TNM namespace without replacing ZKOS kill methods.
- Original ZKOS GmsObserver, ActiveStateController, KillProcessController,
  Millet, freeze/UID and thermal policy execution is retained.
- Only ZK integration identity is translated to TNM
  (\`IS_ZK_BUILD\` -> \`IS_TNM_BUILD\`, SettingsHelper, and local TNM settings
  names). The unavailable \`zk_state\` HAOTIAN thermal endpoint is mapped to
  the existing stock \`temp_state\` endpoint. The donor product-property
  *lookup key* \`ro.product.zk_device\` is intentionally preserved because
  renaming a system-property lookup without a matching value would change
  behavior; it is not UI branding.
- This is **not** a byte-for-byte ZKOS APK: compiled adapted DEX replaces stock
  Xiaomi DEX, but the original Xiaomi AndroidManifest.xml, resources, assets,
  native libraries, and META-INF are retained and verified by content.

## Original ZKOS miui-services.jar deltas

The supplied ZKOS vs Xiaomi reference JARs contain exactly these **twelve**
code changes in common methods:

1. DeviceIdleControllerStubImpl.<clinit> build field
2. BroadcastQueueModernStubImpl.checkApplicationAutoStart build field
3. BroadcastQueueModernStubImpl.checkReceiverAppDealBroadcast build field
4. BroadcastQueueModernStubImpl.isInternationalSpecialAction build field
5. BroadcastQueueModernStubImpl.updateBlockBroadcast build field
6. ProcessManagerService.isForceStopEnable build field
7. ProcessSceneCleaner.handleSwipeKill build field
8. ProcessSceneCleaner.killAppForHasOtherTask build field
9. JobServiceContextImpl.checkIfCancelJob build field
10. NotificationManagerServiceImpl.checkFullScreenIntent build field
11. NotificationManagerServiceImpl.<clinit> removes the existing Xiaomi static
    assignment of IS_INTERNATIONAL_BUILD
12. Greeze PolicyManager.<clinit> changes a literal region comparison
    \`CN\` -> \`ZK\`

\`tnm_zk_power_a16.py\` preserves the underlying ZK branch control flow and
substitutes \`Lcom/android/tnm/TNMBuild;->IS_TNM_BUILD:Z\`, with the value true.
The literal Greeze region compare uses \`TNM\` rather than \`ZK\`.
It does not blanket-force all background APIs or whitelist all GMS apps.
The older RYU FCM/first-boot/FGS one-off patch is **not selected** in
\`COREPATCH/update.sh\`, and overlapping legacy gates are excluded from the
active \`hypermos-zk-power\` compatibility profile. Other unrelated HyperMOS
patches and their existing flags remain unchanged.

Original ZKOS vs uploaded Xiaomi \`framework.jar\`: the 1,701 common methods
in the audited focus classes had identical normalized instructions. Do not
transplant the entire framework.jar from another build. The
\`miui-framework.jar\` and \`services.jar\` donors from ZKOS were not separately
provided, so full cross-JAR bit parity is **not** claimed.

## APK metadata, Android signing and validation

PowerKeeper's verified Xiaomi stock APK is the source of every non-DEX member
and of META-INF/CERT.RSA, CERT.SF and MANIFEST.MF. The original certificate
identity is retained just as before, **but the signature is not cryptographically
valid after replacing DEX**. This flow relies on the ROM's independently
configured signature-verification policy. It cannot be called a valid signed
Xiaomi APK. The integrity and byte-for-byte *content* equality of non-DEX ZIP
members are checked by \`preserve_powerkeeper_identity.py\`.

This source patch uses checked smali method signatures and aborts on unexpected
layouts. No successful full flash/boot, notification-latency comparison or
standby drain/thermal safety result is established by source changes alone.
Verify a completed ROM build and runtime on HAOTIAN before judging parity.

## RYU-style PerfHook and CPU percentage control (80–100%)

The RYU PerfHook is an **explicit exception** to the otherwise original ZKOS
background and notification policy. It adds its original per-app Settings.System
observer and application initialization, but no RYU UID-kill override.

The new ROM-provided `/system_ext/bin/tnm-cpuctl` is root-only and executes
**only when TNM requests it**. It caps CPU `scaling_max_freq` for the real
cpufreq policy clusters to 80–100% of each cluster's `cpuinfo_max_freq`,
rounding down to supported operating points where available. It never edits
thermal/ODM XML, GPU policy, governors, boost XML, `scaling_min_freq`,
charging profiles, thermal services or sysfs permissions. It records the
pre-existing max as a per-boot restore ceiling and refuses to raise a cap
that another owner lowered. 100% requests restoring that saved ceiling,
**not overriding kernel thermal throttling**. Results require sysfs readback;
hardware effective clocks remain under kernel/vendor control.

The CPU % limit is on-demand and is **not automatically re-applied after a
reboot**. There is no resident monitor, init service or boot root escalation.
TNM's app/Rust backend exposes `rom.cpu.percent` and `rom.cpu.status`.

Historical TNM thermal XML import on HAOTIAN A16 remains disabled, so CPU
percent is not implemented as an ODM or powerhint config rewrite.
