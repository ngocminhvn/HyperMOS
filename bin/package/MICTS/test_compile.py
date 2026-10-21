#!/usr/bin/env python3
"""Compile the *generated hook* into DEX (not just textual mock tests).

Uses tiny synthetic classes for both callsites; a real EU services.jar still
needs a separate compatibility/build test.
"""
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import zipfile

HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
SMALI=REPO/"bin/apktool/smaliv2.jar"
AUDIT=HERE/"dex_audit.py"
PATCH=HERE/"patch.py"

VIMS="com/android/server/voiceinteraction/VoiceInteractionManagerService$VoiceInteractionManagerServiceStub.smali"
CSMS="com/android/server/contextualsearch/ContextualSearchManagerService.smali"
STUBS={
 "classes.dex":{CSMS:""".class public Lcom/android/server/contextualsearch/ContextualSearchManagerService;
.super Ljava/lang/Object;
.method private enforcePermission(Ljava/lang/String;)V
    .locals 1
    return-void
.end method
"""},
 "classes3.dex":{VIMS:""".class public Lcom/android/server/voiceinteraction/VoiceInteractionManagerService$VoiceInteractionManagerServiceStub;
.super Ljava/lang/Object;
.method public showSessionFromSession(Landroid/os/IBinder;Landroid/os/Bundle;ILjava/lang/String;)Z
    .locals 1
    const/4 v0, 0x0
    return v0
.end method
"""},
}

def run(*args):
    print("+"," ".join(map(str,args)),flush=True)
    subprocess.run(list(map(str,args)),check=True)

def assemble(root,output):
    with zipfile.ZipFile(output,"w") as archive:
        for dex in STUBS:
            src=root/(dex+".out")
            dst=root/("out-"+dex)
            run("java","-jar",SMALI,"a","--api","36",src,"-o",dst)
            archive.write(dst,dex,compress_type=zipfile.ZIP_STORED)

def main():
    if not SMALI.is_file():raise SystemExit("Missing tracked smaliv2.jar")
    with tempfile.TemporaryDirectory(prefix="micts-smali-") as temp:
        root=Path(temp)/"smali"
        for dex,paths in STUBS.items():
            for rel,src in paths.items():
                p=root/(dex+".out")/rel
                p.parent.mkdir(parents=True,exist_ok=True)
                p.write_text(src)
        initial=Path(temp)/"initial.jar"
        assemble(root,initial)
        run(sys.executable,AUDIT,initial,"--mode","input")
        run(sys.executable,PATCH,"--root",root)
        final=Path(temp)/"patched.jar"
        assemble(root,final)
        run(sys.executable,AUDIT,final,"--mode","output")
        print("MICTS SMALI/DEX COMPILE TEST PASS: real assembler accepted generated bridge")

if __name__=="__main__":
    main()
