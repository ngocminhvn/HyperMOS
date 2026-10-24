# Xiaomi.eu Android 16: Global303 and scoped ZK304 improvements

**Current implementation:** `bin/package/NOTIFICATION_FIX/A16/EU/policy_delta.py`
using `policy_deltas.json` (roughly 14 KB of exact instruction-span edits).

- Original EU JAR with 3 Global303 MiuiBatteryIntelligence method changes
  and MAP_APP field correction, one ZK304 important-app caching method,
  and HyperMOS scoped Play Services FCM exception.
- Original EU PowerKeeper DEX with 7 targeted Global303 policy edits and
  ZK304 GmsObserver / ActiveStateController selected edits.
- 2 additional GmsObserver enable/disable methods match EU already; they
  have no modifications.
- No full donor JAR, APK or DEX and no checked-in Global/ZK binary archive.
- China branch, thermal limits, TNM, CorePatch and Kaorios are unchanged.
- Original PowerKeeper manifest/assets/resources/META-INF retained, but the
  original APK cryptographic signature does not remain valid after DEX edits.

Validated on real donor inputs with assemble/disassemble and exact scope:
https://github.com/ngocminhvn/HyperMOS/actions/runs/40056239788

Host checks cannot establish on-device boot, temperature, idle drain or
notification latency; these still require a device test.
