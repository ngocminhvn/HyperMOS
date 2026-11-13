"""Method-local edits for the Android 17 notification patches."""

import re


FSI_PACKAGES = ("com.zing.zalo", "com.facebook.orca")


def edit_method(source, signature, edit):
    pattern = rf"(?ms)^\.method[^\n]*\s{signature}[ \t]*\n.*?^\.end method[ \t]*$"
    matches = list(re.finditer(pattern, source))
    if len(matches) != 1:
        raise ValueError(f"expected one method matching {signature}, got {len(matches)}")
    method = matches[0]
    return source[:method.start()] + edit(method.group()) + source[method.end():]


def replace_site(block, pattern, replacement, feature, patched_pattern=None):
    marker = f"# XNotifyFix {feature}"
    if marker in block or (patched_pattern and re.search(patched_pattern, block, re.MULTILINE)):
        return block
    matches = list(re.finditer(pattern, block, re.MULTILINE))
    if len(matches) != 1:
        raise ValueError(f"{feature}: expected one instruction site, got {len(matches)}")
    site = matches[0]
    return block[:site.start()] + site.expand(replacement + f"  {marker}") + block[site.end():]
