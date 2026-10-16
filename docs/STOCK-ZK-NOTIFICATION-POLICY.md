# HAOTIAN mixed PowerKeeper policy: guarded UID cleanup + preserved GMS / thermal (Android 16)

## Actual donor evidence

- \`bin/package/NOTIFICATION_FIX/A16/classes.dex\` is the original uploaded ZKOS
  PowerKeeper DEX, pinned by Git blob
  \`f229fb0a5c67d41a55310a119ef64b18a86d6c04\`.
- The pinned DEX matches the \`classes.dex\` from the uploaded
  \`PowerKeeperZK.apk\`; this is checked prior to build.
- The EU reference APK has guarded `setUidState(IZ)V` and
  `shouldKillByCheckerPolicy(I)Z` methods, unlike the ZK DEX. The build now
  transplants the corresponding **conditional UID cleanup methods** from the
  checked-in RYU method donor into the ZK PowerKeeper class, preserving
  locked-app / visible-window / current-IME checks and allowing the
  policy-gated `ProcessManager.kill()` path. This recreates the relevant
  EU-style behavior; it is **not** a claim of byte-identical EU methods.
- The 20 isolated RYU PerfHook classes and their passive onCreate initializer
  remain independently grafted under the TNM namespace.
- Original ZKOS `GmsObserver`, `ActiveStateController`, Millet, freeze/UID,
  and thermal policy execution is retained. In `KillProcessController`, only
  `setUidState` and the conditional policy checker are taken from the RYU
  donor; other ZK methods are left unchanged.
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

## Android 16 conditional UID-kill ABI restoration

The original ZK donor declares \`PowerKeeperInterface$l.setUidPolicy\` but **not**
\`getUidPolicy(I)Landroid/os/Bundle;\`. The EU/RYU \`setUidState\` method calls
\`shouldKillByCheckerPolicy\`, which reads the missing interface method. Porting
those two methods alone creates a possible \`NoSuchMethodError\`.

The build now restores the abstract interface declaration and the matching
concrete \`AppRuleChecker.getUidPolicy\` implementation. It reads the existing
per-UID non-hot policy (\`AppRuleChecker$j.e.a\`) under the same checker lock and
returns a Bundle with the \`POLICY\` key, the **only** field consumed by the
imported kill decision. The existing \`HideModeStateMachineWrapper\` implementor
already defines \`getUidPolicy\`; both known implementors are checked.
The restored getter deliberately does **not** claim full EU hot/delay Bundle
parity. It introduces no background service, timer or polling.

Traced local-config path in ZK/EU:
\`assets/local.config\` -> \`LocalUpdateUtils\` -> cloud app DB ->
\`PowerKeeperAppConfigure\` -> \`toKillProcessAppRuleCheckerParams\` ->
\`PowerKeeperConfigureManager\` -> \`AppRuleChecker\`.
\`set_data_connection=true\` maps to \`bgData\` (background network permission).
\`kill_delay_hot=-2\` maps to \`k_delay_hot\` ->
\`bgKillDelayMinutesHot\` -> \`HOT_DELAY_MINUTE\`.
The conditional UID kill, however, checks \`POLICY\` (values 1 and 2), not
\`HOT_DELAY_MINUTE\`. These config entries alone **do not prove** that
\`com.google.android.gms\` is immune to \`ProcessManager.kill()\`; no new GMS
unrestricted/polling policy is applied in this ABI fix.

A preflight verifies the ABI restoration and aborts if the donor interface,
two known implementations, or backing per-UID policy fields drift.
Compilation and real-world boot/FCM tests are still required.

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
layouts. CI runs conditional-UID synthetic tests before building. No successful
full flash/boot, notification-latency comparison or standby drain/thermal
safety result is established by source changes alone.
Verify a completed ROM build and runtime on HAOTIAN before judging parity.

## RYU-style PerfHook and CPU percentage control (80–100%)

The RYU PerfHook is an isolated addition to the underlying ZK power controls,
independent of the now-restored EU-style conditional UID kill. It adds its
original per-app Settings.System observer and application initialization.

The donor PerfHook `init()` formerly invoked `applyInitialZeroOnce()`
(`sconfig=0`) and `updateConfig()` at boot. HyperMOS strips **only those
two boot-time calls**, retaining observer and foreground callbacks so that
explicit TNM settings changes can activate per-app logic. Frequency discovery
is read-only. Other, explicitly enabled RYU PerfHook profiles may still adjust
governors/GPU; the separate CPU 80–100% slider never uses those profile paths.
Kernel thermal mechanisms remain stock. This is source-audited, not yet
validated by a flashed device.


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

## Google FCM permissions: supplied ZK overlay

`product/etc/permissions/google-zk-permissions.xml` is copied directly
from the user-supplied ZK-named XML (Litegapps header; 76 privapp package
groups). Build preflight pins SHA256
`dc5064a434ee8005eec31c04b0f7e6904e9dbc04f429c829121c7f981ae3b29b`.
It is installed by the existing GMS16 product payload copy, **not** in place
of `product/etc/sysconfig/google.xml`.

The separately supplied `google.xml` contains two entries absent from the
current HyperMOS `google.xml`: a OneTimeInitializer implicit broadcast and a
SearchSelector setup exemption. Both relate to apps not part of the intended
minimal HyperMOS GMS install, so no new background keepalive exemptions are
added. The HyperMOS Google sysconfig has other modern exemptions/associations
not present in the supplied file; these are left untouched rather than
replacing newer configuration with a potentially older Google reference.

Privapp permissions and GMS sysconfig are fundamentally different inputs;
installing the ZK-named permissions is **not** proof of FCM runtime parity.
Actual permission grants depend on APK partition/location and Android version.

