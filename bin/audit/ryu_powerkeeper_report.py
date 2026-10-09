#!/usr/bin/env python3
"""Report RYU PowerKeeper's notification mechanisms; no smali/code is exported."""
import argparse
import re
from pathlib import Path

def file_by_name(root, name):
    matches = list(root.rglob(name))
    return min(matches, key=lambda x: len(str(x))) if matches else None

def method_text(path, name):
    if path is None:
        return ""
    text = path.read_text(encoding="utf-8", errors="replace")
    for block in re.findall(r"(?ms)^\\.method\\s+.*?^\\.end method", text):
        if re.search(r"^\\.method[^\\n]*\\b" + re.escape(name) + r"\\(", block):
            return block
    return ""

def flag(value):
    return "**YES**" if value else "No"

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--smali", required=True, type=Path)
    p.add_argument("--output", required=True, type=Path)
    args = p.parse_args()
    root = args.smali
    millet = file_by_name(root, "MilletConfig.smali")
    kill = file_by_name(root, "KillProcessController.smali")
    observer = file_by_name(root, "GmsObserver.smali")
    app = file_by_name(root, "PowerKeeperApplication.smali")

    k = method_text(kill, "setUidState")
    g = method_text(observer, "isGmsControlEnabled")
    m = millet.read_text(encoding="utf-8", errors="replace") if millet else ""
    a = app.read_text(encoding="utf-8", errors="replace") if app else ""

    signals = [
        ("KillProcessController.setUidState present", bool(k),
         "Required for direct comparison with HyperMOS ZKOS kill suppression"),
        ("ProcessManager.kill still invoked", "ProcessManager;->kill(" in k,
         "HyperMOS removes this invocation"),
        ("Ignore-stop UID marker", "ignore stop uid=" in k,
         "HyperMOS logs 'ignore stop uid=' after ZKOS patch"),
        ("MilletConfig references IS_MIUI", "Lmiui/os/Build;->IS_MIUI:Z" in m,
         "HyperMOS replaces IS_INTERNATIONAL_BUILD with IS_MIUI"),
        ("MilletConfig references IS_INTERNATIONAL_BUILD",
         "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z" in m,
         "Stock branch condition in HyperMOS target"),
        ("GmsObserver.isGmsControlEnabled present", bool(g),
         "HyperMOS forces false only within this method"),
        ("GmsObserver hardcoded return false",
         bool(re.search(r"const/4\\s+v0,\\s*0x0.*?return\\s+v0", g, re.S)),
         "Heuristic: verify exact method logic before porting"),
        ("GMS MILLET key in PowerKeeperApplication",
         "MILLET_NO_RESTRICT_APP" in a,
         "HyperMOS writes this setting at Application.onCreate"),
        ("GMS package in PowerKeeperApplication",
         "com.google.android.gms" in a,
         "Check whether its whitelist is conditional or persistent"),
    ]
    lines = [
        "# RYUOS PowerKeeper Notification Fix audit",
        "",
        "These are disassembly *signals*, not a claim that the RYU patch is beneficial.",
        "HyperMOS A16 currently applies IS_MIUI MilletConfig, removes "
        "ProcessManager.kill in setUidState, disables GmsObserver's dedicated "
        "GMS controller, and enforces one GMS MILLET entry on start.",
        "",
        "| Check | RYU result | HyperMOS interpretation |",
        "|---|---|---|",
    ]
    for title, detected, comment in signals:
        lines.append(f"| {title} | {flag(detected)} | {comment} |")
    lines.extend(["", "## Relevant PowerKeeper class inventory", ""])
    matches = sorted(
        p for p in root.rglob("*.smali")
        if re.search(
            r"(?i)(millet|power|idle|wakelock|greezer|alarm|gms|"
            r"notification|killprocess|background|network)", p.name
        )
    )
    lines.append("Matched relevant classes: **" + str(len(matches)) + "**.")
    for path in matches[:100]:
        lines.append("- \`" + path.relative_to(root).as_posix() + "\`")
    lines.extend([
        "",
        "## Before adopting RYU behavior",
        "",
        "1. Determine which specific methods differ from *matching-version* Xiaomi stock.",
        "2. Do not copy entire RYU PowerKeeper.apk or replace unrelated Xiaomi policies.",
        "3. Assess battery/Doze/notification behavior with Messenger and Zalo.",
        "4. Do not add recurrent background loops or blanket wakelock/network exemptions.",
        "",
        "Note: RYUOS 3.0.309 versus the HyperMOS 3.0.308 base can introduce unrelated OEM changes.",
    ])
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("\n".join(lines)+"\n", encoding="utf-8")
    for title, val, _ in signals:
        print(f"{title}: {val}")
if __name__ == "__main__":
    main()
