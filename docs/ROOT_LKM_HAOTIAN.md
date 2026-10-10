# HyperMOS main: KernelSU Next LKM root

The main ROM build offers one Root mode and one Stock mode. **Root is selected by default.**
Only [KernelSU Next](https://github.com/KernelSU-Next/KernelSU-Next) is supported.

## GitHub Actions

Select [HyperMOS ROM Build](https://github.com/ngocminhvn/HyperMOS/actions/workflows/build.yml) on `main`.

- `root_mode=root` (default): Download the latest **stable KernelSU Next** release, detect kernel KMI from the source firmware, patch `init_boot.img`, and include the correct manager APK for manual install.
- `root_mode=stock`: Leave stock `init_boot.img` unchanged; preserve ordinary main build behavior.

**No KMI or root-version input is needed.** The extracted `boot.img` kernel
version and vendor/odm module vermagic must identify one consistent KMI. For
Xiaomi 15 Pro (HAOTIAN), the Android 16 ROM was verified with
`android15-6.6` during test build #104; the kernel KMI need not equal the Android
userspace version. A missing or conflicting KMI aborts the root build.

The build fetches upstream `releases/latest` assets and verifies their SHA-256
digests from the GitHub release API. It patches the source ROM's `init_boot.img`
with the official Linux `ksud boot-patch` command. The output image is unpacked
and tested for `kernelsu.ko` before it replaces the original.

## Manager APK after flashing

The manager APK is NOT installed as a system app (and competing SukiSU/KernelSU
manager preloads are skipped when root mode is on). The matching APK is staged
at `/system_ext/etc/hypermos-root/RootManager.apk` in the ROM image, with
`/system_ext/etc/init/hypermos-root-manager.rc` to copy it after user 0's
credential-encrypted storage becomes available. Intended destination:

`/storage/emulated/0/Download/KernelSU-Next_vX.Y.Z.apk`

The staging hook does not install the app. Use Files to install it manually.
The actual copy depends on init / SELinux behavior and is **not yet confirmed
by a device boot test**; `RootManager.apk` is also bundled in the ROM ZIP as
a manual fallback. A manager installed in userdata before a dirty flash may
need to be uninstalled manually if it is incompatible.

## ROM ZIP and recovery

Rooted ZIP names end in `_KSUN.zip`; stock ZIP names are unchanged.

For root mode the ZIP includes:
- `images/init_boot.img`: LKM-patched image
- `RootBackup/init_boot.stock.img`: source firmware image for recovery
- `RootManager.apk`: manager APK backup (not automatically installed)
- `ROOT-INFO.txt`: KMI, release tag, expected manager filename and checksums

The paired `boot.img` remains untouched. This integration does not include
kernel swapping, SUSFS, KPM or identity spoofing.

Static patch verification **does not prove actual bootability or active root**.
Keep access to stock boot and init_boot backups for device recovery.
