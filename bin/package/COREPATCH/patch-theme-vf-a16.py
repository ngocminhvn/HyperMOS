#!/usr/bin/env python3
"""Guarded HyperOS 3 / Android 16 variable-theme font bridge.

Stock binaries identified by the isolated font-framework-audit on
haotian OS3.0.308.0.WOBCNXM. Only two font classes change; unknown revisions
remain completely untouched. Do not disable Xiaomi font optimisation.
"""
from __future__ import annotations

import argparse
import hashlib
import re
import sys
from pathlib import Path

KNOWN_SHA256 = {
    "FontSettings": "69a2200d9c6f584c2866d4a85ab1d7f8a70cc203db553b67b4654e0706361c8f",
    "ThemeFontManager": "d367fc17aee4839643e39b64a4ee3d273628bc51252b34308804cd35ea2c875f",
}

FONT_SETTINGS_VF = """.method public static blacklist checkUsingThemeVF()V
    .registers 4

    # Preserve native Xiaomi VF recognition.
    invoke-static {}, Lmiui/util/font/FontSettings;->isUsingThemeFont()Z
    move-result v0
    if-eqz v0, :tnm_vf_false

    new-instance v1, Ljava/io/File;
    const-string v2, "/data/system/theme/fonts/MI_Theme_VF.ttf"
    invoke-direct {v1, v2}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/File;->exists()Z
    move-result v0
    if-nez v0, :tnm_vf_true

    # A Xiaomi theme may install a real variable TTF only as
    # Roboto-Regular.ttf. Accept it ONLY if its actual font axes include wght.
    :try_start_tnm_vf
    new-instance v1, Landroid/graphics/Typeface$Builder;
    const-string v2, "/data/system/theme/fonts/Roboto-Regular.ttf"
    invoke-direct {v1, v2}, Landroid/graphics/Typeface$Builder;-><init>(Ljava/lang/String;)V
    invoke-virtual {v1}, Landroid/graphics/Typeface$Builder;->build()Landroid/graphics/Typeface;
    move-result-object v1
    if-eqz v1, :tnm_vf_false
    const v2, 0x77676874
    invoke-virtual {v1, v2}, Landroid/graphics/Typeface;->isSupportedAxes(I)Z
    move-result v0
    :try_end_tnm_vf
    goto :tnm_vf_store
    .catch Ljava/lang/Throwable; {:try_start_tnm_vf .. :try_end_tnm_vf} :tnm_vf_catch

    :tnm_vf_catch
    move-exception v1
    goto :tnm_vf_false

    :tnm_vf_true
    const/4 v0, 0x1
    goto :tnm_vf_store

    :tnm_vf_false
    const/4 v0, 0x0

    :tnm_vf_store
    invoke-static {v0}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;
    move-result-object v0
    sput-object v0, Lmiui/util/font/FontSettings;->sIsUsingThemeVF:Ljava/lang/Boolean;
    return-void
.end method"""

# Inserted only at ThemeFontManager.getReplacedFont's original return site.
# Android's Typeface.create(base, weight, italic) caches weight/style variants.
# Keep all non-theme fonts and fonts without a real 'wght' axis untouched.
THEME_WEIGHT_TAIL = """    :goto_26
    if-eqz v1, :tnm_font_return
    invoke-virtual {p0, v1}, Lmiui/util/font/ThemeFontManager;->isFontMatched(Landroid/graphics/Typeface;)Z
    move-result v2
    if-eqz v2, :tnm_font_return
    const v2, 0x77676874
    invoke-virtual {v1, v2}, Landroid/graphics/Typeface;->isSupportedAxes(I)Z
    move-result v2
    if-eqz v2, :tnm_font_return

    # Reuse Xiaomi's existing weight scaling and dark-mode adjustment.
    sget-object v2, Lmiui/util/font/FontType;->MIUI:Lmiui/util/font/FontType;
    const/4 v3, 0x0
    invoke-static {p2, v3, v2}, Lmiui/util/font/FontWght;->getWeightIdx(IZLmiui/util/font/FontType;)I
    move-result v3
    invoke-static {v3, p4, v2}, Lmiui/util/font/FontWght;->getScaleWght(IFLmiui/util/font/FontType;)I
    move-result v3

    # Typeface.create takes a weight in the inclusive range 1..1000.
    if-gtz v3, :tnm_font_weight_positive
    const/4 v3, 0x1
    :tnm_font_weight_positive
    const/16 v2, 0x3e8
    if-le v3, v2, :tnm_font_weight_clamped
    move v3, v2
    :tnm_font_weight_clamped

    and-int/lit8 v2, p3, 0x2
    if-eqz v2, :tnm_font_not_italic
    const/4 v2, 0x1
    goto :tnm_font_style_ready
    :tnm_font_not_italic
    const/4 v2, 0x0
    :tnm_font_style_ready
    :try_start_tnm_font
    invoke-static {v1, v3, v2}, Landroid/graphics/Typeface;->create(Landroid/graphics/Typeface;IZ)Landroid/graphics/Typeface;
    move-result-object v1
    :try_end_tnm_font
    goto :tnm_font_return
    .catch Ljava/lang/Throwable; {:try_start_tnm_font .. :try_end_tnm_font} :tnm_font_catch
    :tnm_font_catch
    move-exception v4

    :tnm_font_return
    return-object v1"""


