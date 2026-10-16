#!/usr/bin/env python3
"""Port ZKOS A16 HAOTIAN JAR power-policy gates with TNM branding.

The source ZKOS miui-services JAR differs from the Xiaomi reference at
these power methods by replacing IS_INTERNATIONAL_BUILD with IS_ZK_BUILD.
For Greeze, its region comparison literal is ZK instead of CN.
Use the same instructions/branches with TNMBuild.IS_TNM_BUILD=true.
"""
from __future__ import annotations

from pathlib import Path
import re
import sys

FIELD = 'Lcom/android/tnm/TNMBuild;->IS_TNM_BUILD:Z'
LEGACY = re.compile(r'Lmiui/os/Build;->(?:IS_INTERNATIONAL_BUILD|IS_MIUI):Z')
METHOD = re.compile(r'(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$')
TARGETS = {
    'com/android/server/DeviceIdleControllerStubImpl.smali': ('<clinit>()V',),
    'com/android/server/am/ProcessManagerService.smali': ('isForceStopEnable(Lcom/android/server/am/ProcessRecord;I)Z',),
    'com/android/server/am/ProcessSceneCleaner.smali': (
        'handleSwipeKill(Lmiui/process/ProcessConfig;)Z',
        'killAppForHasOtherTask(ILmiui/process/ProcessConfig;)Z',
    ),
    'com/android/server/job/JobServiceContextImpl.smali': (
        'checkIfCancelJob(Lcom/android/server/job/JobServiceContext;Landroid/content/Context;Landroid/content/Intent;Landroid/content/Context$BindServiceFlags;Lcom/android/server/job/controllers/JobStatus;)Z',
    ),
}
BUILD_CLASS = """.class public final Lcom/android/tnm/TNMBuild;
.super Ljava/lang/Object;

.field public static final IS_TNM_BUILD:Z = true

.method private constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method
"""


def unique_file(root: Path, suffix: str) -> Path:
    hits = sorted(p for p in root.glob('smali*/' + suffix) if p.is_file())
    if len(hits) != 1:
        raise ValueError(f'{suffix}: expected one smali file, found {len(hits)}')
    return hits[0]


def replace_method(source: str, signature: str, transform) -> str:
    hits = [m for m in METHOD.finditer(source)
            if m.group().splitlines()[0].split()[-1] == signature]
    if len(hits) != 1:
        raise ValueError(f'{signature}: expected one method, got {len(hits)}')
    match = hits[0]
    return source[:match.start()] + transform(match.group()) + source[match.end():]


def field_port(body: str) -> str:
    """Change exactly the ZK source gate; never rewrite the surrounding flow."""
    if body.count(FIELD) == 1 and not LEGACY.search(body):
        return body
    stock = re.compile(r'(?m)^([ \t]*sget-boolean[ \t]+[vp]\d+,[ \t]+)'
                       r'Lmiui/os/Build;->(?:IS_INTERNATIONAL_BUILD|IS_MIUI):Z[ \t]*$')
    hits = list(stock.finditer(body))
    if len(hits) == 1:
        m = hits[0]
        return body[:m.start()] + m[1] + FIELD + body[m.end():]
    if hits:
        raise ValueError(f'Unexpected count of power build gates: {len(hits)}')
    # TNM/RYU A16 already folds some original build gates to true.
    marker = re.compile(
        r'(?m)^(?P<indent>[ \t]*)# (?P<name>TNM audited build gate|'
        r'HyperMOS TNM FGS: enable existing Xiaomi guard|'
        r'HyperMOS TNM swipe: enable original Xiaomi FGS guard)\s*\n'
        r'(?P=indent)const/4 (?P<reg>[vp]\d+), 0x1[ \t]*$')
    folded = list(marker.finditer(body))
    if len(folded) != 1:
        raise ValueError(f'Expected one original or TNM-folded build gate: {len(folded)}')
    m = folded[0]
    sub = (f'{m["indent"]}# TNM power build gate: original branch preserved\n'
           f'{m["indent"]}sget-boolean {m["reg"]}, {FIELD}')
    return body[:m.start()] + sub + body[m.end():]


def greeze_port(body: str) -> str:
    if re.search(r'(?m)^\s*const-string(?:/jumbo)?\s+[vp]\d+,\s*"TNM"\s*$', body):
        return body
    pattern = re.compile(r'(?m)^([ \t]*const-string(?:/jumbo)?\s+[vp]\d+,\s*)"CN"[ \t]*$')
    hits = list(pattern.finditer(body))
    if len(hits) != 1:
        raise ValueError(f'Greeze CN comparison must occur once, got {len(hits)}')
    m = hits[0]
    return body[:m.start()] + m[1] + '"TNM"' + body[m.end():]


def run(root: Path) -> None:
    if not root.is_dir():
        raise ValueError(f'Missing decoded miui-services JAR: {root}')
    pending = {}
    total = 0
    for cls, methods in TARGETS.items():
        path = unique_file(root, cls)
        source = path.read_text(encoding='utf-8')
        for signature in methods:
            source = replace_method(source, signature, field_port)
            total += 1
        pending[path] = source
    policy = unique_file(root, 'com/miui/server/greeze/PolicyManager.smali')
    pending[policy] = replace_method(
        policy.read_text(encoding='utf-8'), '<clinit>()V', greeze_port)
    total += 1

    bridge_candidates = list(root.rglob('TNMBuild.smali'))
    if bridge_candidates:
        if (len(bridge_candidates) != 1
                or bridge_candidates[0].read_text(encoding='utf-8') != BUILD_CLASS):
            raise ValueError('Conflicting TNMBuild class')
        bridge = bridge_candidates[0]
    else:
        if not (root / 'smali').is_dir():
            raise ValueError('Expected smali dir to add TNMBuild')
        bridge = root / 'smali/com/android/tnm/TNMBuild.smali'
    for path, data in pending.items():
        if 'Lmiui/zk/Build;' in data:
            raise ValueError(f'Unadapted ZK dependency: {path}')
    # Validate all targets before writing anything, fail fast on stock drift.
    for path, data in pending.items():
        path.write_text(data, encoding='utf-8')
    bridge.parent.mkdir(parents=True, exist_ok=True)
    bridge.write_text(BUILD_CLASS, encoding='utf-8')
    print(f'[TNM-ZK-POWER] {total} power method gates verified, '
          'TNMBuild.IS_TNM_BUILD=true; Greeze region=TNM')


if __name__ == '__main__':
    try:
        if len(sys.argv) != 2:
            raise ValueError('Usage: tnm_zk_power_a16.py <decoded-miui-services>')
        run(Path(sys.argv[1]))
    except (OSError, ValueError) as exc:
        print(f'[TNM-ZK-POWER] FAIL: {exc}', file=sys.stderr)
        sys.exit(1)
