# LOCK: verified donor evidence and safe build integration

LOCK is a read-only build audit. It does not install or execute a helper, add an
init action, patch SELinux, remove precompiled policy, or change AVB images.
The bundled payload is retained; no LOCK tnm.rc is installed and Xiaomi init is
preserved. Unrelated TNM, Kaorios, KeyMint/TEE, PowerKeeper and root code is not
changed by this package.

## Direct donor comparison

[Evidence workflow](https://github.com/ngocminhvn/HyperMOS/actions/runs/38676092039)
successfully downloaded/extracted both archives and compiled their split CIL.
Its artifact records archive members, file hashes/modes, symlinks, init/CIL,
contexts, fs_config and ELF inspection. Artifacts are retained for seven days.

Donor:
https://psychz.dl.sourceforge.net/project/projectzk/ProjectRYU/RYU-CN/RYUOS_HAOTIAN_OS3.0.309.0.WOBCNXM_CN261005.zip
Archive SHA-256:
`42dc542c9024c478e6b45af8e6fef6ba133176fe8201a14cf59496954516ba28`.

Stock OS3.0.308.0 WOBCNXM base archive SHA-256:
`a02c8d3f57e3dede93a96af4a34fc2aa06abf7c7e7d02267760579953403cc43`.
This is stock evidence, not the modified HyperMOS image.

The repository's `system_ext/xbin/ryu_helper` is byte-for-byte identical to
the supplied donor, with SHA-256
`6d82fc8e92089ce24226636ec4d24deb15655d7a7473d37d24fa4ae53588c1df`.
It is an AArch64 ELF64 PIE, with Android API 26 note,
interpreter `/system/bin/linker64`, and DT_NEEDED `libdl.so` and `libc.so`.
Both real ROMs map linker64 and those libraries into the Android runtime APEX.
This establishes static payload/ABI evidence; it is not an execution or linker
namespace test. The helper was never executed during inspection.

## Init: what can and cannot match RYUOS

The donor's actual `system/system/etc/init/hw/init.rc` has nine helper writes
under `on post-fs` (lines 1799-1808), then two locale/blacklist-dependent
actions with nine writes each. The targets include bootloader, flash lock,
vbmeta device state, verified boot state, verity mode, warranty bit,
secureboot lock fields and OEM unlock allowance. These writes force chosen
values; they do not establish actual hardware state.

The donor's Xiaomi init prefix before `# ProjectRYU` matches the stock base
init after trimming trailing whitespace (1796 stock lines versus 1831 donor
lines including the appended blocks). No missing Xiaomi initialization needs
to be transplanted from this donor.

None of those three blocks is copied or activated. There is no independent
safe LOCK initialization task in the inspected helper actions to migrate.
The runtime primary path matches RYUOS/AOSP:
`/system/etc/init/hw/init.rc`, extracted by this builder as
`build/baserom/images/system/system/etc/init/hw/init.rc`.
That shared path does not mean HyperMOS runs RYUOS's LOCK action.

Both a standalone init RC and primary init can register `post-fs`, but matching
actions run in parse/import order. Appending to primary init can move an action
earlier than a standalone file. `post-fs` concerns early mounts;
`post-fs-data` is a separate stage. Blocking `exec` pauses init until the child
exits, so activating an unverified writer can stall boot.
[AOSP init semantics](https://github.com/aosp-mirror/platform_system_core/blob/master/init/README.md).

## DAC and SELinux

The donor extraction reports helper mode 0755, UID/GID 0:2000, and repack
context `u:object_r:ryu_helper_exec:s0`. Its system_ext CIL declares that type
and grants init file read/getattr/map/execute/open/execute_no_trans.
Those facts explain execution staging, not the truth of reported security
state or proof of all runtime property access.

HyperMOS intentionally does not recreate that executable/label/grant because
there is no permitted helper action to run. Source mode need not be executable.
No generic system_file execution grant, permissive domain, blacklist, daemon,
module or fabricated TEE result is added.

Donor and stock split policy compilation returned zero using mapping version
202404 and Android runtime-style secilc flags (`-N`): neverallow analysis is
not included. Native host_init_verifier was unavailable on the inspection
runner. Neither result is a device boot or AVC test.

## Production audit fixes and checks

The old audit missed leftover helper entries in `*_fs_config`, helper types
inside `precompiled_sepolicy*`, and metadata symlinks resolving outside the
image. update.sh now checks those cases, as well as RC/CIL/context contents
and legacy helper/trigger filenames. Relevant linked init/policy directories
must resolve within the extracted tree. Failure leaves image bytes unchanged;
re-extract clean stock instead of guessing how to remove Xiaomi/TNM content.

The main workflow runs LOCK tests before download and reruns update.sh after
all ROM modification/root stages, before partition packing. This closes the
gap where a later stage could reintroduce known remnants. The existing main
build's final split-policy compilation is unchanged.

Run from the repository root:

```sh
bash -n bin/package/LOCK/update.sh
python3 bin/package/LOCK/test_update.py
```

All 17 tests passed locally and in the full workflow's preparation stage.
The three added cases first failed against the old script, then passed after
the production fix. Read-only checks on the real extracted metadata subset
accept stock and reject the donor's helper/init/policy/repack remnants. This
local subset excludes ROM files not collected into the artifact.

`LOCK ROM evidence` supports main-only path-triggered runs and manual dispatch.
It extracts without running donor scripts/helpers, compiles CIL, and invokes
native init verification when that tool is available. `LOCK full build dispatch`
uses actions:write solely to dispatch the existing full build on main.
Dispatch success is not full-build success.

The full build under test is
[38676301628](https://github.com/ngocminhvn/HyperMOS/actions/runs/38676301628),
code SHA `2a401080beb0cbc4938ae3eaa900cb8a160f32d1`.
Its final result must be read separately from the evidence workflow.
No device boot/flash test has been performed. The package dispatcher still
runs DISABLE_AVB outside LOCK; this package does not certify every other
HyperMOS component's security-state reporting.
