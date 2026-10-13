#!/usr/bin/env python3
"""Work only on EROFS partitions in an existing modded super.img. Fail closed on unsupported layouts."""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT=Path.cwd()
W=ROOT/"work"
WS=W/"super-work"
TREES=W/"trees"
CFG=W/"config"
REPORT=W/"reports"
REPORT.mkdir(parents=True,exist_ok=True)
os.environ["PATH"]=str(ROOT/"Linux")+os.pathsep+os.environ.get("PATH","")
PARTITIONS={"product","system","system_ext"}
CHANGED=set()

def run(*args, **kw):
    print("+", " ".join(str(x) for x in args), flush=True)
    return subprocess.run([str(x) for x in args],check=True,**kw)

def sha256(path):
    h=hashlib.sha256()
    with open(path,"rb") as f:
        for chunk in iter(lambda:f.read(4*1024*1024),b""):h.update(chunk)
    return h.hexdigest()

def partition_label(item):
    name=item["name"]
    for suffix in ("_a","_b"):
        if name.endswith(suffix):return name[:-2]
    return name

def unpack():
    # Pin super_rw implementation to repository's vendored audited copy.
    run(sys.executable,"scripts/super_rw.py","unpack",W/"original/super.img",WS,"--no-expand")
    manifest=json.loads((WS/"super_rw_manifest.json").read_text())
    if manifest.get("slot_layouts_differ") or manifest.get("slot_metadata_incomplete"):
        raise RuntimeError("A/B source slot metadata are inconsistent; refuse automatic repack")
    found={}
    for p in manifest["partitions"]:
        base=partition_label(p)
        if base in PARTITIONS:
            # A/B layouts may include an empty placeholder for the inactive slot.
            if not p["original_partition_size"]:
                continue
            if base in found:
                raise RuntimeError(f"Multiple populated logical partitions matching {base}; manual review needed")
            if p["filesystem"]!="erofs":
                raise RuntimeError(f"{base}: {p['filesystem']} is not yet supported by safe EROFS editor")
            found[base]=p
    if "product" not in found:
        raise RuntimeError("product EROFS partition missing; expected HAOTIAN OS3 image")
    (W/"metadata.json").write_text(json.dumps(found,indent=2))
    TREES.mkdir(exist_ok=True)
    CFG.mkdir(exist_ok=True)
    for base,p in found.items():
        img=WS/p["image"]
        target=TREES/base
        target.mkdir(exist_ok=True)
        c=CFG/base
        c.mkdir(exist_ok=True)
        # Extract filesystem metadata and data; never reconstruct contexts from generic defaults.
        run("extract.erofs","-x","-i",img,"-o",target,"-c",c)
        fc=list(c.rglob("*_fs_config"))
        se=list(c.rglob("*_file_contexts"))
        if len(fc)!=1 or len(se)!=1 or not fc[0].stat().st_size or not se[0].stat().st_size:
            raise RuntimeError(f"{base}: missing exact fs_config or SELinux file_contexts from EROFS source")
    (REPORT/"partitions.json").write_text(json.dumps([{k:v for k,v in p.items() if k!="original_sha256"} for p in manifest["partitions"]],indent=2))

def bootanimation():
    source=ROOT/"Mods/Boot/bootanimation.zip"
    if not source.is_file():raise RuntimeError("Mods/Boot/bootanimation.zip missing")
    import zipfile
    with zipfile.ZipFile(source) as z:
        if "desc.txt" not in z.namelist(): raise RuntimeError("bootanimation.zip lacks desc.txt")
        if z.testzip():raise RuntimeError("Corrupted bootanimation.zip")
    dests=[]
    for base in ("product","system","system_ext"):
        d=TREES/base
        for item in (d/"media/bootanimation.zip",d/"system/media/bootanimation.zip"):
            if item.exists():dests.append((base,item))
    if not dests:
        raise RuntimeError("Existing bootanimation.zip not found; no guesswork on path")
    # Match active path priority, warn for shadowed copies.
    base,target=next((v for v in dests if v[0]=="product"),dests[0])
    shutil.copyfile(source,target)
    CHANGED.add(base)
    (REPORT/"bootanimation.txt").write_text(f"Replaced: {target.relative_to(TREES)}\nSHA256: {sha256(source)}\nOther bootanimation candidates: {len(dests)-1}\n")

def compatibility():
    (ROOT/"bin/modfile").mkdir(parents=True,exist_ok=True)
    os3=ROOT/"bin/modfile/OS3"
    if not os3.exists():os3.symlink_to((ROOT/"Mods/OS3").resolve(),target_is_directory=True)
    ddev=ROOT/"bin/ddevice"
    ddev.mkdir(exist_ok=True)
    (ddev/"rom_os.txt").write_text("OS3\n")
    out=ROOT/"build/baserom/images"
    out.parent.mkdir(parents=True,exist_ok=True)
    if not out.exists():out.symlink_to(TREES.resolve(),target_is_directory=True)
    stub=ROOT/"functions.sh"
    if not stub.exists():
        stub.write_text("""#!/bin/bash
mods() { printf '[MOD] %s\\n' "$*"; }
info() { printf '[INFO] %s\\n' "$*"; }
warn() { printf '[WARN] %s\\n' "$*" >&2; }
error() { printf '[ERROR] %s\\n' "$*" >&2; }
""")
    # LFS pointers are not APKs; avoid partial replacement of system apps.
    for p in (ROOT/"Mods/OS3/system").glob("*.apk"):
        with p.open("rb") as apk:
            is_lfs_pointer = apk.read(80).startswith(b"version https://git-lfs.github.com/spec/v1")
        if is_lfs_pointer:
            raise RuntimeError(f"Git LFS object missing: {p.name}; use checkout lfs:true and git lfs pull")

