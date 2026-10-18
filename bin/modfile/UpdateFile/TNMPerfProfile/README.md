# Retired RYU/TNM thermal and performance profiles

For HAOTIAN Android 16 the PowerKeeper.apk uses the uploaded xiaomi.eu
PowerKeeper classes.dex as its sole DEX base. Only seven build flag reads
across GmsObserver, DeviceIdleController and DisplayFrameSetting are rewritten,
matching methods previously adapted from the ZKOS donor. All other EU
method bodies remain unchanged.
No ZKOS PowerKeeper DEX or RYU PerfHook code is imported. The RYU DEX in the
repo is used *only* as a zstd compression reference to reconstruct EU DEX,
whose final SHA-256 is independently pinned.

The original Xiaomi manifest/assets/resources/JNI, vendor/ODM thermal
profiles and normal package/installation path are retained. The original
Xiaomi v1 certificate metadata is preserved, but **the resulting changed
APK does not have a valid Xiaomi cryptographic signature**; compatible ROM
signature policy remains required.

This `update.sh` is intentionally a no-op apart from logging. It does not
import the RYU thermal profile overlay, KGSL overlay, PerfHook worker,
observer or additional persistent service.

The standalone TNM CPU-percentage control remains independent and on-demand.
Effective cooling, standby drain and notification latency still require
controlled on-device testing.
