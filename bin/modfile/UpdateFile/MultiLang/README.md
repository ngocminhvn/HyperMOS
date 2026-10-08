# HyperMOS Vietnamese translations (HyperOS 3 / Android 16)

The bundled translations live in `updatesource/` (67 prebuilt `Nothings.*.apk`
RRO packages). **Do not delete or overwrite these files automatically.**

## What changed

- Read-only audit: `translation_audit.py`.
- Dedicated workflow: [Vietnamese Translation Audit](../../../../.github/workflows/vietnamese-translation-audit.yml).
- Optional `supplemental/*.apk` files are copied to `product/overlay/`
  during the normal China ROM build, without replacing existing filenames.
- No framework, system service, `boot.img`, `vendor_boot.img`, AVB, or runtime
  property changes. No periodic background service.

## Run the audit

Open **Actions → Vietnamese Translation Audit → Run workflow**.

**Quick mode:** Leave `rom_url` blank. This inventories overlay package IDs,
target package IDs, resource configuration coverage and invalid/duplicate APKs.
Without the stock ROM, the workflow **cannot** identify all missing translations.

**Full mode:** Paste the complete *stock* HyperOS China OTA ZIP URL containing
`payload.bin`, matching the actual ROM base. This workflow extracts
`product`, `system_ext`, and `system` (EROFS). It inspects Xiaomi apps and
system components there, including apps that have no translation overlay.

Download the **vietnamese-translation-audit** artifact after the run:

- `SUMMARY.md`: per-package totals and missing translation candidates.
- `report.json`: structured findings and original overlay file names.
- `missing.csv`: target package / resource names to review for translation.

Results are *coverage candidates*, not actual translated UI percentages.
Specifically, an overlay entry in the default `()` configuration may contain
Vietnamese, English, or Chinese. The audit counts it as a candidate **but does
not assert** it is translated. The stock ROM may also already provide `vi`.

Resource arrays, hardcoded DEX strings, remote content, and Java/Kotlin UI
code are outside this audit. A missing `string/foo` report also does not prove
it is safe or permitted to overlay: inspect `overlayable` restrictions first.

## Adding translations without breaking existing ones

1. Use `missing.csv` from the matching stock ROM build. Prioritize
   Settings, SystemUI, SystemUIPlugin, SecurityCenter, ThemeManager, Gallery,
   Camera, Calendar, Phone, Home and other frequently used Xiaomi apps.
2. Translate only verified resource names from the **matching target APK**.
   Retain format placeholders (`%s`, `%1$d`), line breaks, HTML and plurals.
3. Compile/sign a **separate** Android 16-compatible RRO APK with a unique
   package name, correct `targetPackage` and, when required, `targetName`.
   Verify overlayable policy before installing. Android cannot overlay
   resources that do not exist in the target package.
4. Put the reviewed APK in `supplemental/` and commit it. The normal ROM
   build stages it after bundled overlays **only if its filename is unique**.
5. After flashing, run:
   ```sh
   adb shell cmd overlay list --user 0
   adb shell cmd overlay dump <overlay.package.name>
   ```
   Confirm the intended overlay is enabled and the resource idmap is valid.
   Different users can have different overlay states.

The build does **not** auto-create or auto-enable an RRO: Android's
`product/overlay/config/config.xml` and existing OEM overlay configuration
control activation/precedence. A ZIP-valid APK alone does **not** guarantee
that Android will apply it. Never replace stock system APKs merely to translate
UI resources.

## Local usage

```bash
python3 bin/modfile/UpdateFile/MultiLang/translation_audit.py --self-test
python3 bin/modfile/UpdateFile/MultiLang/translation_audit.py \
  --aapt2 "$ANDROID_HOME/build-tools/36.0.0/aapt2" \
  --overlays bin/modfile/UpdateFile/MultiLang/updatesource \
  --extra-overlays bin/modfile/UpdateFile/MultiLang/supplemental \
  --stock-apks /path/to/unpacked/rom \
  --output translation-audit
```

Omit `--stock-apks` to inspect only the overlays.
