# Xiaomi.eu ROM customization

This directory runs **only** for a ROM whose source filename starts with
`xiaomi.eu_`. The source identity is stored in
`bin/ddevice/rom_source.txt` independently of the ROM's China-derived version
suffix `CNXM` or the legacy `device_type.txt` region.

- `update.sh`: delete exactly `/product/priv-app/XiaomiEUExt` from the
  **extracted build tree**, not from any connected device. Keep
  `/product/priv-app/MiuiExtraPhoto` untouched.
- `verify.sh`: after applying the normal China/shared mods, reject a result
  that has reintroduced XiaomiEUExt or lost the Kashi MiuiHome APK.
- `bin/package/NOTIFICATION_FIX/notificationFIX.sh` skips Xiaomi.eu. This
  prevents China-specific notification/PowerKeeper DEX transplants.
- Everything else uses the existing HyperMOS pipeline, including the Kashi
  launcher, CorePatch, AVB, Kaorios, MiCTS, GMS and UpdateFile stages.

For Xiaomi.eu ZIPs with sparse `images/super.img.N`, the build merges and
extracts their logical partitions. SourceForge URLs use the same downloader as
the dump workflow.

The original China build path and its notification fix remain unchanged.
EU runtime compatibility with all China-oriented mods still requires a full
test build and device verification; do not mistake passing build steps for
proven runtime compatibility.
