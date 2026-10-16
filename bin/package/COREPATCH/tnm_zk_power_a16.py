#!/usr/bin/env python3
"""Faithful ZKOS HAOTIAN A16 JAR power and notification delta, renamed ZK -> TNM.

The original uploaded ZK miui-services.jar differs from the Xiaomi reference in
exactly twelve normalized target methods: ten IS_INTERNATIONAL_BUILD -> IS_ZK_BUILD
field reads, the NotificationManagerServiceImpl static initialization (removal
of the build-field assignment), and Greeze PolicyManager's CN -> ZK region literal.
No other Xiaomi methods or unrelated policy areas are changed by this patch.
"""
from pathlib import Path
import re
import sys

METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
ZK_FIELD = "Lcom/android/tnm/TNMBuild;->IS_TNM_BUILD:Z"
OLD_FIELD = r"Lmiui/os/Build;->(?:IS_INTERNATIONAL_BUILD|IS_MIUI):Z"
ZK_METHODS = {
    "com/android/server/DeviceIdleControllerStubImpl.smali": (
        "<clinit>()V",),
    "com/android/server/am/BroadcastQueueModernStubImpl.smali": (
        "checkApplicationAutoStart(Lcom/android/server/am/BroadcastQueue;Lcom/android/server/am/BroadcastRecord;Landroid/content/pm/ResolveInfo;)Z",
        "checkReceiverAppDealBroadcast(Lcom/android/server/am/BroadcastQueue;Lcom/android/server/am/BroadcastRecord;Lcom/android/server/am/ProcessRecord;Z)Z",
        "isInternationalSpecialAction(Ljava/lang/String;Landroid/content/pm/ResolveInfo;)Z",
        "updateBlockBroadcast()V",
    ),
    "com/android/server/am/ProcessManagerService.smali": (
        "isForceStopEnable(Lcom/android/server/am/ProcessRecord;I)Z",),
    "com/android/server/am/ProcessSceneCleaner.smali": (
        "handleSwipeKill(Lmiui/process/ProcessConfig;)Z",
        "killAppForHasOtherTask(ILmiui/process/ProcessConfig;)Z",
    ),
    "com/android/server/job/JobServiceContextImpl.smali": (
        "checkIfCancelJob(Lcom/android/server/job/JobServiceContext;Landroid/content/Context;Landroid/content/Intent;Landroid/content/Context$BindServiceFlags;Lcom/android/server/job/controllers/JobStatus;)Z",),
    "com/android/server/notification/NotificationManagerServiceImpl.smali": (
        "checkFullScreenIntent(Landroid/app/Notification;Landroid/app/AppOpsManager;ILjava/lang/String;)V",),
}
BRIDGE = """.class public final Lcom/android/tnm/TNMBuild;
.super Ljava/lang/Object;

.field public static final IS_TNM_BUILD:Z = true

.method private constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method
"""


def one(root: Path, suffix: str) -> Path:
    paths = sorted(p for p in root.glob("smali*/" + suffix) if p.is_file())
    if len(paths) != 1:
        raise ValueError(f"{suffix}: expected one definition; found {len(paths)}")
    return paths[0]


def transform(source: str, signature: str, fn) -> str:
    matches = [m for m in METHOD.finditer(source)
               if m.group().splitlines()[0].split()[-1] == signature]
    if len(matches) != 1:
        raise ValueError(f"{signature}: unexpected method count {len(matches)}")
    match = matches[0]
    patched = fn(match.group())
    return source[:match.start()] + patched + source[match.end():]


def port_field(body: str) -> str:
    if body.count(ZK_FIELD) == 1 and not re.search(OLD_FIELD, body):
        return body
    gate = re.compile(
        rf"(?m)^([ \t]*sget-boolean[ \t]+[vp]\d+,[ \t]+){OLD_FIELD}[ \t]*$")
    matches = list(gate.finditer(body))
    if len(matches) != 1:
        raise ValueError(
            f"ZK power/notification method: expected one stock build field, "
            f"found {len(matches)}; refusing guessed bytecode")
    m = matches[0]
    return body[:m.start()] + m[1] + ZK_FIELD + body[m.end():]


