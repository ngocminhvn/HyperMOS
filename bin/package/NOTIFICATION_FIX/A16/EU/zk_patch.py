#!/usr/bin/env python3
"""ZK304 method-scoped EU309 policy port: no compressed donors, no daemon.

Donor-confirmed changes: cached getImportantApps, NotificationManager initializer,
and KillProcessController.setUidState. Not full ZKOS parity.
"""
import argparse
import json
import re
import shutil
import subprocess
import tempfile
import zipfile
from pathlib import Path

METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")


def method_edit(src, signature, editor):
    found = [m for m in METHOD.finditer(src)
             if m.group().splitlines()[0].strip().split()[-1] == signature]
    if len(found) != 1:
        raise ValueError(f"{signature}: expected 1 method, found {len(found)}")
    match = found[0]
    result = editor(match.group())
    if result == match.group():
        raise ValueError(f"{signature}: method unchanged; refusing false success")
    return src[:match.start()] + result + src[match.end():]


def cached_important_apps(body):
    field = "Lcom/miui/server/greeze/InternationalPolicyManager;->tmpImportantApps:Ljava/util/List;"
    reg = re.search(r"(?m)^[ \t]*\.registers[ \t]+7[ \t]*$", body)
    if not reg or ":zk304_cache_miss" in body:
        raise ValueError("getImportantApps(): incompatible register layout or already patched")
    if field not in body or not re.search(
        r"(?m)^[ \t]*new-instance v0, Ljava/util/ArrayList;[ \t]*$", body
    ):
        raise ValueError("getImportantApps(): original EU list logic not found")
    # Exact 11-code-unit ZK304 prefix, using existing EU field and registers.
    prefix = (
        f"\n    iget-object v0, p0, {field}\n"
        "    invoke-interface {v0}, Ljava/util/List;->size()I\n"
        "    move-result v0\n"
        "    if-lez v0, :zk304_cache_miss\n"
        f"    iget-object v0, p0, {field}\n"
        "    return-object v0\n"
        "    :zk304_cache_miss\n"
    )
    return body[:reg.end()] + prefix + body[reg.end():]


def notification_initializer(body):
    read = "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z"
    write = "Lcom/android/server/notification/NotificationManagerServiceImpl;->IS_INTERNATIONAL_BUILD:Z"
    lines = body.splitlines(keepends=True)
    hits = []
    for i in range(len(lines)-1):
        a = re.fullmatch(r"\s*sget-boolean\s+(v\d+),\s*" + re.escape(read) + r"\s*", lines[i])
        b = re.fullmatch(r"\s*sput-boolean\s+(v\d+),\s*" + re.escape(write) + r"\s*", lines[i+1])
        if a and b and a[1] == b[1]:
            hits.append(i)
    if len(hits) != 1:
        raise ValueError("NotificationManagerServiceImpl.<clinit>: expected one adjacent EU cached flag pair")
    i = hits[0]
    return "".join(lines[:i] + lines[i+2:])


def remove_eu_uid_kill(body):
    target = "Lmiui/process/ProcessManager;->kill(Lmiui/process/ProcessConfig;)Z"
    lines = body.splitlines(keepends=True)
    hits = [i for i, line in enumerate(lines) if re.fullmatch(
        r"\s*invoke-static(?:/range)?\s+\{[^}]*\},\s*" + re.escape(target) + r"\s*", line
    )]
    if len(hits) != 1:
        raise ValueError("KillProcessController.setUidState: expected exactly one ProcessManager.kill")
    pos = hits[0]
    # The original EU309 result is unused; moving a result from a removed invoke
    # would be invalid DEX, so abort if a different build introduces that pattern.
    for line in lines[pos+1:]:
        x = line.strip()
        if not x or x.startswith((".", ":", "#")):
            continue
        if x.startswith("move-result"):
            raise ValueError("KillProcessController: kill result is now consumed")
        break
    return "".join(lines[:pos] + lines[pos+1:])


