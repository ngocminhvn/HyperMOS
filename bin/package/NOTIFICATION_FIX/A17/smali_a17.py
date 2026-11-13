"""Method-local edits for the Android 17 notification patches."""

import os
import re

DEFAULT_FSI_PACKAGES = ("com.zing.zalo", "com.facebook.orca")


def load_fsi_packages():
    """Load FSI packages from environment variables or use defaults.

    Allows adding or overriding packages via command line / environment:
      FSI_PACKAGES="com.zing.zalo,com.facebook.orca,org.telegram.messenger"
    or appending extra packages:
      EXTRA_FSI_PACKAGES="org.telegram.messenger,com.whatsapp"
    """
    env_fsi = os.getenv("FSI_PACKAGES") or os.getenv("HYPERMOS_FSI_PACKAGES")
    extra_fsi = os.getenv("EXTRA_FSI_PACKAGES")
    if env_fsi:
        packages = [p.strip() for p in env_fsi.split(",") if p.strip()]
    else:
        packages = list(DEFAULT_FSI_PACKAGES)
    if extra_fsi:
        for p in extra_fsi.split(","):
            p = p.strip()
            if p and p not in packages:
                packages.append(p)
    return tuple(packages)


FSI_PACKAGES = load_fsi_packages()


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
