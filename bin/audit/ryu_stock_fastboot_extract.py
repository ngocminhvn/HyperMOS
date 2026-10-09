#!/usr/bin/env python3
"""Extract stock PowerKeeper and 3 JARs from an official Xiaomi fastboot TGZ."""
import argparse
import hashlib
import json
import re
import tarfile
import time
import urllib.request
from pathlib import Path
from ryu_fetch_extract import process_image

def main():
    p=argparse.ArgumentParser()
    p.add_argument("--url",required=True)
    p.add_argument("--work",type=Path,default=Path("stock-work"))
    p.add_argument("--out",type=Path,default=Path("stock-extracted"))
    a=p.parse_args()
    a.work.mkdir(parents=True,exist_ok=True)
    a.out.mkdir(parents=True,exist_ok=True)
    target=a.work/"super.img"
    segments=[]
    amount=0
    stamp=time.monotonic()
    req=urllib.request.Request(a.url,headers={"User-Agent":"HyperMOS-Audit/2"})
    with urllib.request.urlopen(req,timeout=180) as stream:
        with tarfile.open(fileobj=stream,mode="r|gz") as tf:
            with target.open("wb") as out:
                for member in tf:
                    name=Path(member.name).name
                    if not member.isfile() or not re.fullmatch(r"super\.img(?:\.\d+)?",name):continue
                    match=re.search(r"\.(\d+)$",name)
                    number=int(match.group(1)) if match else 0
                    if segments and number!=segments[-1]+1:
                        raise RuntimeError("Unsorted super.img fragments: "+str(segments+[number]))
                    segments.append(number)
                    print("STOCK MEMBER",member.name,member.size,flush=True)
                    source=tf.extractfile(member)
                    if source is None:raise RuntimeError("Cannot read stock image member")
                    left=member.size
                    while left:
                        block=source.read(min(left,4*1024*1024))
                        if not block:raise RuntimeError("Truncated stock super.img")
                        out.write(block)
                        left-=len(block)
                        amount+=len(block)
                        if time.monotonic()-stamp>30:
                            print("STOCK READ PROGRESS",amount,"bytes",flush=True)
                            stamp=time.monotonic()
    if not segments:raise RuntimeError("No super.img in Xiaomi Fastboot TGZ")
    print("STOCK SUPER",amount,"segments",segments,flush=True)
    process_image(target,a.work,a.out)
    required=("framework.jar","services.jar","miui-services.jar","PowerKeeper.apk")
    missing=[n for n in required if not (a.out/n).is_file()]
    if missing:raise RuntimeError("Missing Xiaomi stock targets: "+str(missing))
    hashes={n:hashlib.sha256((a.out/n).read_bytes()).hexdigest() for n in required}
    (a.out/"stock-file-hashes.json").write_text(json.dumps(hashes,indent=2)+"\n")
    print("STOCK SHA256",hashes,flush=True)

if __name__=="__main__":
    main()
