#!/usr/bin/env python3
"""Global303/Taiwan303 NotificationFilterHelper, exact two method EU port.

Global/TW: 3 blockable Xiaomi packages, 8 forced-on core packages, XMSF
all-channel guard; EU lacks these initializers and unconditionally returns true.
No modifications to GMS wakelocks, FCM socket, third-party notification policy.
"""
import argparse
import json
import re
from pathlib import Path

CLS = "Lmiui/util/NotificationFilterHelper;"
PATH = "miui/util/NotificationFilterHelper.smali"
SIG = "canSystemNotificationBeBlocked(Ljava/lang/String;)Z"
RX = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
BLOCKABLE = ("com.miui.fm", "com.miui.antispam", "com.miui.securitycenter")
FORCED = ("android", "com.android.incallui", "com.android.deskclock",
          "com.android.mms", "com.android.bluetooth", "com.android.updater",
          "com.android.providers.downloads", "com.miui.hybrid")
def parsed(src):
    out = {}
    for m in RX.finditer(src):
        sig = m.group().splitlines()[0].split()[-1]
        if sig in out: raise ValueError("duplicate method " + sig)
        out[sig] = m.group()
    return out

def rewrite(src, sig, fn):
    matched = [m for m in RX.finditer(src) if m.group().splitlines()[0].endswith(" " + sig)]
    if len(matched) != 1: raise ValueError("missing/duplicate method " + sig)
    m = matched[0]
    return src[:m.start()] + fn(m.group()) + src[m.end():]

def patch(src):
    if not re.search(r"(?m)^\.class[^\n]*" + re.escape(CLS) + r"\s*$", src):
        raise ValueError("not original NotificationFilterHelper")
    if len(re.findall(r"(?m)^\.field[^\n]*sNotificationCanBeBlockedList:Ljava/util/HashSet;", src)) != 1:
        raise ValueError("blockable field does not exist")
    before = parsed(src)
    if "<clinit>()V" not in before or SIG not in before:
        raise ValueError("required methods missing")
    def init(block):
        needed = ("sIsSystemApp:Ljava/util/HashMap;",
                  "sNotificationForcedEnabledPkgList:Ljava/util/HashSet;",
                  "sNotificationForcedEnabledAllChannelList:Ljava/util/HashSet;",
                  "sNotificationForcedEnabledChannelList:Ljava/util/HashMap;",
                  "sNotificationCannotSetImportanceList:Ljava/util/HashSet;")
        if not re.search(r"(?m)^\s*\.registers\s+14\s*$", block):
            raise ValueError("EU clinit register layout changed")
        if "sNotificationCanBeBlockedList" in block or any(block.count(f) != 1 for f in needed):
            raise ValueError("unexpected EU initializer or already patched")
        anchor = "    sput-object v0, " + CLS + "->sIsSystemApp:Ljava/util/HashMap;"
        if block.count(anchor) != 1 or block.count("    return-void") != 1:
            raise ValueError("initializer anchor changed")
        addition = ("\n    new-instance v0, Ljava/util/HashSet;\n"
                    "    invoke-direct {v0}, Ljava/util/HashSet;-><init>()V\n"
                    "    sput-object v0, " + CLS + "->sNotificationCanBeBlockedList:Ljava/util/HashSet;")
        block = block.replace(anchor, anchor + addition, 1)
        def add(field, name, reg):
            return ("    sget-object v0, " + CLS + "->" + field + ":Ljava/util/HashSet;\n"
                    '    const-string ' + reg + ', "' + name + '"\n'
                    "    invoke-virtual {v0, " + reg +
                    "}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z\n")
        tail = "\n"
        for p in BLOCKABLE: tail += add("sNotificationCanBeBlockedList", p, "v1")
        for i,p in enumerate(FORCED): tail += add("sNotificationForcedEnabledPkgList", p, "v2" if i == 0 else "v3")
        tail += add("sNotificationForcedEnabledAllChannelList", "com.xiaomi.xmsf", "v3")
        tail += ("    new-instance v0, Ljava/util/HashSet;\n"
                 "    invoke-direct {v0}, Ljava/util/HashSet;-><init>()V\n"
                 "    invoke-virtual {v0, v1}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z\n"
                 "    sget-object v3, " + CLS + "->sNotificationForcedEnabledChannelList:Ljava/util/HashMap;\n"
                 "    invoke-virtual {v3, v1, v0}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;\n"
                 "    sget-object v1, " + CLS + "->sNotificationCannotSetImportanceList:Ljava/util/HashSet;\n"
                 "    invoke-virtual {v1, v2}, Ljava/util/HashSet;->add(Ljava/lang/Object;)Z\n")
        if not re.search(r"(?m)^    return-void\n\.end method\s*$", block):
            raise ValueError("unexpected clinit tail")
        return re.sub(r"(?m)^    return-void\n\.end method\s*$",
                      lambda m: tail + m.group(), block, count=1)
    result = rewrite(src, "<clinit>()V", init)
    def can_block(block):
        if "sNotificationCanBeBlockedList" in block or not re.search(
            r"(?m)^\s*const/4\s+v0,\s*0x1\s*$", block
        ):
            raise ValueError("unexpected EU notification blocking method")
        return (block.splitlines()[0] + "\n    .registers 2\n"
                "    sget-object v0, " + CLS + "->sNotificationCanBeBlockedList:Ljava/util/HashSet;\n"
                "    invoke-virtual {v0, p0}, Ljava/util/HashSet;->contains(Ljava/lang/Object;)Z\n"
                "    move-result v0\n    return v0\n.end method")
    result = rewrite(result, SIG, can_block)
    after = parsed(result)
    if set(before) != set(after) or any(before[k] != after[k] for k in before if k not in ("<clinit>()V", SIG)):
        raise ValueError("unrelated methods modified")
    verify(result)
    return result

def verify(src):
    methods = parsed(src)
    a,b=methods.get("<clinit>()V",""),methods.get(SIG,"")
    if "->sNotificationCanBeBlockedList:Ljava/util/HashSet;" not in a or "->sNotificationCanBeBlockedList:Ljava/util/HashSet;" not in b:
        raise ValueError("Global filter not present")
    for p in (*BLOCKABLE, *FORCED, "com.xiaomi.xmsf"):
        if a.count('"'+p+'"') != 1: raise ValueError("missing/duplicate forced package " + p)
    if "->contains(Ljava/lang/Object;)Z" not in b:
        raise ValueError("Global canBlock policy not present")
    return {"class": PATH, "methods": ["<clinit>()V", SIG],
            "forced_packages": list(FORCED), "xmsf_all_channels": True}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", type=Path, required=True)
    ap.add_argument("--verify", action="store_true")
    ap.add_argument("--report", type=Path)
    args = ap.parse_args()
    files = list(args.root.rglob(PATH))
    if len(files) != 1: raise ValueError("Expected one NotificationFilterHelper")
    path=files[0]
    if args.verify: report=verify(path.read_text(encoding="utf-8"))
    else:
        result=patch(path.read_text(encoding="utf-8"))
        path.write_text(result, encoding="utf-8")
        report=verify(result)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report,indent=2)+"\n",encoding="utf-8")
    print("[EU GLOBAL/TW FILTER] " + json.dumps(report))

if __name__ == "__main__":
    try: main()
    except (ValueError,OSError) as e:
        raise SystemExit("[EU GLOBAL/TW FILTER] FAIL: "+str(e))
