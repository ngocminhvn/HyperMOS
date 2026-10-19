#!/usr/bin/env python3
"""Port MiCTS Xiaomi Home long-press hook into native system_server DEX."""
import argparse
import re
from pathlib import Path

OWNER = "Lcom/android/server/policy/MiuiSingleKeyRule;"
NAME = "MiuiSingleKeyRule.smali"
MARK = "# HYPERMOS_MICTS_HOME"

class PatchError(Exception):
    pass

def locate(root):
    files = list(root.glob("smali*/**/" + NAME))
    if len(files) != 1:
        raise PatchError(f"MiuiSingleKeyRule count={len(files)}")
    p = files[0]
    data = p.read_text()
    if not re.search(r"(?m)^\.class\s+[^\n]*" + re.escape(OWNER) + r"\s*$", data):
        raise PatchError("Wrong class descriptor")
    if not re.search(r"(?m)^\.field\s+[^\n]*\bmKeyCode:I(?:\s|$)", data):
        raise PatchError("No mKeyCode:I field")
    return p

def inject(lines, signature, params, snippet):
    pattern = re.compile(r"^\s*\.method\b.*\s" + re.escape(signature) + r"$")
    matches = [i for i,s in enumerate(lines) if pattern.match(s)]
    if len(matches) != 1:
        raise PatchError(f"{signature}: expected 1, found {len(matches)}")
    start = matches[0]
    if re.search(r"\b(?:static|native|abstract)\b",lines[start]):
        raise PatchError(f"Unexpected method modifiers: {signature}")
    end = next((i for i in range(start+1,len(lines)) if lines[i].strip()==".end method"), None)
    if end is None:
        raise PatchError("unterminated method " + signature)
    decl = next((i for i in range(start+1,end) if re.fullmatch(
        r"\s*\.(?:locals|registers)\s+\d+\s*", lines[i])), None)
    if decl is None:
        raise PatchError("register directive missing")
    m=re.fullmatch(r"\s*\.(locals|registers)\s+(\d+)\s*",lines[decl])
    style,count=m[1],int(m[2])
    minimum=1 if style=="locals" else params+1
    if count < minimum:
        if style=="registers":
            locals_before=count-params
            if locals_before<0 or any(
                int(n)>=locals_before for line in lines[decl+1:end]
                for n in re.findall(r"\bv(\d+)\b",line)
            ):
                raise PatchError("unsafe vN parameter alias expansion")
        lines[decl]=f"    .{style} {minimum}"
    lines[decl+1:decl+1]=snippet

HELPERS = '''
.method private hypermosMiCTSIsHome()Z
    .locals 2
    iget v0, p0, Lcom/android/server/policy/MiuiSingleKeyRule;->mKeyCode:I
    const/4 v1, 0x3
    if-ne v0, v1, :hmcts_not_home
    const/4 v0, 0x1
    return v0
    :hmcts_not_home
    const/4 v0, 0x0
    return v0
.end method

.method private hypermosMiCTSStart()Z
    .locals 5
    :try_start_hmcts
    const-string v0, "voiceinteraction"
    invoke-static {v0}, Landroid/os/ServiceManager;->getService(Ljava/lang/String;)Landroid/os/IBinder;
    move-result-object v0
    if-eqz v0, :hmcts_failed
    invoke-static {v0}, Lcom/android/internal/app/IVoiceInteractionManagerService$Stub;->asInterface(Landroid/os/IBinder;)Lcom/android/internal/app/IVoiceInteractionManagerService;
    move-result-object v0
    if-eqz v0, :hmcts_failed
    new-instance v1, Landroid/os/Bundle;
    invoke-direct {v1}, Landroid/os/Bundle;-><init>()V
    const-string v2, "omni.entry_point"
    const/4 v3, 0x1
    invoke-virtual {v1, v2, v3}, Landroid/os/Bundle;->putInt(Ljava/lang/String;I)V
    const/4 v2, 0x0
    const/4 v3, 0x7
    const-string v4, "hyperOS_home"
    invoke-interface {v0, v2, v1, v3, v4}, Lcom/android/internal/app/IVoiceInteractionManagerService;->showSessionFromSession(Landroid/os/IBinder;Landroid/os/Bundle;ILjava/lang/String;)Z
    move-result v0
    :try_end_hmcts
    .catch Ljava/lang/Exception; {:try_start_hmcts .. :try_end_hmcts} :catch_hmcts
    return v0
    :catch_hmcts
    move-exception v0
    :hmcts_failed
    const/4 v0, 0x0
    return v0
.end method
'''

def patch(root):
    p=locate(root)
    lines=p.read_text().splitlines()
    before="\n".join(lines)
    if MARK in before:
        if before.count(MARK)==2 and before.count(".method private hypermosMiCTSStart()Z")==1:
            return p,False
        raise PatchError("partial existing hook")
    if "hypermosMiCTS" in before:
        raise PatchError("conflicting hook helper")

    inject(lines,"onLongPress(J)V",3,[
        "    "+MARK+" onLongPress",
        f"    invoke-direct {{p0}}, {OWNER}->hypermosMiCTSIsHome()Z",
        "    move-result v0",
        "    if-eqz v0, :hmcts_stock_long",
        f"    invoke-direct {{p0}}, {OWNER}->hypermosMiCTSStart()Z",
        "    move-result v0",
        "    if-eqz v0, :hmcts_stock_long",
        "    return-void",
        "    :hmcts_stock_long",
    ])
    inject(lines,"supportLongPress()Z",1,[
        "    "+MARK+" supportLongPress",
        f"    invoke-direct {{p0}}, {OWNER}->hypermosMiCTSIsHome()Z",
        "    move-result v0",
        "    if-eqz v0, :hmcts_stock_support",
        "    const/4 v0, 0x1",
        "    return v0",
        "    :hmcts_stock_support",
    ])
    lines.extend(HELPERS.splitlines())
    data="\n".join(lines)+"\n"
    if data.count(MARK)!=2:
        raise PatchError("post-patch validation failed")
    p.write_text(data)
    return p,True

def main():
    arg=argparse.ArgumentParser()
    arg.add_argument("decoded",type=Path)
    arg.add_argument("--report",type=Path,required=True)
    a=arg.parse_args()
    try:
        f,modified=patch(a.decoded)
    except (PatchError,OSError) as e:
        print(f"[MiCTS Home][ERROR] {e}")
        return 1
    a.report.parent.mkdir(parents=True,exist_ok=True)
    a.report.write_text(
        f"MiCTS Home native keycode3\nsmali={f}\npatched={modified}\n"
        "fallback=stock_on_failure\nbackground_daemon=no\napk_patch=no\n")
    print(f"[MiCTS Home] {f}; changed={modified}")
    return 0

if __name__=="__main__":
    raise SystemExit(main())