def apply_os3():
    compatibility()
    if not shutil.which("aapt"):raise RuntimeError("aapt required to verify app package IDs")
    run("bash","Mods/OS3/kashimod.sh")
    run("bash","Mods/OS3/system/update.sh")
    # Module applies cross-partition overlay/privapp changes; repack only eligible EROFS partitions.
    CHANGED.update({"product","system","system_ext"}.intersection(x.name for x in TREES.iterdir() if x.is_dir()))

def replace_installer():
    run(sys.executable,"scripts/prepare_installer.py")
    apk=W/"installer/MIUIPackageInstaller.apk"
    selected=[]
    for base in ("product","system_ext","system"):
        d=TREES/base
        if not d.exists():continue
        for f in d.rglob("*.apk"):
            if f.name.lower().find("packageinstaller")<0:continue
            try:
                t=subprocess.check_output(["aapt","dump","badging",str(f)],text=True,stderr=subprocess.DEVNULL)
            except subprocess.CalledProcessError:continue
            if "package: name='com.miui.packageinstaller'" in t: selected.append((base,f))
    if len(selected)!=1:
        raise RuntimeError(f"Installer com.miui.packageinstaller not uniquely found ({len(selected)} matches)")
    base,dest=selected[0]
    old=dest.parent
    prev=old/"lib"
    if prev.exists():shutil.rmtree(prev)
    # Don't retain stale oat/vdex files compiled for another application.
    for sub in ("oat","arm","arm64"):
        folder=old/sub
        if folder.exists() and folder.is_dir():shutil.rmtree(folder)
    shutil.copy2(apk,dest)
    whitelist=ROOT/"Mods/Packageinstaller/privapp_whitelist_kashi.pkginstaller.xml"
    if not whitelist.exists():raise RuntimeError("Installer privilege whitelist absent")
    perms=TREES/base/"etc/permissions"
    if base=="system" and (TREES/base/"system/etc/permissions").is_dir():
        perms=TREES/base/"system/etc/permissions"
    perms.mkdir(parents=True,exist_ok=True)
    shutil.copy2(whitelist,perms/whitelist.name)
    CHANGED.add(base)
    (REPORT/"installer.txt").write_text(f"Replaced package com.miui.packageinstaller: {dest.relative_to(TREES)}\nNew SHA256: {sha256(apk)}\nCaution: AOSP test-key signing differs from stock; app data/privileges may be incompatible.\n")

def audit_properties():
    found=[]
    for base in ("system","product","system_ext"):
        d=TREES/base
        if not d.exists():continue
        for f in d.rglob("build.prop"):
            for i,line in enumerate(f.read_text(errors="replace").splitlines(),1):
                if re.search(r"ryu|zkos|kaorios|(?:^|[^a-z])zk(?:[^a-z]|$)",line,re.I):
                    key=line.split("=",1)[0].strip()
                    found.append(f"{f.relative_to(TREES)}:{i}: {key}")
    (REPORT/"build-prop-audit.txt").write_text(
      "# Audit only: deleting vendor/module properties automatically can break existing mods.\n"+
      "\n".join(found)+"\n")
    print("Potential old ROM props:",len(found))

def repack():
    modified=sorted(CHANGED)
    orig=json.loads((W/"metadata.json").read_text())
    for base in modified:
        image=WS/orig[base]["image"]
        conf=CFG/base
        fs=list(conf.rglob("*_fs_config"))
        sel=list(conf.rglob("*_file_contexts"))
        if len(fs)!=1 or len(sel)!=1:raise RuntimeError(f"{base}: missing original EROFS metadata")
        replacement=W/"repacked"/f"{base}.img"
        replacement.parent.mkdir(exist_ok=True)
        run("mkfs.erofs","-zlz4hc,9","--mount-point",base,
            f"--fs-config-file={fs[0]}",f"--file-contexts={sel[0]}",
            replacement,TREES/base)
        if replacement.stat().st_size>orig[base]["original_partition_size"]:
            raise RuntimeError(f"{base} rebuilt EROFS exceeds logical partition size")
        shutil.copyfile(replacement,image)
    run(sys.executable,"scripts/super_rw.py","repack",WS,W/"output/super.img","--verify-payloads")
    (REPORT/"repacked-partitions.txt").write_text("\n".join(modified)+"\n")

def main():
    (W/"output").mkdir(parents=True,exist_ok=True)
    unpack()
    bootanimation()
    apply_os3()
    replace_installer()
    audit_properties()
    repack()

if __name__=="__main__":
    main()
