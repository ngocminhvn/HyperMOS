# Retired RYU/TNM thermal and performance profiles

For HAOTIAN Android 16, the build retains the **original Xiaomi-signed
PowerKeeper.apk from the base ROM**. Its DEX, manifest, assets, signature,
thermal and battery controls are not replaced with ZKOS, RYU or EU donor APKs.
This is stock-first and EU-like in policy intent, **not** exact EU DEX parity.

`update.sh` is intentionally a no-op aside from build logging. No RYU
per-app thermal profile, KGSL permission overlay, PerfHook initializer,
observer, daemon or root control service is staged.

The independent TNM CPU-percentage control remains on-demand and separate.
GMS/notification framework modifications outside PowerKeeper are not changed
by this migration. Runtime notification and standby-drain tests are required
before claiming any battery or thermal improvement.
