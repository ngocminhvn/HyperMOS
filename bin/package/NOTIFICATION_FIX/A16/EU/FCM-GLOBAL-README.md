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