def notification_static(body: str) -> str:
    # The uploaded ZK JAR removes only the two instructions that initialized
    # IS_INTERNATIONAL_BUILD; source debug .line comments can be interleaved.
    read_pat = re.compile(
        rf"(?m)^[ \t]*sget-boolean[ \t]+(?P<reg>[vp]\d+),[ \t]+"
        rf"{OLD_FIELD}[ \t]*$")
    write_pat = re.compile(
        r"(?m)^[ \t]*sput-boolean[ \t]+(?P<reg>[vp]\d+),[ \t]+"
        r"Lcom/android/server/notification/NotificationManagerServiceImpl;"
        r"->IS_INTERNATIONAL_BUILD:Z[ \t]*$")
    reads = list(read_pat.finditer(body))
    writes = list(write_pat.finditer(body))
    if not reads and not writes:
        return body
    if len(reads) != 1 or len(writes) != 1 or reads[0]["reg"] != writes[0]["reg"]:
        raise ValueError("NotificationManagerServiceImpl.<clinit>: ambiguous build field")
    middle = body[reads[0].end():writes[0].start()]
    # Debug directives are okay; actual instructions/control flow are not.
    if reads[0].end() > writes[0].start() or any(
        line.strip() and not line.strip().startswith((".", "#"))
        for line in middle.splitlines()
    ):
        raise ValueError("Notification initializer build read/write not adjacent")
    # Remove instructions in descending offset order; preserve all debug lines.
    result = body
    for m in sorted([reads[0], writes[0]], key=lambda x: x.start(), reverse=True):
        result = result[:m.start()] + result[m.end():]
    return result


def greeze_static(body: str) -> str:
    needle = re.compile(
        r'(?m)^([ \t]*const-string(?:/jumbo)?[ \t]+[vp]\d+,[ \t]+)"CN"[ \t]*$')
    hits = list(needle.finditer(body))
    if len(hits) == 0 and re.search(
        r'(?m)^[ \t]*const-string(?:/jumbo)?[ \t]+[vp]\d+,[ \t]+"TNM"[ \t]*
    ):
        return body
    if len(hits) != 1:
        raise ValueError(
            f"PolicyManager.<clinit>: expected one CN region literal, found {len(hits)}")
    m = hits[0]
    return body[:m.start()] + m[1] + '"TNM"' + body[m.end():]


def run(root: Path):
    if not root.is_dir():
        raise ValueError(f"JAR smali folder not found: {root}")
    pending = {}
    count = 0
    for suffix, signatures in ZK_METHODS.items():
        path = one(root, suffix)
        source = path.read_text(encoding="utf-8")
        for signature in signatures:
            source = transform(source, signature, port_field)
            count += 1
        pending[path] = source
    nm = one(root, "com/android/server/notification/NotificationManagerServiceImpl.smali")
    pending[nm] = transform(
        pending.get(nm, nm.read_text(encoding="utf-8")),
        "<clinit>()V", notification_static)
    greeze = one(root, "com/miui/server/greeze/PolicyManager.smali")
    pending[greeze] = transform(
        greeze.read_text(encoding="utf-8"), "<clinit>()V", greeze_static)

    bridge = root / "smali/com/android/tnm/TNMBuild.smali"
    bridge_instances = list(root.rglob("TNMBuild.smali"))
    if bridge_instances and (len(bridge_instances) != 1 or
                             bridge_instances[0] != bridge or
                             bridge.read_text(encoding="utf-8") != BRIDGE):
        raise ValueError("Conflicting/duplicate TNMBuild implementation")
    if not (root / "smali").is_dir():
        raise ValueError("Missing primary smali directory for TNMBuild")

    # All checks pass before first write; fail closed if the target ROM drifts.
    for path, content in pending.items():
        path.write_text(content, encoding="utf-8")
    bridge.parent.mkdir(parents=True, exist_ok=True)
    bridge.write_text(BRIDGE, encoding="utf-8")
    print(f"[TNM-ZKOS] {count} exact ZK field gates, 1 notification initializer, "
          "1 Greeze region constant; only ZK naming adapted to TNM")


