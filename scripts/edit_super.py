#!/usr/bin/env python3
"""Work only on EROFS partitions in an existing modded super.img. Fail closed on unsupported layouts."""
import hashlib
import json
import os
import re
from urllib.parse import unquote, urlsplit
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
            lines = log_file.read_text(errors="replace").splitlines()
            # Even on errors, omit per-file/percentage progress from console.
            diagnostics = [
                line for line in lines
                if line.strip() and not ("Extract:" in line and "%" in line)
            ]
            raise RuntimeError(
                f"{base}: extract.erofs failed with exit {exc.returncode}. "
                f"Full log: {log_file}\n" + "\n".join(diagnostics[-25:])
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

def apply_os3():
    compatibility()
    if not shutil.which("aapt"):raise RuntimeError("aapt required to verify app package IDs")
    run("bash","Mods/OS3/kashimod.sh")
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

def verify_haotian_input():
    """Check the labeled ROM and expected vendor partition without reading properties.

    A filename is not hardware attestation. Always verify the target manually
    before flashing; the kernel KMI is checked separately by the root patcher.
    """
    url = os.environ.get("INPUT_URL", "").strip()
    rom_name = Path(unquote(urlsplit(url).path)).name
    if not re.search(r"(?i)(?:^|[^a-z0-9])haotian(?:[^a-z0-9]|$)", rom_name):
        raise RuntimeError(
            f"Root mode requires a HAOTIAN-labeled ROM ZIP (got {rom_name!r}); "
            "no build.prop/device-property fallback is used"
        )
    manifest = json.loads((WS/"super_rw_manifest.json").read_text())
    vendor_parts = [
        p for p in manifest["partitions"]
        if partition_label(p) == "vendor" and p.get("original_partition_size", 0) > 0
    ]
    if len(vendor_parts) != 1 or vendor_parts[0].get("filesystem") != "erofs":
        raise RuntimeError("Expected one populated vendor EROFS image for HAOTIAN root mode")
    vendor_image = WS/vendor_parts[0]["image"]
    if not vendor_image.is_file():
        raise RuntimeError(f"Original vendor image missing: {vendor_image}")
    (REPORT/"root-device.txt").write_text(
        f"Input ROM filename: {rom_name}\n"
        f"Original vendor image: {vendor_parts[0]['image']}\n"
        "No build.prop or Android system-property inspection/overrides performed.\n"
        "Note: ROM filename and layout are not cryptographic device identity proof.\n"
    )
    print("[ROOT] HAOTIAN-labeled ROM and vendor image present; no property handling", flush=True)

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
    verify_haotian_input()
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

def reconcile_erofs_metadata(base, fs_path, contexts_path):
    """Rebase extract.erofs' image-relative metadata and cover added mod files.

    extract.erofs emits /app/... while mkfs.erofs --mount-point product looks
    for product/app/.... Keep source ownership, capabilities and SELinux labels;
    add only missing paths after mods are installed, never rewrite build.prop.
    """
    import stat

    tree = TREES / base
    if not tree.is_dir():
        raise RuntimeError(f"{base}: extracted filesystem tree is missing")
    original_fs = fs_path.read_text(errors="replace").splitlines()
    original_ctx = contexts_path.read_text(errors="replace").splitlines()
    if not original_fs or not original_ctx:
        raise RuntimeError(f"{base}: empty original fs_config or file_contexts")

    def canonical(raw):
        raw = raw.lstrip("/")
        if raw in ("", "."):
            return base
        # Some extractors emit a partition-prefixed path (or the A/B image
        # stem) instead of a filesystem-root-relative path.
        for prefix in (base + "_a", base + "_b", base):
            if raw == prefix:
                return base
            if raw.startswith(prefix + "/"):
                tail = raw[len(prefix) + 1:]
                if prefix != base or not (tree / raw).exists():
                    return base + "/" + tail
        return base + "/" + raw

    fs_map = {}
    fs_lines = []
    for line in original_fs:
        fields = line.split(maxsplit=1)
        if not fields:
            continue
        if len(fields) < 2:
            raise RuntimeError(f"{base}: malformed fs_config line: {line!r}")
        key = canonical(fields[0])
        # mkfs.erofs --mount-point still looks up its root inode using an
        # empty path, i.e. a literal "/" entry in canned fs_config.
        # Non-root inodes use the partition-prefixed paths as before.
        if key == base:
            key = "/"
        value = fields[1]
        if key in fs_map:
            if fs_map[key] != value:
                raise RuntimeError(f"{base}: conflicting ownership for {key}")
            continue
        fs_map[key] = value
        fs_lines.append(f"{key} {value}")

    if "/" not in fs_map:
        raise RuntimeError(f"{base}: source fs_config missing root inode metadata")

    # extract.erofs emits an exact per-inode regex with escaped special
    # characters; preserve the original SELinux label for every source inode.
    ctx_map = {}
    ctx_lines = []
    for line in original_ctx:
        fields = line.split(maxsplit=1)
        if not fields:
            continue
        if len(fields) < 2:
            raise RuntimeError(f"{base}: malformed SELinux context: {line!r}")
        token = fields[0]
        anchored = token.startswith("^")
        if anchored:
            token = token[1:]
        if not token.startswith("/"):
            raise RuntimeError(f"{base}: non-absolute SELinux path: {token}")
        key = canonical(token)
        token = ("^" if anchored else "") + "/" + key
        if token in ctx_map and ctx_map[token] != fields[1]:
            raise RuntimeError(f"{base}: conflicting SELinux context for {token}")
        if token not in ctx_map:
            ctx_lines.append(f"{token} {fields[1]}")
        ctx_map[token] = fields[1]

    # The extracted metadata contains original entries. Only paths created
    # by selected mods/root staging require new ownership and SELinux entries.
    # Preserve existing entries (including capability strings) byte-for-byte.
    normalized_context = {}
    for regex_path, label in ctx_map.items():
        plain = regex_path.removeprefix("^").replace(r"\.", ".")
        if not any(ch in plain for ch in ("*", "[", "]", "(", ")", "+", "?", "|", "$")):
            normalized_context[plain] = label

    missing = []
    for item in sorted(tree.rglob("*")):
        rel = item.relative_to(tree).as_posix()
        key = base + "/" + rel
        if key in fs_map:
            continue
        mode = stat.S_IMODE(item.lstat().st_mode)
        if item.is_dir() and not item.is_symlink():
            mode = mode or 0o755
        elif item.is_symlink():
            mode = 0o777
        elif not mode:
            mode = 0o644
        parent = key.rpartition("/")[0]
        if parent not in fs_map:
            raise RuntimeError(f"{base}: untracked parent directory for {key}")
        # Newly copied APK/.so/overlays normally inherit root ownership;
        # retain an existing owner's UID/GID when the parent specifies it.
        owner = fs_map[parent].split()
        if len(owner) < 3:
            raise RuntimeError(f"{base}: invalid parent fs_config for {key}")
        uid, gid = owner[:2]
        fs_lines.append(f"{key} {uid} {gid} {mode:04o}")
        fs_map[key] = f"{uid} {gid} {mode:04o}"

        selkey = "/" + key
        escaped = re.escape(selkey)
        if not any(path.removeprefix("^") == escaped for path in ctx_map):
            context = next(
                (normalized_context["/" + ancestor]
                 for ancestor in [parent] + [
                     parent.rsplit("/", n)[0] for n in range(1, parent.count("/") + 1)
                 ]
                 if "/" + ancestor in normalized_context and ancestor != base),
                None,
            )
            if context is None:
                raise RuntimeError(
                    f"{base}: missing inherited SELinux label for new {key}; "
                    "refuse to guess a security context"
                )
            ctx_lines.append(f"{escaped} {context}")
            ctx_map[escaped] = context
            normalized_context[selkey] = context
        missing.append(key)

    if len(missing) > 500:
        raise RuntimeError(
            f"{base}: {len(missing)} paths lack source fs_config (possible bad "
            "metadata root); refusing mass re-labeling"
        )
    fs_path.write_text("\n".join(fs_lines) + "\n")
    contexts_path.write_text("\n".join(ctx_lines) + "\n")
    (REPORT / f"metadata-{base}.txt").write_text(
        f"Original fs_config entries: {len(original_fs)}\n"
        f"Rebased entries: {len(fs_lines)}\n"
        f"New mod paths: {len(missing)}\n" + "\n".join(missing) + "\n"
    )
    print(f"[EROFS] {base}: rebased source metadata; "
          f"added {len(missing)} mod path entries", flush=True)


def repack():
    modified=sorted(CHANGED)
    orig=json.loads((W/"metadata.json").read_text())
    for base in modified:
        image=WS/orig[base]["image"]
        conf=CFG/base
        fs=list(conf.rglob("*_fs_config"))
        sel=list(conf.rglob("*_file_contexts"))
        if len(fs)!=1 or len(sel)!=1:raise RuntimeError(f"{base}: missing original EROFS metadata")
        reconcile_erofs_metadata(base, fs[0], sel[0])
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
    repack()

if __name__=="__main__":
    main()
