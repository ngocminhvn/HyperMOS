# Custom variable fonts in HyperMOS

## Add a new font

Place a **single variable** `.ttf` or `.otf` file directly inside:

`bin/modfile/UpdateFile/Fonts/HyperOS/`

Example: `Inter-VF.ttf`. The ROM build automatically discovers it and registers a
separate native Xiaomi ThemeManager font resource. No edits to `update.sh`,
`font_utils.py`, or the framework patch are necessary.

**Requirements:** A valid OpenType variable font with a real `wght` axis and
ten distinguishable weight stops. A collection of separate static
`Regular.ttf`, `Medium.ttf`, `Bold.ttf` files will **not** become a
continuous-weight font. The build rejects static files with a clear error
rather than quietly presenting a nonfunctional weight slider.

Emoji is stored **once** at `Fonts/Shared/NotoColorEmoji.ttf`, outside the
HyperOS variable-text-font catalog. Both HyperOS and classic MIUI use this
single payload through `install-emoji.sh`; the original MiSans and MIUI text
fonts are unaffected. Stock `MiSansVF.ttf` is excluded from ThemeManager
custom-font registration, and SF Pro / Roboto IDs are preserved.

## Optional display names or leading correction

Add an optional `fonts.json` inside the same `HyperOS/` directory:

```json
{
  "Inter-VF.ttf": {
    "title": "Inter",
    "author": "Inter",
    "normalize_line_gap": false
  }
}
```

The filename must match exactly. Unknown keys and missing files cause a
fast, clear build error. The default display title comes from the filename.
`normalize_line_gap` is only enabled by default for `SF-Pro.ttf`; other
fonts preserve their original vertical metrics. Do not enable it unless the
font really has excess leading, as it may affect Vietnamese diacritics.

## Implementation details

- Build-time validator: `font_utils.py catalog <directory> <output>`
- Output: `catalog.tsv` and `catalog.json` plus prepared fonts where needed.
- Resource IDs: stable UUIDv5 derived from **filename**, not font bytes.
- SF Pro / Roboto: previous fixed resource IDs preserved for safe upgrades.
- Registration: existing Xiaomi `.mrc` / `.mrm` ThemeManager graph and dark
  previews; no duplication across partitions.
- Font preview: `font_utils.py preview <title> <font> <png>`
- CI: `Font Catalog Check` checks actual bundled fonts and a simulated third
  custom variable font without a full ROM build.

**Important:** Metadata and the guarded Android 16 framework patch do not
prove that the Settings weight slider works on a device. Xiaomi Settings may
also require `/data/system/theme/fonts/MI_Theme_VF.ttf`; the existing
framework fallback is not a substitute for a verified Settings integration.
Only real-device testing can confirm this UI behavior.

## Shared emoji (HyperOS and MIUI)

The canonical emoji file is `bin/modfile/UpdateFile/Fonts/Shared/NotoColorEmoji.ttf`.
It replaces each existing `NotoColorEmoji.ttf` under extracted ROM partitions.
Do **not** add emoji files to `HyperOS/` or `MIUI/`. The legacy separate MIUI
emoji payload has been removed; both platforms intentionally use the former
HyperOS iOS-emoji payload. The change is built into the ROM, not applied at runtime.
