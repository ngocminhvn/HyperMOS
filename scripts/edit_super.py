#!/usr/bin/env python3
"""Work only on EROFS partitions in an existing modded super.img. Fail closed on unsupported layouts."""
import hashlib
import json
import os
from pathlib import Path
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
BUILD_PROP_BASELINE={}

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
        extract_erofs_partition(base, img)
    (REPORT/"partitions.json").write_text(json.dumps([{k:v for k,v in p.items() if k!="original_sha256"} for p in manifest["partitions"]],indent=2))
    BUILD_PROP_BASELINE.update(snapshot_build_props())

def extract_erofs_partition(base, img):
    """Extract using extract.erofs' real output layout (outdir/<image-stem>, outdir/config).

    -c/--config is an INPUT selection file, not a metadata output directory.
    Never synthesize fs_config or SELinux file_contexts when the tool omits them.
    """
    stage=W/"extract-staging"/base
    if stage.exists():
        raise RuntimeError(f"{base}: stale EROFS staging directory: {stage}")
    stage.mkdir(parents=True)
    # The extractor renders thousands of incremental percentages. Keep its full
    # diagnostics in the report artifact, not the live Actions console.
    log_file = REPORT / f"extract-{base}.log"
    with log_file.open("wb") as output:
        try:
            run("extract.erofs", "-x", "-i", img, "-o", stage,
                stdout=output, stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as exc:
            tail = log_file.read_text(errors="replace").splitlines()[-40:]
            raise RuntimeError(
                f"{base}: extract.erofs failed with exit {exc.returncode}. "
                f"Full log: {log_file}\n" + "\n".join(tail)
            ) from exc
    extracted=[p for p in stage.iterdir() if p.is_dir() and p.name!="config"]
    config=stage/"config"
    if len(extracted)!=1 or not config.is_dir():
        raise RuntimeError(
            f"{base}: unexpected EROFS extractor layout; "
            f"trees={len(extracted)}, config_present={config.is_dir()}")
    fc=list(config.rglob("*_fs_config"))
    se=list(config.rglob("*_file_contexts"))
    if len(fc)!=1 or len(se)!=1 or not fc[0].stat().st_size or not se[0].stat().st_size:
        raise RuntimeError(f"{base}: missing exact fs_config or SELinux file_contexts from EROFS source")
    target=TREES/base
    dest_config=CFG/base
    if target.exists() or dest_config.exists():
        raise RuntimeError(f"{base}: refusing to overwrite previous extracted trees or metadata")
    extracted[0].rename(target)
    config.rename(dest_config)
    stage.rmdir()
    print(f"Extracted {base}: files={target}, metadata={dest_config}", flush=True)


def snapshot_build_props():
    """Read-only fingerprint of every build.prop in extracted partitions."""
    result={}
    for base in sorted(PARTITIONS):
        directory=TREES/base
        if not directory.is_dir():
            continue
        for f in directory.rglob("build.prop"):
            if f.is_file():
                rel=str(f.relative_to(TREES))
                result[rel]=sha256(f)
    return result

def assert_build_props_untouched():
    current=snapshot_build_props()
    if current != BUILD_PROP_BASELINE:
        before=set(BUILD_PROP_BASELINE)
        after=set(current)
        changed=sorted(key for key in before & after if BUILD_PROP_BASELINE[key]!=current[key])
        added=sorted(after-before)
        removed=sorted(before-after)
        raise RuntimeError(
            f"build.prop modification forbidden; changed={changed}, added={added}, removed={removed}")
    (REPORT/"build-prop-preservation.txt").write_text(
        f"Preserved {len(current)} build.prop files byte-for-byte. No properties were edited.\n")

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

def verify_haotian_base():
    """Require evidence for HAOTIAN from original modified ROM product/system property values."""
    keys = {"ro.product.device", "ro.product.vendor.device",
            "ro.product.product.device", "ro.product.system.device",
            "ro.build.product"}
    values = []
    for base in ("product", "system", "system_ext"):
        d = TREES/base
        if not d.is_dir():
            continue
        for propfile in d.rglob("build.prop"):
            for line in propfile.read_text(errors="replace").splitlines():
                if "=" not in line or line.lstrip().startswith("#"):
                    continue
                key, value = (x.strip() for x in line.split("=", 1))
                if key in keys and value:
                    values.append((key, value))
    if not any(value.lower() == "haotian" for _, value in values):
        raise RuntimeError("Cannot verify Xiaomi 15 Pro HAOTIAN from original build.prop; refusing init_boot root patch")
    mismatches = [(key,value) for key,value in values if value.lower() != "haotian"]
    if mismatches:
        raise RuntimeError(f"Conflicting device identities, do not root automatically: {mismatches}")
    (REPORT/"root-device.txt").write_text("Device: haotian\n" + "\n".join(f"{key}={value}" for key,value in values)+"\n")

def append_root_metadata():
    """Add metadata only for new KernelSU Next manager staging files."""
    base="system_ext"
    c=CFG/base
    fs=list(c.rglob("*_fs_config"))
    ctx=list(c.rglob("*_file_contexts"))
    if len(fs)!=1 or len(ctx)!=1:
        raise RuntimeError("Missing original filesystem/SELinux metadata for system_ext root-manager staging")
    additions=[
        ("etc/hypermos-root", 0, 0, "0755"),
        ("etc/hypermos-root/RootManager.apk", 0, 0, "0644"),
        ("etc/hypermos-root/manager-name.txt", 0, 0, "0644"),
        ("bin/hypermos-root-manager-stage", 0, 2000, "0755"),
        ("etc/init/hypermos-root-manager.rc", 0, 0, "0644"),
    ]
    fs_lines=fs[0].read_text(errors="replace").splitlines()
    ctx_lines=ctx[0].read_text(errors="replace").splitlines()
    fs_keys={line.split()[0] for line in fs_lines if line.split()}
    ctx_keys={line.split()[0] for line in ctx_lines if line.split()}
    for rel,uid,gid,mode in additions:
        target=TREES/base/rel
        if not target.exists():
            raise RuntimeError(f"Root manager staging component absent: {target}")
        fskey=f"{base}/{rel}"
        selkey=f"/{base}/{rel}"
        if fskey not in fs_keys:
            fs_lines.append(f"{fskey} {uid} {gid} {mode}")
        if selkey not in ctx_keys:
            ctx_lines.append(f"{selkey} u:object_r:system_file:s0")
    fs[0].write_text("\n".join(fs_lines)+"\n")
    ctx[0].write_text("\n".join(ctx_lines)+"\n")

def apply_root():
    mode=os.environ.get("ROOT_MODE","stock")
    if mode=="stock":
        (REPORT/"root.txt").write_text("ROOT_MODE=stock; input init_boot.img is unchanged.\n")
        return
    if mode!="root":
        raise RuntimeError("ROOT_MODE must be root or stock")
    info=json.loads((W/"input.json").read_text())
    if info.get("input_type")!="rom_zip" or "root_members" not in info:
        raise RuntimeError("Root requires a full ROM ZIP with paired boot.img and init_boot.img")
    if "system_ext" not in json.loads((W/"metadata.json").read_text()):
        raise RuntimeError("KernelSU Next manager staging needs a system_ext EROFS partition")
    verify_haotian_base()
    for name in ("boot.img", "init_boot.img"):
        source=W/"root-input"/name
        if not source.is_file() or source.stat().st_size<4096:
            raise RuntimeError(f"Paired input image missing: {name}")
        shutil.copy2(source,TREES/name)
    if (TREES/"system_ext/etc/hypermos-root").exists() or (TREES/"system_ext/etc/init/hypermos-root-manager.rc").exists():
        raise RuntimeError("Source ROM already has HyperMOS root manager staging; refusing to inject root twice")
    binroot=ROOT/"bin"
    (binroot/"Linux").mkdir(exist_ok=True)
    for name,dest in (
        (binroot/"root",ROOT/"Root"),
        (binroot/"Linux/x86_64",ROOT/"Linux"),
    ):
        if not name.exists():
            name.symlink_to(dest.resolve(),target_is_directory=True)
    (binroot/"ddevice").mkdir(exist_ok=True)
    (binroot/"ddevice/device_f.txt").write_text("haotian\n")
    run("bash","Root/patch_init_boot.sh")
    append_root_metadata()
    CHANGED.add("system_ext")
    backup=ROOT/"build/baserom/root-stock-init_boot.img"
    if not backup.is_file() or sha256(backup)!=info.get("original_init_boot_sha256"):
        raise RuntimeError("Root patch changed or lost the original init_boot.img backup")
    patched=TREES/"init_boot.img"
    if sha256(patched)==sha256(backup):
        raise RuntimeError("KernelSU Next patched init_boot is unchanged")
    (REPORT/"root.txt").write_text(
        "ROOT_MODE=root\nProvider: KernelSU Next LKM from HyperMOS main\n"
        f"Stock init_boot SHA256: {sha256(backup)}\n"
        f"Patched init_boot SHA256: {sha256(patched)}\n"
        "boot.img unchanged; original init_boot bundled for recovery.\n"
        "Static checks only. AVB/device bootability not confirmed.\n")

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
    apply_root()
    assert_build_props_untouched()
    repack()

if __name__=="__main__":
    main()
