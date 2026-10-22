# Android 16 notification and power policy — CN / Xiaomi.eu

- `CN/`: existing China FrameworkPatcher and PowerKeeper workflow, unchanged.
- `EU/`: `ContentCatcher_EU.sh` plus verified ZK304 notification initialization, and `PowerKeeper_ZK.sh` to merge compatible ZK304 power policy **methods** into the EU-supplied APK, preserving EU-only classes and method signatures.
- `EU/ZK304/`: SHA256-pinned original ZK304 `miui-services.jar` and PowerKeeper DEX reference. Build always verifies donor checksums.

EU workflow:

1. Preserve the original EU ContentCatcher behavior as previously requested.
2. Verify native `IS_INTERNATIONAL_BUILD` references in 10 broadcast/Doze/process/notification methods, without injecting a fictitious `IS_ZK_BUILD` class or hardcoding region values.
3. Port the verified ZK304 `NotificationManagerServiceImpl.<clinit>` difference: remove the extra EU cached build-flag assignment, while comparing the result with the real ZK304 donor.
4. Use the ZK PowerKeeper donor to replace only ABI-compatible original EU methods in the selected `GmsObserver`, `DeviceIdleController`, `ActiveStateController` and `KillProcessController` controllers; report every method ported, skipped, or missing. Recompile/verify the resulting EU DEX before APK replacement.
5. Retain Android's original freezer, Greeze, Doze, thermal limits and EU PowerKeeper package resources. Do not replace entire ZK JAR or blindly remove EU-only APIs.

**This is a guarded policy port, not byte-identical full ZKOS.** Methods requiring missing ZK-private APIs are excluded; their names and reasons are written to `build/reports/zk304-powerkeeper-eu/methods.json`. The previous HyperMOS-specific FCM override was disabled in the ZK-parity build because it does not exist in the ZK donor.

**Risk:** Replacing `classes.dex` invalidates the original Xiaomi APK's cryptographic signature. The current firmware relies on its separate signature policy. Build-time smali assembly does not prove Android service boot or runtime notification delivery. Imported ZK background-activity policies can change standby battery or freezing behavior. Before normal use, verify PowerKeeper starts, `Greezer Denial` counts, notification latency and idle drain.

Test: `python3 -m unittest discover -s bin/package/NOTIFICATION_FIX/A16/EU/tests -v`; a GitHub Actions workflow also merges real DEX inputs and recompiles them.
