# HAOTIAN A16: classic CN notification fix restored

## Active ROM build scope

`bin/package/COREPATCH/update.sh` (Android 16) enables ONLY these
feature flags:
- `--disable-signature-verification`: existing signature policy from build #150
- `--cn-notification-fix`: restored original pre-ZK broad CN notification fix
- `--disable-secure-flag`: existing FLAG_SECURE control

The Android 16 main build NO LONGER enables:
- `--tnm-zk-power-parity`: former ZKOS `miui-services.jar` Doze,
  broadcast, force-stop, scene cleanup, job, notification, and Greeze gates
- `--tnm-app-compat-gates`: former RYU-derived framework and app gates

### Original CN notification fix

The active `apply_miui_services_cn_notification_fix` and
`apply_miui_framework_cn_notification_fix` function bodies were restored
byte-for-byte from repository commit
`6b83518fc77a8342738634f5e2d56e347270be05` (before the ZK parity
class exclusions). This reinstates the complete original class list,
including `DeviceIdleControllerStubImpl`, `BroadcastQueueModernStubImpl`,
`AppOpsManagerInjector`, `ProcessManagerService` and Greeze.
The classic `PolicyManager.CN_MODEL=false` and framework `xBuild`
substitutions are retained, as originally authored.

The obsolete ZKOS/RYU JAR parity, TNM Doze, FCM policy and audited
compatibility scripts have been deleted from COREPATCH. Their retired flags
are rejected; the active A16 build only runs the three options above.

### Explicitly unchanged

- PowerKeeper EU DEX with its **seven selected ZK-referenced gate rewrites**
  (a separate PowerKeeper-specific adaptation, not the JAR ZKOS profile)
- All original EU `KillProcessController` methods
- Xiaomi stock system/vendor/ODM thermal and CPU profiles
- TNM's independent CPU percentage controller
- Build #150 signature-metadata preservation / CorePatch logic

### EU miui-services.jar comparison limitation

The existing uploads include a Xiaomi/unnamed `miui-services.jar` and
distinct ZKOS and RYU JARs, **but no independently identified or
authenticated xiaomi.eu `miui-services.jar` donor**.

The two uploaded files named `miui-services.jar` and
`miui-services(1).jar` are byte-identical (SHA-256 begins
`00561c82eccd541a1935`), whereas named ZKOS and RYU donors differ.
This is NOT evidence that the unnamed JAR is xiaomi.eu.

Do not port EU JAR methods or claim EU parity until a known xiaomi.eu JAR
from the matching Android 16 build is supplied and checked for API and
method compatibility.

Runtime notification delivery and idle power require a new full build
and physical HAOTIAN tests; static parity is not a boot test.

### Selected EU NotificationFilterHelper port

HyperMOS retains the wide, pre-ZK CN notification fix, then ports ONLY the
user-supplied xiaomi.eu `miui-framework.jar` behavior in
`miui/util/NotificationFilterHelper.smali`:

- `<clinit>()V`: remove the CN-only initialization of
  `sNotificationCanBeBlockedList` and hard-coded default forced-on and
  locked-importance notification package/channel entries. Keep the other
  original collections.
- `canSystemNotificationBeBlocked(Ljava/lang/String;)Z`: return true
  (matching EU), allowing system notification blocking in that helper.

These are the only two altered methods in this class. The patch is validated
against the expected CN method layout; unknown layouts fail the ROM build.
It is applied during the normal A16 `miui-framework.jar` rebuild, following
the existing CN notification adjustments.

**PowerInsightPolicy is deliberately not ported** per user request.
No `com.powerinsight.permission.PROVIDER_ACCESS` checks or helper methods
are injected. No changes are made to GMS sysconfig, PowerKeeper EU,
other framework methods, vendor thermal protections, or TNM CPU control.
