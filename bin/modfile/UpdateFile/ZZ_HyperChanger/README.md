# TNM HyperChanger SystemUI integration

This module ports the lock-screen charging information behavior demonstrated by
the supplied Project RYU `MiuiSystemUI.apk`, while using TNM App's existing
`Settings.System` contract (`hyperchanger_*`). It supports power, current,
voltage, battery temperature, original-text visibility, text size, one-shot
sampling, and configurable periodic refresh.

The hook is the same stable lifecycle point used by the RYU reference:
`KeyguardIndicationInjector(Context, KeyguardIndicationController, ...)`. The
runtime is self-contained and does not require ProjectRYU framework classes,
resource IDs, a service, root, or a wakelock. Unsupported Xiaomi class layouts
are left untouched and do not receive the capability marker.

`classes3.dex` in HAOTIAN OS3.0.308 is already at its string-reference limit,
so the runtime is isolated in a new `classes4.dex` (or the next free DEX on a
base that already has more splits); only the injector's existing DEX is rebuilt.

The APK is never re-signed. Matching the supplied RYU APK, the output omits the
v2/v3 APK Signing Block while retaining every V1 META-INF identity file and all
original ZIP-entry metadata. The build verifies that every non-target member is
byte-identical. Because DEX bytes change, the retained V1 signature metadata is
intentionally invalid and requires the ROM's existing signature-verification
bypass.

The TNM capability marker is written only after patching, assembly, package
identity, ZIP integrity, and metadata-preservation checks all pass:
`/system_ext/etc/tnm/hyperchanger-v1`.
