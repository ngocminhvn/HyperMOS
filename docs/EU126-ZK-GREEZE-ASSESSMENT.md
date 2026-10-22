# EU #126 notification delivery: ZK 3.0.304 policy assessment

## Symptom and evidence

During EU #126 Messenger test, the notification log records repeated `Greezer Denial` for `com.google.android.c2dm.intent.RECEIVE` addressed to `com.facebook.orca` after screen-on. FCM is reaching Android's broadcast dispatch, but the receiver is restricted before delivery. The evidence is about *delayed/denied delivery*, not proof that FCM messages are permanently lost.

## Corrected EU ZK304 parity patch (October 22, 2026)

`A16/EU/eu_zk_broadcast_greeze_parity_a16.py` **does not force** an international build or a non-CN region. It verifies the four BroadcastQueue method reads and `PolicyManager.<clinit>` and retains:
- `sget-boolean ..., Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z`
- `CN_MODEL = (ro.miui.region == "CN")`

These are **semantically identical** to the observed ZK304 donor and original EU309. If the exact donor alias `IS_ZK_BUILD` is encountered in a supported BroadcastQueue method, it is normalized to the native `IS_INTERNATIONAL_BUILD` field, without hard-coding a branch value. The previous forced true/false gates have been removed from active builds. This change alone cannot solve EU #126 FCM delivery, because those five gates were already aligned in the original Xiaomi.eu 309 JAR.

## Relevant ZK 304 observed bytecode

`GreezeManagerService.isRestrictReceiver` examines frozen UID status, then calls `isAllowBroadcast`; on some allowed paths it invokes `thawUidAsync`, otherwise `isNeedCachedBroadcast` is consulted.

`isAllowBroadcast` checks caller/target whitelists, control maps, `AurogonImmobulusMode`, international strategy and display state. In the inspected ZK 304 `isAllowBroadcast`, `CN_MODEL=false` leads into an international-strategy branch which **can** allow `com.google.android.c2dm.intent.RECEIVE` early when its remaining conditions match. It still contains other conditions, including a Google-services/display-related branch, that may reject the same broadcast depending on state. This is why changing `CN_MODEL` does not guarantee immediate delivery.

The ZK `PolicyManager.<clinit>` donor inspected here reads `ro.miui.region` and compares to `CN`; do not claim a byte-identical ZK port just because the final false value is forced.

## Assessment and falsification

**Possible partial improvement, NOT a verified fix.** Correct behavior depends on the EU 309 method layout, `InternationalPolicyManager.enableNewStrategy()`, the target UID's frozen state and other branch conditions. Synthetic smali tests confirm only textual gate replacement and idempotence, not actual `isRestrictReceiver` semantics. A pass building JAR and booting would still not prove FCM delivery.

Collect before/after logs with identical test timing and at least several notifications on every relevant app; measure:
1. `Greezer Denial` count for each app while screen on.
2. End-to-end notification latency, especially after receiver UID has become frozen/cached.
3. Whether `thawUidAsync` runs or broadcast is cached.
4. Power consumption and effects on unrelated broadcasts.

If `Greezer Denial` persists, the next investigation belongs in the actual `GreezeManagerService.isAllowBroadcast/isRestrictReceiver` and broadcast cache/thaw path; do not assume changing more build flags will solve it.

## ZK donor freeze-path delta and battery warning

Normalized DEX instruction comparisons found the following changes in ZK304 relative to EU309:

- `GreezeManagerService.freezeUids`: EU has an `isUpdateScreenStatus` early-return check; ZK lacks it. Porting ZK blindly could remove EU's screen-update protection and **increase** freezes, rather than cure the FCM delay.
- `GreezeManagerService.freezeAction`: EU adds a null-info log/guard and additional checks; differences are not a proven cause of cached FCM.
- `GreezeManagerService.isAllowBroadcast`: EU adds a Xiaomi Mi Push (`com.xiaomi.xmsf` / `com.xiaomi.mipush.RECEIVE_MESSAGE`) branch; core Google FCM checks exist in both.
- `GreezeManagerService.isRestrictReceiver` and `isNeedCachedBroadcast`: normalized instruction flows are identical.
- `InternationalPolicyManager.getImportantApps`: ZK reuses a cached list if nonempty; EU recomputes it. This does not establish FCM delivery correctness.

No changes were made to these runtime Greeze methods without a proved targeted mechanism. Screen-on cached FCM denials require validation of freeze/thaw and broadcast deferral on the real ROM. Testing should measure per-app denial count, notification latency and idle battery before importing any additional ZK behavior.
