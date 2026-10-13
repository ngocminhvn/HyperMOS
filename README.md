# HyperMOS Super IMG Editor (isolated branch)

This branch is intentionally minimal. It operates on an **already modded** `super.img` for Xiaomi 15 Pro (HAOTIAN). No full ROM build, framework patching, root/boot image repacking, or modifications to `main`.

## Requested scope (future editing phase)

1. Replace the active `bootanimation.zip` from a user-supplied ZIP.
2. Replace **only** the APK whose Android package ID is `com.miui.packageinstaller`; preserve package permissions, signing compatibility, and native libraries.
3. Apply OS3 app snapshots from the separately pinned HyperMOS revision: AppVault, ColorOS Control Center, Launcher, ThemeManager, SecurityCenter, File Manager, Gallery Editor, Gallery, ScreenRecorder, Screenshot. Keep required overlays, permissions and external native libraries.
4. Audit cosmetic `build.prop` entries containing `ryu`, `zk`, `zkos`, or `kaorios`. Do NOT blindly delete active property keys, integrity/boot/security state or dependencies; require an audited list before deletion.
5. Keep every unrelated logical partition, APK, existing ROM mod, boot chain and AVB file unchanged.
6. When supported and verified, export `super.img` plus an audit/changes report as a GitHub Actions artifact.

## Status: safe preflight and READ-ONLY audit, not a finished repacker

A ready-to-flash `super.img` is **not** produced by the current workflow. Repacking is intentionally blocked until the actual source image has been inspected for filesystem (EROFS/ext4), dynamic partition layout/slots, metadata and AVB consistency. The GitHub Actions audit records partition names and filesystem types only.

## Inputs

Edit `config.json` **on this branch**, not on main.

* `source_super_url`: publicly accessible direct HTTPS download URL of an unchanged `super.img`. GitHub Actions cannot access `D:\\ROM-Work\\original\\super.img` directly.
* `source_sha256`: SHA-256 of exactly those input bytes. Windows: `Get-FileHash 'D:\\ROM-Work\\original\\super.img' -Algorithm SHA256`.
* `apk_bundle_url`: eventually a direct HTTPS URL to a ZIP of the user-provided `apk/` directory (can remain blank during audit). Do not include secrets or paid hotlink URLs requiring browser sessions.
* `apk_bundle_sha256`: SHA-256 of that ZIP.
* `os3_source_ref`: pinned original HyperMOS commit from which OS3 app assets will be sourced later.

The audit workflow runs on **push to this branch**. A workflow existing only on a non-default branch may not have an Actions UI `Run workflow` button; edit and commit `config.json` here to start a push run.

## Important

A hosted GitHub runner may not have sufficient disk for a large `super.img`, extracted partitions, and a rebuilt image. The audit fails closed if space is insufficient; a self-hosted Linux runner with sufficient free space might be necessary for the actual build. APK signature/permissions checks and AVB verification will be mandatory before releasing a rebuilt image.

Source baseline is the original modified image, NOT HyperMOS stock ROM. This branch deliberately excludes the old build scripts, obsolete workflows, and unrelated assets.
