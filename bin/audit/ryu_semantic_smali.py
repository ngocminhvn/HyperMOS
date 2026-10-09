#!/usr/bin/env python3
"""Structural smali comparison of ALL classes/methods for 3 framework JARs.
Reports method signatures, changed calls/constants/control-flow counts, never
publishes disassembled smali or ROM binaries.
"""
import argparse
import collections
import hashlib
import json
import re
from pathlib import Path

SKIP_RE=re.compile(r"^\s*(?:\.line\s|\.prologue|\.epilogue|\.local\s|\.end local|\.restart local|\.param\s|\.end param|\.source\s|#)")
INVOKE=re.compile(r"\binvoke-[\w/-]+\s+\{[^}]*\},\s*(\S+)")
CONST=re.compile(r"\bconst(?:-wide|-string|-class|/[\w]+)?\s+\S+,\s*(.+)")
BRANCH=re.compile(r"^(?:if-|goto|packed-switch|sparse-switch|throw|return)")
CATEGORIES=(
 ("POWER",re.compile("(?i)(power|battery|doze|idle|thermal|wakelock|millet|greezer)")),
 ("NOTIFICATION",re.compile("(?i)(notification|toast|push|alert|gms|broadcast)")),
 ("SECURITY",re.compile("(?i)(key|integrity|signature|permission|appops|verify|security|selinux)")),
 ("PROCESS",re.compile("(?i)(activity|process|package|zygote|service|kill|binder)")),
 ("NETWORK",re.compile("(?i)(network|dns|wifi|telephony|connectivity)")),
 ("UI",re.compile("(?i)(display|window|surface|input|theme|render|refresh|launcher)")),
 ("MEDIA",re.compile("(?i)(camera|audio|media|codec|video)")),
 ("OTHER",re.compile(".*")),
)

def bucket(name):
    for label,expr in CATEGORIES:
        if expr.search(name):return label
    return "OTHER"

def method_name(line):
    # .method flags name(ARGS)Return
    return line.strip().split()[-1]

def normalized(block):
    return tuple(line.strip() for line in block
        if line.strip() and not SKIP_RE.match(line))

def analyze_method(lines):
    text=normalized(lines)
    inv=set();cons=set();ctrl=collections.Counter()
    for line in text:
        match=INVOKE.search(line)
        if match:inv.add(match.group(1))
        match=CONST.search(line)
        if match:cons.add(match.group(1)[:160])
        head=line.split(None,1)[0]
        if BRANCH.match(head):ctrl[head.split("/")[0]]+=1
    return {"digest":hashlib.sha256("\n".join(text).encode()).hexdigest()[:24],
      "calls":sorted(inv),"constants":sorted(cons),"control":dict(ctrl),
      "opcodes":len(text)}

def parse(path):
    data={"methods":{},"fields":{},"class_header":[],
          "sha256":hashlib.sha256(path.read_bytes()).hexdigest()}
    state=None;block=[];key=None
    for line in path.read_text(encoding="utf8",errors="replace").splitlines():
        s=line.strip()
        if s.startswith(".method "):
            state="method";block=[line];key=method_name(line)
        elif s==".end method" and state=="method":
            block.append(line);data["methods"][key]=analyze_method(block)
            state=None;block=[];key=None
        elif state=="method":block.append(line)
        elif s.startswith(".field "):
            # Preserve field's access flags and initializer as metadata.
            token=s.split("=",1)[0].strip().split()[-1]
            data["fields"][token]=hashlib.sha256(s.encode()).hexdigest()[:16]
        elif s.startswith((".class ", ".super ", ".implements ")):
            data["class_header"].append(s)
    return data

def collect(root):
    out={}
    for path in root.rglob("*.smali"):
        # Class descriptor from source .class line, not smali physical path.
        txt=path.open(encoding="utf8",errors="replace")
        desc=""
        with txt:
            for line in txt:
                if line.lstrip().startswith(".class "):
                    desc=line.strip().split()[-1];break
        if not desc:continue
        # Folder names include jar and classesN.dex.
        rel=path.relative_to(root).parts
        if len(rel)<3:continue
        jar=rel[0]
        if jar not in ("framework.jar","services.jar","miui-services.jar"):continue
        key=jar+"/"+desc
        if key in out:raise RuntimeError("Duplicate class descriptor: "+key)
        out[key]=parse(path)
    return out

