# EU A16 — Global303 + scoped Google FCM delivery

Active EU path: `bin/package/NOTIFICATION_FIX/A16/EU/patch.sh`.

1. Preserve the Xiaomi.eu original `miui-services.jar` class layout.
2. Port the three previously audited Global303 `MiuiBatteryIntelligence`
   methods and `MAP_APP` field.
3. Apply **only** the legacy HyperMOS EU FCM exception to
   `GreezeManagerService.isAllowBroadcast`: when the broadcast's
   action is `com.google.android.c2dm.intent.RECEIVE` and the caller
   package parameter equals `com.google.android.gms`, return true;
   otherwise run the original EU logic without modification.
4. Keep the original `isRestrictReceiver`, `thawUidAsync`,
   `isNeedCachedBroadcast`, freeze policies, Region and Doze logic.
5. Reassemble the original EU JAR.
6. Port seven Global303 PowerKeeper policy method bodies into the original
   EU APK without re-signing (original APK signature becomes invalid).

The FCM exception originates from the former HyperMOS EU patch, **not**
byte-for-byte from original ZK304. The archived legacy source is in
`EU/backupzk.zip`. When evaluating original ZK-only method bodies, treat
`Lmiui/zk/Build;->IS_ZK_BUILD:Z` as a candidate alias of
`Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z` for this ROM target,
not as permission to globally rewrite unrelated Android properties.
This scoped FCM guard does not use either build flag.

Only Google Play Services C2DM receives get the allowBroadcast exception;
no blanket freeze disabling or exceptions for other actions. Actual app
notification delivery still depends on other Android and Xiaomi policies.
More app wakeups and energy usage are possible. Runtime FCM and battery
performance remain unverified on the device.

## Single-flash ZK304 candidate batch (EU Android 16)

Main pipeline now additionally selects **only** ZK304 `GmsObserver.isGmsControlEnabled`,
`enableGms`, `disableGms`, `InternationalPolicyManager.getImportantApps`,
and `ActiveStateController.dealNoRestrictApp` methods, after the Global303
method-level ports. The source is the SHA-pinned `backupzk.zip` already in
the repository. Identical donor methods are preserved, not falsely counted as
changed. The independent EU-only class/method inventory is retained.
ZK-private class references are rejected and only a method-local
`IS_ZK_BUILD` read is mapped to EU's native international build read.
A dependency mismatch fails the build rather than shipping a partial port.
No blanket GMS whitelist, Millet shutdown, background daemon or thermal
replacement is introduced by the patching script.

The Global303 PowerKeeper seven-method pre-port and FCM Greeze exception are
retained. Build artifacts report the exact changed and equal methods:
`build/reports/global-a16/zk-important-apps.json` and
`build/reports/global-a16/zk-gms-millet.json`. Full Android device behavior,
standby drain, notifications, signature acceptance and boot are **unverified**
until testing the ROM, even if host smali verification succeeds.
