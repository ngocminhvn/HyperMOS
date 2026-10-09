#!/usr/bin/env python3
"""Selective RYUOS HAOTIAN KillProcessController port, Android 16.

This is an instruction-level delta (not an APK transplant) verified against
the genuine Xiaomi and RYU PowerKeeper bytecode. It updates only:
  - setUidState(IZ)V: apply RYU's conditional UID process-kill policy
  - shouldKillByCheckerPolicy(I)Z: RYU's existing rule checker invocation
All other PowerKeeper classes/methods/resources are unchanged.
"""
from pathlib import Path
import hashlib
import json
import re
import sys

SOURCE_SHA = "03467d8b5f908d6382eb71378cd20009755c92a7262a40aee8afbb18b26e3840"
TARGET_SHA = "cf3fb92a974e35fa87bb94fcba03b7d444c6e3c3ce81f73f50d203374df6d7da"
HELPER_SHA = "ecf802cb7a6f79b77f144ce74eaf43fb489ea0b088b0b4f8c8657febf85d5262"
CLASS = "KillProcessController"
SIG = "setUidState(IZ)V"
HELPER_SIG = "shouldKillByCheckerPolicy(I)Z"
FIELD = ".field private mKillProcessAppRuleChecker:Lcom/miui/powerkeeper/PowerKeeperInterface$l;"
DELTA = json.loads(r'''[{"at":53,"remove":["move-result p2"],"insert":["move-result v3"]},{"at":56,"remove":["if-nez p2, :cond_4"],"insert":["if-nez v3, :cond_5"]},{"at":59,"remove":["move-result-object p2","invoke-interface {p2, p1}, Landroid/view/IWindowManager;->checkAppOnWindowsStatus(I)Z","move-result p2","if-eqz p2, :cond_2","new-instance p2, Ljava/lang/StringBuilder;","invoke-direct {p2}, Ljava/lang/StringBuilder;-><init>()V","const-string v3, \"calling ProcessManager killApplicationAlways, visible not kill uid = \"","invoke-virtual {p2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;","invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;","invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;","move-result-object p2","invoke-static {v2, p2}, Landroid/util/Slog;->i(Ljava/lang/String;Ljava/lang/String;)I"],"insert":["move-result-object v3","invoke-interface {v3, p1}, Landroid/view/IWindowManager;->checkAppOnWindowsStatus(I)Z","move-result v3","if-eqz v3, :cond_2","new-instance v3, Ljava/lang/StringBuilder;","invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V","const-string v4, \"calling ProcessManager killApplicationAlways, visible not kill uid = \"","invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;","invoke-virtual {v3, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;","invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;","move-result-object v3","invoke-static {v2, v3}, Landroid/util/Slog;->i(Ljava/lang/String;Ljava/lang/String;)I"]},{"at":75,"remove":["move-exception p2"],"insert":["move-exception v3"]},{"at":77,"remove":["new-instance v3, Ljava/lang/StringBuilder;","invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V","const-string v4, \"error : \"","invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;","invoke-virtual {v3, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;","invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;","move-result-object p2","invoke-static {v2, p2}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I"],"insert":["new-instance v4, Ljava/lang/StringBuilder;","invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V","const-string v5, \"error : \"","invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;","invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;","invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;","move-result-object v3","invoke-static {v2, v3}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;)I"]},{"at":86,"remove":["iget-object p2, p0, Lcom/miui/powerkeeper/controller/Controller;->mPowerKeeperManager:Lcom/miui/powerkeeper/PowerKeeperManager;","invoke-virtual {p2, v0}, Lcom/miui/powerkeeper/PowerKeeperManager;->getCurrentIME(I)I","move-result p2","if-ne p2, p1, :cond_3"],"insert":["iget-object v3, p0, Lcom/miui/powerkeeper/controller/Controller;->mPowerKeeperManager:Lcom/miui/powerkeeper/PowerKeeperManager;","invoke-virtual {v3, v0}, Lcom/miui/powerkeeper/PowerKeeperManager;->getCurrentIME(I)I","move-result v0","if-ne v0, p1, :cond_3"]},{"at":92,"remove":[],"insert":["invoke-direct {p0, p1}, Lcom/miui/powerkeeper/controller/KillProcessController;->shouldKillByCheckerPolicy(I)Z","move-result v0",":try_end_2",".catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_0","const-string v3, \" policy=\"","if-eqz v0, :cond_4",":try_start_3","new-instance v0, Lmiui/process/ProcessConfig;","const/16 v4, 0xd","invoke-direct {v0, v4, p2, p1}, Lmiui/process/ProcessConfig;-><init>(ILjava/lang/String;I)V","invoke-static {v0}, Lmiui/process/ProcessManager;->kill(Lmiui/process/ProcessConfig;)Z"]},{"at":95,"remove":[],"insert":["const-string v0, \"stop uid=\"","invoke-virtual {p2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;","invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;","invoke-virtual {p2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;","invoke-virtual {p2, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;","invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;","move-result-object p1","invoke-virtual {p0, p1}, Landroid/util/LocalLog;->log(Ljava/lang/String;)V","goto :goto_1",":cond_4","iget-object p0, p0, Lcom/miui/powerkeeper/controller/KillProcessController;->mHistoryLog:Landroid/util/LocalLog;","new-instance p2, Ljava/lang/StringBuilder;","invoke-direct {p2}, Ljava/lang/StringBuilder;-><init>()V"]},{"at":98,"remove":["const-string p1, \" policy=\"","invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;"],"insert":["invoke-virtual {p2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;"]},{"at":104,"remove":[":try_end_2",".catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_0"],"insert":[":try_end_3",".catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_0"]},{"at":110,"remove":[":cond_4"],"insert":[":cond_5"]}]''')
HELPER = r'''.method private shouldKillByCheckerPolicy(I)Z
    .locals 2
    const/4 v0, 0x0
    :try_start_0
    iget-object p0, p0, Lcom/miui/powerkeeper/controller/KillProcessController;->mKillProcessAppRuleChecker:Lcom/miui/powerkeeper/PowerKeeperInterface$l;
    if-nez p0, :cond_0
    return v0
    :cond_0
    invoke-interface {p0, p1}, Lcom/miui/powerkeeper/PowerKeeperInterface$l;->getUidPolicy(I)Landroid/os/Bundle;
    move-result-object p0
    if-eqz p0, :cond_3
    const-string p1, "POLICY"
    invoke-virtual {p0, p1, v0}, Landroid/os/Bundle;->getInt(Ljava/lang/String;I)I
    move-result p0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0
    const/4 p1, 0x1
    if-eq p0, p1, :cond_2
    const/4 v1, 0x2
    if-ne p0, v1, :cond_1
    goto :goto_0
    :cond_1
    return v0
    :cond_2
    :goto_0
    return p1
    :catch_0
    move-exception p0
    const-string p1, "PowerKeeper.KillControl"
    const-string v1, "shouldKillByCheckerPolicy error"
    invoke-static {p1, v1, p0}, Landroid/util/Slog;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :cond_3
    return v0
.end method'''


