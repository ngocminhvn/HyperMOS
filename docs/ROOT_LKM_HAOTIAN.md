# HyperMOS — SukiSU Ultra newest stable LKM (GKI, guarded)

The Actions build input root_mode=root resolves the newest stable OFFICIAL
SukiSU Ultra release at build time, fetches verified aarch64 LKM/ksuinit/
manager assets, builds the matching Linux host ksud from that release's Git tag,
and patches an actual stock boot image. root_mode=stock preserves stock images.

## Compatibility (no unconditional "all phones" claim)

No device-code allowlist. Every target must meet these requirements:

1. Extracted original boot.img contains a detectable GKI KMI. The detection
   corroborates vendor/odm module vermagic where available.
2. SukiSU release ships an official aarch64 LKM for the *exact* KMI:
   android12-5.10, android13-5.10, android13-5.15, android14-5.15,
   android14-6.1, android15-6.6, android16-6.12, android17-6.18.
3. A usable ramdisk is present in original init_boot.img (preferred) or
   original boot.img. Unsupported layouts, mismatched KMI, missing assets,
   invalid signatures/digests or an invalid patched image FAIL the build.
4. Xiaomi-compatible ROM extraction, fastboot packaging and image flashing
   must already be supported by HyperMOS for that specific codename.
   Merely finding a GKI KMI is not proof that root boots on that device.

Non-GKI/vendor-specific kernel integration, unsupported CPU architectures, and
vendor_boot-only boot layouts are NOT automatically patched. Such phones need
a separately reviewed implementation, not blindly reused ARM64 LKMs.

## Latest official release and provenance

bin/root/fetch_sukisu_latest.py reads:
https://api.github.com/repos/SukiSU-Ultra/SukiSU-Ultra/releases/latest

The helper checks draft/prerelease flags, official release URLs and the
GitHub-provided sha256 digest of the selected LKM, ksuinit and manager APK.
Missing checksums fail rather than using unchecked binaries. It requires that
the latest stable release contain the exact KMI asset; it never silently falls
back to an older release or another device's module.

bin/root/prepare_sukisu.sh clones the matching official release TAG with full
Git history, records the actual source commit and builds the x86_64 Linux
host ksud from the same source tag. Only officially sourced and SHA-256
verified release binaries enter the boot image. No external unsigned mirror
or invented KMI fallback is allowed.

New upstream versions can change asset naming, build dependencies or patch
semantics; fail-closed is deliberate. A successful CI build does not prove
hardware runtime bootability; a first physical boot test is still needed.

## Boot image handling and recovery

bin/root/patch_init_boot.sh chooses init_boot when it has a valid ramdisk,
otherwise boot when it has a valid ramdisk. It backs up the original partition,
patches only that partition, re-unpacks the result, verifies the LKM and init
inside the resulting ramdisk and only then replaces the staged image.

Root/ inside the output ZIP contains:
- boot.stock.img OR init_boot.stock.img (the matching original firmware image)
- RootManager.apk (official manager, manually installed as a user app)
- ROOT-INFO.txt (target partition, release, KMI, commit, hashes)

The selected patched image is written to images/boot.img or images/init_boot.img.
The other boot image remains untouched. No root manager is preinstalled into
system/product partitions. Stock-only builds have no Root directory and do not
append _SUKISU to the ZIP filename.

IMPORTANT: Preserve the stock image, do not flash an image from a different
device/ROM version, and test a rollback procedure before testing an unverified
root integration on hardware.
