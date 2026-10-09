# HyperMOS Vietnamese translations (HyperOS 3 / Android 16)

The bundled translations live in `updatesource/` (67 prebuilt `Nothings.*.apk`
RRO packages). **Do not delete or overwrite these files automatically.**

## New HyperOS 3 translations merged into existing APKs

Commit `207abc07dba65abaae7b1aac703779c769f94b88` adds **358 new,
independently authored** Vietnamese strings to the original existing RRO APKs:

| Existing overlay APK | Added string keys |
| --- | ---: |
| Nothings.Settings.apk | 85 |
| Nothings.MiuiSystemUI.apk | 115 |
| Nothings.MiuiSystemUIPlugin.apk | 56 |
| Nothings.SecurityCenter.apk | 102 |
| **Total in this batch** | **358** |

All additions are kept as original source XML under `owned-additions-batch/`.
Workflow [Merge original Vietnamese translations into existing RROs]
(../../../../.github/workflows/merge-reviewed-vietnamese-batch.yml) verifies
each name against matching HyperOS 3 stock English `MISSING_VI` entries,
rejects conflicting old translations or mismatched placeholders, and checks
matching overlay package/target and signing certificate. The 4 existing APKs
are replaced in the *repository* only after all 4 pass the checks. No extra
overlay APKs and no framework/boot changes are made.

**These 358 are only part of the 1,676 candidate gaps**, not a claim that
1,676 translations have been added. The earlier 22 Language/region additions were explicitly **removed**
by request because Vietnamese language selection already worked. The remaining
358 strings were compiled and checked, but not every label has been individually
verified on a running device.

The upstream public community translation repo is not licensed for bulk
redistribution; do not assume its entire values-vi XML can be copied merely
because it is publicly readable. Instead, independently translate remaining
English stock resources and review correctness before merging.

## Language/region translations intentionally retired

The earlier 22 source-owned Language & region labels were removed from
the existing Settings RRO after user testing confirmed that Vietnamese
language selection was already supported by the original overlays.
The 85 newer independently translated Settings strings remain intact.
The retired-language-region.keys list prevents future accidental re-addition.

## What changed

- Read-only audit: `translation_audit.py`.
- Dedicated workflow: [Vietnamese Translation Audit](../../../../.github/workflows/vietnamese-translation-audit.yml).
- Optional `supplemental/*.apk` files are copied to `product/overlay/`
  during the normal China ROM build, without replacing existing filenames.
- No framework, system service, `boot.img`, `vendor_boot.img`, AVB, or runtime
  property changes. No periodic background service.

## Additional apps — original Vietnamese batch

An additional **106 independently authored Vietnamese strings across 8 existing overlays** are staged in `owned-additions-batch/`:

- `Nothings.Calendar.apk`: 27 new keys
- `Nothings.MiShare.apk`: 21 new keys
- `Nothings.InCallUI.apk`: 12 new keys
- `Nothings.PowerKeeper.apk`: 10 new keys
- `Nothings.ThemeManagerV2.apk`: 8 new keys
- `Nothings.ThemeManager.apk`: 17 new keys
- `Nothings.MiuiHome.apk`: 8 new keys
- `Nothings.Contacts.apk`: 3 new keys

These are new, manually authored translations of resource names verified by the
matching HyperOS OS3.0.308.0 stock-resource audit (successful run
`37803649836`). The merge workflow now discovers all reviewed XML additions
rather than only four fixed overlays. It checks the English `MISSING_VI`
rows, preserves old values, validates format placeholders, compiled resource IDs,
overlay package/target identity and original signing certificate. It changes
no ROM framework, boot image or Kashi asset.

The XML source commit alone does **not** mean the APK files were rebuilt.
Only a successful `Merge original Vietnamese translations into existing RROs`
workflow and its subsequent APK commit establish a compiled update. Device
idmap/render testing remains necessary.

## Xiaomi framework-dependent overlay repair

The stock-HyperOS audit run `37869472353` confirmed a missing Apktool
Xiaomi framework resource package ID 18. It now extracts the matching
`miuisystem.apk` from the `OS3.0.308.0.WOBCNXM` OTA, installs it using
`apktool if`, and archives installed framework files for subsequent RRO
decoding and verified signing. It successfully decoded **FileExplorer,
MiuiGallery and MiuiBluetooth** overlays that previously failed.

This batch stages **290 independently authored Vietnamese strings** for
these three existing overlay APKs, without translating application-internal
class names, fonts, encoded keys, Android permission constants or other
non-UI resources:

- `Nothings.FileExplorer.apk`: 22 new strings
- `Nothings.MiuiGallery.apk`: 86 new strings
- `Nothings.MiuiBluetooth.apk`: 182 new strings

The merge workflow is configured to use audit run `37869472353` and its
`stock-frameworks/18.apk` for decompilation and recompilation. Existing
Vietnamese values are append-only and unchanged. Successful build/commit
is required before an APK update is considered complete.

## Extending Vietnamese to more built-in apps

The 67 original Nothings RROs already cover many Xiaomi apps. The full
English-to-Vietnamese gap audit now inspects 24 existing overlay targets,
including **MiuiHome, Camera, Gallery, FileExplorer, Weather, Calendar,
Contacts, InCallUI, ThemeManager, Permissioncontroller, PowerKeeper,
PersonalAssistant, Messages, AOD, Bluetooth, MiSound and MiShare**.

The workflow produces a per-overlay missing-string breakdown and
`english-vietnamese-review.csv`. This is a read-only **candidate inventory**,
not a claim that all these additional applications have been newly translated.
New texts must be independently translated from the matching stock ROM,
checked for technical terms and placeholders, and merged into the matching
existing APK without overwriting existing Vietnamese.

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
