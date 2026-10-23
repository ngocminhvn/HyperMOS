#!/usr/bin/env python3
"""Read-only ZK304 vs EU309 vs Global303 notification/battery DEX audit."""
from pathlib import Path
import argparse, collections, difflib, json, re

METHOD=re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
CLASS=re.compile(r"(?m)^\.class\b[^\n]*\s(L[^;\n ]+;)\s*$")
SKIP=(".line ", ".param ", ".end param", ".local ", ".end local",
      ".restart local", ".source ", ".prologue", ".epilogue", "#")
FOCUS=re.compile(r"notification|greeze|freeze|deviceidle|doze|broadcast|process|kill|millet|google|gms|fcm|wakelock|power|battery|thermal|perf|alarm|job|appstandby|autostart|cloud|sleep|activeState|stamina|sync",re.I)
KEY=re.compile(r"setUidState|shouldKill|isAllowBroadcast|isRestrictReceiver|updateGoogleSync|"
               r"isGmsControlEnabled|thawUidAsync|isLowPowerDozeEnable|checkApplicationAutoStart|"
               r"isNeedCachedBroadcast|notifyProcessStarted|isForceStopEnable|"
               r"checkIfCancelJob|isInternationalSpecialAction",re.I)
ZK_REFS=("Lmiui/zk/","Lcom/zk/","IS_ZK_BUILD","/sys/class/thermal/thermal_message/zk_state")
def norm(body):
    return tuple(t for line in body.splitlines()
                 if (t:=line.strip()) and not t.startswith(SKIP))
def load(directory):
    entries={}
    for f in directory.rglob("*.smali"):
        body=f.read_text(encoding="utf-8",errors="replace")
        match=CLASS.search(body)
        if not match:raise ValueError("No owner in "+str(f))
        owner=match.group(1)
        for m in METHOD.finditer(body):
            src=m.group(); name=src.splitlines()[0].split()[-1]
            key=(owner,name)
            if key in entries:raise ValueError("duplicate "+str(key))
            entries[key]=src
    if not entries:raise ValueError("no smali at "+str(directory))
    return entries
def compare(zk,eu,glob,out,details):
    a,b,c=load(zk),load(eu),load(glob)
    union=set(a)|set(b)|set(c)
    diffs=[]
    for k in sorted(union):
        if k not in a:continue
        focus=bool(FOCUS.search(" ".join(k)))
        if not focus:continue
        sa=a[k]; eb=b.get(k); gb=c.get(k)
        if eb is not None and norm(sa)==norm(eb):continue
        if gb is not None and norm(sa)==norm(gb):continue
        status=("missing_EU" if eb is None else "changed_EU") + "/" + ("missing_Global" if gb is None else "changed_Global")
        zkrefs=[r for r in ZK_REFS if r in sa]
        diffs.append((k,status,zkrefs,sa,eb,gb))
    out.parent.mkdir(parents=True,exist_ok=True)
    data={
      "sources":{"ZK":"ZK304 HAOTIAN donor","EU":"Original EU309 HAOTIAN","Global":"Global303 dada"},
      "method_counts":{"zk":len(a),"eu":len(b),"global":len(c)},
      "zk_specific_focus_count":len(diffs),
      "missing_zeu_methods":len(set(a)-set(b)),
      "zk_focus":[
        {"class":k[0],"method":k[1],"status":status,"zk_only_references":refs,
         "priority":"high" if KEY.search(k[0]+k[1]) else "review"}
        for k,status,refs,*_ in diffs],
    }
    out.write_text(json.dumps(data,ensure_ascii=False,indent=2)+"\n")
    write=["# ZK304 vs EU309 and Global303","Method counts: "+str(data["method_counts"]),
           "ZK-specific focus differences: "+str(len(diffs)),
           "Note: disassembly label renumbering can create non-semantic differences.",
           "Absence of a Global method or ZK-only reference is not approval to port."]
    hi=[x for x in diffs if KEY.search(x[0][0]+x[0][1])]
    other=[x for x in diffs if x not in hi]
    for k,status,refs,sa,eb,gb in hi+other[:100]:
        write+=["\n## "+k[0]+"->"+k[1]+"  ["+status+"]",
                "ZK-private refs: "+repr(refs)]
        if eb is not None:
            d=list(difflib.unified_diff(norm(eb),norm(sa),fromfile="EU309",tofile="ZK304",lineterm=""))
            write+=d[:95]
        if gb is not None and norm(gb)!=norm(sa):
            write+=["Global vs ZK (first 35 diff lines):"]
            write+=list(difflib.unified_diff(norm(gb),norm(sa),fromfile="Global303",tofile="ZK304",lineterm=""))[:35]
    details.write_text("\n".join(write)+"\n")
    print("[ZK AUDIT] methods",len(a),len(b),len(c),"ZK-specific focus",len(diffs),"high",len(hi))
    for k,status,refs,*_ in hi:
        print("[ZK CANDIDATE]",k[0]+"->"+k[1],status,"private:",repr(refs))
if __name__=="__main__":
    p=argparse.ArgumentParser()
    for v in ("zk","eu","global","report","details"):
        p.add_argument("--"+v,required=True,type=Path)
    x=p.parse_args()
    compare(x.zk,x.eu,getattr(x,"global"),x.report,x.details)
