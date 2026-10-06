# HyperMOS haotian boot-chain investigation (2026-10-06)

Baseline: `937926812bdcce525c825d625236140a07096844`, main.
Scope: boot chain, read-only attestation pipeline trace, ResetProp history.
No changes to Kaorios, Settings, fingerprints, root integration or application-specific behavior.

## Findings proven by source and images

1. Build #69 vendor_boot v4 is structurally inconsistent. Header vendor_ramdisk_size
   is **26,971,697**, but the single table entry remains **26,863,267** (stock size).
   Its fragment is short by **108,430 bytes**. A strict table-based LZ4 decode fails.
   `vbpatcher.py` rewrote the payload but copied the original table unchanged.
2. The same repacker copied the stock embedded AVB hash descriptor unchanged while
   moving the footer. Its digest and image_size therefore describe the old payload.
   This is stale metadata, not evidence of a new OEM trust key.
3. `DISABLEavb.sh` ignored failed repacks and treated existence of the input file
   as success. `patchpackage.sh` did not propagate DISABLE_AVB failure.
4. For allowlisted haotian, disabling vbmeta verification depended on a ramdisk
   `/avb` directory. That directory is absent in this stock image. Build #69 modified
   vendor_boot and filesystem partitions while vbmeta flags stayed **0**.
   Signed parent descriptors consequently remain tied to stock partition contents.
5. The old injection calculated SHA256 and size of the **whole padded vbmeta file**,
   not libavb's digest and size of loaded vbmeta structures. It also prepended
   parameters without removing duplicates. The fix stops generating these values.

These are proven build defects. **The cause of the reported attestation divergence
is not proven from repository alone.** The two report summaries lack build SHA/run
IDs and original certificate DER chains, so they cannot be assigned to exact builds
or independently cryptographically validated.

## Artifact comparison

Stock images extracted selectively from the official full OTA, with operation
SHA256 verification enabled using the repository's payload-extract:

`https://bkt-sgp-miui-ota-update-alisgp.oss-ap-southeast-1.aliyuncs.com/OS3.0.308.0.WOBCNXM/haotian-ota_full-OS3.0.308.0.WOBCNXM-user-16.0-9aea0c2b20.zip`

