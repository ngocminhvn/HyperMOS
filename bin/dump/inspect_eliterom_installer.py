#!/usr/bin/env python3
"""Read-only static analysis of EliteRom installer scripts and binaries."""
import argparse
import io
import json
import re
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path
from urllib.parse import urlsplit

import requests
from sourceforge_download import normalize, download_router_url, direct_mirror_url

DEFAULT_URL = ("https://downloads.sourceforge.net/project/eliteroms/"
    "HyperOS-STABLE-UPDATES/HyperOS-v3.0/"
    "EliteRomLite_v4.05_HAOTIAN_OS3.0.307.0_ChinaStable-A16.zip")
MEMBERS = (
    "linux_mac_fastboot_install_or_update.sh",
    "windows_fastboot_install_or_update.exe",
    "META-INF/com/google/android/update-binary",
    "META-INF/com/google/android/updater-script",
)
KEYWORDS = re.compile(
    r"custom\.img|openssl|aes[-_ ]|decrypt|encrypt|cipher|salted__|"
    r"fastboot|simg2img|lpunpack|\bdd\b|cryptsetup|base64|\bkey\b|"
    r"password|passphrase|payload|exec|source |flash ", re.I)
SECRET = re.compile(
    r"(?i)(\b(?:password|passwd|passphrase|secret|token|key)\b\s*[=:]\s*)([^\s;]+)")
PASS_ARG = re.compile(r"(?i)(-pass\s+(?:pass:)?)([^\s;]+)")


class RangeUnsupported(RuntimeError):
    pass


class RangeFile(io.RawIOBase):
    def __init__(self, session, url, chunk=1024*1024):
        self.session, self.url, self.chunk = session, url, chunk
        self.pos, self.cached_at, self.cached = 0, -1, b""
        with session.get(url, headers={"Range":"bytes=0-0", "Accept-Encoding":"identity"},
                         stream=True, timeout=(9,18)) as reply:
            if reply.status_code != 206:
                raise RangeUnsupported("Initial HTTP " + str(reply.status_code))
            match = re.fullmatch(r"bytes 0-0/(\d+)",
                                 reply.headers.get("Content-Range", ""))
            if not match:
                raise RangeUnsupported("No Content-Range total")
            self.size, self.url = int(match.group(1)), reply.url
        if not 1024 <= self.size <= 20*1024**3:
            raise RangeUnsupported("Unexpected ZIP size")

    def readable(self): return True
    def seekable(self): return True
    def tell(self): return self.pos

    def seek(self, offset, whence=0):
        if whence == 1: offset += self.pos
        elif whence == 2: offset += self.size
        elif whence != 0: raise ValueError("Invalid seek mode")
        if offset < 0: raise ValueError("Negative seek")
        self.pos = offset
        return offset

    def read(self, count=-1):
        if count is None or count < 0: count = self.size - self.pos
        count = min(count, max(0,self.size-self.pos))
        result = []
        while count:
            start = self.pos//self.chunk*self.chunk
            if self.cached_at != start:
                end = min(start+self.chunk,self.size)-1
                with self.session.get(
                    self.url, headers={"Range":f"bytes={start}-{end}",
                                       "Accept-Encoding":"identity"},
                    stream=True, timeout=(12,70)
                ) as reply:
                    if reply.status_code != 206:
                        raise RangeUnsupported("Range HTTP " + str(reply.status_code))
                    expected=f"bytes {start}-{end}/{self.size}"
                    if reply.headers.get("Content-Range") != expected:
                        raise RangeUnsupported("Unexpected content range")
                    data = reply.content
                if len(data) != end-start+1:
                    raise RangeUnsupported("Truncated content range")
                self.cached_at, self.cached = start, data
            piece = self.cached[self.pos-start:self.pos-start+count]
            if not piece: raise IOError("Short ZIP read")
            result.append(piece)
            self.pos += len(piece)
            count -= len(piece)
        return b"".join(result)


def candidate_links(url):
    sf=normalize(url)
    if sf is None: return [url]
    _,project,name=sf
    links=[url,download_router_url(project,name)]
    for mirror in ("master","onboardcloud","psychz","zenlayer","netix"):
        links.append(direct_mirror_url(project,name,mirror))
    return list(dict.fromkeys(links))


