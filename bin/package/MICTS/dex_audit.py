#!/usr/bin/env python3
"""No-dependencies MiCTS services.jar DEX preflight/post-build audit.

Parses class_def/method_def signatures rather than trusting loose byte-string
matches. Does not claim to verify runtime behaviour or Android boot.
"""
import argparse
import struct
import sys
import zipfile
from pathlib import Path

VIMS="Lcom/android/server/voiceinteraction/VoiceInteractionManagerService$VoiceInteractionManagerServiceStub;"
CSMS="Lcom/android/server/contextualsearch/ContextualSearchManagerService;"
BRIDGE="Lcom/android/server/micts/MiCTSBridge;"
TARGETS={
    (VIMS,"showSessionFromSession",("(Landroid/os/IBinder;Landroid/os/Bundle;ILjava/lang/String;)","Z")),
    (CSMS,"enforcePermission",("(Ljava/lang/String;)","V")),
}
# (params, return) serialized as descriptors in scan() below.

def u4(b,p):return struct.unpack_from("<I",b,p)[0]
def u2(b,p):return struct.unpack_from("<H",b,p)[0]
def leb(b,p):
    val=0
    for n in range(5):
        x=b[p];p+=1;val|=(x&127)<<(7*n)
        if not x&128:return val,p
    raise ValueError("invalid LEB128")

def scan(b):
    if not b.startswith(b"dex\n") or len(b)<112:raise ValueError("not DEX")
    strings=[]
    soff=u4(b,0x3c)
    for n in range(u4(b,0x38)):
        p=u4(b,soff+4*n)
        _,p=leb(b,p)
        end=b.index(b"\0",p)
        strings.append(b[p:end].decode("utf-8","replace"))
    types=[strings[u4(b,u4(b,0x44)+4*i)] for i in range(u4(b,0x40))]
    protos=[]
    for i in range(u4(b,0x48)):
        p=u4(b,0x4c)+12*i
        _,ret,prms=struct.unpack_from("<III",b,p)
        params=() if not prms else tuple(types[u2(b,prms+4+2*j)] for j in range(u4(b,prms)))
        protos.append(("("+"".join(params)+")",types[ret]))
    meth=[]
    for i in range(u4(b,0x58)):
        p=u4(b,0x5c)+8*i
        cl,proto,name=struct.unpack_from("<HHI",b,p)
        meth.append((types[cl],strings[name],protos[proto]))
    defs=set()
    for i in range(u4(b,0x60)):
        p=u4(b,0x64)+32*i
        cl,_,_,_,_,_,data,_=struct.unpack_from("<IIIIIIII",b,p)
        if not data:continue
        owner=types[cl]
        if owner not in {VIMS,CSMS,BRIDGE}:continue
        n_static,data=leb(b,data);n_instance,data=leb(b,data)
        n_direct,data=leb(b,data);n_virtual,data=leb(b,data)
        for _ in range(n_static+n_instance):
            _,data=leb(b,data);_,data=leb(b,data)
        for n in (n_direct,n_virtual):
            idx=0
            for _ in range(n):
                delta,data=leb(b,data);_,data=leb(b,data);_,data=leb(b,data)
                idx+=delta
                if idx>=len(meth):raise ValueError("method index out of range")
                defs.add(meth[idx])
    return defs,u4(b,0x58),strings

def audit(path,mode):
    found=set()
    bridge_refs=0
    with zipfile.ZipFile(path) as z:
        names=[x for x in z.namelist() if x=="classes.dex" or x.startswith("classes") and x.endswith(".dex") and x[7:-4].isdigit()]
        if not names:raise ValueError("JAR contains no DEX")
        for name in names:
            defs,count,strings=scan(z.read(name))
            if count>65535:raise ValueError(f"{name} exceeds method-id limit: {count}")
            target=defs.intersection(TARGETS)
            if target:
                print(f"MICTS DEX {name}: {count}/65536 method IDs; methods: {len(target)}")
            elif count>65000:
                print(f"MICTS DEX {name}: {count}/65536 method IDs (near limit)")
            found.update(defs)
            if BRIDGE in strings:bridge_refs+=1
    missing=TARGETS-found
    if missing:raise ValueError("missing target method definitions: "+repr(sorted(missing)))
    if mode=="output":
        required={(BRIDGE,"start",("(Landroid/os/Bundle;)","Z")),
                  (BRIDGE,"isRequest",("(Landroid/os/Bundle;)","Z")),
                  (BRIDGE,"isActive",("()","Z"))}
        if not required.issubset(found):
            raise ValueError("rebuilt MiCTSBridge methods missing")
        if bridge_refs<2:
            raise ValueError("rebuilt DEX has too few MiCTSBridge references")
    print(f"MICTS DEX AUDIT PASS: {mode}; {len(names)} DEX; bridge refs in {bridge_refs} DEX")

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("jar",type=Path)
    parser.add_argument("--mode",choices=["input","output"],required=True)
    a=parser.parse_args()
    try:audit(a.jar,a.mode)
    except (ValueError,IndexError,struct.error,zipfile.BadZipFile,OSError) as exc:
        sys.exit("MICTS DEX AUDIT FAIL: "+str(exc))

if __name__=="__main__":main()
