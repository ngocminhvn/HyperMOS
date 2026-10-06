# FK_LOCK

FK_LOCK is HyperMOS' build-time identity and software lock-state compatibility stage.

It performs two deliberately separate tasks:

1. **Identity normalization**
   - Uses the clean top-level `ro.build.fingerprint` as the target identity.
   - Normalizes `system`, `system_ext`, and `product` fingerprints.
   - Normalizes their device/name/model/brand/manufacturer properties.
   - Removes visible `missi`, `miproduct`, `qssi`, `generic`, and `mainline` identity mismatches.
   - Intentionally preserves `vendor` and `odm` fingerprints because Xiaomi can ship those partitions from an older Android base.

2. **FakeLock runtime reinforce**
   - Reapplies `ro.boot.flash.locked=1`, `ro.boot.vbmeta.device_state=locked`,
     `ro.boot.verifiedbootstate=green`, and `ro.secureboot.lockstate=locked`
     only after `sys.boot_completed=1`.
   - Does not run at `post-fs-data`.
   - Uses a dedicated SELinux domain validated with `secilc`; it does not execute the helper in init's own domain.
   - Adds only those four keys to Xiaomi `cust_prop_white_keys_list`.

FK_LOCK **does not relock the physical bootloader** and does not claim to change hardware-backed attestation.

Disable for diagnostics with:

```sh
HYPERMOS_FK_LOCK=false
```
