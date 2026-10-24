# Xiaomi.eu Android 16: Global303 and scoped ZK304 improvements

**Current implementation:** `bin/package/NOTIFICATION_FIX/A16/EU/policy_delta.py`
using `policy_deltas.json` (roughly 14 KB of exact instruction-span edits).

- Xiaomi.eu `MiuiBatteryIntelligence` / `MAP_APP` is left completely alone:
  no Global303 import, app-list pinning or verification (device stock values
  remain intact). ZK304 important-app caching and HyperMOS scoped FCM
  exception remain.
- Original EU PowerKeeper DEX with 7 targeted Global303 policy edits;
  stock EU GmsObserver and ActiveStateController remain untouched. Their
  ZK304 variants are behaviorally equivalent and are not patched.
- The sole active ZK304 donor method is
  `InternationalPolicyManager.getImportantApps()` in `miui-services.jar`.
- No donor JAR, APK or DEX is used by the build patcher.
  `EU/backupzk.zip` remains stored solely for historical analysis.
- China branch, thermal limits, TNM, CorePatch and Kaorios are unchanged.
- Original PowerKeeper manifest/assets/resources/META-INF retained, but the
  original APK cryptographic signature does not remain valid after DEX edits.

Validated on real donor inputs with assemble/disassemble and exact scope:
https://github.com/ngocminhvn/HyperMOS/actions/runs/40056239788

Host checks cannot establish on-device boot, temperature, idle drain or
notification latency; these still require a device test.
