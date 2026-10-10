#!/usr/bin/env python3
"""Test branch only: port original RYU PerfHook from supplied RYU PowerKeeper smali.

Performs dependency closure and a guarded one-time activation in Xiaomi's
PowerKeeperApplication. ROM thermal/charging/boot files are NOT touched.
Original RYU bytecode stays in temporary GitHub Actions runner, not the repo.
"""
import argparse
import json
import re
from pathlib import Path

CLASS = re.compile(r'(?m)^\.class\b[^\n]*?\s(L[^;\s]+;)\s*$')
ONCREATE = re.compile(r'(?ms)^\.method\b[^\n]*\bonCreate\(\)V\s*$.*?^\.end method\s*$')
PRIVATE = re.compile(r'L(?:com/projectryu|com/miui/powerkeeper)/[^;\s]+;')
PERF = 'Lcom/projectryu/perf/PerfHook'
CALL = ('Lcom/projectryu/perf/PerfHook;->getInstance'
        '(Landroid/content/Context;)Lcom/projectryu/perf/PerfHook;')
APP = 'Lcom/miui/powerkeeper/PowerKeeperApplication;'

# RYU framework's getSystemString(ContentResolver, String) ultimately
# delegates to Settings.System.getString. The foreign framework class is
# NOT present in Xiaomi stock; port only this exact verified entrypoint.
RYU_SETTING = ('Lcom/projectryu/ProjectRYUFramework;->getSystemString'
               '(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;')
ANDROID_SETTING = ('Landroid/provider/Settings$System;->getString'
                   '(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;')
FOREIGN_CLASS = 'Lcom/projectryu/ProjectRYUFramework;'


def compatible_smali(body):
    if FOREIGN_CLASS not in body:
        return body
    if body.count(RYU_SETTING) != 1 or FOREIGN_CLASS in body.replace(RYU_SETTING, ''):
        raise ValueError('Unexpected external RYU framework dependency in PerfHook')
    return body.replace(RYU_SETTING, ANDROID_SETTING)


def index(root):
    found = {}
    for f in root.glob('smali*/**/*.smali'):
        body = f.read_text(encoding='utf-8', errors='replace')
        m = CLASS.search(body)
        if m:
            if m.group(1) in found:
                raise ValueError('Duplicate class: ' + m.group(1))
            found[m.group(1)] = (f, body)
    return found


def app_method(classes):
    if APP not in classes:
        raise ValueError('PowerKeeperApplication not found')
    path, body = classes[APP]
    methods = list(ONCREATE.finditer(body))
    if len(methods) != 1:
        raise ValueError('Expected exactly one Application.onCreate()')
    return path, body, methods[0]


def dependency_closure(source, stock):
    initial = sorted(c for c in source
                     if c == PERF + ';' or c.startswith(PERF + '$'))
    if len(initial) < 17:
        raise ValueError('Incomplete RYU PerfHook family: ' + str(len(initial)))
    if any(c in stock for c in initial):
        raise ValueError('Stock contains PerfHook; refuse duplicate')
    selected = set(initial)
    queue = initial.copy()
    while queue:
        parent = queue.pop()
        for ref in PRIVATE.findall(compatible_smali(source[parent][1])):
            if ref in selected:
                continue
            if ref.startswith('Lcom/projectryu/') and ref not in stock:
                if ref not in source:
                    raise ValueError('Missing RYU dependency ' + ref)
                selected.add(ref)
                queue.append(ref)
            elif ref.startswith('Lcom/miui/powerkeeper/') and (
                    ref in source and ref not in stock):
                raise ValueError('RYU-only Xiaomi PowerKeeper dependency: ' + ref)
    if len(selected) > 32:
        raise ValueError('Unexpected dependency closure too large')
    return sorted(selected)


