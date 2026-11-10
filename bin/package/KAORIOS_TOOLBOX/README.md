# KAORIOS_TOOLBOX — HyperMOS integration (upstream v2.0.6.2)

Integrates [Kaorios Toolbox v2.0.6.2](https://github.com/hzzmonetvn/Kaorios-Toolbox/releases/tag/v2.0.6.2).

## Layout

| Path | Content |
|---|---|
| `script/` | Byte-for-byte upstream files, only the ones the pipeline needs (no tests, docs, packaging helpers, or `bionic_fakelock_patcher.py` — HyperMOS already has its own fakelock). Replace the whole folder on update. |
| `app/` | Release assets: `classes.dex` (framework payload), `KaoriosToolbox.apk`, `lib/*/libkaoripif.so` and `lib/*/libkaoripif_diagnostic.so` (JNI installer + diagnostic engine), plus `com.kousei.kaorios.xml` (HyperMOS priv-app permissions). `patch.sh` pins their SHA-256 from the release `SHA256SUMS`. |
| `mod/kaorios_mod.py` | HyperMOS-only commands: `config`, `secure-flag`, `selinux`. |
| `patch.sh` | The only glue: calls upstream artifact pipelines and the extras below. |
| `config.json` | `enabled`, `build_spoof`, `secure_flag`, `native_pif`. |

## What runs

1. `framework.jar` — `script/patch-framework-a17-artifact.sh`: imports the payload class-by-class and patches `ActivityThread`, `Instrumentation`, `Settings$NameValueCache`; re-extracts and verifies the candidate.
2. Android 17 + `build_spoof` — upstream `kaorios_patcher.py --mode 2` on `Build` / `Build$VERSION`.
3. `services.jar` — `script/patch-services-a17-artifact.sh`: `ComputerEngine` and `SystemServer`.
4. `secure_flag` — static FLAG_SECURE bypass in `services.jar` and, if present, `miui-services.jar` (`mod secure-flag`).
5. `native_pif` — `libkaoripif.so` and `libkaoripif_diagnostic.so` to `/system_ext/lib64` and `/system_ext/lib` (paths used by upstream `KaoriosPifInstaller` and `PifNative`).
6. Toolbox APK as `system_ext` priv-app.
7. `patchpackage.sh` afterwards installs and re-checks the `kaorios_advanced_policy` SELinux contract (`mod selinux`).

The v2.0.6.2 hook set is fixed upstream, so the old per-hook switches (`pif_spoof`, `keybox`, `hidden_app`, `installer_source`, `devstatus`) are gone. Keystore hooks, the `ApplicationPackageManager` hook and the `SettingsProvider.apk` patch no longer exist upstream and are not applied. Start from a stock `SettingsProvider.apk`.

Kaorios CorePatch is not run. HyperMOS `COREPATCH/` runs first and already patches `miui-services` `notAllowCaptureDisplay`; the static Secure Flag pass here is idempotent on top of it (Android 15/16/17).

## Updating

Download the new `classes.dex`, `KaoriosToolbox-release.apk`, `libkaoripif-*.so` and `SHA256SUMS.txt`, copy `script/` from upstream, then update the `PIN` hashes in `patch.sh`.
