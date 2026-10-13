# Lock branch

This branch replaces the standalone KernelSU-Next test module with a ROM package. `bin/package/LOCK/update.sh` installs an ARM64 `hypermos-resetprop` binary into `system_ext/xbin` and a separate init file into `system/etc/init`.

During `post-fs-data`, init executes three synchronous, one-shot property writes:

```ini
ro.boot.flash.locked=1
ro.boot.vbmeta.device_state=locked
ro.boot.verifiedbootstate=green
```

Kaorios remains enabled with its existing `initGenerateSoftwareKeyPair` and `CertificateChainIfNeeded` hooks. The LOCK package does not patch framework DEX, AVB metadata, `boot`, `vendor_boot`, or `init_boot`; it also does not append commands to the stock `init.rc` or add custom SELinux CIL.

Like the old ResetProp package, this uses blocking `exec u:r:init:s0 root root` commands at `post-fs-data`. It does not start a persistent process. The trigger is isolated in a new init file; the old package appended to stock `init.rc`, added a SELinux rule, and invoked `DISABLEavb.sh` again. Only the three properties shown above are written.

Compared with the KernelSU-Next module, this ROM package does not require a module installation or the KernelSU module loader. It is present for every build that runs `patchpackage.sh`, including stock root mode differences. The tradeoff is that removing it requires rebuilding or editing the ROM; it is no longer independently disableable from KernelSU Manager.

Because init waits for each `exec` to finish, a hung binary can delay or block boot. This branch must be boot-tested on HAOTIAN before merging. Check all three `getprop` values, Duck Detector, `/proc/bootconfig`, `/proc/cmdline`, Kaorios attestation, KernelSU-Next root, TNM, PowerKeeper, thermal controls, and Notification Fix. A matching property screen does not change the real bootloader state or hardware Root of Trust.