PATCHES = {
    "miui-services.jar": (
        ("com/miui/server/greeze/InternationalPolicyManager.smali",
         "getImportantApps()Ljava/util/List;", cached_important_apps),
        ("com/android/server/notification/NotificationManagerServiceImpl.smali",
         "<clinit>()V", notification_initializer),
    ),
    "PowerKeeper.apk": (
        ("com/miui/powerkeeper/controller/KillProcessController.smali",
         "setUidState(IZ)V", remove_eu_uid_kill),
    ),
}


def command(*args):
    subprocess.run(list(map(str, args)), check=True, stdout=subprocess.DEVNULL)


def check_compiled(root, rel, signature):
    hits = list(root.rglob(rel))
    if len(hits) != 1:
        raise ValueError(f"Recompiled class {rel} missing or duplicated")
    methods = [m.group() for m in METHOD.finditer(hits[0].read_text(encoding="utf-8"))
               if m.group().splitlines()[0].strip().split()[-1] == signature]
    if len(methods) != 1:
        raise ValueError("Recompiled method not found: " + signature)
    body = methods[0]
    if signature.startswith("getImportantApps") and not all(x in body for x in ("->tmpImportantApps:Ljava/util/List;", "Ljava/util/List;->size()I", "if-lez", "return-object")):
        raise ValueError("Cached important-apps guard lost after compile")
    if signature.startswith("setUidState") and "Lmiui/process/ProcessManager;->kill(" in body:
        raise ValueError("EU UID kill still exists after compile")
    if signature == "<clinit>()V" and "NotificationManagerServiceImpl;->IS_INTERNATIONAL_BUILD:Z" in body:
        raise ValueError("EU NotificationManager cached flag still exists")
    return True


def build_one(source, out, temp, tools):
    name = source.name
    original_members = {}
    with zipfile.ZipFile(source) as archive:
        infos = archive.infolist()
        if len({x.filename for x in infos}) != len(infos):
            raise ValueError("Duplicate ZIP member in "+name)
        original_members = {x.filename: archive.read(x.filename) for x in infos}
        dex_names = [x.filename for x in infos if re.fullmatch(r"classes\d*\.dex", x.filename)]
        if not dex_names:
            raise ValueError("Missing DEX in "+name)
        comments = archive.comment
    decoded = temp/"decoded"
    for dex in dex_names:
        dexfile = temp/dex
        dexfile.write_bytes(original_members[dex])
        command("java","-jar",tools/"baksmaliv2.jar","d","--api",36,
                dexfile,"-o",decoded/Path(dex).stem)
    records = []
    targets = {}
    for rel,signature,fn in PATCHES[name]:
        hits = list(decoded.glob("*/"+rel))
        if len(hits) != 1:
            raise ValueError(f"{rel}: expected 1 EU class, found {len(hits)}")
        file = hits[0]
        file.write_text(method_edit(file.read_text(encoding="utf-8"), signature, fn), encoding="utf-8")
        targets[rel] = signature
        records.append(rel+":"+signature)
    built = {}
    verified = temp/"verified"
    for dex in dex_names:
        stem=Path(dex).stem
        rebuilt=temp/("compiled-"+dex)
        command("java","-jar",tools/"smaliv2.jar","a","--api",36,
                decoded/stem,"-o",rebuilt)
        command("java","-jar",tools/"baksmaliv2.jar","d","--api",36,
                rebuilt,"-o",verified/stem)
        built[dex]=rebuilt.read_bytes()
    for rel,sig in targets.items():
        check_compiled(verified,rel,sig)
    with zipfile.ZipFile(out,"w") as archive:
        archive.comment = comments
        for info in infos:
            archive.writestr(info,built.get(info.filename,original_members[info.filename]))
    with zipfile.ZipFile(out) as archive:
        if archive.namelist() != [x.filename for x in infos]:
            raise ValueError("APK/JAR member list changed")
        for name,data in original_members.items():
            if name not in dex_names and archive.read(name) != data:
                raise ValueError("Non-DEX member changed: "+name)
    return records,original_members,dex_names


