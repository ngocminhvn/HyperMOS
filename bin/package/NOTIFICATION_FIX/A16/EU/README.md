# Xiaomi.eu A16 policy — method-level deltas (no donor DEX)

Active entry: `patch.sh`. Data: `policy_deltas.json` (~14 KB).

`policy_delta.py` checks original EU method hashes and applies only the
listed changed smali lines. Unlike the retired ZK/Global donor archives, the
ROM build no longer unpacks full foreign JAR/APK/DEX files. The full donor
binaries remain recoverable in Git history if an audit is ever required.

## Patched classes

- `miui-services.jar`: three Global303 `MiuiBatteryIntelligence` methods
  and `MAP_APP` field; ZK304
  `InternationalPolicyManager.getImportantApps()`.
- `GreezeManagerService.isAllowBroadcast`: existing HyperMOS scoped
  `com.google.android.gms` / `com.google.android.c2dm.intent.RECEIVE`
  exception. All other native EU Greeze, region and Doze logic remains.
- `PowerKeeper.apk`: seven selected Global303 methods, ZK304
  `GmsObserver.isGmsControlEnabled()` and
  `ActiveStateController.dealNoRestrictApp()`. The two GmsObserver
  enable/disable functions matched EU originally, so are not rewritten.
- No change to EU KillProcessController, other Millet methods, thermal,
  stock vendor power limits, or any China ROM policy.

The manifest is compiled directly onto the original EU Android 16 APK/JAR,
never replaces an entire donor class. A mismatch to audited EU309 aborts.
The APK's original META-INF data is copied but its original digital signature
is not cryptographically valid after DEX modification. Firmware signature
compatibility and runtime stability require actual device verification.

Preflight with original EU309/Global303/ZK304 inputs and post-assembly
method checks: https://github.com/ngocminhvn/HyperMOS/actions/runs/40056239788
