#!/usr/bin/env python3
"""Global303 MiuiBatteryIntelligence targeted port onto EU original."""
import argparse
import json
import re
from pathlib import Path

R = re.compile(r'(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$')
F = re.compile(r'(?m)^\.field[^\n]*MAP_APP:\[Ljava/lang/String;[^\n]*$')
TARGET = {'<clinit>()V', '<init>(Landroid/content/Context;)V',
          'init(Landroid/content/Context;)V'}
IGNORE = ('#','.line','.local','.end local','.restart local',
          '.param','.end param','.source','.prologue','.epilogue')

def methods(source):
    output = {}
    for match in R.finditer(source):
        block = match.group()
        sig = block.splitlines()[0].split()[-1]
        if sig in output:
            raise ValueError('duplicate smali method '+sig)
        output[sig] = block
    return output

def locate(root):
    matches = list(root.glob('smali*/com/android/server/MiuiBatteryIntelligence.smali'))
    if len(matches) != 1:
        raise ValueError('requires exactly one MiuiBatteryIntelligence class')
    return matches[0]

def norm(block):
    return tuple(t for line in block.splitlines()
                 if (t := line.strip()) and not t.startswith(IGNORE))

def port(eu_root, donor, original=None, report=None):
    path = locate(eu_root)
    current = path.read_text(encoding='utf-8')
    global_source = donor.read_text(encoding='utf-8')
    old, new = methods(current), methods(global_source)
    if set(old) != set(new) or not TARGET <= set(old):
        raise ValueError('Global/EU method ABI mismatch')
    a, b = F.findall(current), F.findall(global_source)
    if len(a) != 1 or len(b) != 1:
        raise ValueError('MAP_APP definition missing or ambiguous')
    if original is not None:
        original_methods = methods(locate(original).read_text(encoding='utf-8'))
        changed = {sig for sig in original_methods
                   if norm(original_methods[sig]) != norm(old[sig])}
        if changed != TARGET or a != b:
            raise ValueError('reassembly changed methods or fields outside scope')
        for sig in TARGET:
            if norm(old[sig]) != norm(new[sig]):
                raise ValueError('reassembled method not equal Global donor: '+sig)
        print('[GLOBAL EU JAR] verified 3 methods plus MAP_APP field')
        return
    changed = {sig for sig in old if norm(old[sig]) != norm(new[sig])}
    if changed != TARGET:
        raise ValueError('unexpected Global changes in battery class '+str(changed))
    if ' static ' not in a[0] or ' static ' in b[0]:
        raise ValueError('MAP_APP static/instance ABI differs from expected')
    edited = current.replace(a[0], b[0], 1)
    for sig in sorted(TARGET):
        if edited.count(old[sig]) != 1:
            raise ValueError('ambiguous method '+sig)
        edited = edited.replace(old[sig], new[sig], 1)
    assert F.findall(edited) == b
    path.write_text(edited, encoding='utf-8')
    if report is not None:
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(json.dumps({
            'target':'miui-services.jar', 'class':'MiuiBatteryIntelligence',
            'methods':sorted(TARGET),'field':'MAP_APP static to instance',
            'source':'Global303 dada', 'other_eu_methods_preserved': True,
            'runtime_tested':False},indent=2)+'\n')
    print('[GLOBAL EU JAR] ported 3 methods and MAP_APP field')

if __name__ == '__main__':
    args=argparse.ArgumentParser()
    args.add_argument('eu_root',type=Path)
    args.add_argument('donor',type=Path)
    args.add_argument('--original',type=Path)
    args.add_argument('--report',type=Path)
    p=args.parse_args()
    try:
        port(p.eu_root,p.donor,p.original,p.report)
    except (OSError, ValueError) as exc:
        raise SystemExit('[GLOBAL EU JAR] FAIL: '+str(exc))