def method_replace(source: str, signature: str, replacement: str) -> str:
    pattern = re.compile(
        r"(?ms)^\.method[^\n]*" + re.escape(signature)
        + r"[^\n]*\n.*?^\.end method"
    )
    matches = list(pattern.finditer(source))
    if len(matches) != 1:
        raise ValueError(f"Expected one exact method {signature}, found {len(matches)}")
    return source[:matches[0].start()] + replacement + source[matches[0].end():]


def apply_font_settings(source: str) -> str:
    return method_replace(source, " checkUsingThemeVF()V", FONT_SETTINGS_VF)


def apply_theme_manager(source: str) -> str:
    signature = " getReplacedFont(Landroid/graphics/Typeface;IIF)Landroid/graphics/Typeface;"
    pattern = re.compile(
        r"(?ms)^\.method[^\n]*" + re.escape(signature) + r"\n.*?^\.end method"
    )
    matches = list(pattern.finditer(source))
    if len(matches) != 1:
        raise ValueError("Expected exact ThemeFontManager.getReplacedFont method")
    method = matches[0].group(0)
    if not method.startswith(".method public blacklist"):
        raise ValueError("Unexpected ThemeFontManager method access")
    if method.count("    :goto_26\n    return-object v1") != 1:
        raise ValueError("Unknown ThemeFontManager return-site layout")
    if ".registers 8" not in method:
        raise ValueError("Unknown ThemeFontManager register layout")
    method = method.replace("    .registers 8", "    .registers 10", 1)
    method = method.replace("    :goto_26\n    return-object v1", THEME_WEIGHT_TAIL, 1)
    return source[:matches[0].start()] + method + source[matches[0].end():]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("smali_root", type=Path)
    args = parser.parse_args()
    roots = sorted(args.smali_root.glob("**/miui/util/font"))
    if len(roots) != 1:
        raise ValueError(f"Expected one miui/util/font directory, got {len(roots)}")
    parent = roots[0]
    originals = {}
    for name in KNOWN_SHA256:
        path = parent / (name + ".smali")
        original = path.read_text(encoding="utf-8")
        digest = hashlib.sha256(original.encode()).hexdigest()
        if digest != KNOWN_SHA256[name]:
            print(f"[FONT-VF] Stock {name} changed (sha={digest[:12]}); skip both patches safely.")
            return 0
        originals[name] = (path, original)

    patched = {
        "FontSettings": apply_font_settings(originals["FontSettings"][1]),
        "ThemeFontManager": apply_theme_manager(originals["ThemeFontManager"][1]),
    }
    for name, text in patched.items():
        if text == originals[name][1]:
            raise ValueError(f"No change was made to {name}")
        if text.count(".method ") != originals[name][1].count(".method "):
            raise ValueError(f"Method count changed for {name}")
        if text.count(".end method") != originals[name][1].count(".end method"):
            raise ValueError(f"Method closure count changed for {name}")

    for name, source in patched.items():
        originals[name][0].write_text(source, encoding="utf-8")
        print(f"[FONT-VF] Patched {name}: MIUI theme variable font weight bridge")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError) as exc:
        print(f"[FONT-VF] ERROR: {exc}", file=sys.stderr)
        sys.exit(1)
