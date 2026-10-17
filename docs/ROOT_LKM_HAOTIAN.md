# HyperMOS HAOTIAN — SukiSU Ultra v4.2.1 (LKM)

The HyperMOS ROM builder supports two modes, selected in `.github/workflows/build.yml`:
- `root_mode=root` (default): use SukiSU Ultra **v4.2.1** from pinned upstream source, patch stock `init_boot.img`, and **preinstall the matching SukiSU manager**.
- `root_mode=stock`: preserve stock `init_boot.img` and do not insert the SukiSU manager.

## Root source, KMI and integrity

Source: https://github.com/SukiSU-Ultra/SukiSU-Ultra/releases/tag/v4.2.1

The Actions job builds from the pinned signed upstream tag `v4.2.1` at commit
`fd2a85151c8312fd9b4237db9ba827dcea692228`, not its mutable `main` branch.

The stock ROM kernel KMI is detected from `boot.img` and vendor/odm module
metadata using `bin/root/detect_kernel_kmi.py`. Currently only HAOTIAN's
verified `android15-6.6` KMI is supported. Build aborts if detection differs.

`bin/root/prepare_sukisu.sh` compiles:
- `kernelsu.ko`: ARM64 GKI `android15-6.6` using the upstream DDK image.
- `ksuinit`: ARM64 Android from the same upstream tag.
- `ksud`: Linux x86_64 from that tag for offline image patching.

This intentionally costs more build time than using prebuilt KernelSU Next assets,
but avoids mixing the SukiSU **v4.2.1 manager** with a mismatched older kernel
module. Version identifiers in `ksud` rely on upstream Git history and must not
be synthesized with a shallow clone.

The SukiSU manager is pinned to official asset
`SukiSU_v4.2.1_40994-release.apk`. Its SHA-256 is verified against the
official release metadata:

`c7f69280cf468e8415c585ff31f963d0147386831217a1e89b822afddc5f40ed`

The builder preserves stock `boot.img` and patches **only** `init_boot.img`,
using upstream `ksud boot-patch --module --init`. It unpacks the result and
refuses to package an empty, unchanged, or unreadable image.

## Manager preinstallation

In root mode the APK is placed at:

`/product/app/SukiSUUltra/SukiSUUltra.apk`

This is an ordinary signed system application, **not priv-app**, and the ROM
does not attempt to auto-grant root to any app. It is discovered by Android's
package manager at boot. The older first-unlock Download staging flow is not
used by this builder.

When a device already has a conflicting manager installed as a user app,
a dirty flash may require resolving the app/signing conflict manually.

## ZIP output and recovery

Root ZIPs end in `_SUKISU.zip`; stock ZIP names are unchanged. A root ZIP contains:
- `images/init_boot.img` — SukiSU-patched init_boot;
- `RootBackup/init_boot.stock.img` — original firmware init_boot;
- `RootManager.apk` — official SukiSU v4.2.1 APK as an additional manual fallback;
- `ROOT-INFO.txt` — KMI, upstream commit, manager name and hashes.

This integration does **not** include SUSFS, a custom GKI kernel replacement,
KPM, changed bootloader state, or app/identity spoofing.

**Bootability and runtime root require testing on the Xiaomi 15 Pro.** A successful
build and static ramdisk validation do not prove the device boots. Keep the
matching stock `init_boot.img` and know the stock recovery procedure before
testing a new root provider.
