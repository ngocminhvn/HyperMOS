# FK_LOCK

FK_LOCK is HyperMOS' software lock-state runtime stage.

It intentionally does **not** synchronize or normalize fingerprints or product identity.

Runtime behavior:
- Reapplies `ro.boot.flash.locked=1`.
- Reapplies `ro.boot.vbmeta.device_state=locked`.
- Reapplies `ro.boot.verifiedbootstate=green`.
- Reapplies `ro.secureboot.lockstate=locked`.
- Runs only after `sys.boot_completed=1`.
- Uses a dedicated SELinux domain validated with `secilc`.
- Adds only the four lock-state keys to Xiaomi `cust_prop_white_keys_list`.

All extracted ROM fingerprints and product identity properties are preserved as-is.

FK_LOCK does not relock the physical bootloader and does not claim to change hardware-backed attestation.

Disable for diagnostics with:

```sh
HYPERMOS_FK_LOCK=false
```
