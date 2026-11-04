# LiteGapps17 — Android 17 / API 37 / arm64

This module is called by Universal/insfile.sh for **China Android 17**
and deliberately skips Xiaomi.eu/Global. Android 16 continues to use
LiteGapps16 unchanged apart from its path.

## Pinned upstream packages

- Core: https://sourceforge.net/projects/litegapps/files/litegapps/arm64/37/core/2026-10-01/
- Addons: https://sourceforge.net/projects/litegapps/files/addon/arm64/37/
- The exact archive URLs and upstream-published SHA-256 digests are in sources.json.
- Includes Common, GmsCore, GoogleServicesFramework, PlayStore,
  GoogleExtShared, ConfigUpdater, AndroidAuto, GoogleKeyboard, Gmail,
  GoogleSearch, Maps and GoogleDialer.

No APK or JAR from A16 is reused in the Android 17 staging path.
The Core archive contains files/files.tar.xz (or another supported tar
compression); addons expose their product/system_ext content under system/.
The staging script reads **data only**, never executes upstream module or
recovery installers. It overlays allowed app/priv-app/etc/framework/overlay
payloads into the extracted ROM, validates real APK ZIPs, and stops the build
on hash, download, archive or required-package failure.

This directory is initially **not a full APK payload**. To publish the actual
Android 17 assets under product/, system_ext/ and system/ in Git LFS, run the
[Sync LiteGapps17 assets](https://github.com/ngocminhvn/HyperMOS/actions/workflows/sync-litegapps17.yml)
GitHub Action (or execute locally):

```sh
python3 bin/modfile/Universal/LiteGapps17/stage.py --root . --hydrate-repo
python3 bin/modfile/Universal/LiteGapps17/stage.py --root . --verify-repo
```

The sync action downloads the exact pinned archives, verifies SHA-256,
extracts real APK/JAR/XML content, and pushes the resulting files through
Git LFS to main. It cannot publish files if SourceForge, validation, write
permissions or Git LFS uploads fail. Until inventory.json appears, ROM
builds still download the verified packages at build time. After the files
have been committed, ROM builds use the verified on-repo payload.

APK/JAR bytes are never substituted with Android 16 payloads.
The file structure and device boot are **not yet validated** against an
actual Android 17 China base ROM. If a release changes archive layouts,
the build must fail and the extractor must be updated after inspecting
upstream contents. Do not silently copy A16 permissions, system config, or
GApps framework JARs to A17.
