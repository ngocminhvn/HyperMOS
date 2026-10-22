# EU #126 notification delivery: ZK 3.0.304 policy assessment

## Symptom and evidence

During EU #126 Messenger test, the notification log records repeated `Greezer Denial` for `com.google.android.c2dm.intent.RECEIVE` addressed to `com.facebook.orca` after screen-on. FCM is reaching Android's broadcast dispatch, but the receiver is restricted before delivery. The evidence is about *delayed/denied delivery*, not proof that FCM messages are permanently lost.

## What the current EU patch actually changes

`A16/EU/eu_zk_global_greeze_broadcast_a16.py` changes **four** `IS_INTERNATIONAL_BUILD` reads in `BroadcastQueueModernStubImpl` to local true and the final `PolicyManager.CN_MODEL` assignment to false. The patch is **global** across app packages, broadcast actions and screen states. `A16/EU/ContentCatcher_EU.sh` runs both patchers in one decode/rebuild pass.

It does *not* modify:
- `GreezeManagerService.isAllowBroadcast` or `isRestrictReceiver`
- `services.jar` BroadcastQueueImpl
- PowerKeeper, Doze, Millet, network policy or frozen-UID bookkeeping

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
