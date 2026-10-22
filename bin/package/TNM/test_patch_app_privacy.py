#!/usr/bin/env python3
"""Host-side regression checks for the signature-gated APM transformer."""
import subprocess
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
PATCHER = HERE / "patch_app_privacy.py"

SIGNATURES = (
    "getInstalledApplicationsAsUser(Landroid/content/pm/PackageManager$ApplicationInfoFlags;I)Ljava/util/List;",
    "getInstalledPackagesAsUser(Landroid/content/pm/PackageManager$PackageInfoFlags;I)Ljava/util/List;",
    "getApplicationInfoAsUser(Ljava/lang/String;Landroid/content/pm/PackageManager$ApplicationInfoFlags;I)Landroid/content/pm/ApplicationInfo;",
    "getPackageInfoAsUser(Ljava/lang/String;Landroid/content/pm/PackageManager$PackageInfoFlags;I)Landroid/content/pm/PackageInfo;",
    "getPackageUidAsUser(Ljava/lang/String;Landroid/content/pm/PackageManager$PackageInfoFlags;I)I",
    "getPackageGids(Ljava/lang/String;Landroid/content/pm/PackageManager$PackageInfoFlags;)[I",
)


def fixture(signatures=SIGNATURES):
    methods = []
    for signature in signatures:
        if signature.startswith("getInstalled"):
            body = "    .locals 1\n    const/4 v0, 0x0\n    return-object v0"
        elif signature.endswith(")I"):
            body = "    .locals 1\n    const/4 v0, 0x0\n    return v0"
        else:
            body = "    .locals 1\n    const/4 v0, 0x0\n    return-object v0"
        methods.append(f".method public {signature}\n{body}\n.end method")
    return ".class public Landroid/app/ApplicationPackageManager;\n.super Ljava/lang/Object;\n\n" + "\n\n".join(methods) + "\n"


with tempfile.TemporaryDirectory() as directory:
    target = Path(directory) / "ApplicationPackageManager.smali"
    target.write_text(fixture())
    subprocess.run(["python3", str(PATCHER), str(target)], check=True)
    patched = target.read_text()
    assert patched.count("Landroid/app/TnmAppPrivacy;") >= 6
    assert patched.count(":tnm_app_privacy_continue") == 8
    assert patched.count("filterApplicationInfoList") == 1
    assert patched.count("filterPackageInfoList") == 1

    before = fixture(SIGNATURES[:-1])
    target.write_text(before)
    failed = subprocess.run(["python3", str(PATCHER), str(target)], capture_output=True)
    assert failed.returncode != 0
    assert target.read_text() == before, "unsupported layout must remain untouched"

print("TNM App Privacy APM transformer PASS")
