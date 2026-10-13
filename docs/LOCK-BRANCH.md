# Lock branch

This branch replaces the standalone KernelSU-Next test module with a ROM package. `bin/package/LOCK/update.sh` installs an ARM64 `hypermos-resetprop` binary into `system_ext/xbin` and a separate init file into `system/etc/init`.

When Android reaches `sys.boot_completed=1`, init starts three asynchronous writes:

```ini
ro.boot.flash.locked=1
ro.boot.vbmeta.device_state=locked
ro.boot.verifiedbootstate=green
```

Kaorios remains enabled with its existing `initGenerateSoftwareKeyPair` and `CertificateChainIfNeeded` hooks. The LOCK package does not patch framework DEX, AVB metadata, `boot`, `vendor_boot`, or `init_boot`; it also does not append commands to the stock `init.rc` or add custom SELinux CIL.

Compared with the old ResetProp package, the result is the same property overlay and it still uses the same style of standalone resetprop binary. The trigger is isolated in a new init file, runs after boot completion, and uses `exec_background`; the old package ran blocking commands at `post-fs-data`, appended to stock `init.rc`, added a SELinux rule, and invoked `DISABLEavb.sh` again.

Compared with the KernelSU-Next module, this ROM package does not require a module installation or the KernelSU module loader. It is present for every build that runs `patchpackage.sh`, including stock root mode differences. The tradeoff is that removing it requires rebuilding or editing the ROM; it is no longer independently disableable from KernelSU Manager.

This branch must be boot-tested on HAOTIAN before merging. Check all three `getprop` values, Duck Detector, `/proc/bootconfig`, `/proc/cmdline`, Kaorios attestation, KernelSU-Next root, TNM, PowerKeeper, thermal controls, and Notification Fix. A matching property screen does not change the real bootloader state or hardware Root of Trust.
