# ProjectRYU Hide App List: static evidence and TNM scope

This report is based on static disassembly of the supplied artifacts. It is not
a boot/runtime compatibility claim.

## Artifact evidence

`frameworkRYU(1).jar` SHA-256 is
`6bebf380a92beced2a500bef2d8ffa61a54ff66d14728980440cbf6a5df1b48b`.
Its `classes.dex` patches `android.app.ApplicationPackageManager`; `classes5.dex`
contains `android.security.projectryu.ProjectRYUHook`; and `classes6.dex`
contains `com.projectryu.ProjectRYUFramework`, `ProjectRYUSettings`, and the
obfuscated policy/cache classes `RYUalf`, `RYUale`, and `RYUadj`.

The other supplied hashes are `servicesRYU.jar`
`d4a16f6908c36336188ac031ca9abb98a47e168aaeb8596d37bdf658802f7f7a`,
`miui-servicesRYU(2).jar`
`777e17d73b4871fccfd4aa06e3b5ff06204f90c259416afa51575c9391ed1388`,
`miui-frameworkRYU(2).jar`
`2b5394d7c5a0a3fcc7bcecb6743fa8bec34de480af82345f19d7c14d420c4696`,
and `ProjectRYU-Toolbox.apk`
`a8cab0addec27fcdf13f4b0dc58b95ea7d854a305f3591ea3d0af5f151b09341`.
All DEX files in all four JARs were searched; the Hide App List symbols and
policy occur in `frameworkRYU(1).jar`, not the services or MIUI JARs.

Observed call sites are:

| Android API | RYU action |
| --- | --- |
| `getInstalledApplicationsAsUser(ApplicationInfoFlags,int)` | filters returned `ApplicationInfo` objects |
| `getInstalledPackagesAsUser(PackageInfoFlags,int)` | filters returned `PackageInfo` objects |
| `getApplicationInfoAsUser(String,ApplicationInfoFlags,int)` | throws `NameNotFoundException` when hidden |
| `getPackageInfoAsUser(String,PackageInfoFlags,int)` | throws `NameNotFoundException` when hidden |
| `getPackageUidAsUser(String,PackageInfoFlags,int)` | throws `NameNotFoundException` when hidden |
| `getPackageGids(String,PackageInfoFlags)` | throws `NameNotFoundException` when hidden |

`shouldHideAppName()` was also searched. The only definition is Android's
unrelated `ConversationLayout.shouldHideAppName()`; it is not part of RYU's
package-list policy.

## Configuration and identity

Decoded constants prove that `RYUalf` reads two comma-separated
`Settings.Global` values: `projectryu_hide_devlist` and
`projectryu_hide_applist`. The second is the set of package names hidden from
queries; it is not a set of viewer apps. Empty entries are discarded and the
sets are cached against ProjectRYU's time/config token. Toolbox native strings
also contain `projectryu_hide_applist`, and its UI describes selected apps as
apps to hide.

RYU obtains the caller with `Process.myUid()` and
`IPackageManager.getPackagesForUid(uid)`. It fails open for app IDs below 10000,
missing caller packages, the target's own package, and these decoded exemptions:
`android`, `com.projectryu.toolbox`, `com.projectryu`,
`com.android.systemui`, and `com.android.providers.settings`. List filtering
constructs a fresh list and does not mutate PackageManager's installed-package
database. The hook is enabled only after decoded property `sys.boot_completed`
is true.

`ProjectRYUSettings.initialize()` reads a global ABI/version integer, raises it
to at least 2, and initializes the RYU time token when absent. It does not prove
that every package discovery API is covered. No observed hook covers direct
Binder calls or intent/provider query APIs.

## TNM differences and unverified areas

TNM uses its own schema-1 keys and an even/odd generation transaction instead
of RYU's shared time token. It additionally protects installers, permission
controllers, launchers, SecurityCenter and TNM itself to reduce boot/package
management risk. The six client API semantics match the observed RYU call sites;
the broader RYU framework, Keybox, Activation and developer-option logic is not
ported.

Static Smali assembly and synthetic call-site tests cannot prove boot, runtime,
multi-user, China/EU vendor behavior, or parity with direct Binder and query
APIs. Those remain device-validation items; therefore the ROM build gate is
off by default.

The supplied Android 16 Xiaomi.eu 17.0 `framework.jar` was also decompiled and
the gated transformer successfully rebuilt its complete APM DEX and candidate
JAR. The RYU framework conflict test preserved the input SHA-256 exactly and
created no marker. These are host-side compatibility checks, not device boot or
runtime validation; a clean China framework has not yet been supplied/tested.
