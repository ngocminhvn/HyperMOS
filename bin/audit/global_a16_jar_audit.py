#!/usr/bin/env python3
"""Diff decoded Global303 vs stock EU309 miui-services. Audit only."""
import argparse, collections, difflib, json, re
from pathlib import Path
METHOD=re.compile(r'(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$')
CLASS=re.compile(r'(?m)^\.class\b[^\n]*\s(L[^;\n ]+;)\s*$')
IGNORE=('.line ','.param ','.end param','.local ','.end local',
        '.restart local','.prologue','.epilogue','.source ','#')
FOCUS=('MiuiBatteryIntelligence','PerfShielderService','ActivityManagerServiceImpl',
       'AppOpsServiceStubImpl','NotificationManagerServiceImpl',
       'BroadcastQueueModernStubImpl','GreezeManagerService',
       'DeviceIdleControllerStubImpl','ProcessManagerService',
       'InternationalPolicyManager','SystemServerImpl')
def norm(code):
    return tuple(line for x in code.splitlines() if (line:=x.strip())
                 and not line.startswith(IGNORE))
def load(root):
    out={};classes=set()
    for f in root.rglob('*.smali'):
        src=f.read_text(encoding='utf-8')
        owner=CLASS.search(src)
        if owner is None:raise ValueError('class declaration absent: '+str(f))
        owner=owner.group(1)
        if owner in classes:raise ValueError('duplicate class '+owner)
        classes.add(owner)
        for m in METHOD.finditer(src):
            code=m.group()
            key=(owner,code.splitlines()[0].strip().split()[-1])
            if key in out:raise ValueError('duplicate method '+repr(key))
            out[key]=code
    return out,classes
def run(glo,eu,report,diffs):
    a,ca=load(glo);b,cb=load(eu)
    common=a.keys()&b.keys()
    changed=[k for k in sorted(common) if norm(a[k])!=norm(b[k])]
    info={'global303_methods':len(a),'eu309_methods':len(b),
          'common_methods':len(common),'changed_methods':len(changed),
          'global_only_class':sorted(ca-cb),'eu_only_class':sorted(cb-ca),
          'global_only_methods':len(a.keys()-b.keys()),
          'eu_only_methods':len(b.keys()-a.keys()),
          'changes':[{'class':c,'method':s,'relevant':any(x in c for x in FOCUS)}
                     for c,s in changed]}
    report.parent.mkdir(parents=True,exist_ok=True)
    report.write_text(json.dumps(info,indent=2,ensure_ascii=False)+'\n')
    out=['# Global303 vs original EU309 miui-services.jar',
         'Common '+str(len(common))+', changed '+str(len(changed)),
         '## All changed methods']+[c+'->'+s for c,s in changed]
    out+=['## Focused changes (EU -> Global)']
    for k in changed:
        if not any(x in k[0] for x in FOCUS):continue
        lines=list(difflib.unified_diff(norm(b[k]),norm(a[k]),fromfile='EU309',
                                        tofile='Global303',lineterm=''))
        out+=['### '+k[0]+'->'+k[1]]+lines[:90]
    diffs.write_text('\n'.join(out)+'\n')
    print('[GLOBAL JAR AUDIT] common',len(common),'changed',len(changed),
          'only-global',len(a.keys()-b.keys()),'only-EU',len(b.keys()-a.keys()))
    for k in changed:print('[JAR DIFF]',k[0]+'->'+k[1])
if __name__=='__main__':
    p=argparse.ArgumentParser()
    for n in ('global-root','eu-root','report','diff-text'):
        p.add_argument('--'+n,required=True,type=Path)
    x=p.parse_args()
    run(x.global_root,x.eu_root,x.report,x.diff_text)
