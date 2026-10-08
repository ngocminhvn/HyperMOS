# HyperMOS Vietnamese translations (HyperOS 3 / Android 16)

The bundled translations live in `updatesource/` (67 prebuilt `Nothings.*.apk`
RRO packages). **Do not delete or overwrite these files automatically.**

## Verified additive language menu translations (OS3.0.308)

`owned-additions/Nothings.Settings.xml` contains 22 **new, independently
written** Vietnamese UI strings from the stock English **Language & region**
screen. These strings were checked against the stock Settings.apk's
`MISSING_VI` resources. They were added to the **existing**
`updatesource/Nothings.Settings.apk` by the
[`Merge reviewed Vietnamese into existing overlays`](../../../../.github/workflows/merge-reviewed-vietnamese.yml)
workflow, without overwriting old Vietnamese strings, changing the Android
overlay package ID/target, or changing its signing certificate.

**This localizes the Language & region screen text.** It does not change the
list of languages the China ROM exposes in the locale picker.
To open the picker on a running phone, use Settings search for
`Language & region` / `Add a language`. If Vietnamese is missing from
the offered locales, check the underlying Xiaomi Settings locale filters
separately rather than trying to solve it by inserting extra string resources.

The community Xiaomi.eu translation repository is used as **reference for
resource-name coverage only**. Its public repository has no explicit license;
this project does not copy its full translated XML text or distribute the
1,676 candidate translations without permission. The
`Xiaomi.eu Vietnamese Resource Gap Audit` artifact contains only candidate
resource names, including 1,676 stock-validated gaps, not the translation
text itself. Treat these as review candidates, not completed translations.

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

## English stock → Vietnamese overlay comparison

**English is the source language; Vietnamese is the translation.**
When a matching stock HyperOS OTA is provided, the audit compares the English
strings from the stock Settings/SystemUI/SecurityCenter APKs with
the corresponding names in the existing Vietnamese RROs. The audit now exports:

- `english-vietnamese-all.csv`: original English text, existing Vietnamese
  text, and the status of each matched string name.
- `english-vietnamese-review.csv`: potentially untranslated / missing keys,
  with likely user-facing settings listed first.
- `english-vi-summary.json`: counts, warnings and limitations.

Settings, MiSettings, MiuiSystemUI, HyperPhoneSystemUI, MiuiSystemUIPlugin,
and SecurityCenter are the initial high-priority overlay files.
If no stock ROM URL is supplied, only the overlay inventory is available;
a missing-English-translation claim **cannot** be made from the overlays alone.

Caveats: this intentionally conservative English detector may miss short labels.
Unchanged brand names and technical acronyms are not necessarily translation
errors. A resource name can exist in multiple APKs, and RRO signature/idmap
compatibility must be tested on the device. Do not create another overlay package
or automatically translate every candidate. Preserve the existing APK identity
and only rebuild an existing RRO after verifying its signing requirements.

## Adding translations without breaking existing ones

1. Use `english-vietnamese-review.csv` from the exact matching stock OTA
   and inspect the existing Settings, SystemUI, and SecurityCenter overlay XML.
2. Translate only relevant missing user-facing English resources. Keep exact
   resource names, placeholders (`%s`, `%1$d`), plurals, markup and escapes.
3. Prefer updating the **original existing** overlay APK; do not add a new
   package with the same target. Check that the source package's signing policy
   allows safe repacking, and verify the overlay idmap on a test device.
4. If original-signature compatibility cannot be preserved, leave the APK
   unchanged instead of swapping in a test-signed replacement.
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
