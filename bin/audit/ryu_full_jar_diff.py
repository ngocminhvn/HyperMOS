#!/usr/bin/env python3
"""Full 3-JAR DEX inventory + diff (all defined classes, fields, methods).

This inventories structural changes and raw instruction hashes. Different
DEX constant-pool indexes can cause false positives. Confirm with smali
before deciding that logic changed. No ROM binary is uploaded to Actions.
"""
import argparse
import collections
import gzip
import hashlib
import json
import re
import struct
import zipfile
from pathlib import Path

JARS = ("framework.jar", "services.jar", "miui-services.jar")
TOPICS = (
 ("Power / Doze / battery", r"(?i)(power|battery|deviceidle|wakelock|thermal|millet|greezer|standby)"),
 ("Notifications / push", r"(?i)(notification|fcm|gms|push|toast|alert)"),
 ("App lifecycle / process", r"(?i)(activitymanager|activitythread|process|kill|broadcast|service|oomadjuster)"),
 ("Security / permissions", r"(?i)(keystore|keymint|permission|security|packageverify|integrity|signature|appops|selinux)"),
 ("Package install / identity", r"(?i)(packagemanager|installer|packageparser|fingerprint|deviceid|build\;)"),
 ("Network / DNS / telephony", r"(?i)(network|wifi|dns|connectivity|telephony|radio|netd)"),
 ("Display / graphics", r"(?i)(display|surface|render|windowmanager|refresh|animation|aod)"),
 ("Location / sensors", r"(?i)(location|sensor|gnss|geofenc)"),
 ("Media / camera / audio", r"(?i)(camera|media|audio|codec|player)"),
 ("Input / keyboard", r"(?i)(inputmethod|keyboard|touch|gesture)"),
 ("Scheduling / alarms", r"(?i)(alarm|jobservice|jobscheduler|schedule|timer)"),
 ("Accounts / backup", r"(?i)(account|sync|backup|restore)"),
 ("Other framework", r".*"),
)

def u16(b,p):return struct.unpack_from("<H",b,p)[0]
def u32(b,p):return struct.unpack_from("<I",b,p)[0]
def leb(b,p):
    n=0
    for shift in range(0,35,7):
        v=b[p];p+=1;n|=(v&127)<<shift
        if v<128:return n,p
    raise ValueError("bad uleb")
def scan_dex(b):
    if b[:4]!=b"dex\n":raise ValueError("not a DEX")
    count,off=u32(b,56),u32(b,60)
    strings=[]
    for i in range(count):
        p=u32(b,off+4*i);_,p=leb(b,p)
        q=b.index(b"\0",p)
        strings.append(b[p:q].decode("utf-8","replace"))
    count,off=u32(b,64),u32(b,68)
    types=[strings[u32(b,off+4*i)] for i in range(count)]
    count,off=u32(b,72),u32(b,76)
    protos=[]
    for i in range(count):
        _,ret,po=struct.unpack_from("<III",b,off+12*i)
        a="".join(types[u16(b,po+4+j*2)] for j in range(u32(b,po))) if po else ""
        protos.append("("+a+")"+types[ret])
    count,off=u32(b,80),u32(b,84)
    fields=[]
    for i in range(count):
        cl,typ,nam=struct.unpack_from("<HHI",b,off+8*i)
        fields.append(types[cl]+"->"+strings[nam]+":"+types[typ])
    count,off=u32(b,88),u32(b,92)
    methods=[]
    for i in range(count):
        cl,pr,nam=struct.unpack_from("<HHI",b,off+8*i)
        methods.append(types[cl]+"->"+strings[nam]+protos[pr])
    count,off=u32(b,96),u32(b,100)
    output={}
    for i in range(count):
        cl,acc,sup,interfaces,_,_,cdata,_=struct.unpack_from("<8I",b,off+32*i)
        typ=types[cl]
        impl=[types[u16(b,interfaces+4+2*j)] for j in range(u32(b,interfaces))] if interfaces else []
        obj={"access":acc,"super":types[sup] if sup<len(types) else "",
             "interfaces":impl,"fields":{},"methods":{}}
        if cdata:
            pos=cdata;counts=[]
            for _ in range(4):
                value,pos=leb(b,pos);counts.append(value)
            idx=0
            for j in range(counts[0]+counts[1]):
                delta,pos=leb(b,pos);idx+=delta
                flags,pos=leb(b,pos);obj["fields"][fields[idx]]=flags
                if j+1==counts[0]:idx=0
            for n in (counts[2],counts[3]):
                idx=0
                for _ in range(n):
                    delta,pos=leb(b,pos);idx+=delta
                    flags,pos=leb(b,pos);code,pos=leb(b,pos)
                    if code:
                        words=u32(b,code+12)
                        insns=b[code+16:code+16+words*2]
                        if len(insns)!=words*2:raise ValueError("truncated code_item")
                        digest=hashlib.sha256(insns).hexdigest()[:24]
                    else:digest="no-code"
                    obj["methods"][methods[idx]]=[flags,digest]
        output[typ]=obj
    return output

