#!/usr/bin/env python3
"""Test branch only: port original RYU PerfHook from supplied RYU PowerKeeper smali.

Performs dependency closure and a guarded one-time activation in Xiaomi's
PowerKeeperApplication. ROM thermal/charging/boot files are NOT touched.
Original RYU bytecode stays in temporary GitHub Actions runner, not the repo.
"""
import argparse
import json
import re
import shutil
from pathlib import Path

CLASS = re.compile(r'(?m)^\.class\b[^\n]*?\s(L[^;\s]+;)\s*$')
ONCREATE = re.compile(r'(?ms)^\.method\b[^\n]*\bonCreate\(\)V\s*$.*?^\.end method\s*$')
PRIVATE = re.compile(r'L(?:com/projectryu|com/miui/powerkeeper)/[^;\s]+;')
PERF = 'Lcom/projectryu/perf/PerfHook'
CALL = ('Lcom/projectryu/perf/PerfHook;->getInstance'
        '(Landroid/content/Context;)Lcom/projectryu/perf/PerfHook;')
APP = 'Lcom/miui/powerkeeper/PowerKeeperApplication;'


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
        for ref in PRIVATE.findall(source[parent][1]):
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
    calls = re.findall(r'invoke-\w+(?:/range)?\s+\{[^}]*\},\s*Lcom/projectryu/perf/PerfHook;->[^\n]+',
                       ryu_method)
    if len(calls) != 1 or not re.search(
        r'invoke-static\s+\{p0\},\s*' + re.escape(CALL), calls[0]):
        raise ValueError('RYU original Application.onCreate activation differs: ' + repr(calls))
    app_path, app_src, stock_oncreate = app_method(stock)
    block = stock_oncreate.group()
    if CALL in block:
        raise ValueError('PerfHook already initialized in stock')
    supercall = re.search(
        r'(?m)^([ \t]*invoke-super(?:/range)?\s+\{p0\},\s*L[^;]+;->onCreate\(\)V)[ \t]*$',
        block)
    if not supercall or len(re.findall(
        r'(?m)^\s*invoke-super[^\n]*->onCreate\(\)V', block)) != 1:
        raise ValueError('Unexpected super.onCreate layout')
    # No register edits: Android/Dalvik permits unused non-void invoke result.
    addition = ('\n    # RYU PerfHook: one-time start after Application.onCreate\n'
                '    invoke-static {p0}, ' + CALL + '\n')
    new_method = block[:supercall.end()] + addition + block[supercall.end():]
    new_app = app_src[:stock_oncreate.start()] + new_method + app_src[stock_oncreate.end():]
    dex_nums = [1 if f.name == 'smali' else int(f.name.removeprefix('smali_classes'))
                for f in stock_root.iterdir() if f.is_dir() and
                (f.name == 'smali' or re.fullmatch(r'smali_classes\d+', f.name))]
    if not dex_nums:
        raise ValueError('Missing stock smali directories')
    extra_dex = stock_root / ('smali_classes' + str(max(dex_nums) + 1))
    return source, selected, app_path, new_app, extra_dex, calls[0].strip()


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
            shutil.copyfile(input_file, target)
        app_path.write_text(app_body, encoding='utf-8')
        installed = index(args.stock)
        if any(c not in installed for c in classes):
            raise ValueError('Post-installation class verification failed')
        if app_method(installed)[2].group().count(CALL) != 1:
            raise ValueError('Post-installation init invocation missing/duplicated')
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    print(f'[RYU PERFHOOK] {len(classes)} original classes; init site: {original_call}')
    print('[RYU PERFHOOK] '+('STATIC CHECK PASS' if args.dry_run else 'INJECTED; APK assembly is next'))


if __name__ == '__main__':
    main()
