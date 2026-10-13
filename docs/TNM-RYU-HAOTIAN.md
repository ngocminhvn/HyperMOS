# TNM app / RYU HAOTIAN integration branch

ROM: `ngocminhvn/HyperMOS@test-tnm-ryu-haotian`, based on
`test-ryu-performance-haotian` at `4461ab0e25701ee92ed6e0097955705b0e69650a`.
App: `ngocminhvn/app@test-tnm-ryu-haotian`, based on
`codex/ryu-thermal-ui` at `0ff35e40e214bda7ea9a62093da555731e83ff94`.

## Latest TNM APK during ROM builds

The ROM workflow downloads the latest **signed TNM app** from
`ngocminhvn/app@main` through GitHub Pages:

- Manifest: `https://ngocminhvn.github.io/app/update.json`
- APK: `TNM.apk` or `TNM.apk.xz`, as specified by the manifest
- Integrity: `packageSha256` from the manifest (SHA-256 checked before extraction)

No `tnm_test_apk_url` or `tnm_test_apk_sha256` Action inputs are needed.
The installer also validates APK signature, package name, minimum version,
manifest versionCode/versionName, framework backend capability contract and
ARM64 native libraries before staging it as a privileged app.

**Important:** This selects the latest *published* `app/main` version,
not an unbuilt or unpublished commit on an experimental app branch.
The RYU PowerKeeper donor APK is a separate dependency, not the TNM app.
Because the old release URL returns HTTP 404, ROM build and RYU DEX preflight
look up the newest unexpired `RYUOS-HAOTIAN-PowerKeeper` Actions extraction
artifact from this repository. Its original SHA-256 is still pinned to
`7783b8581deeaf2c39d4fdf04d68a724b9f9c2d0fdf2604b866b399efca27108`.
The current extraction artifact expires on **2026-10-19 UTC**; before then,
renew the extraction artifact or migrate the donor to a durable authorized
storage location. Builds fail closed if the reference expires or hash differs.

## Framework, notifications and app behavior

The ROM retains the guarded framework FCM/FGS/Doze patches and ten
original performance XMLs plus nineteen selected thermal profiles. The default
PowerKeeper path is now `full-donor-dex`: transplant all 2,974 verified
RYUOS executable classes (including 20 PerfHook classes and UID/GMS policy)
into the Xiaomi APK while retaining its original Manifest/resources.
This is verified in CI, not yet proven to boot or operate on the phone.

TNM app calls `tnm-bridge` -> its signed APK backend `tnmctl` ->
`/system_ext/bin/tnm-frameworkctl` -> `/system_ext/bin/tnm-thermalctl`.
Those commands update the `projectryu_thermal_*` Settings keys. The
PowerKeeper RYU observer/PerfHook reads the same keys. The original names
must stay for binary compatibility with the transplanted RYU observers;
TNM remains the UI/ROM brand and the control implementation.

For direct Java call sites, **TNMFramework is now embedded into the
PowerKeeper DEX** as `Lcom/android/tnm/TNMFramework;`, not as a
ProjectRYUFramework jar alias. The port rewrites ten original calls to
seven concrete TNMFramework static APIs:
`getSystemInt`, `getSystemIntForUser`, `getSystemLong`,
`getSystemString`, `putSystemInt`, `putSystemLong`,
`putSystemString`. These delegate to their matching
`Settings.System` implementations. A compiled DEX verifier refuses
missing/abstract methods or leftover `ProjectRYUFramework` references.

The TNM app already includes ROM diagnostics, battery saver, display presets,
and notification tools from its base branch. This branch exposes the full
ROM command list, replaces visible RYU labels with TNM, allows up to 32
per-app profiles and confirms the saved per-app map after applying it.

The shell `TNMFramework` remains an on-demand root adapter; the embedded
`TNMFramework` Java class is a **real direct-call compatibility API inside
PowerKeeper**, not a system-wide Binder service or extra framework JAR.
The **20 original RYU PerfHook implementation classes are relocated at build
time to `com.android.tnm.perf.*`**, with DEX descriptor and Java reflection
class-name references rewritten throughout the donor bytecode. The compiled
APK verifier rejects remaining `com.projectryu.perf.*` names/references.
The `projectryu_thermal_*` Settings keys are intentionally unchanged for
compatibility with the original observer/settings protocol; those names are
not Java classes or evidence of a ProjectRYUFramework JAR dependency.
No-limit/charging profiles and thermal safety changes remain outside the port.
A complete ROM build and on-device test are still required to establish boot
and functional parity with RYU.

