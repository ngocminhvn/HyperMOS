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