if __name__ == "__main__":
    try:
        if len(sys.argv) != 2:
            raise ValueError("Usage: tnm_zk_power_a16.py <decompiled-miui-services>")
        run(Path(sys.argv[1]))
    except (ValueError, OSError) as exc:
        print(f"[TNM-ZKOS] FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
, body
    ):
        return body
    if len(hits) != 1:
        raise ValueError(
            f"PolicyManager.<clinit>: expected one CN region literal, found {len(hits)}")
    m = hits[0]
    return body[:m.start()] + m[1] + '"TNM"' + body[m.end():]


def run(root: Path):
    if not root.is_dir():
        raise ValueError(f"JAR smali folder not found: {root}")
    pending = {}
    count = 0
    for suffix, signatures in ZK_METHODS.items():
        path = one(root, suffix)
        source = path.read_text(encoding="utf-8")
        for signature in signatures:
            source = transform(source, signature, port_field)
            count += 1
        pending[path] = source
    nm = one(root, "com/android/server/notification/NotificationManagerServiceImpl.smali")
    pending[nm] = transform(
        pending.get(nm, nm.read_text(encoding="utf-8")),
        "<clinit>()V", notification_static)
    greeze = one(root, "com/miui/server/greeze/PolicyManager.smali")
    pending[greeze] = transform(
        greeze.read_text(encoding="utf-8"), "<clinit>()V", greeze_static)

    bridge = root / "smali/com/android/tnm/TNMBuild.smali"
    bridge_instances = list(root.rglob("TNMBuild.smali"))
    if bridge_instances and (len(bridge_instances) != 1 or
                             bridge_instances[0] != bridge or
                             bridge.read_text(encoding="utf-8") != BRIDGE):
        raise ValueError("Conflicting/duplicate TNMBuild implementation")
    if not (root / "smali").is_dir():
        raise ValueError("Missing primary smali directory for TNMBuild")

    # All checks pass before first write; fail closed if the target ROM drifts.
    for path, content in pending.items():
        path.write_text(content, encoding="utf-8")
    bridge.parent.mkdir(parents=True, exist_ok=True)
    bridge.write_text(BRIDGE, encoding="utf-8")
    print(f"[TNM-ZKOS] {count} exact ZK field gates, 1 notification initializer, "
          "1 Greeze region constant; only ZK naming adapted to TNM")


if __name__ == "__main__":
    try:
        if len(sys.argv) != 2:
            raise ValueError("Usage: tnm_zk_power_a16.py <decompiled-miui-services>")
        run(Path(sys.argv[1]))
    except (ValueError, OSError) as exc:
        print(f"[TNM-ZKOS] FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
, body
    ):
        return body
    if len(hits) != 1:
        raise ValueError(
            f"PolicyManager.<clinit>: expected one CN region literal, found {len(hits)}")
    m = hits[0]
    return body[:m.start()] + m[1] + '"TNM"' + body[m.end():]