## Local RYU framework audit (2026-10-11)

Reference: `D:/RYUOS`, HAOTIAN OS3.0.309.0.WOBCNXM CN261005.
User-supplied base: `D:/rom_goc` (three JARs; no version metadata supplied).
SHA-256:

- `framework.jar`: `36426149118b109a33f4a8b143bb5390dbe50ca0e21d00fd16f357710b368f0f`
- `services.jar`: `00b899d027d940cdf7c130bab8e3a08cf7cf4fefef464eb476572392551ec799`
- `miui-services.jar`: `00561c82eccd541a1935a4ed608283afdba712234aa5f884f4ba276c17104144`

JAR hashes and 44 method signatures / 47 build-gate sites are pinned in
`bin/package/COREPATCH/ryu_framework_gates_a16.json`. The actual donor's
`com.projectryu.Build.IS_RYU_BUILD` is initialized to true.

On the TNM branch, `--ryu-framework-gates` replaces only those audited gates
with a true constant. This covers the existing full-screen intent AppOp
branch, force-stop policy branch, application start/compatibility checks,
clipboard, JobService, input permission policy, location regional gates,
dark-mode list, fonts, Nearby and shortcut/AppOps policies. Original method
bodies, Android permission checks and package resource IDs are preserved.
Many of these outcomes were already enabled by the generic CN patch's
`IS_MIUI`/`xBuild` substitutions. They are now explicit and checked per method;
they should not be counted as 47 newly introduced behaviors versus #118.

The confirmed opposite outcome is `ProcessPolicy.updateContentCatcherWhitelist`:
the previous ContentExtension patch forces false and updates the Taplus
whitelist, while the donor takes the true/international early exit. TNM now
matches that donor branch, retaining the stock logging and code below it.
FCM/FGS, first-boot broadcast and low-power Doze keep their specialized patches.

The build rejects missing/duplicate classes, changed method signatures,
register layouts or gate neighbors before writing any target in that JAR.
Both MIUI JARs are checked after all CorePatch edits. The test suite exercises
idempotence, branch/register drift, partial-write rejection and parameter
register encoding. Local verification assembles the actual reference class
subsets to DEX and decodes them again; this is not a device runtime test.
The 37 miui-services methods / 39 gates are tested against the actual
`D:/rom_goc/miui-services.jar`. The base has no `miui-framework.jar`: its
seven methods / eight gates are tested using donor class layouts with stock
build-gate reads substituted as fixtures, so compatibility with the base
miui-framework is not yet confirmed. The build performs that validation
against the actual input and aborts on layout drift.
The complete miui-services patch function was also run on every class it
targets from that base, with signature bypass, CN/FCM/FGS policy, low-power
Doze, the new gates and FLAG_SECURE bypass enabled together; both resulting
DEX class subsets assembled successfully. This checks patch interaction,
not Android boot or hardware behavior.

TNM remains the ROM app. Kaorios Toolbox and its framework/keystore hooks,
CorePatch/signature bypass, FLAG_SECURE bypass and AVB disabling remain enabled
in their existing order. RYU's private, obfuscated keybox/PIF/app-hiding/native
hook stack is not copied on top of Kaorios. Resource-table IDs, the additional
malware method in the newer donor, and MTK-specific fling changes are not
transplanted from the different donor version. This audit does not imply full
RYU framework equivalence.


### Extended RYU thermal selection

18 selectors use the IDs from donor HAOTIAN thermal-odm-map.conf. `thermal.profiles` returns only installed, nonempty configurations; TNM uses this list for global and per-app menus and rechecks before applying. The original PerfHook foreground/screen-off behavior is retained. Charging, No Limits and TGame are not added to the manual selector. Original RYU framework API/native, game props, PIF/keybox UI and malware/AppOps donor changes are outside this change. Device runtime validation is still required.


### Full audit follow-up

ROM-side thermal changes are serialized across separate clients. A complete batch is validated before taking the lock; previous Settings are captured, writes are read back, and failures restore the previous map, global selection and activation mode. Missing Settings are restored by deletion rather than writing the literal `null`. Protected profiles stay excluded. The TNM APK is selected automatically from the latest published app/main updater manifest, not pinned to a historical test APK. The PowerKeeper donor is separately SHA-256 pinned and must remain available to the ROM workflow.

Locks use the kernel boot ID and are removed on normal exits and catchable signals. A writer killed with SIGKILL cannot run rollback; its lock is retained for that boot to prevent concurrent clients from incorrectly reaping a newly acquired lock. A reboot creates a fresh lock namespace.
