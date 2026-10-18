# HAOTIAN Android 16 PowerKeeper: real EU DEX on Xiaomi original APK

## Active build

This build replaces the base ROM's PowerKeeper **classes.dex only** with the
EXACT classes.dex extracted from the user's uploaded `PowerKeeperEU.apk`
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

This is genuine **EU donor DEX**, not “stock-first EU-like policy” and not
a rebadged ZKOS/RYU DEX. Byte-identical EU PowerKeeper bytecode does NOT
prove that all ROM framework services are identical to EU or that thermal
or notification results will improve. Device boot and runtime tests are
still necessary.