def canonical(method: str) -> list[str]:
    return [line.strip() for line in method.splitlines()
            if line.strip() and not line.lstrip().startswith(
                ("#", ".line", ".param", ".local", ".end local",
                 ".restart local", ".prologue"))]


def digest(tokens: list[str]) -> str:
    return hashlib.sha256("\n".join(tokens).encode("utf-8")).hexdigest()


def only_method(source: str, name: str):
    regex = re.compile(
        rf"(?ms)^\.method[^\n]*\s{re.escape(name)}\s*$.*?^\.end method\s*$"
    )
    results = list(regex.finditer(source))
    if len(results) != 1:
        raise ValueError(f"{name}: expected exactly one method, got {len(results)}")
    return results[0]


def build_method(tokens: list[str], locals_count: int) -> str:
    if not tokens[0].startswith(".method ") or tokens[-1] != ".end method":
        raise ValueError("Unexpected smali method delimiter")
    body = [tokens[0], f"    .locals {locals_count}"]
    for line in tokens[1:]:
        body.append(line if line.startswith((":")) or line == ".end method"
                    else "    " + line)
    return "\n".join(body)


def patch_class(source: str) -> str:
    if source.count(FIELD) != 1:
        raise ValueError("PowerKeeper rule checker field missing or duplicated")
    for call in ("PowerKeeperInterface$l;", "ProcessManager;->isLockedApplication",
                 "checkAppOnWindowsStatus"):
        if call not in source:
            raise ValueError(f"Missing expected Xiaomi KillProcessController dependency: {call}")
    m = only_method(source, SIG)
    before = canonical(m.group())
    h = digest(before)
    already_done = h == TARGET_SHA
    if not already_done and h != SOURCE_SHA:
        raise ValueError(f"Unknown Xiaomi setUidState layout SHA={h}; refusing patch")
    if already_done:
        post = source
    else:
        items = before.copy()
        for change in reversed(DELTA):
            i = change["at"]
            removed = change["remove"]
            if items[i:i + len(removed)] != removed:
                raise ValueError("Instruction delta hunk mismatch")
            items[i:i + len(removed)] = change["insert"]
        if digest(items) != TARGET_SHA:
            raise ValueError("Unexpected post-patch instructions (RYU parity failed)")
        post = source[:m.start()] + build_method(items, 6) + source[m.end():]
    found = re.findall(r"(?m)^\.method[^\n]*shouldKillByCheckerPolicy\(I\)Z\s*$", post)
    if len(found) == 0:
        if digest(canonical(HELPER)) != HELPER_SHA:
            raise ValueError("Bundled checker method differs from verified RYU")
        post = post.rstrip() + "\n\n" + HELPER + "\n"
    elif len(found) == 1:
        h = only_method(post, HELPER_SIG)
        if digest(canonical(h.group())) != HELPER_SHA:
            raise ValueError("Unexpected pre-existing checker implementation")
    else:
        raise ValueError("Duplicate checker methods")
    if digest(canonical(only_method(post, SIG).group())) != TARGET_SHA:
        raise ValueError("setUidState no longer matches RYU after patch")
    if post.count("->shouldKillByCheckerPolicy(I)Z") != 1:
        raise ValueError("Expected one RYU checker invocation")
    set_uid = only_method(post, SIG).group()
    if set_uid.count("Lmiui/process/ProcessManager;->kill(") != 1:
        raise ValueError("Expected exactly one RYU conditional UID kill call")
    return post


def main(root: Path):
    paths = list(root.rglob(CLASS + ".smali"))
    if len(paths) != 1:
        raise ValueError(f"{CLASS}: expected exactly one class, got {len(paths)}")
    file = paths[0]
    original = file.read_text(encoding="utf-8")
    patched = patch_class(original)
    if patch_class(patched) != patched:
        raise ValueError("Non-idempotent RYU kill policy")
    if patched != original:
        file.write_text(patched, encoding="utf-8")
    print("[RYU-A16-KILL] setUidState and shouldKillByCheckerPolicy matched RYU method hashes")
    print("[RYU-A16-KILL] Restricts UID kill to checker POLICY 1 or 2; missing checker => no kill")


if __name__ == "__main__":
    try:
        if len(sys.argv) != 2:
            raise ValueError("Usage: ryu_killprocess_a16.py <decompiled-PowerKeeper-APK>")
        main(Path(sys.argv[1]))
    except (ValueError, OSError) as err:
        print(f"[RYU-A16-KILL] FAIL: {err}", file=sys.stderr)
        sys.exit(1)
