# LOCK safety audit

The former `system/etc/init/tnm.rc` forced three boot properties during
`post-fs`: `ro.boot.flash.locked=1`, `ro.boot.vbmeta.device_state=locked`,
and `ro.boot.verifiedbootstate=green`. These values were unconditional and
could disagree with the actual bootloader and AVB state. Property changes do
not lock the bootloader or establish a verified chain of trust.

Consequently there is no safe LOCK action to migrate to stock init. This
package no longer installs an init file, appends an action, installs a helper,
adds SELinux rules/contexts, or deletes precompiled policies. In particular it
preserves every byte of the extracted Xiaomi
`build/baserom/images/system/system/etc/init/hw/init.rc`
(runtime `/system/etc/init/hw/init.rc`). It never copies RYUOS init.rc.

`update.sh` checks the expected extracted system/system_ext layout, stock init,
and the reviewed helper hash. It audits extracted RC, CIL, file-context files,
and installed payload names for prior LOCK changes. A reused tree containing
those changes fails before any mutation; rebuild from clean stock rather than
automatically deleting or rewriting Xiaomi/TNM content. Clean repeat runs make
no changes and cannot add duplicate actions. Unrelated TNM files are preserved.

## Retained binary

`system_ext/xbin/ryu_helper` remains unchanged in this source package:
SHA-256 `6d82fc8e92089ce24226636ec4d24deb15655d7a7473d37d24fa4ae53588c1df`.
Static ELF inspection shows an AArch64 ELF64 PIE, Android API 26 note, interpreter
`/system/bin/linker64`, and DT_NEEDED `libdl.so` and `libc.so`.
Strings identify a resetprop/property manipulation tool; this is not a source
audit or proof of all behavior. Do not execute it as a validation step.

The old installer used mode 0755 and runtime path
`/system_ext/xbin/ryu_helper`, with custom label
`u:object_r:ryu_helper_exec:s0` and init execute_no_trans permission.
That execution permission alone does not establish all property-access
permissions, dependency resolution, policy compatibility, or safety. Since
the helper is now unused, no executable image permissions or new SELinux label
are assigned. The source file need not be executable.

## Validation limits and flash risks

Bash syntax and synthetic extracted-image tests cover clean/repeat builds,
missing paths, payload integrity, stale standalone/appended triggers, and
stale custom policy/contexts. They verify image bytes remain unchanged.
No complete Xiaomi ROM was available in the editing workspace; no full ROM
build, native host_init_verifier, combined SELinux compilation, linker namespace
test, device boot test, or flash has been performed. No new init/CIL syntax is
introduced.

This is a LOCK-only change. The package dispatcher still runs DISABLE_AVB
before LOCK; Kaorios, TNM, PowerKeeper, framework and root code are untouched.
This patch does not establish that the rest of HyperMOS reports hardware
security state faithfully. Review the complete build, resulting images and
device's actual boot state before flashing. Existing documentation outside this
directory describing active LOCK property writes is historical and is not the
current package behavior.

## RYUOS parity and Android init ordering (2026-10-15)

| Component | HyperMOS result | Evidence / limit |
| --- | --- | --- |
| RYU helper payload | Retained ARM64 payload, pinned hash above | Proven identity against the existing HyperMOS blob; donor identity is repository provenance, not an independent RYUOS download |
| Primary init path | Preserves Xiaomi `/system/etc/init/hw/init.rc` | This is the RYUOS location reported by the user and the AOSP primary init path |
| Separate LOCK tnm.rc | Absent | No separate LOCK init action is installed; unrelated TNM files remain untouched |
| RYUOS `post-fs` execution | Intentionally not reproduced | The former LOCK commands force three security properties; no safe replacement command has been established |
| RYUOS SELinux/runtime behavior | Not certified identical | No original RYUOS init.rc, complete policy or extracted Xiaomi image is available |

AOSP loads the primary init file and its imports, then partition init
directories. Matching actions execute in parse order. Thus a standalone
`/system/etc/init/tnm.rc` and an action appended to primary init.rc can share
the `post-fs` event while running at different positions in the action queue.
Moving an action is not a dependency check, a SELinux fix, or a guarantee of
identical behavior. Existing Xiaomi `post-fs` actions must remain intact.
`post-fs` is the early-mount configuration stage; `post-fs-data` is a distinct
stage associated with mounting/configuring /data. A blocking `exec` pauses
init commands until the child exits, so an unverified helper can stall boot.

The binary's embedded usage text describes `-n NAME VALUE` as a property write
without notifying listeners. Suppressing notifications does not make
`locked/green` values faithful to hardware. No blacklist, seal hook, daemon,
module, or fabricated TEE/KeyMint/AVB report is introduced. No helper invocation,
including a diagnostic invocation, is added merely to imitate RYUOS timing.

Source for Android init semantics:
[AOSP init README](https://github.com/aosp-mirror/platform_system_core/blob/master/init/README.md).
The RYUOS path/event comparison is based on the user's supplied information;
full donor parity needs the actual donor init and policy, not this AOSP reference.

## Reproducible workflow checks

Run `bash -n bin/package/LOCK/update.sh` and
`python3 bin/package/LOCK/test_update.py` from the repository root.
The main ROM workflow now runs both before downloading/unpacking the ROM.
The package dispatcher labels LOCK as a safety audit rather than property sync.
The 17 offline tests passed locally. They cover the pinned ARM64 payload,
repeat runs, standalone/appended duplicate actions, image and repack contexts,
both legacy helper names, CIL remnants, missing paths and changed payloads.
They preserve fixture bytes/modes, including stock init, unrelated TNM and
vendor/ODM precompiled policy files. These fixtures are not actual Xiaomi policy
or a substitute for Android init verification and combined SELinux compilation.
The original helper is never executed.

## Residual image audit fixes

The previous audit could report success with helper entries left in repack
`*_fs_config`, or helper types left in `precompiled_sepolicy*` after the CIL
and executable were removed. It now scans those files too. This is a search
for legacy LOCK identifiers, not validation of compiled SELinux semantics.
Relevant audit files and linked init/policy directories must resolve within
the extracted image root; external, dangling or cyclic audit links fail rather
than reading host files or silently skipping a linked policy/init tree.
These failures leave the image unchanged and require a clean extraction.

The workflow also reruns LOCK after the ROM modification/root stages and before
packing, so a later stage cannot silently reintroduce a known LOCK remnant.
Existing final split-policy compilation in the main build is left unchanged;
no additional permissions or policy patches are introduced by LOCK.

The user supplied the donor ROM URL:
https://psychz.dl.sourceforge.net/project/projectzk/ProjectRYU/RYU-CN/RYUOS_HAOTIAN_OS3.0.309.0.WOBCNXM_CN261005.zip
The editing executor could not connect to its configured HTTP proxy, so this
archive has not been downloaded or inspected. The retained helper hash is
verified against the repository payload, not against this remote archive.
There is still no extracted real ROM or native init/SELinux verifier result.
GitHub Actions execution must be reported separately from local test results.
