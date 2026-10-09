# HyperMOS variable fonts

HyperMOS keeps **stock MiSans** and **Roboto**, adds **Noto Sans** and
**Open Sans**, and retires **SF Pro**. All custom text fonts are registered as
separate Xiaomi ThemeManager `.mrc`/`.mrm` resources in **one** theme root.
No framework patch, boot-chain modification, or font mirroring is used.

## Included font choices

- **MiSans**: original HyperOS system font and native slider behavior (untouched).
- **Roboto**: existing `Roboto-VF.ttf` resource (stable resource ID).
- **Noto Sans**: official Google Fonts variable `wght` font.
- **Open Sans**: official Google Fonts variable `wght` font.
- **SF Pro**: binary removed and previous generated ThemeManager resource IDs
  cleaned up at build time.

The two new fonts are downloaded **at ROM build time**, not from the phone:
`font_utils.py prepare` pins a specific `google/fonts` commit and validates
the actual downloaded bytes against their known Git blob hashes and sizes.
A failed fetch or mismatch fails the build; it never silently substitutes a
font. This avoids embedding two large third-party binaries in Git history.

## Weight adjustment and limitations

`font_utils.py catalog` reads the real OpenType `fvar/wght` axis and maps
**ten MiSans-style relative weight positions** into each custom font's
supported range. The ThemeManager metadata uses the plural `fontWeights`
list on both font and parent theme resources.

**Important:** The stock Xiaomi Settings app may not expose/apply its MiSans
weight slider for third-party theme fonts. Ten valid metadata entries cannot,
by themselves, override framework gating. This configuration is ready for
variable weights, but actual slider behavior must be confirmed on the device.
We intentionally do **not** reintroduce the removed framework font patch.

## Add a local font

Put one true variable `.ttf`/`.otf` file with a `wght` axis in
`bin/modfile/UpdateFile/Fonts/HyperOS/`. A static Regular/Bold family
is not a substitute. Optional display metadata belongs in `fonts.json`:

```json
{
  "Inter-VF.ttf": {
    "title": "Inter",
    "author": "The Inter Project",
    "normalize_line_gap": false
  }
}
```

Unknown fields and missing files fail validation. A custom font must contain
the Vietnamese glyphs needed for full coverage; the catalog warns for common
missing glyphs. `normalize_line_gap` is off by default.

## Build validation

```bash
python3 bin/modfile/UpdateFile/Fonts/font_utils.py prepare \
    bin/modfile/UpdateFile/Fonts/HyperOS /tmp/hypermos-font-sources
python3 bin/modfile/UpdateFile/Fonts/font_utils.py catalog \
    /tmp/hypermos-font-sources /tmp/hypermos-font-catalog
```

The ROM workflow performs this preflight before unpacking stock partitions.
The actual installer repeats validation and checks each ThemeManager resource
graph. Original default theme and MiSans are not modified.

## Licensing and shared emoji

Noto Sans and Open Sans are distributed under the **SIL Open Font License 1.1**.
Their upstream notices are under `HyperOS/licenses/` and copied to the ROM's
`etc/licenses/hypermos-fonts`. Sources:
- https://github.com/google/fonts/tree/main/ofl/notosans
- https://github.com/google/fonts/tree/main/ofl/opensans

The shared iOS emoji payload is separate at
`Fonts/Shared/NotoColorEmoji.ttf`. HyperOS and classic MIUI use that
source through `install-emoji.sh`. Nothing in this change modifies
MIUI's default text fonts.
