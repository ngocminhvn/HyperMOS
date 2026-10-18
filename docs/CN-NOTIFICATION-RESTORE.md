# HAOTIAN A16 — CN notification fix and ZK/RYU compatibility

## Active sources

Android 16 `COREPATCH/update.sh` continues to enable
`--disable-signature-verification`, `--cn-notification-fix`,
`--tnm-zk-power-parity`, `--tnm-app-compat-gates` and
`--disable-secure-flag`.

These are separate framework/JAR policies. PowerKeeper `classes.dex`
remains EU-based and is not changed by this restoration.

## Original CN fix restoration

On 2026-10-16, ZKOS parity integration excluded entire classes from the
original CN notification pass. Compared to the pre-ZK version
`6b83518fc77a8342738634f5e2d56e347270be05`, that prevented the CN
build-field substitution from running on other unrelated methods in those
classes. The `miui-framework` AppOps/autostart class was also excluded.

The pre-ZK CN behavior is now restored for those unrelated methods in
`miui-services.jar` and for `AppOpsManagerInjector` in
`miui-framework.jar`. The original CN replacement remains
`IS_INTERNATIONAL_BUILD` -> `IS_MIUI`, and the Gboard package alias
remains unchanged.

**Necessary compatibility exception:** the ten exact methods ported from
ZKOS and two ZK static initializers must retain their original instructions
until `tnm_zk_power_a16.py` applies its verified parity patch. The method-
scoped `cn_zk_compatible_a16.py` skips only these, instead of skipping
whole classes. Restoring the old indiscriminate substitution *inside* those
methods would cause the ZK verifier to fail. This is an intentional safe
restoration, **not** a byte-for-byte reversion of every old instruction.

The legacy forced `PolicyManager.CN_MODEL=false` behavior remains available
only when ZK parity is disabled. With ZK parity enabled, the ZK/region
initializer is left in charge to avoid conflicting Greeze flags.

## What ZK parity changes

`tnm_zk_power_a16.py`: ten scoped reads and two initializers across
`DeviceIdleControllerStubImpl`, `BroadcastQueueModernStubImpl`,
`ProcessManagerService`, `ProcessSceneCleaner`,
`JobServiceContextImpl`, `NotificationManagerServiceImpl` and
`PolicyManager`/Greeze. Static gates/region logic, no new daemons.

The methods may influence broadcasts, Doze, swipe cleanup, job cancellation,
and notification full-screen policy. They are **not** PowerKeeper
`KillProcessController` methods.

## What is actually enabled from RYU

`--tnm-app-compat-gates` chooses the **six** entries in profile
`hypermos-zk-power`, not the full 18-entry
`hypermos-app-compat` profile:

- `ActivitySecurityHelper#getCheckStartActivityIntent`
- `ProcessPolicy#updateContentCatcherWhitelist`
- Four `PackageManagerServiceImpl` methods: `checkGTSSpecAppOptMode`,
  `hasDomainVerificationRestriction`,
  `isExceptionByTestPolicy`, `shouldInstallTargetSdkFail`

These control app compatibility, activities, content-catcher and install/domain
policies; they do not directly change CPU/GPU thermal, the EU
`KillProcessController`, or introduce a background process.

They are unchanged in this restoration; consider disabling only after
checking installed-app/install/domain-link behavior.

## Validation

`test_cn_zk_compatible_a16.py` runs in Build ROM preflight.
It checks the CN substitutions in unrelated methods, preservation of exact ZK
methods and idempotency. The existing `test_tnm_zk_power_a16.py` continues to
verify ZK gates; an actual ROM build and on-device notification, GMS/Zalo,
idle drain and thermals still require explicit testing.
