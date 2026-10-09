#!/usr/bin/env python3
"""Compare every PowerKeeper class, method and field across three decoded APKs."""
import argparse
import json
from pathlib import Path
from ryu_semantic_smali import parse,differences,build_md

def collect(root):
    result={}
    for path in sorted(root.rglob("*.smali")):
        with path.open(encoding="utf8",errors="replace") as stream:
            descriptor=next((line.strip().split()[-1] for line in stream if line.lstrip().startswith(".class ")),None)
        if not descriptor:continue
        key="PowerKeeper.apk/"+descriptor
        if key in result:raise RuntimeError("Duplicate class "+key)
        result[key]=parse(path)
    if not result:raise RuntimeError("No PowerKeeper classes at "+str(root))
    return result

def signatures(diff):
    return {c+"->"+sig for c,v in diff["changed_classes"].items()
            for sig in v["changed_methods"]}

def main():
    p=argparse.ArgumentParser()
    for label in ("ryu","stock","hypermos","output","markdown"):
        p.add_argument("--"+label,type=Path,required=True)
    a=p.parse_args()
    data={name:collect(getattr(a,name)) for name in ("ryu","stock","hypermos")}
    reports={
        "ryu_vs_stock":differences(data["stock"],data["ryu"]),
        "hypermos_vs_stock":differences(data["stock"],data["hypermos"]),
        "ryu_vs_hypermos":differences(data["hypermos"],data["ryu"])}
    r=signatures(reports["ryu_vs_stock"])
    h=signatures(reports["hypermos_vs_stock"])
    output={"status":"three_way_complete",
            "source_class_counts":{k:len(v) for k,v in data.items()},
            "comparisons":reports,
            "ryu_only_candidates":sorted(r-h),
            "common_modified_methods":sorted(r&h),
            "hypermos_only_candidates":sorted(h-r)}
    a.output.parent.mkdir(parents=True,exist_ok=True)
    a.output.write_text(json.dumps(output,ensure_ascii=False,separators=(",",":"))+"\n")
    header=["# PowerKeeper exhaustive three-way comparison","",
            "All decoded methods and fields are examined, NOT nine static indicators.",
            "Debug/source directives are ignored in method hashes, but register/layout",
            "differences can still yield false positives; verify logic before porting.",""]
    for name,diff in reports.items():
        section=build_md(diff).replace(
            "# RYUOS vs Xiaomi stock: full smali comparison",
            "### "+name.replace("_"," "))
        header.append(section)
        print(name,"changed_classes",len(diff["changed_classes"]),
              "added",len(diff["classes_added"]),"removed",len(diff["classes_removed"]),flush=True)
    header+=["## Candidate improvements (RYU-only changes)","",
             "Names below require manual review and notification/standby testing:",
             *("- "+s for s in sorted(r-h)),"",
             "## Both RYU and simulated HyperMOS modify","",
             *("- "+s for s in sorted(r&h)),"",
             "## HyperMOS-only modifications","",
             *("- "+s for s in sorted(h-r)),"",
             "## Caveat","",
             "Stock 3.0.308 is the common baseline. The RYU ZIP says 3.0.309;",
             "cross-check ROM identity/hash before treating changes as RYU-only.",
             "The HyperMOS comparison applies current main A16 patch to stock and",
             "is not a measurement of FCM latency, battery draw or device behavior.",""]
    a.markdown.write_text("\n".join(header),encoding="utf8")

if __name__=="__main__":
    main()