def run(root: Path):
    if not root.is_dir():
        raise ValueError(f"JAR smali folder not found: {root}")
    pending = {}
    count = 0
    for suffix, signatures in ZK_METHODS.items():
        path = one(root, suffix)
        source = path.read_text(encoding="utf-8")
        for signature in signatures:
            source = transform(source, signature, port_field)
            count += 1
        pending[path] = source
    nm = one(root, "com/android/server/notification/NotificationManagerServiceImpl.smali")
    pending[nm] = transform(
        pending.get(nm, nm.read_text(encoding="utf-8")),
        "<clinit>()V", notification_static)
    greeze = one(root, "com/miui/server/greeze/PolicyManager.smali")
    pending[greeze] = transform(
        greeze.read_text(encoding="utf-8"), "<clinit>()V", greeze_static)

    bridge = root / "smali/com/android/tnm/TNMBuild.smali"
    bridge_instances = list(root.rglob("TNMBuild.smali"))
    if bridge_instances and (len(bridge_instances) != 1 or
                             bridge_instances[0] != bridge or
                             bridge.read_text(encoding="utf-8") != BRIDGE):
        raise ValueError("Conflicting/duplicate TNMBuild implementation")
    if not (root / "smali").is_dir():
        raise ValueError("Missing primary smali directory for TNMBuild")

    # All checks pass before first write; fail closed if the target ROM drifts.
    for path, content in pending.items():
        path.write_text(content, encoding="utf-8")
    bridge.parent.mkdir(parents=True, exist_ok=True)
    bridge.write_text(BRIDGE, encoding="utf-8")
    print(f"[TNM-ZKOS] {count} exact ZK field gates, 1 notification initializer, "
          "1 Greeze region constant; only ZK naming adapted to TNM")


if __name__ == "__main__":
    try:
        if len(sys.argv) != 2:
            raise ValueError("Usage: tnm_zk_power_a16.py <decompiled-miui-services>")
        run(Path(sys.argv[1]))
    except (ValueError, OSError) as exc:
        print(f"[TNM-ZKOS] FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
, body
    ):
        return body
    if len(hits) != 1:
        raise ValueError(
            f"PolicyManager.<clinit>: expected one CN region literal, found {len(hits)}")
    m = hits[0]
    return body[:m.start()] + m[1] + '"TNM"' + body[m.end():]


def run(root: Path):
    if not root.is_dir():
        raise ValueError(f"JAR smali folder not found: {root}")
    pending = {}
    count = 0
    for suffix, signatures in ZK_METHODS.items():
        path = one(root, suffix)
        source = path.read_text(encoding="utf-8")
        for signature in signatures:
            source = transform(source, signature, port_field)
            count += 1
        pending[path] = source
    nm = one(root, "com/android/server/notification/NotificationManagerServiceImpl.smali")
    pending[nm] = transform(
        pending.get(nm, nm.read_text(encoding="utf-8")),
        "<clinit>()V", notification_static)
    greeze = one(root, "com/miui/server/greeze/PolicyManager.smali")
    pending[greeze] = transform(
        greeze.read_text(encoding="utf-8"), "<clinit>()V", greeze_static)

    bridge = root / "smali/com/android/tnm/TNMBuild.smali"
    bridge_instances = list(root.rglob("TNMBuild.smali"))
    if bridge_instances and (len(bridge_instances) != 1 or
                             bridge_instances[0] != bridge or
                             bridge.read_text(encoding="utf-8") != BRIDGE):
        raise ValueError("Conflicting/duplicate TNMBuild implementation")
    if not (root / "smali").is_dir():
        raise ValueError("Missing primary smali directory for TNMBuild")

    # All checks pass before first write; fail closed if the target ROM drifts.
    for path, content in pending.items():
        path.write_text(content, encoding="utf-8")
    bridge.parent.mkdir(parents=True, exist_ok=True)
    bridge.write_text(BRIDGE, encoding="utf-8")
    print(f"[TNM-ZKOS] {count} exact ZK field gates, 1 notification initializer, "
          "1 Greeze region constant; only ZK naming adapted to TNM")


if __name__ == "__main__":
    try:
        if len(sys.argv) != 2:
            raise ValueError("Usage: tnm_zk_power_a16.py <decompiled-miui-services>")
        run(Path(sys.argv[1]))
    except (ValueError, OSError) as exc:
        print(f"[TNM-ZKOS] FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