def differences(stock,custom):
    diff={"classes_added":sorted(custom.keys()-stock.keys()),
      "classes_removed":sorted(stock.keys()-custom.keys()),
      "changed_classes":{}}
    for name in sorted(stock.keys()&custom.keys()):
        old,new=stock[name],custom[name]
        if old["sha256"]==new["sha256"]:continue
        changed_methods={}
        om,nm=old["methods"],new["methods"]
        for sig in sorted(om.keys()&nm.keys()):
            o,n=om[sig],nm[sig]
            if o["digest"]==n["digest"]:continue
            changed_methods[sig]={
              "calls_added":sorted(set(n["calls"])-set(o["calls"])),
              "calls_removed":sorted(set(o["calls"])-set(n["calls"])),
              "constants_added":sorted(set(n["constants"])-set(o["constants"]))[:25],
              "constants_removed":sorted(set(o["constants"])-set(n["constants"]))[:25],
              "control_before":o["control"],"control_after":n["control"],
              "opcodes_before":o["opcodes"],"opcodes_after":n["opcodes"]}
        add=sorted(nm.keys()-om.keys())
        remove=sorted(om.keys()-nm.keys())
        fadd=sorted(new["fields"].keys()-old["fields"].keys())
        frem=sorted(old["fields"].keys()-new["fields"].keys())
        fchange=sorted(k for k in old["fields"].keys()&new["fields"].keys()
                       if old["fields"][k]!=new["fields"][k])
        meta=(old["class_header"]!=new["class_header"])
        if changed_methods or add or remove or fadd or frem or fchange or meta:
            diff["changed_classes"][name]={
              "bucket":bucket(name),
              "changed_methods":changed_methods,
              "methods_added":add,"methods_removed":remove,
              "fields_added":fadd,"fields_removed":frem,
              "fields_modified":fchange,"class_header_changed":meta}
    return diff

def build_md(diff):
    totals=collections.Counter()
    for name,item in diff["changed_classes"].items():
        totals[item["bucket"]]+=1
    out=["# RYUOS vs Xiaomi stock: full smali comparison","",
      "Method bodies normalized to ignore source debug lines only. "
      "Changed methods need manual semantic review; not all changes are fixes.","",
      f"Classes added: **{len(diff['classes_added'])}**; removed: "
      f"**{len(diff['classes_removed'])}**; changed: "
      f"**{len(diff['changed_classes'])}**.","",
      "## Changed classes by area",""]
    for topic,num in totals.most_common():out.append(f"- {topic}: {num}")
    out+=["","## Every changed class and method",""]
    for name,obj in diff["changed_classes"].items():
        out.append("### "+name)
        if obj["class_header_changed"]:out.append("- Class metadata changed")
        if obj["fields_added"] or obj["fields_removed"] or obj["fields_modified"]:
            out.append(f"- Fields +{len(obj['fields_added'])} / -{len(obj['fields_removed'])} / altered {len(obj['fields_modified'])}")
        if obj["methods_added"] or obj["methods_removed"]:
            out.append(f"- Methods +{len(obj['methods_added'])} / -{len(obj['methods_removed'])}")
        for method,data in obj["changed_methods"].items():
            out.append("- `"+method.replace("`","")+"`")
            if data["calls_added"]:out.append("  - Calls added: "+", ".join(data["calls_added"][:6]))
            if data["calls_removed"]:out.append("  - Calls removed: "+", ".join(data["calls_removed"][:6]))
            if data["constants_added"] or data["constants_removed"]:
                out.append(f"  - Constants: +{len(data['constants_added'])}, -{len(data['constants_removed'])}")
            if data["control_before"]!=data["control_after"]:
                out.append("  - Conditional/return/branch structure changed")
        out.append("")
    out += ["","This report covers all three JARs, not notification-only. "
        "Only port methods after reviewing side-by-side logic and device runtime impact."]
    return "\n".join(out)+"\n"

def main():
    p=argparse.ArgumentParser()
    p.add_argument("--stock",required=True,type=Path)
    p.add_argument("--ryu",required=True,type=Path)
    p.add_argument("--output",required=True,type=Path)
    p.add_argument("--markdown",required=True,type=Path)
    a=p.parse_args()
    diff=differences(collect(a.stock),collect(a.ryu))
    a.output.parent.mkdir(parents=True,exist_ok=True)
    a.output.write_text(json.dumps(diff,ensure_ascii=False,indent=2)+"\n",encoding="utf8")
    a.markdown.write_text(build_md(diff),encoding="utf8")
    print(f"Changed classes: {len(diff['changed_classes'])}; added: {len(diff['classes_added'])}; removed: {len(diff['classes_removed'])}")
if __name__=="__main__":main()
