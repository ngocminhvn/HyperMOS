# HAOTIAN Android 16 PowerKeeper: real EU DEX on Xiaomi original APK

## Active build

This build replaces the base ROM's PowerKeeper **classes.dex only** with the
classes.dex extracted from the user's uploaded `PowerKeeperEU.apk`
(v4.2.00, versionCode 40200, Android 16). The normal Android package
`com.miui.powerkeeper`, APK path, manifest, resources, assets, native
libraries and v1 signature metadata come from the Xiaomi base ROM.

EU classes.dex SHA-256:
`ad30c2d2aa6d474c1b975bce8fb0f8816fc4dafe19fc825ff23022a5016f73ae`

EU DEX is reconstructed byte-for-byte offline from the pinned
`eu-powerkeeper-from-ryu.zst` binary delta. The existing pinned RYU DEX is
used only as a **zstd compression dictionary**. Neither RYU runtime classes
nor RYU performance hook methods are imported. This avoids a second donor
ROM download. The delta and dictionary Git blobs and resulting EU DEX SHA
are enforced at build time.

### Selected previous ZKOS adaptations

Exactly seven build flag reads in six **previously audited against ZKOS**
methods are adjusted in-place. The previous comparison results are frozen in
`bin/package/NOTIFICATION_FIX/A16/zk_gate_reference_a16.json`.
At build time the exact EU DEX, method inventory, counts, EU output checksum
and original EU KillProcessController fingerprint are verified. The old
4,074,428-byte ZKOS `classes.dex` is no longer required:

- `GmsObserver.<init>` and `updateGoogleSync`: one read each.
- `DeviceIdleController$1.<init>` and `$2.<init>`: one read each.
- `DisplayFrameSetting.getValidLocalConfigPath`: two reads.
- `DisplayFrameSetting.isSupportDevice`: one read.

These correspond to `IS_ZK_BUILD` branches in the supplied ZKOS DEX, which
were mapped to an enabled TNM build flag in the earlier implementation.
The EU `IS_INTERNATIONAL_BUILD` reads in these *specific* methods now act
as true. Other international, cloud, privacy, payment, temperature or device
property gates remain unmodified, as do RYU UID methods and PerfHook.
No new DEX classes, hooks, fields, resource overlays or persistent workers.

EU source SHA-256: `ad30c2d2aa6d474c1b975bce8fb0f8816fc4dafe19fc825ff23022a5016f73ae`

Scoped EU output SHA-256: `64efd5ef111c27b7040c6d89054b72bef9e01d5363075dd348098e866fa6e2f1`

The former ZK DEX was a **comparison-only** reference, never copied into the
APK. It has been removed from the current Git tree, with its original Git blob
SHA-1 preserved in the JSON manifest and its bytes recoverable from Git history.
Builds now verify the frozen comparison record, not the removed ZK binary.
The patch keeps instruction sizes constant and updates DEX header checksums;
all other EU method instructions are preserved. Runtime behavior needs testing.

### EU KillProcessController integrity check

All **23** executable `Lcom/miui/powerkeeper/controller/KillProcessController;`
methods (including `setUidState(IZ)V` and
`shouldKillByCheckerPolicy(I)Z`) must retain their exact EU instruction
sequences. The scoped port fails if any such method changes or disappears.
Instruction fingerprint for this original EU class:
`e4a1804e1e715fa9ab07e1d5cd5916c041a58d2e71b5677c4d85358027515f1f`.

No RYU conditional-UID import, no ZKOS kill bypass, and no additional GMS
exception is applied inside this class. A negative test modified a byte in
EU `setUidState()` and correctly caused the integrity guard to fail.
The check does not modify DEX output: scoped EU DEX SHA-256 remains unchanged.

### What the ROM ships

- Real EU PowerKeeper DEX, including EU `KillProcessController`,
  `GmsObserver`, `ActiveStateController`, DeviceIdle and thermal controllers.
- Xiaomi original non-DEX APK entries and corresponding resources/configs.
- No `PerfHook`, extra RYU workers, or ZKOS `SettingsHelper`.
- Independent TNM CPU-percent functionality unchanged.
- Separate HyperMOS framework/JAR notification patches unchanged.

### Signature and compatibility

Replacing DEX **invalidates the Xiaomi cryptographic APK signature**.
The build preserves Xiaomi's existing certificate files (`META-INF`),
which is NOT equivalent to a valid Xiaomi cryptographic signature.
Installation depends on the ROM's existing compatible signature policy.
The signature preservation report deliberately records
`cryptographic_signature_valid: false`. An original APK's authentic
signature is verified *before* modification.

The source must be `com.miui.powerkeeper`, versionCode 40200,
minSdkVersion 36. Mismatches fail the build instead of blindly importing a
foreign DEX. The installed non-DEX ZIP members are byte-comparable to the
Xiaomi base; the final DEX SHA is tested after zipalign.

This is the original **EU donor DEX with seven verified scoped ZK build-gate
adaptations**, not “stock-first EU-like policy” and not a rebadged ZKOS/RYU DEX. Byte-identical EU PowerKeeper bytecode does NOT
prove that all ROM framework services are identical to EU or that thermal
or notification results will improve. Device boot and runtime tests are
still necessary.
