#!/usr/bin/env python3
"""Generate installer from user's local Mods/Packageinstaller payload, not from latest network releases."""
from pathlib import Path
import subprocess
import shutil

ROOT=Path.cwd()
MODS=ROOT/"Mods/Packageinstaller"
OUT=ROOT/"work/installer/MIUIPackageInstaller.apk"
OUT.parent.mkdir(parents=True, exist_ok=True)

def call(*args):
    subprocess.run([str(a) for a in args], check=True)

def package(apk):
    output=subprocess.check_output(["aapt","dump","badging",str(apk)],text=True)
    import re
    return re.search(r"^package: name='([^']+)'",output,re.M).group(1)

ready=MODS/"MIUIPackageInstaller.apk"
if ready.is_file():
    if package(ready)!="com.miui.packageinstaller":
        raise SystemExit("User-supplied MIUIPackageInstaller.apk has unexpected Android package")
    shutil.copy2(ready,OUT)
else:
    source=MODS/"InstallerX-Revived-online-26.09.apk"
    if not source.is_file():
        raise SystemExit("Need prepared MIUIPackageInstaller.apk or InstallerX source")
    decoded=ROOT/"work/installer/decode"
    unsigned=ROOT/"work/installer/unsigned.apk"
    call("java","-Xmx4g","-jar",ROOT/"Tools/apke.jar","d","-t","xml","-f","-no-dex-debug","-i",source,"-o",decoded)
    old="com.rosan.installer.x.revived"
    new="com.miui.packageinstaller"
    changed=0
    for p in decoded.rglob("*"):
        if not p.is_file():
            continue
        try: text=p.read_text("utf-8")
        except UnicodeDecodeError: continue
        if old in text:
            p.write_text(text.replace(old,new),encoding="utf-8")
            changed+=1
    if not changed or new not in (decoded/"AndroidManifest.xml").read_text("utf-8"):
        raise SystemExit("InstallerX package identity patch was not verified")
    call("java","-Xmx4g","-jar",ROOT/"Tools/apke.jar","b","-t","xml","-f","-i",decoded,"-o",unsigned)
    call("java","-jar",ROOT/"Tools/apksigner.jar","sign",
         "--key",ROOT/"Tools/security/testkey.pk8","--cert",ROOT/"Tools/security/testkey.x509.pem",
         "--out",OUT,unsigned)
if package(OUT)!="com.miui.packageinstaller":
    raise SystemExit("Installer package mismatch after patch")
call("java","-jar",ROOT/"Tools/apksigner.jar","verify","--verbose","--print-certs",OUT)
print("Installer prepared and signature verified; compatibility with original app still requires testing.")