def open_remote_zip(url):
    session=requests.Session()
    session.headers["User-Agent"]="Mozilla/5.0 (HyperMOS read-only installer inspection)"
    errors=[]
    for candidate in candidate_links(url):
        host=urlsplit(candidate).hostname
        try:
            reader=RangeFile(session,candidate)
            archive=zipfile.ZipFile(reader)
            print("[AUDIT] Selective ZIP range access:",host,flush=True)
            return archive,session
        except (requests.RequestException,RangeUnsupported,zipfile.BadZipFile,
                OSError,ValueError,EOFError) as err:
            errors.append(host+" "+type(err).__name__)
            print("[AUDIT] Range unavailable:",host,type(err).__name__,flush=True)
    session.close()
    raise RangeUnsupported("; ".join(errors))


def extract(archive,root):
    result={}
    for member in MEMBERS:
        try:
            info=archive.getinfo(member)
        except KeyError:
            continue
        if info.file_size > 32*1024**2:
            raise RuntimeError("Installer unexpectedly large: "+member)
        path=root/member
        path.parent.mkdir(parents=True,exist_ok=True)
        with archive.open(info) as src,path.open("wb") as dst:
            shutil.copyfileobj(src,dst,1024*1024)
        result[member]=info.file_size
        print("[AUDIT] Extracted:",member,info.file_size,"bytes",flush=True)
    if "linux_mac_fastboot_install_or_update.sh" not in result:
        raise RuntimeError("Main fastboot installation script not present")
    return result


def inspect(root,output,found):
    summary={"executed":False,"files":{}}
    md=["# EliteRom installer static report","",
        "No ROM script or binary was executed. Potential credentials in excerpts are masked.",""]
    for member in found:
        data=(root/member).read_bytes()
        binary=data.startswith((b"\x7fELF",b"MZ")) or b"\0" in data[:8192]
        if binary:
            lines=[v.decode("ascii","replace") for v in re.findall(rb"[\x20-\x7e]{5,}",data)]
        else:
            lines=data.decode("utf-8","replace").splitlines()
        hits=[]; count=0
        for index,line in enumerate(lines,1):
            if KEYWORDS.search(line):
                count+=1
                if len(hits)<150:
                    filtered=SECRET.sub(lambda x:x.group(1)+"[REDACTED]",line)
                    filtered=PASS_ARG.sub(lambda x:x.group(1)+"[REDACTED]",filtered)
                    hits.append({"position":index,"text":filtered[:350]})
        kind="ELF" if data.startswith(b"\x7fELF") else "PE" if data.startswith(b"MZ") else (
            "script" if data.startswith(b"#!") else "unidentified")
        summary["files"][member]={"size":len(data),"kind":kind,
            "match_count":count,"nul_bytes":data.count(b"\0"),"evidence":hits}
        md.extend(["## "+member,"","Format "+kind+"; size "+str(len(data))+
                   " bytes; relevant matches "+str(count),""])
        for hit in hits:
            md.append("- Line/string "+str(hit["position"])+": "+hit["text"])
        if not hits: md.append("No matching plaintext. Binary logic may still exist.")
        md.append("")
        print("[AUDIT] Analyzed",member,"format:",kind,"matches:",count,flush=True)
    (output/"installer-report.json").write_text(
        json.dumps(summary,indent=2,ensure_ascii=False)+"\n")
    (output/"installer-report.md").write_text("\n".join(md)+"\n")


def main():
    p=argparse.ArgumentParser()
    p.add_argument("--url",default=DEFAULT_URL)
    p.add_argument("--zip",type=Path)
    p.add_argument("--output",type=Path,required=True)
    p.add_argument("--full-fallback",action="store_true")
    args=p.parse_args()
    args.output.mkdir(parents=True,exist_ok=True)
    archive=session=None
    try:
        if args.zip: archive=zipfile.ZipFile(args.zip)
        else:
            try: archive,session=open_remote_zip(args.url)
            except RangeUnsupported as ex:
                print("[AUDIT] Range unavailable:",str(ex),flush=True)
                if not args.full_fallback: raise
                print("[AUDIT] Falling back to full ZIP download",flush=True)
                f=args.output/"full-source.zip"
                subprocess.run([sys.executable,
                    str(Path(__file__).with_name("sourceforge_download.py")),
                    "--url",args.url,"--output",str(f),
                    "--report",str(args.output/"mirror-report.json")],check=True)
                archive=zipfile.ZipFile(f)
        found=extract(archive,args.output/"installer")
        inspect(args.output/"installer",args.output,found)
        print("[AUDIT] Read-only inspection complete",flush=True)
    finally:
        if archive: archive.close()
        if session: session.close()
        (args.output/"full-source.zip").unlink(missing_ok=True)


if __name__=="__main__":
    main()
