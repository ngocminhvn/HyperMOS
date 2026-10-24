# Xiaomi.eu A16 policy — method-level deltas (no donor DEX)

Active entry: `patch.sh`. Data: `policy_deltas.json` (method-level edits only).

`policy_delta.py` checks class/method signatures and original smali opcode
anchors, not per-device method SHA-256 hashes, before applying targeted edits. Unlike the retired ZK/Global donor archives, the
ROM build no longer unpacks full foreign JAR/APK/DEX files. The full donor
binaries remain recoverable in Git history if an audit is ever required.

## Patched classes

- `miui-services.jar`: do not inspect, verify or patch EU
  `MiuiBatteryIntelligence` / `MAP_APP` at all. Its original device-specific
  navigation-app list remains unchanged automatically. Only ZK304
  `InternationalPolicyManager.getImportantApps()` is ported.
- `GreezeManagerService.isAllowBroadcast`: existing HyperMOS scoped
  `com.google.android.gms` / `com.google.android.c2dm.intent.RECEIVE`
  exception. All other native EU Greeze, region and Doze logic remains.
- `PowerKeeper.apk`: seven selected Global303 methods only. ZK304
  `GmsObserver.isGmsControlEnabled`, `enableGms`, `disableGms` and
  `ActiveStateController.dealNoRestrictApp` are **not patched**: they match
  original EU behavior (the bytecode differences are string opcode encoding
  and jump-label offsets, or no differences at all). Keep stock EU GMS/Millet.
- ZK304: only `InternationalPolicyManager.getImportantApps()` in
  `miui-services.jar` changes behavior by reusing an existing nonempty app
  list. Keep `backupzk.zip` as an inactive source/reference.
- No change to EU KillProcessController, other Millet methods, thermal,
  stock vendor power limits, or any China ROM policy.

The manifest is applied directly to the original EU Android 16 APK/JAR,
never replaces an entire donor class. Missing/ambiguous instruction anchors abort instead of blindly patching another ROM.
The APK's original META-INF data is copied but its original digital signature
is not cryptographically valid after DEX modification. Firmware signature
compatibility and runtime stability require actual device verification.

Preflight with original EU309/Global303/ZK304 inputs and post-assembly
method checks: https://github.com/ngocminhvn/HyperMOS/actions/runs/40056239788