def self_test():
    field="Lcom/miui/server/greeze/InternationalPolicyManager;->tmpImportantApps:Ljava/util/List;"
    a=(".method public getImportantApps()Ljava/util/List;\n .registers 7\n"
       " new-instance v0, Ljava/util/ArrayList;\n"
       f" iget-object v1, p0, {field}\n return-object v0\n.end method\n")
    b=(".method static constructor <clinit>()V\n .registers 2\n"
       " sget-boolean v0, Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z\n"
       " sput-boolean v0, Lcom/android/server/notification/NotificationManagerServiceImpl;->IS_INTERNATIONAL_BUILD:Z\n"
       " return-void\n.end method\n")
    c=(".method public setUidState(IZ)V\n .registers 9\n"
       " invoke-static {v0}, Lmiui/process/ProcessManager;->kill(Lmiui/process/ProcessConfig;)Z\n"
       " const/4 v0, 0x1\n return-void\n.end method\n")
    assert "if-lez v0, :zk304_cache_miss" in cached_important_apps(a)
    assert "sput-boolean" not in notification_initializer(b)
    assert "ProcessManager;->kill" not in remove_eu_uid_kill(c)
    for fn,original in ((cached_important_apps,a),(notification_initializer,b),(remove_eu_uid_kill,c)):
        try:
            fn(fn(original))
        except ValueError:
            continue
        raise AssertionError(fn.__name__+" allowed a second patch")
    print("[ZK304 EU] PASS: all 3 scoped transformations and fail-closed repeat guards")


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--images",type=Path)
    parser.add_argument("--tools",type=Path)
    parser.add_argument("--report",type=Path)
    args=parser.parse_args()
    if args.self_test:
        self_test()
        return
    if not args.images or not args.tools or not args.report:
        parser.error("--images, --tools and --report are required")
    if any(not (args.tools/x).is_file() for x in ("baksmaliv2.jar","smaliv2.jar")):
        raise ValueError("HyperMOS baksmali/smali tools missing")
    images=args.images.resolve()
    jars=list(images.rglob("miui-services.jar"))
    apks=list(images.rglob("PowerKeeper.apk"))
    if len(jars)!=1 or len(apks)!=1:
        raise ValueError(f"Expected one miui-services.jar and PowerKeeper.apk; found {len(jars)} and {len(apks)}")
    originals=(jars[0],apks[0])
    with tempfile.TemporaryDirectory(prefix="hypermos-zk304-") as d:
        root=Path(d)
        finished=[]
        for i,original in enumerate(originals):
            temp=root/str(i)
            temp.mkdir()
            out=temp/original.name
            records,members,dex_names=build_one(original,out,temp,args.tools)
            if original.name=="PowerKeeper.apk":
                aligned=temp/"aligned.apk"
                command("zipalign","-p","-f",4,out,aligned)
                command("zipalign","-c","-p",4,aligned)
                out=aligned
                with zipfile.ZipFile(out) as archive:
                    if archive.namelist()!=list(members) or any(
                        archive.read(name)!=data for name,data in members.items() if name not in dex_names
                    ):
                        raise ValueError("PowerKeeper non-DEX metadata changed during zipalign")
            finished.append((original,out,records))
        for original,out,_ in finished:
            shutil.copyfile(out,original)
            if original.name=="PowerKeeper.apk":
                shutil.rmtree(original.parent/"oat",ignore_errors=True)
        result={
            "donor":"ZK304 original DEX, selected method semantics (audited EU309)",
            "methods":[m for _,_,methods in finished for m in methods],
            "original_apk_non_dex_contents":"preserved byte-for-byte",
            "resigned":False,
            "apk_cryptographic_signature_valid":False,
            "gms_doze_thermal":"EU original, unchanged",
            "complete_zk_parity":False,
            "boot_tested":False,
        }
        args.report.parent.mkdir(parents=True,exist_ok=True)
        args.report.write_text(json.dumps(result,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")
        print("[ZK304 EU] Rebuilt 3 method-scoped changes; PowerKeeper non-DEX content preserved")


if __name__ == "__main__":
    try:
        main()
    except (OSError,ValueError,subprocess.CalledProcessError,zipfile.BadZipFile) as error:
        raise SystemExit("[ZK304 EU] FAIL: "+str(error))
