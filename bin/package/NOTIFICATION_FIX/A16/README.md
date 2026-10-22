# Android 16 notification and power policy — CN / Xiaomi.eu

`A16/patch.sh` is the shared A16 entrypoint and JAR lifecycle.
It selects the original China or Xiaomi.eu Python patchers by `rom_source.txt`,
while preserving their distinct donor hashes, methods, reports and policy checks.
For A17, `A17/patch.sh` now exposes the same version-entrypoint convention
without importing any Android 16 donor or policy code.

- `CN/`: existing China FrameworkPatcher Python policy and PowerKeeper workflow; the previous FrameworkPatcher shell wrapper is merged into `A16/patch.sh`.
- `EU/`: `A16/patch.sh` retains the ZK304 Greeze/notification framework port. **The extra `PowerKeeper_ZK.sh` 61-method APK port is temporarily disabled by default** to preserve the working #181 PowerKeeper behavior. The script and original donor remain available but are not invoked.
- `EU/ZK304/`: SHA256-pinned original ZK304 `miui-services.jar` and PowerKeeper DEX reference. Build always verifies donor checksums.

EU workflow:

1. Preserve the original EU ContentCatcher behavior as previously requested.
2. Verify native `IS_INTERNATIONAL_BUILD` references in 10 broadcast/Doze/process/notification methods, without injecting a fictitious `IS_ZK_BUILD` class or hardcoding region values.
3. Port the verified ZK304 `NotificationManagerServiceImpl.<clinit>` difference, verifying its result against the original ZK donor. Then copy eight donor method bodies covering `GreezeManagerService.freezeAction`, `freezeUids`, `isAllowBroadcast`, `updateDynamicIsLandInfo`, two `InternationalPolicyManager` handlers, `DeviceIdleControllerStubImpl.isLowPowerDozeEnable` and `ProcessManagerService.notifyProcessStarted`, preserving EU-only callbacks and constructors.
4. The 61-method ZK304 PowerKeeper donor transplant into `GmsObserver`, `DeviceIdleController`, `ActiveStateController`, and `KillProcessController` is **temporarily disabled** in the default EU Android 16 build. The existing #181 APK handling stays unchanged. The method-merger remains available for future controlled testing.
5. Retain Android's original freezer, Greeze, Doze, thermal limits and EU PowerKeeper package resources. Do not replace entire ZK JAR or blindly remove EU-only APIs.

**This is a guarded policy port, not byte-identical full ZKOS.** ZK and EU still have ABI differences in entire framework/services packages. The method-level transfer does not claim to reproduce all carrier/Google/APK integration, all supporting JARs, or tested runtime power draw. Methods requiring missing ZK-private APIs are excluded; their names and reasons are written to `build/reports/zk304-powerkeeper-eu/methods.json`. The previous HyperMOS-specific FCM override was disabled in the ZK-parity build because it does not exist in the ZK donor.

**Risk:** Replacing `classes.dex` invalidates the original Xiaomi APK's cryptographic signature. The current firmware relies on its separate signature policy. Build-time smali assembly does not prove Android service boot or runtime notification delivery. Imported ZK background-activity policies can change standby battery or freezing behavior. Before normal use, verify PowerKeeper starts, `Greezer Denial` counts, notification latency and idle drain.

Test: `python3 -m unittest discover -s bin/package/NOTIFICATION_FIX/A16/EU/tests -v`; a GitHub Actions workflow also merges real DEX inputs and recompiles them.

## Actual CI verification on original donors

The [donor-based EU309/ZK304 preflight](https://github.com/ngocminhvn/HyperMOS/actions/runs/39792507522) succeeded: eight additional Greeze/Doze/process method bodies were ported into original EU309 `miui-services.jar`, and both DEX were reassembled. The [PowerKeeper donor preflight](https://github.com/ngocminhvn/HyperMOS/actions/runs/39787201551) passed its method-level checks (61 changed, 98 equivalent).

**Retained PowerKeeper packaging path (inactive on current main):** the previous [EU build failure](https://github.com/ngocminhvn/HyperMOS/actions/runs/39790269239) was caused by a strict original-Xiaomi-certificate verification step in the APK packer, which was not part of the intended metadata-preserving contract. The new EU-only `eu_powerkeeper_keep_metadata.py` copies the entire original ZIP entry inventory, all original `META-INF` contents, manifest, resources, assets, JNI and all other non-DEX bytes unchanged, replacing `classes.dex` only. After zipalign the result is verified against the original, then installed. **There is no `apksigner` verification or signing step in the EU PowerKeeper port.** CN signature handling is unchanged.

**Cryptographic limitation:** the original certificate file content is preserved, but replacing classes.dex invalidates the original digital signature, and any v2/v3 signing block is not reconstructed. The result requires the ROM runtime to accept the modified APK. Metadata preservation does not prove package integrity or boot compatibility; successful APK packaging alone does not prove runtime loading, standby battery, or notification delivery.

**TNM App Privacy is independent** from this PowerKeeper path and is required for CN and Xiaomi.eu Android 16 by `bin/package/TNM`.

**Current main safety choice:** EU Android 16 still ports ZK304 notification/Greeze framework methods, but does not call `EU/PowerKeeper_ZK.sh`. The China A16 PowerKeeper path is unchanged, and TNM App Privacy is managed independently. This temporary pause does not undo the existing #181 PowerKeeper integration from the normal build/mod stages.