def prepare(source_root, stock_root):
    source, stock = index(source_root), index(stock_root)
    selected = dependency_closure(source, stock)
    _, _, source_oncreate = app_method(source)
    ryu_method = source_oncreate.group()
    # Actual RYUOS HAOTIAN dex: getInstance(Context) followed by init()V.
    # Do not mistake retrieving the singleton for starting its worker.
    calls = re.findall(
        r'invoke-\w+(?:/range)?\s+\{[^}]*\},\s*'
        r'Lcom/projectryu/perf/PerfHook;->[^\n]+', ryu_method)
    if (len(calls) != 2 or 'getInstance' not in calls[0]
            or '->init()V' not in calls[1]):
        raise ValueError('RYU original startup differs: ' + repr(calls))
    if not re.search(r'invoke-static\s+\{[vp]\d+\},\s*' +
                     re.escape(CALL), calls[0]):
        raise ValueError('RYU getInstance(Context) call missing')
    if not re.search(r'invoke-virtual\s+\{[vp]\d+\},\s*'
                     r'Lcom/projectryu/perf/PerfHook;->init\(\)V', calls[1]):
        raise ValueError('RYU instance init() call missing')
    if 'Lcom/projectryu/perf/PerfHook;->init()V' not in source[PERF + ';'][1]:
        # The method definition has no owner descriptor; the check below
        # verifies the actual declared method instead.
        if not re.search(r'(?m)^\.method\b[^\n]*\binit\(\)V\s*$',
                         source[PERF + ';'][1]):
            raise ValueError('RYU PerfHook.init()V implementation missing')
    app_path, app_src, stock_oncreate = app_method(stock)
    block = stock_oncreate.group()
    helper = 'hypermosInitRyuPerfHook'
    if CALL in block or helper in app_src:
        raise ValueError('PerfHook already integrated into stock Application')
    # Original RYU onCreate starts PerfHook at the tail, after PowerKeeper
    # has initialized its own controllers. Avoid starting it right after super.
    supercall = re.search(
        r'(?m)^[ \t]*invoke-super(?:/range)?\s+\{p0\},\s*L[^;]+;->onCreate\(\)V',
        block)
    returns = list(re.finditer(r'(?m)^[ \t]*return-void[ \t]*$', block))
    if not supercall or len(returns) != 1:
        raise ValueError('Unexpected stock PowerKeeperApplication onCreate layout')
    helper_call = (
        '    # RYU PerfHook: start after the other PowerKeeper components\n'
        '    invoke-direct {p0}, ' + APP + '->' + helper + '()V\n'
    )
    new_method = block[:returns[0].start()] + helper_call + block[returns[0].start():]
    extra_method = (
        '\n.method private ' + helper + '()V\n'
        '    .locals 1\n\n'
        '    invoke-static {p0}, ' + CALL + '\n'
        '    move-result-object v0\n'
        '    invoke-virtual {v0}, Lcom/projectryu/perf/PerfHook;->init()V\n'
        '    return-void\n'
        '.end method\n'
    )
    new_app = (app_src[:stock_oncreate.start()] + new_method +
               app_src[stock_oncreate.end():]).rstrip() + '\n' + extra_method
    dex_nums = [1 if f.name == 'smali' else int(f.name.removeprefix('smali_classes'))
                for f in stock_root.iterdir() if f.is_dir() and
                (f.name == 'smali' or re.fullmatch(r'smali_classes\d+', f.name))]
    if not dex_nums:
        raise ValueError('Missing stock smali directories')
    extra_dex = stock_root / ('smali_classes' + str(max(dex_nums) + 1))
    return source, selected, app_path, new_app, extra_dex, ' -> '.join(calls)



def main():
    p = argparse.ArgumentParser()
    p.add_argument('--ryu', required=True, type=Path)
    p.add_argument('--stock', required=True, type=Path)
    p.add_argument('--report', required=True, type=Path)
    p.add_argument('--dry-run', action='store_true')
    args = p.parse_args()
    src, classes, app_path, app_body, new_dex, original_call = prepare(args.ryu, args.stock)
    report = dict(class_count=len(classes), classes=classes,
                  source_activation=original_call, new_dex=new_dex.name,
                  runtime='original RYU PerfHook, from user-provided source APK',
                  thermal_profiles_unchanged=True)
    if not args.dry_run:
        if new_dex.exists():
            raise ValueError('New dex destination unexpectedly exists')
        for cls in classes:
            input_file = src[cls][0]
            target = new_dex / (cls[1:-1] + '.smali')
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(compatible_smali(src[cls][1]), encoding='utf-8')
        app_path.write_text(app_body, encoding='utf-8')
        installed = index(args.stock)
        if any(c not in installed for c in classes):
            raise ValueError('Post-installation class verification failed')
        app_text = installed[APP][1]
        if app_text.count(CALL) != 1 or app_text.count('PerfHook;->init()V') != 1:
            raise ValueError('Post-installation getInstance/init invocation missing/duplicated')
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    print(f'[RYU PERFHOOK] {len(classes)} original classes; init site: {original_call}')
    print('[RYU PERFHOOK] '+('STATIC CHECK PASS' if args.dry_run else 'INJECTED; APK assembly is next'))


if __name__ == '__main__':
    main()
