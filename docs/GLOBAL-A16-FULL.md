# Archived Global303 + ZK304 EU policy (eu_global)

This document describes the historical implementation preserved in the
[eu_global branch](https://github.com/ngocminhvn/HyperMOS/tree/eu_global)
at commit ae8549d17784b752b418af821c5f07468a133dda.

It is no longer the active policy of main. The previous method-level
manifest is eu_global/bin/package/NOTIFICATION_FIX/A16/EU/policy_deltas.json.

The archived policy contained:
- Global303 seven PowerKeeper method edits, while retaining APK non-DEX
  ZIP members; digital signatures were not valid after modifying DEX.
- ZK304 InternationalPolicyManager.getImportantApps caching.
- Scoped Google FCM exception in Greeze.
- Original EU MiuiBatteryIntelligence / MAP_APP.

For main's replacement, see
bin/package/NOTIFICATION_FIX/A16/EU/README.md and ryu_policy.json.
The new RYU-based main policy retains stock PowerKeeper (no APK mutation,
no signature invalidation), excludes PerfHook, thermal and custom FPS changes,
and targets only selected miui-services.jar method gates.

Preflight run 40056239788 validated the OLD archived Global/ZK policy,
not the RYU implementation on main. Boot, idle notification, battery and
thermal behavior of main's RYU policy still require device tests.
