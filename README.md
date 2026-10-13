# Super IMG Editor for Xiaomi 15 Pro (HAOTIAN)

This is an isolated branch for applying **existing local mods** to an **already-modded** ROM ZIP that contains a `super.img`. The original ROM's unrelated image entries and the repository `main` branch are not changed.

## Inputs in GitHub Actions
* `input_url` — **full ROM ZIP download link**, e.g. one containing `images/super.img` or `super/super.img`. Direct `super.img` is also accepted.
* `upload_method` — `drive` (Rclone), `pixeldrain`.
* `root_mode` — `root` (default: KernelSU Next LKM from pinned HyperMOS main code), or `stock` (preserve source init_boot unchanged).
* `builder_id` — optional Telegram chat ID.
* `source_sha256` — optional input SHA-256 (recommended).

Secrets reused from HyperMOS: `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHANNEL_ID`, `RCLONE_TOKEN_PATH`, `PIXELDRAIN_API_KEY`. Optional repository variable: `RCLONE_REMOTE`.

Workflow: `.github/workflows/super-editor.yml`. It runs `download ZIP → locate super.img → unpack logical partitions → replace bootanimation → apply Mods/OS3 Kashi/System → adapt local InstallerX to com.miui.packageinstaller → verify all build.prop files remain unchanged → rebuild EROFS and LP metadata → repackage source ZIP → Rclone/Pixeldrain upload → Telegram result`.

**This is not the HyperMOS stock-ROM build workflow.** A full OTA `payload.bin` without a `super.img` is rejected, not silently converted into a different ROM. ZIPs containing more than one `super.img` are also rejected.

## Running a manual build

The only build input is the **GitHub Actions manual form**. You do **not** edit `config.json` (it has been deleted). Choose:

- `input_url`: direct HTTPS/HTTP URL to a previously modded ROM ZIP containing `super.img` (or to a standalone `super.img` in stock mode).
- `root_mode`: `root` (default) or `stock` (does not modify init_boot).
- `upload_method`: `drive` or `pixeldrain`.
- `builder_id`: optional Telegram recipient.
- `source_sha256`: optional expected download hash.

**GitHub default-branch requirement:** The GitHub website only displays the **Run workflow** button for workflows that exist on the repository's default branch. This project deliberately does not modify `main` without express approval. After the workflow has been registered by GitHub, it may be dispatched against `super-img-editor` using GitHub CLI:

```powershell
gh auth login
gh workflow run super-editor.yml --ref super-img-editor -f "input_url=https://example.com/your-modded-rom.zip" -f root_mode=root -f upload_method=drive
```

To enable the **web form** while isolating all ROM code on `super-img-editor`, a **small workflow_dispatch dispatcher** must be added to `main` with explicit authorization. This branch already exposes `workflow_call`, ready for that dispatcher to call `ngocminhvn/HyperMOS/.github/workflows/super-editor.yml@super-img-editor` with `secrets: inherit`. Do not copy the full editor or mods to `main`.

## Mods already in the branch
* `Mods/Boot/bootanimation.zip`
* `Mods/OS3/kashi/*.zip`: HyperOS AppVault, ColorOS plugin, Launcher, Security Center, ThemeManager
* `Mods/OS3/system/*.apk`: File Manager, Gallery Editor, Gallery, ScreenRecorder, Screenshot. **Real Git LFS blobs are required**, not 132-byte pointer text.
* `Mods/Packageinstaller/InstallerX-Revived-online-26.09.apk` or a prepared `Mods/Packageinstaller/MIUIPackageInstaller.apk`; permissions XML.

The editor uses the repository's local `Linux/` and `Tools/` binaries, plus a vendored pinned GPLv3 `super_rw.py` implementation and original AOSP test-signing key already present in HyperMOS. Original EROFS fs_config and SELinux contexts are required and regenerated from the input image, not from stock templates.

## Safety constraints and current limitations
* **EROFS partitions only** (product/system/system_ext). If the input uses ext4 for a target partition, build fails rather than remounting or rewriting it incorrectly.
* Original LP metadata A/B slots must agree; different/incomplete slots stop automatically. Original logical partition size is enforced; unrelated payloads are preserved.
* **Every `build.prop` is preserved byte-for-byte**. No ROM identity/property cleanup or modification is performed. A pre/post hash check blocks output if a mod changes any `build.prop`.
* Apk signing compatibility is not guaranteed. InstallerX adaptation signs with the upstream AOSP **testkey**, and signature differences from the installed ROM can disrupt updates/data. Back up app data and validate.
* Original vbmeta/AVB state may be incompatible with modified partitions. The generated file has **not** been tested on device; do not flash until boot chain / AVB compatibility is independently verified.
* Adequate disk space, an accessible direct download URL and valid existing upload credentials are required.
* Only a known-fastboot-style super-based ZIP or direct super.img is supported. No vendor_boot, FakeLock, or SELinux policy patches. Root is explicit via `root_mode`.
* Reports are uploaded as a small Artifact. The large ZIP/super.img goes through the selected uploader.

## Running after local edits
```cmd
cd /d D:\\super-img-editor
git pull --ff-only origin super-img-editor
git add Mods
git commit -m "Update ROM assets"
git push origin super-img-editor
```

License for vendored `scripts/super_rw.py` in `third_party/super_rw.LICENSE`. Original source commit: `ybtag/super_rw@46ce981c6a523d1c4a1a0da8c75b090af0e91ee7`.

## KernelSU Next root (ported from main)

The exact four `main/bin/root` scripts were copied to `Root/`:
`patch_init_boot.sh`, `detect_kernel_kmi.py`, `stage_root_manager.sh`, and `stage_root_manager.rc`.

- `root_mode=root` is the default. Requires a **complete already-modded ROM ZIP** containing one `boot.img` and one `init_boot.img`. A standalone `super.img` cannot be rooted by this workflow and fails closed.
- Root patches **only the original ROM's init_boot.img** using official KernelSU Next LKM stable assets, automatic kernel KMI detection, and upstream SHA-256 digests. It does not patch `boot.img`, `vendor_boot.img`, `vbmeta.img`, or disable AVB. A source identity check requires matching `haotian` properties, and the image must not already have HyperMOS root staging.
- The matching root manager is staged in `system_ext` for copying to Download after user 0 unlock; it is *not* silently installed as a privileged Android app. The workflow adds metadata entries for these new files before EROFS repack.
- The rebuilt ZIP replaces the original `init_boot.img`, appends `RootBackup/init_boot.stock.img`, `RootManager.apk`, `ROOT-INFO.txt`, and uses suffix `_KSUN.zip`. Keep the original ROM ZIP for recovery.
- `root_mode=stock` skips root changes and retains source `init_boot.img` byte-for-byte. This is the safer choice when the input ROM is already rooted by another solution.
- Static validation cannot confirm root activates on a real Xiaomi 15 Pro. Backup data, check Android Verified Boot compatibility, and inspect reports before flashing.