def read_json(path):
    if str(path).endswith(".gz"):
        with gzip.open(path,"rt",encoding="utf-8") as f:return json.load(f)
    return json.loads(path.read_text(encoding="utf-8"))
def write_json(path,obj):
    path.parent.mkdir(parents=True,exist_ok=True)
    if str(path).endswith(".gz"):
        with gzip.open(path,"wt",encoding="utf-8",compresslevel=6) as f:json.dump(obj,f,separators=(",",":"),ensure_ascii=False)
    else:path.write_text(json.dumps(obj,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")
def scan(directory):
    result={"format":2,"files":{}}
    for jar in JARS:
        p=directory/jar
        if not p.exists():
            raise FileNotFoundError(f"Missing required JAR: {p}")
        item={"sha256":hashlib.sha256(p.read_bytes()).hexdigest(),"classes":{},"dex":{}}
        with zipfile.ZipFile(p) as z:
            for name in z.namelist():
                if not re.fullmatch(r"classes\d*\.dex",name):continue
                raw=z.read(name)
                item["dex"][name]=hashlib.sha256(raw).hexdigest()
                item["classes"].update(scan_dex(raw))
        result["files"][jar]=item
        n=sum(len(v["methods"]) for v in item["classes"].values())
        print(f"{jar}: {len(item['dex'])} DEX, {len(item['classes'])} classes, {n} methods")
    return result
def topic(name):
    for label,regex in TOPICS:
        if re.search(regex,name):return label
    return "Other framework"
def compare(stock,custom):
    result={"note":"Instruction fingerprints are candidates, not verified semantic changes.",
            "files":{},"summary":{}}
    for jar in JARS:
        old=stock["files"][jar]
        new=custom["files"][jar]
        oa,nb=old["classes"],new["classes"]
        report={"same_jar_bytes":old["sha256"]==new["sha256"],
                "stock_sha256":old["sha256"],"custom_sha256":new["sha256"],
                "class_added":sorted(nb.keys()-oa.keys()),
                "class_removed":sorted(oa.keys()-nb.keys()),
                "class_changed":{}}
        counts=collections.Counter()
        for cls in sorted(oa.keys() & nb.keys()):
            a,b=oa[cls],nb[cls]
            am,bm=a["methods"],b["methods"]
            af,bf=a["fields"],b["fields"]
            changed=sorted(k for k in am.keys() & bm.keys() if am[k]!=bm[k])
            ma=sorted(bm.keys()-am.keys())
            mr=sorted(am.keys()-bm.keys())
            fa=sorted(bf.keys()-af.keys())
            fr=sorted(af.keys()-bf.keys())
            fm=sorted(k for k in af.keys() & bf.keys() if af[k]!=bf[k])
            meta={k:[a[k],b[k]] for k in ("access","super","interfaces") if a[k]!=b[k]}
            if changed or ma or mr or fa or fr or fm or meta:
                report["class_changed"][cls]={
                    "code_or_access_changed":changed,"methods_added":ma,"methods_removed":mr,
                    "fields_added":fa,"fields_removed":fr,"field_access_changed":fm,
                    "metadata_changed":meta}
                counts[topic(cls)]+=1
        report["topic_changed_class_counts"]=dict(counts.most_common())
        result["files"][jar]=report
        result["summary"][jar]={
            "identical_bytes":report["same_jar_bytes"],
            "classes_added":len(report["class_added"]),
            "classes_removed":len(report["class_removed"]),
            "classes_changed":len(report["class_changed"]),
            "methods_changed_raw":sum(len(v["code_or_access_changed"]) for v in report["class_changed"].values()),
            "methods_added":sum(len(v["methods_added"]) for v in report["class_changed"].values()),
            "methods_removed":sum(len(v["methods_removed"]) for v in report["class_changed"].values()),
            "topic_class_counts":dict(counts.most_common())}
    return result
def markdown(diff,description):
    lines=["# RYUOS vs Xiaomi Stock — full framework DEX inventory","",
        description,"",
        "**WARNING:** raw instruction hashes can change with DEX index remapping. "
        "A changed hash is NOT proof that behavior changed. Verify changed "
        "methods with normalized smali before deciding what to port.","",
        "| JAR | Added classes | Removed classes | Changed classes | Raw method candidates |",
        "|---|---:|---:|---:|---:|"]
    for jar,row in diff["summary"].items():
        lines.append(f"| `{jar}` | {row['classes_added']} | {row['classes_removed']} | "
                     f"{row['classes_changed']} | {row['methods_changed_raw']} |")
    lines.extend(["","## Full coverage by area",""])
    for jar,entry in diff["files"].items():
        lines.append("### "+jar)
        for topic_name,num in entry["topic_changed_class_counts"].items():
            lines.append(f"- {topic_name}: {num} changed classes")
        lines.append("")
    lines.extend(["## Review categories","",
        "- P0: package / permission / signature / app lifecycle / init / security impacts.",
        "- P1: power, doze, notification, wakelock, scheduling, background policy.",
        "- P2: screen, UI, input, network, sensors, media, framework compatibility.",
        "- P3: private logging, telemetry, flags without confirmed runtime effect.",
        "",
        "Inspect the JSON inventory to get **every** added, deleted or potentially changed "
        "class, method and field. Do not claim functional differences from hashes alone.",
        ""])
    return "\n".join(lines)
def main():
    p=argparse.ArgumentParser();s=p.add_subparsers(dest="cmd",required=True)
    a=s.add_parser("scan");a.add_argument("--directory",type=Path,required=True);a.add_argument("--output",type=Path,required=True)
    x=s.add_parser("summary");x.add_argument("--input",type=Path,required=True);x.add_argument("--markdown",type=Path,required=True)
    b=s.add_parser("compare");b.add_argument("--stock",type=Path,required=True);b.add_argument("--custom",type=Path,required=True);b.add_argument("--output",type=Path,required=True);b.add_argument("--markdown",type=Path,required=True)
    args=p.parse_args()
    if args.cmd=="scan":write_json(args.output,scan(args.directory))
    elif args.cmd=="summary":
        snapshot=read_json(args.input)
        lines=["# RYUOS full 3-JAR DEX inventory","",
               "This inventories ALL classes, methods and fields.",
               "Stock comparison has not run unless a separate validated stock snapshot is supplied.",
               "", "| JAR | DEX | Classes | Methods | Fields | SHA256 |",
               "|---|---:|---:|---:|---:|---|"]
        for name,item in snapshot["files"].items():
            classes=item["classes"]
            lines.append(f"| {name} | {len(item['dex'])} | {len(classes)} | "
                         f"{sum(len(v['methods']) for v in classes.values())} | "
                         f"{sum(len(v['fields']) for v in classes.values())} | "
                         f"{item['sha256'][:20]}... |")
        lines += ["","## Important limitation","",
          "Inventory does NOT identify RYU changes versus Xiaomi stock.",
          "Use compare with the matching stock fingerprint and verify smali changes.",
          ""]
        args.markdown.parent.mkdir(parents=True,exist_ok=True)
        args.markdown.write_text("\\n".join(lines),encoding="utf-8")
    else:
        diff=compare(read_json(args.stock),read_json(args.custom))
        write_json(args.output,diff)
        args.markdown.parent.mkdir(parents=True,exist_ok=True)
        args.markdown.write_text(markdown(diff,"Compared three JARs from the supplied sources."),encoding="utf-8")
        print(json.dumps(diff["summary"],indent=2))
if __name__=="__main__":main()
