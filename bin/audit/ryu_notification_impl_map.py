#!/usr/bin/env python3
"""RYUOS single-ROM PowerKeeper method and call graph audit; no APK export."""
import argparse
import hashlib
import json
import re
from pathlib import Path

METH=re.compile(r"(?ms)^\.method\s+([^\n]+)\n(.*?)^\.end method\s*$")
CLAS=re.compile(r"(?m)^\.class\s+[^\n]*?\s+(L[^;\s]+;)\s*$")
CALL=re.compile(r"\binvoke-[\w/-]+\s+\{[^}]*\},\s*(L[^;]+;->\S+)")
CONST=re.compile(r'\bconst-string(?:/jumbo)?\s+[^,]+,\s*"([^"\n]{1,128})"')
TOPICS={
 "FCM_GMS":r"gms|google|fcm|firebase|mtalk|heartbeat|gmsobserver",
 "NOTIFICATIONS":r"notification|notify|push|alert|listener|channel",
 "BACKGROUND":r"process|kill|uidstate|background|millet|freeze|greezer|appstandby",
 "POWER_DOZE":r"wakelock|deviceidle|doze|powersave|battery|sleep",
 "SCHEDULING":r"alarm|job|schedule|broadcast|receiver|timer",
 "NETWORK":r"network|firewall|dns|connect|restrict|netpolicy"}
PATTERNS={k:re.compile(v,re.I) for k,v in TOPICS.items()}
SKIP=re.compile(r"^\s*(?:\.line\b|\.local\b|\.end local\b|\.param\b|\.end param\b|\.prologue\b|\.epilogue\b|\.source\b|#)")
def scan(root):
 classes={}
 for path in sorted(root.rglob("*.smali")):
  txt=path.read_text(encoding="utf8",errors="replace")
  cm=CLAS.search(txt)
  if not cm:continue
  cls=cm.group(1)
  if cls in classes:raise RuntimeError("Duplicate PowerKeeper class "+cls)
  methods={}
  for entry in METH.finditer(txt):
   sig=entry.group(1).split()[-1]
   body=entry.group(2)
   calls=sorted(set(CALL.findall(body)))
   const=sorted(set(CONST.findall(body)))
   content=cls+"->"+sig+" "+" ".join(calls)+" "+" ".join(const)
   tags=[k for k,r in PATTERNS.items() if r.search(content)]
   clean="\n".join(x.strip() for x in body.splitlines() if x.strip() and not SKIP.match(x))
   branches=sum(1 for x in clean.splitlines() if re.match(r"(?:if-|goto|return|throw|packed-switch|sparse-switch)",x))
   methods[sig]={"sha256":hashlib.sha256(clean.encode()).hexdigest()[:24],
                 "calls":calls,"strings":const,"tags":tags,
                 "branches":branches,"normalized_lines":len(clean.splitlines())}
  classes[cls]=methods
 if not classes:raise RuntimeError("No PowerKeeper smali classes")
 return classes
def markdown(data):
 lines=["# RYUOS notification mechanism investigation","",
  "Single ROM inspection of all decompiled PowerKeeper methods.",
  "This maps possible code paths, not verified fixes or runtime behavior.",
  "Classes: "+str(len(data))+"; methods: "+str(sum(map(len,data.values()))),""]
 for category in PATTERNS:
  hits=[(cls,sig,m) for cls,items in data.items() for sig,m in items.items() if category in m["tags"]]
  lines+=["## "+category,"","Matching methods: "+str(len(hits)),""]
  prioritized=[item for item in hits if PATTERNS[category].search(item[0]+"->"+item[1])]
  for cls,sig,m in prioritized[:90]:
   lines+=["### "+cls+"->"+sig,
    "Calls: "+", ".join(m["calls"][:20]),
    "String constants: "+str(m["strings"][:15]),
    "Branch instructions: "+str(m["branches"])," "]
  if len(prioritized)>90:lines.append("Additional methods in JSON: "+str(len(prioritized)-90))
 lines+=["## Caveats","",
  "A method's existence does not establish that RYUOS modified it.",
  "Use on-device latency and idle-drain testing before adopting any policy.",
  "Do not blanket-disable power management, thermal or network protection.",""]
 return "\n".join(lines)
def main():
 p=argparse.ArgumentParser()
 p.add_argument("--smali",type=Path,required=True)
 p.add_argument("--output",type=Path,required=True)
 p.add_argument("--markdown",type=Path,required=True)
 a=p.parse_args()
 data=scan(a.smali)
 a.output.parent.mkdir(parents=True,exist_ok=True)
 a.output.write_text(json.dumps({"classes":data},ensure_ascii=False,separators=(",",":"))+"\n")
 a.markdown.write_text(markdown(data),encoding="utf8")
 print("Mapped",len(data),"PowerKeeper classes and",sum(map(len,data.values())),"methods",flush=True)
if __name__=="__main__":
 main()
