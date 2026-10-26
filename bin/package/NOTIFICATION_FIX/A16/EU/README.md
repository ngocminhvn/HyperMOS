# Xiaomi.eu Android 16: Global303-equivalent JAR notification and power policy

## Source comparison

Compared the original `miui-services.jar` from Xiaomi.eu EU309
(`HAOTIAN`, Xiaomi 15 Pro) with the original Global303
(`DADA`, Xiaomi 15; `OS3.0.303.0.WOCMIXM`) at the normalized DEX
instruction and resolved-reference level.

The following methods were **identical** in the two original JARs:

| Class | Method |
| --- | --- |
| `BroadcastQueueModernStubImpl` | `checkApplicationAutoStart` |
| `GreezeManagerService` | `isAllowBroadcast`, `isRestrictReceiver`, `freezeUids`, `freezeAction` |
| `PowerManagerServiceImpl` | `isWakelockDisabledByPolicy`, both `setUidPartialWakeLockDisabledState` overloads |
| `DeviceIdleControllerStubImpl` | `isLowPowerDozeEnable` |

**Outcome:** Do not transplant entire DADA JARs or insert custom
`com.google.android.c2dm.intent.RECEIVE`, `GCM_WORK`, or
`GCM_CONN_ALARM` bypasses. Xiaomi.eu already has the same native
implementations at these audited sites. The previous HyperMOS FCM
autostart, Greeze and wakelock exceptions are disabled on main.

`PowerKeeper.apk` is unchanged byte-for-byte by this EU notification
pipeline, including its DEX and original signature. China notification
patching, Doze, freeze/kill policy, Millet, thermal and TNM CPU controls
are outside this change and remain as before.

## Audited Global303 notification JAR port

A second comparison used the original EU309 and DADA Global303 archives for
`framework.jar`, `services.jar`, `miui-framework.jar` and
`miui-services.jar`. Xiaomi Greeze/Doze/Alarm/PowerManager/FCM wake-policy
paths remain equal after resolving DEX references, so no wake-lock or
CPU-stay-awake bypass is imported. `MiuiBatteryIntelligence` differs in the
device-specific `MAP_APP` navigation list (18 EU entries versus three
Global entries); this remains EU stock.

One real system-notification policy difference is in
`miui-framework.jar`/`miui.util.NotificationFilterHelper`. CorePatch's
EU A16 pass now ports exactly the two Global303 methods:

- `<clinit>()V`: initializes the 3-package blockable-system-app list,
  eight forced-enabled core packages, `com.xiaomi.xmsf` all-channel rule,
  and donor forced-channel/importance entries.
- `canSystemNotificationBeBlocked(Ljava/lang/String;)Z`: checks that
  blockable-system-app list instead of EU's unconditional `true`.

Porter:
`bin/package/COREPATCH/port_global_notification_filter_a16.py`.
It retains every other `NotificationFilterHelper` method and fails on
unexpected EU method/field/register layouts. Only EU A16 uses this port;
China's separate EU-filter method port is unchanged.

**Limit:** this adjusts system-package notification settings, not the
third-party Zalo/Messenger FCM delivery path. It does not prove lower
temperatures or fewer missed pushes. AppOps differences and the Android
`BroadcastController` debug-log difference were not transplanted because
their connection to missed FCM notifications is unproven.

## Independent non-notification patch

Main already contains one separate `ProcessPolicy.updateContentCatcherWhitelist()`
change in `ryu_policy.json`. It is kept unchanged because ContentCatcher
is not part of the requested battery/notification alignment. The EU patch
step still decodes/rebuilds `miui-services.jar` for this independent
method, validates the ZIP/DEX and verifies the change after reassembly.
CorePatch and Kaorios continue their separate passes.

## Scope and limitations

This comparison covers the named methods from **EU309 / Global303**, not
all ROM classes or every future source version. It does not prove
identical end-to-end power or FCM behavior: EU PowerKeeper, settings,
carrier configuration and device-specific binaries can differ.
A build, boot, screen-off FCM test, Wi-Fi/mobile handover test and
idle/thermal comparison are still needed to evaluate the runtime outcome.
