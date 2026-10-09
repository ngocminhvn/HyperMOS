#!/usr/bin/env python3
"""Disassemble every DEX entry of 3 framework JARs into temporary smali trees.
The raw files are local CI scratch data ONLY, never CI report artifacts.
"""
import argparse
import shutil
import subprocess
import tempfile
import zipfile
from pathlib import Path

JARS=("framework.jar","services.jar","miui-services.jar")

def main():
    p=argparse.ArgumentParser()
    p.add_argument("--input",required=True,type=Path)
    p.add_argument("--out",required=True,type=Path)
    p.add_argument("--baksmali",default="bin/apktool/baksmaliv2.jar",type=Path)
    args=p.parse_args()
    if not args.baksmali.exists():raise SystemExit("baksmali jar missing")
    for jar in JARS:
        source=args.input/jar
        if not source.exists():raise SystemExit("Missing "+str(source))
        with zipfile.ZipFile(source) as z:
            dex_files=[name for name in z.namelist() if name.startswith("classes") and name.endswith(".dex")]
            if not dex_files:raise SystemExit("No DEX found: "+str(source))
            for dex in dex_files:
                with tempfile.TemporaryDirectory() as tmp:
                    dexpath=Path(tmp)/Path(dex).name
                    with z.open(dex) as inp, dexpath.open("wb") as out:
                        shutil.copyfileobj(inp,out)
                    dest=args.out/jar/Path(dex).name
                    dest.mkdir(parents=True,exist_ok=True)
                    cmd=["java","-Xmx3g","-jar",str(args.baksmali),"disassemble",str(dexpath),"-o",str(dest)]
                    print("Decode",jar,dex,flush=True)
                    subprocess.run(cmd,check=True)
    print("Completed full 3-JAR smali decoding")
if __name__=="__main__":main()
