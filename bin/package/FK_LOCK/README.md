# FK_LOCK

FK_LOCK is HyperMOS' build-time fingerprint synchronization stage.

It now does **one task only**:

- Synchronizes `ro.system.build.fingerprint`, `ro.system_ext.build.fingerprint`, and `ro.product.build.fingerprint` to a trusted top-level `ro.build.fingerprint` when one is available.
- Preserves `vendor` and `odm` fingerprints.
- Does not change device/name/model/brand/manufacturer identity properties.
- Does not install any runtime service, init trigger, resetprop helper, SELinux domain, or lock-state properties.
- If a trusted top-level fingerprint cannot be resolved, synchronization is skipped instead of failing the ROM build.

Disable for diagnostics with:

```sh
HYPERMOS_FK_LOCK=false
```
