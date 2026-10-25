#!/usr/bin/env python3
"""EU A16: FCM-only Autostart exception, preserving all other stock Xiaomi.eu gates."""
import argparse
import json
import re
from pathlib import Path

CLASS = "com/android/server/am/BroadcastQueueModernStubImpl.smali"
SIG = ("checkApplicationAutoStart(Lcom/android/server/am/BroadcastQueue;"
       "Lcom/android/server/am/BroadcastRecord;Landroid/content/pm/ResolveInfo;)Z")
BR = "Lcom/android/server/am/BroadcastRecord;"
METHOD = re.compile(r"(?ms)^\\.method[^\\n]*\\n.*?^\\.end method[ \\t]*$")
REG = re.compile(r"(?m)^\\s*\\.(locals|registers)\\s+(\\d+)\\s*$")
MARKER = "HYPERMOS_EU_GMS_FCM_AUTOSTART"
GUARD = f'''    # {MARKER}: only GMS-authored C2DM, never override other EU traffic
    if-eqz p2, :eu_fcm_stock_autostart
    iget-object v0, p2, {BR}->intent:Landroid/content/Intent;
    if-eqz v0, :eu_fcm_stock_autostart
    invoke-virtual {{v0}}, Landroid/content/Intent;->getAction()Ljava/lang/String;
    move-result-object v0
    const-string v1, "com.google.android.c2dm.intent.RECEIVE"
    invoke-virtual {{v1, v0}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :eu_fcm_stock_autostart
    iget-object v0, p2, {BR}->callerPackage:Ljava/lang/String;
    const-string v1, "com.google.android.gms"
    invoke-virtual {{v1, v0}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :eu_fcm_stock_autostart
    const/4 v0, 0x1
    return v0

    :eu_fcm_stock_autostart
'''

def get_method(src):
    matches = [m for m in METHOD.finditer(src)
               if m.group().splitlines()[0].strip().split()[-1] == SIG]
    if len(matches) != 1:
        raise ValueError(f"Expected exactly one EU Autostart method: {len(matches)}")
    return matches[0]

def is_guard_present(body):
    ops = [s.strip().replace("const-string/jumbo ", "const-string ")
           for s in body.splitlines()
           if s.strip() and not s.strip().startswith((".", ":", "#"))]
    needle = [
        f"iget-object v0, p2, {BR}->intent:Landroid/content/Intent;",
        "if-eqz v0,",
        "invoke-virtual {v0}, Landroid/content/Intent;->getAction()Ljava/lang/String;",
        "move-result-object v0",
        'const-string v1, "com.google.android.c2dm.intent.RECEIVE"',
        "invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z",
        "move-result v0", "if-eqz v0,",
        f"iget-object v0, p2, {BR}->callerPackage:Ljava/lang/String;",
        'const-string v1, "com.google.android.gms"',
        "invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z",
        "move-result v0", "if-eqz v0,", "const/4 v0, 0x1", "return v0"
    ]
    def eq(a,b):
        return a.startswith(b) if b.endswith(",") else a == b
    return any(all(eq(ops[i+j],n) for j,n in enumerate(needle))
               for i in range(max(0,len(ops)-len(needle)+1)))

def patch_source(src, verify=False):
    m = get_method(src)
    body = m.group()
    if MARKER in body and body.count(MARKER) != 1:
        raise ValueError("Duplicate autostart guard marker")
    if is_guard_present(body):
        if "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z" not in body:
            raise ValueError("EU stock international gate lost")
        return src, "verified" if verify else "already_patched"
    if MARKER in body or verify:
        raise ValueError("GMS FCM guard missing or malformed")
    decl = REG.findall(body)
    if len(decl) != 1:
        raise ValueError("Ambiguous EU Autostart registers")
    kind,size = decl[0]
    if (int(size) if kind=="locals" else int(size)-4) < 2:
        raise ValueError("Need two local registers for FCM guard")
    if "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z" not in body:
        raise ValueError("Original EU international gate absent")
    lines = body.splitlines(keepends=True)
    begin = next(i for i,s in enumerate(lines) if REG.fullmatch(s.strip()))
    index = None
    for i in range(begin+1,len(lines)):
        s=lines[i].strip()
        if not s or s.startswith((".", "#")):
            continue
        if s.startswith(":") or re.match(r"^[a-z][\\w/-]*(?:\\s|$)",s):
            index=i
            break
    if index is None:
        raise ValueError("No original EU executable code")
    lines.insert(index,GUARD)
    return src[:m.start()] + "".join(lines) + src[m.end():], "patched"

def apply(root, verify=False, report=None):
    hits = list(root.glob("smali*/"+CLASS))
    if len(hits)!=1:
        raise ValueError(f"Autostart class count: {len(hits)}")
    original=hits[0].read_text(encoding="utf-8")
    changed,status=patch_source(original,verify)
    if not verify and changed!=original:
        hits[0].write_text(changed,encoding="utf-8")
    outcome={"method":SIG,"status":status,"scope":"GMS C2DM to every eligible app; others stock EU"}
    if report:
        report.parent.mkdir(parents=True,exist_ok=True)
        report.write_text(json.dumps(outcome,indent=2)+"\\n",encoding="utf-8")
    return outcome

def main():
    p=argparse.ArgumentParser()
    p.add_argument("decoded",type=Path)
    p.add_argument("--verify",action="store_true")
    p.add_argument("--report",type=Path)
    a=p.parse_args()
    try:
        print("[EU FCM AUTOSTART] "+json.dumps(apply(a.decoded,a.verify,a.report)))
    except (ValueError,OSError) as e:
        raise SystemExit("[EU FCM AUTOSTART] FAIL: "+str(e))

if __name__=="__main__":
    main()