Actual final images downloaded individually from the ROM ZIP produced by
[build #69](https://github.com/ngocminhvn/HyperMOS/actions/runs/37350478272),
`https://pixeldrain.com/api/file/LfvX4N65`.

| Image | Stock SHA256 | Build #69 final SHA256 |
|---|---|---|
| boot | a82414002b3358f897258ff25f25d8b77c83f40a8d883eb194dbae6826fbe222 | identical |
| init_boot | c6adf86f450493002f73ed89968fef4884276f2e5c9c1d97c8b1c8cf8a346554 | identical |
| dtbo | e1a3051ede9b903e6604d485b10c1dfd6dff092a0d18de43c02dbb624ccf2811 | identical |
| vbmeta | 73391140dfdf175040b17c46f5626de13aafdbfa8353fe8c4dc602e53de330fc | identical |
| vbmeta_system | 39a7286da34c8f89b6bea3040a6065b8fa9b562de578d3d68a61adc6670933ce | identical |
| vendor_boot | 111d3d09b0dc1baaee0f2f63c2bc083d9f562d537dd73d0402f31edcca249f9b | a0212cb24c15668fda7550af14b9210ef1ff883137892ea85c4b4742c68e4ae1 |

Stock boot v4 has empty generic ramdisk, no GKI boot signature, and a signed AVB
footer (SHA256_RSA4096). init_boot has the generic ramdisk. vendor_boot has a single
platform fragment, DTB, bootconfig, and an unsigned (`NONE`) AVB footer.
This change preserves boot/init_boot/dtbo, vendor cmdline, DTB, bootconfig,
table fragment types/names/board IDs, and public keys. It updates fragment sizes
and offsets, and recomputes the **unsigned** embedded vendor_boot descriptor.
It does not sign a modified image using a replacement key. A signed vendor_boot
cannot be silently repacked without its signing key.

## What is e71fdea945abcd...?

It is the `verifiedBootHash` value **reported by the supplied attestation summaries**.
Its identity as a particular artifact digest has not been proven.

Direct calculations on the matching official OTA/build #69 show:

| Candidate | SHA256 |
|---|---|
| Whole vbmeta.img (12,288 bytes) | 73391140dfdf175040b17c46f5626de13aafdbfa8353fe8c4dc602e53de330fc |
| Top-level vbmeta structure (9,536 bytes) | d6857066bce9b8b560b724bd7f1d913eb6d980bcfc388dcaebb6ca2879c9084b |
| avbtool chained digest: vbmeta + boot + recovery + vbmeta_system | bf19608cf96fae2bd158c2985aa4d0fb87a75642e1a2c64096df6667d9b263d2 |
| vbmeta + boot + vbmeta_system (excluding recovery) | 7074f9904abdad121f8ead8bfc14cc282f297f6b2f30c2247f3168814c9b9914 |
| SHA256 of AVB-encoded public key | 6be268f3b6ba81c45934f400873aa6e36035d33db0b3d9b1c9d10e77ad92390e |

None equals e71f... . With stock flags 0, the top-level structure chains boot,
recovery, and vbmeta_system; final #69 omits recovery because
`bin/modfile/UpdateFile/System_MultiDisableFeature/update.sh` deletes it.
This task does not change that module. The verifier reports a missing chain input
instead of claiming it knows the device's loaded digest. When flags bit 2 is set,
the bundled libavb reference returns before loading descriptors/chained vbmeta:
only the top-level structure enters its digest. Vendor bootloader behavior still
requires runtime evidence. Equal reported hashes alone do not prove equal images,
equal bootloader lock states, or equal attestation generation paths.

## verifiedBootKey

The reported new 72d363... is not the SHA256 of this artifact's AVB-encoded public
key (6be268...), RSA SPKI DER (376605...), RSA PKCS1 DER (cf30bc...), or modulus
(5a43f2...). No source/image evidence proves why the reported key changed.
Under the Android reference semantics, unlocked/Unverified uses a zero boot key;
Verified uses the manufacturer root of trust. Userspace `ro.boot.*` values do not
establish which data the secure implementation received. Do not infer a physical
bootloader relock from this report or claim that a repack selected another OEM key.

## Google root and chain length

The supplied 3ee445... and feb2ea... exactly match **SHA256(SPKI DER public key)**
of Google's published roots; they are not SHA256 fingerprints of certificate DER:

| Report | Public-key digest | Published root |
|---|---|---|
| OLD | 3ee44512a1af2beb39c889490c60ea3f82e43f5d5a5532f5ab9419f676cd07ec | Google Key Attestation CA1, EC |
| NEW | feb2ea7551ee316ed4bb443c8293b884dbfdea40b603ee3e4f4a897e4580fbae | Google legacy attestation root, RSA |

The matching currently published certificate DER digests are respectively
6d9db4ce6c5c0b293166d08986e05774a8776ceb525d9e4329520de12ba4bcc0 and
cedb1cb6dc896ae5ec797348bce9286753c2b38ee71ce0fbe34a9a1248800dfc.
Older RSA root certificates share the RSA SPKI but have other DER fingerprints.
Thus OLD -> NEW is **EC -> RSA**, not forward migration to Google's new EC root.
Removing/reordering certificates cannot change an RSA root public key into EC.
The summaries establish different reported trust anchors, but do not identify
the device-side selection mechanism or validate their chains.

RKP provisioning/cached versus fresh keys, different attestation keys, TEE versus
StrongBox, framework certificate replacement, or a different request/security path
are possible explanations, each **not proven from repository alone**. Chain length
5 -> 4 does not identify any one of them. Boot-state correlation is not causation.
Without DER, challenge, security levels, extension provenance, signatures and key
alias/request metadata, the report's 'hardware-backed' label is not independent proof.

Kaorios may influence certificate-chain/key-generation output because the read-only
trace of `KAORIOS_TOOLBOX/patch.sh` installs `initGenerateSoftwareKeyPair` and
`CertificateChainIfNeeded` hooks, and #69 logs `Keybox=true`. Its README describes
runtime-imported keybox support. Runtime configuration and key origin are not in
the repository. No Kaorios file, config, hook or APK was modified.

## History and ResetProp

| Commit/time (Asia/Saigon) | Relevant behavior |
|---|---|
| bf184af, 2026-09-29 00:27 | imported vendor_boot vbpatcher flow |
| be041c1, 2026-10-01 14:08 | switched DISABLE_AVB to HMATools, boot + vendor_boot |
| ae6f051, 2026-10-01 14:20 | checked HMATools errors and runtime tool sync |
| d5497a8, 2026-10-01 17:29 | restored vbpatcher flow; HMATools/start becomes uncalled |
| f303d67, 2026-10-01 22:50 | ResetProp no-op, boot properties preserved |
| cec6d68, 2026-10-05 16:04 | restored late-boot Fake Lock |
| a23b36e, 2026-10-06 00:15 | removed ResetProp from package pipeline |
| 983eb60 through da5c5eb, 2026-10-06 00:16 | removed obsolete ResetProp package/payload |

Current main contains HMATools boot/vendor_boot code but **does not execute it**.
It is not re-enabled in this fix. The supplied reports cannot be dated precisely
within this history without their build identifiers.

BEACHEAD ResetProp at `62f38b043a4ca49437b7c642060801109f07608f` (2026-08-17
02:31 Asia/Saigon) **sources DISABLEavb.sh**, then installs userspace xeutoolbox/init
property overrides. It therefore has a build-stage dependency, not only runtime
property writes. No `vbmeta_disable=true` assignment was found in that DISABLE_AVB
script or the inspected current HyperMOS pipeline. Its conditional digest injection
is not proven to execute without an external assignment. When it does execute, it
uses whole-file vbmeta SHA256/size. Its runtime property writes do not directly
change TEE boot measurements or select Google attestation root keys. Repeated
DISABLE_AVB invocations can nevertheless repack vendor_boot at build time.
Current main invokes DISABLE_AVB once and has no ResetProp stage.

Build #63 (`65f03ee`, run 37289310030) logs the same official OTA input,
vendor_boot repack, `Keybox=true`, and installation of late-boot Fake Lock.
Build #69 logs the same OTA and repack with no ResetProp stage. The three
DISABLEavb.sh/vbpatcher.py/patch-vbmeta.py sources have **no git diff** between
these two build commits. #63 was uploaded to Drive; its image bytes were not
downloaded in this investigation, so identical final vendor_boot bytes are not
claimed. Neither build number was attached to the supplied attestation reports.

Kaorios changed in adjacent history (e.g. 0e6bf72, 2026-10-05 23:57 framework
classes.dex pin handling; cc29a7d/05e50ee, 23:57 SettingsProvider patch retirement).
These are recorded as possible pipeline differences, with no edits to that package
and no claimed causal link to the supplied reports.

The user supplied matching fingerprint patterns for the two reports. Full runtime
property dumps were not attached, so equality of all three cannot be independently
confirmed. The official vbmeta_system descriptor contains the requested missi
16OS3.1.260729.200538803.QCPECN.S; vendor/boot descriptors contain haotian
OS3.0.308.0.WOBCNXM with Android 15. Fingerprints were not modified and are not
established as a difference between the supplied reports.

## Fix and validation

- Update v4 ramdisk fragment sizes/offsets and handle individual compressed fragments.
- Recompute unsigned embedded vendor_boot payload hash; preserve signing keys.
- Reject truncated image/CPIO/LZ4, invalid magic, overflow and failed repacks.
- Use a fresh temporary workspace; validate output before replacing original image.
- Apply existing disable-AVB flag policy consistently rather than gating it on `/avb`.
  Modified signed vbmeta flags invalidate its old signature by design; the diagnostic
  does not claim signature validity or a locked/Verified device.
- Remove synthesized boot digest/size injection and reuse the existing token-safe
  fstab helper instead of partial regex stripping.
- Propagate DISABLE_AVB failure to the build.
- Capture SHA256/size/header/cmdline/bootconfig/ramdisk/DTB/AVB/public-key metadata
  before all patches, after DISABLE_AVB, and on final package images. Store JSON
  in the ROM and as a GitHub Actions artifact. No private key material is emitted.

Local checks: shell syntax checks on all changed shell files; Python compilation;
five regression tests (invalid input, truncated compression/CPIO, footer bounds,
and changed first fragment in a two-fragment v4 image) all passed.
Real official stock-image DISABLE_AVB before/after/final smoke passed under Linux:
boot/init_boot/dtbo unchanged; vendor DTB/bootconfig unchanged; no vbmeta parameter
injection; updated vendor_boot embedded payload hash matches; vbmeta flags=3.
The fixed vendor_boot hash is
12f701f87de5eb8e1bb3cb4d780a157858a61d12872fcc5b04105745e6812d76.
Reference digest after disabling verification is
9a34dcaf62c540579ba3cb0a45b336f5dff2ece13fe899c367caf9fc9ad57d88 (9,536 bytes).

[GitHub Actions validation](https://github.com/ngocminhvn/HyperMOS/actions/runs/37396492924)
**passed** for fix commit `2b306f05ef6adabb20068a60c927a52dbcdd7efe`:
shell/Python syntax, all five regression tests, and a build of official haotian
boot-chain images through the real DISABLE_AVB script followed by before/after/final
verification. JSON metadata is available in its `stock-boot-chain-integration`
artifact. Fixed fragment length is 26,971,697, matching the header and payload.
The full ROM filesystem/application build was not rerun; this CI builds and checks
the changed boot-chain path. Baseline #69 full ROM build had passed before this fix.

Review the complete [implementation diff](https://github.com/ngocminhvn/HyperMOS/commit/2b306f05ef6adabb20068a60c927a52dbcdd7efe).
Changed files: `bin/vbpatcher.py`, `bin/patch-vbmeta.py`, `bin/verify_boot_chain.py`,
`bin/package/verify_boot_chain.sh`, `bin/package/DISABLE_AVB/DISABLEavb.sh`,
`bin/package/patchpackage.sh`, `build.sh`, `uploadROM.sh`, the two boot-chain test
files, `.github/workflows/build.yml`, `.github/workflows/boot-chain-check.yml`,
and this report.

Runtime-only conclusions remain open: actual bootloader measurements, provisioning
path/key cache, certificate hook execution, TEE/StrongBox selection, root-chain
authenticity and resulting attestation/bootability of the fixed ROM. No flash test
is requested and none is claimed.

Primary references:
- https://developer.android.com/privacy-and-security/security-key-attestation
- https://source.android.com/docs/security/features/keystore/attestation
- Bundled avbtool.v1.2.py `calculate_vbmeta_digest`, and libavb1.2
  `avb_slot_verify.c` verification-disabled early return/digest calculation.
- https://github.com/BEACHEADVN/nothingsvn_xiaomi-stocktoolbuild/tree/62f38b043a4ca49437b7c642060801109f07608f/bin/package/ResetProp
