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
