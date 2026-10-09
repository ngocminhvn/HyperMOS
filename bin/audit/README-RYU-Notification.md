# RYUOS HAOTIAN Notification Fix audit

Branch: `audit-ryuos-haotian-notification`. This is an investigation workflow,
**not** a patch automatically merged into HyperMOS.

## Sources

- RYUOS: `RYUOS_HAOTIAN_OS3.0.309.0.WOBCNXM_CN261005.zip`
  on SourceForge ProjectRYU / RYU-CN.
- SourceForge advertises full ZIP SHA-256:
  `42dc542c9024c478e6b45af8e6fef6ba133176fe8201a14cf59496954516ba28`.
  The default range-based workflow validates ZIP member CRCs on extraction,
  but does **not** download the entire archive and therefore cannot verify
  this full-file SHA-256. Do not confuse ZIP CRC with full-archive SHA-256.
- User-supplied stock `framework.jar`, `services.jar`,
  `miui-services.jar`: hashed locally; only a small subset of
  notification-relevant method fingerprints was saved in
  `ryu_stock_reference.json`, **not binary JARs**.
  Exact stock version must be verified; user previously referenced
  HyperMOS base OS3.0.308.0, but RYU is OS3.0.309.0.

## What the Action does

1. Read the remote ZIP directory over HTTP byte-range requests; inventory
   `images/` without storing the entire 8.4GB ZIP.
2. Stream only useful partition IMG entries. Process partition images
   one at a time, or handle `super.img` via this repo's `lpunpack.py`.
3. Read ext4/EROFS readonly. Copy framework/MIUI services JARs and
   PowerKeeper/SystemUI/SecurityCenter APKs **only within the temporary runner**.
4. Fingerprint DEX methods; compare notification/doze-related code hashes with
   the locally derived stock reference.
5. Disassemble RYU `PowerKeeper.apk` and report methods and markers:
   `MilletConfig`, `KillProcessController`, `GmsObserver`,
   `PowerKeeperApplication`, GMS MILLET settings.
6. Upload **text/JSON reports only**. Never upload stock or RYU ROM, APK,
   JAR, keybox, proprietary code or disassembled smali files.

## What it does NOT prove

- A RYU vs stock **version mismatch** may change DEX method hashes without
  any notification patch. To identify true RYU alterations, repeat against
  an **unmodified Xiaomi OS3.0.309.0** build.
- Markers do not prove push timing or battery impact. Test screen-off Doze,
  foreground/background push behavior and battery stats.
- It does not modify framework/services, PowerKeeper or the main branch.

## Run

Open repository Actions and select **RYUOS HAOTIAN Notification Fix Audit**.
Choose branch `audit-ryuos-haotian-notification`. Because newly created
`workflow_dispatch` workflow files sometimes must exist on the default branch
to appear in the UI, a **push trigger scoped to this audit branch** is
also provided for the initial run. Check Actions and download the
`ryous-haotian-notification-audit` report artifact.

GitHub-hosted standard runners have limited disk. If sparse `super.img`
exceeds free space, the workflow will fail with a clear size diagnostic.
Use `inventory_only=true` to inspect archive structure first, or
switch to a large/self-hosted runner if the partition set cannot fit.
Use a SourceForge mirror with working HTTP Range support; do not commit
expiring signed URLs.

## Next step

Only after reviewing reports, port verified minimal method patches into
a second test branch. Preserve working FCM notifications; never blindly
replace the entire RYU PowerKeeper/SystemUI and do not add persistent
wake-lock/network bypass loops.
