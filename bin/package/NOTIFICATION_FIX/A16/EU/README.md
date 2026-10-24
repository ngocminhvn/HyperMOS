# Xiaomi.eu A16 policy — method-level deltas (no donor DEX)

Active entry: `patch.sh`. Data: `policy_deltas.json` (~14 KB).

`policy_delta.py` checks class/method signatures and original smali opcode
anchors, not per-device method SHA-256 hashes, before applying targeted edits. Unlike the retired ZK/Global donor archives, the
ROM build no longer unpacks full foreign JAR/APK/DEX files. The full donor
binaries remain recoverable in Git history if an audit is ever required.

## Patched classes

- `miui-services.jar`: preserve original Xiaomi.eu `MiuiBatteryIntelligence`
  with all 18 map apps and its static `MAP_APP`; only ZK304
  `InternationalPolicyManager.getImportantApps()` is ported.
- `GreezeManagerService.isAllowBroadcast`: existing HyperMOS scoped
  `com.google.android.gms` / `com.google.android.c2dm.intent.RECEIVE`
  exception. All other native EU Greeze, region and Doze logic remains.
- `PowerKeeper.apk`: seven selected Global303 methods plus the four ZK304
  selected entries `GmsObserver.isGmsControlEnabled`, `enableGms`,
  `disableGms` and `ActiveStateController.dealNoRestrictApp`.
  The two enable/disable methods are unchanged relative to EU; the other
  ZK PowerKeeper differences are mostly string encoding and label changes,
  so they are not proof of different GMS/Millet runtime behavior.
- ZK304 also ports `InternationalPolicyManager.getImportantApps()` in
  `miui-services.jar`. Keep `backupzk.zip` solely as a reference.
- No change to EU KillProcessController, other Millet methods, thermal,
  stock vendor power limits, or any China ROM policy.

The manifest is applied directly to the original EU Android 16 APK/JAR,
never replaces an entire donor class. Missing/ambiguous instruction anchors abort instead of blindly patching another ROM.
The APK's original META-INF data is copied but its original digital signature
is not cryptographically valid after DEX modification. Firmware signature
compatibility and runtime stability require actual device verification.

Preflight with original EU309/Global303/ZK304 inputs and post-assembly
method checks: https://github.com/ngocminhvn/HyperMOS/actions/runs/40056239788
