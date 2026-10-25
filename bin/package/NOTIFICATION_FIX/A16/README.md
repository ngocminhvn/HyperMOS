# HyperMOS Android 16: independent China and Xiaomi.eu notification policies

Entry point: `bin/package/NOTIFICATION_FIX/A16/patch.sh`.

- **China:** Existing `CN/frameworkpatcher_cn_a16.py` and
  `CN/PowerKeeper.sh` stay unchanged.
- **Xiaomi.eu:** `EU/patch.sh` applies two method-specific GMS/C2DM guards
  in `miui-services.jar`:
  `EU/fcm_autostart.py` and `EU/fcm_greeze.py`.
  Their checks cover **all eligible applications**, not a fixed whitelist.
- Four independent user-requested method changes remain in
  `EU/ryu_policy.py` / `EU/ryu_policy.json`: ContentCatcher,
  PackageManager's two no-op gates and ActivitySecurityHelper.
- The other 15 RYU broad international overrides are no longer active.
  EU keeps its original `CN_MODEL`, screen/idle state, Doze, power
  management and process cleanup policy.
- EU `PowerKeeper.apk` is **not modified**. Its DEX, signing metadata
  and signature remain intact. No PerfHook, daemon, extra thermal rules
  or foreign JAR/DEX transplant.
- `backupzk.zip` is inactive historical reference; branch `eu_global`
  is only for retrospective comparison.

The patch fails closed if the EU method layout changes. It verifies
post-assembly opcodes after DEX round-trip, but an actual ROM build, boot,
idle push test and battery/heat test are still required.
