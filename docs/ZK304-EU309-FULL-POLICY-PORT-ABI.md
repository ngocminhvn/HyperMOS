# HAOTIAN EU 309 vs ZK 304 — Full notification and power policy feasibility

Source ROM comparison is based on the original `ZKOS_HAOTIAN_OS3.0.304.0` donor from GitHub Actions run `39751679932` and the original EU309 `miui-services.jar` from run `39452530513`. Both are original extracted files, not patched HyperMOS outputs.

## Findings directly from DEX inventories

- ZK304 `miui-services.jar`: 7,536 DEX classes.
- EU309 `miui-services.jar`: 7,626 DEX classes.
- 7,524 class names are common.
- `BroadcastQueueModernStubImpl`: **45** ZK executable methods vs **51** EU. EU has six extra broadcast timeout-related methods: `cancelDeliveryPreTimeoutLocked`, `deliveryPreTimeout`, `deliveryPreTimeoutLocked`, `deliveryPreTimeoutSoftLocked`, `setPreBroadcastWarningContext`, `startDeliveryPreTimeoutLocked`.
- `GreezeManagerService`: **307** ZK executable methods vs **312** EU. EU has additional screen update and vehicle-state handlers (`notiFyFinishUpdateScreenStatus`, `isMisCarConnect`, and generated accessors).
- `GreezeManagerStubImpl`: 13 ZK vs 14 EU methods (`notiFyFinishUpdateScreenStatus` is EU-only).
- `NotificationManagerServiceImpl`: 104 ZK vs 105 EU methods (`sendNotificationDisabledByUserBroadcast` is EU-only).

These ABI additions matter independently from whether the vendor **patches** for notifications and battery have the same logical intent. Replacing entire ZK classes/JAR would remove EU-only methods, possibly breaking dependent services.

## Confirmed behavioral core

- `BroadcastQueueModernStubImpl.checkApplicationAutoStart`, `checkReceiverAppDealBroadcast`, `checkReceiverIfRestricted`, `isInternationalSpecialAction` and `updateBlockBroadcast` have equivalent normalized original ZK/EU bytecode.
- `GreezeManagerService.isRestrictReceiver` and `isNeedCachedBroadcast` also have equivalent normalized bytecode.
- `GreezeManagerService.isAllowBroadcast` differs in its Xiaomi Mi Push handling. Google FCM itself already goes through equivalent native gates.
- `GreezeManagerService.freezeUids` differs: EU has an `isUpdateScreenStatus` condition that is absent from ZK; dropping that guard may increase UID freezes rather than fix notification latency.
- `freezeAction` also differs; **do not** assume a blind transplant improves the receiver thaw path.

## ZK304 PowerKeeper donor

ZK304 `PowerKeeper.apk` contains one `classes.dex` of 3,758,688 bytes (SHA-256 `439ed4b5fe3dfaa8d0c539bdbc90c54b049e9cf5143fe5664aee1e1becd6b2bf`). It defines 2,866 classes and 17,840 executable methods. `KillProcessController` defines 22 executable methods in this donor; the previously audited EU counterpart defines 23, with additional UID-policy behavior. The ZK DEX references a ZK-private `SettingsHelper` and thermal node `/sys/class/thermal/thermal_message/zk_state`. Those require compatibility handling if the whole donor DEX is imported.

## Engineering decision

**Full ZK policy should be a method-level compatibility port, not whole-JAR replacement.** Preserve all EU-only public/overridden methods; import changed donor methods only after proving their field, method and callback dependencies against EU309. Before switching PowerKeeper's entire DEX, validate the exact app ABI and every affected framework/service call, plus APK signature integrity. Retaining `META-INF` metadata after replacing DEX is **not** a valid cryptographic signature. Never silently skip a failing compatibility check.

The current all-app FCM override on `main` is a new HyperMOS exception, **not** original ZK behavior. It should not be misreported as full ZKOS parity.

No proof of reduced notification latency or standby power exists without a full build, boot and device A/B test. The EU #126 screen-on `Greezer Denial` log is a real broadcast restriction signal, but cannot by itself isolate the responsible freeze policy across ROM versions.

## Next safe integration target

A guarded EU-only donor-method port should keep CN unchanged and preserve EU-specific methods. Compare the frozen UID, thaw and background process policy alongside the `PowerKeeper` GMS observer, Doze and kill-controller behavior. Run build/boot tests before activating broad changes in the default ROM pipeline.
