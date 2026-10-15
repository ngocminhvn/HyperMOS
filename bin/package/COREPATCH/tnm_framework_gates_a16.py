#!/usr/bin/env python3
"""Audited TNM build gates for TNM, without importing TNM private framework.

All targets are validated before writing. Unknown method/register/branch layouts
abort the build. The original permission checks and method bodies stay in place.
"""
import argparse
import json
import re
from pathlib import Path

MANIFEST = Path(__file__).with_suffix('.json')
MARKER = '# TNM audited build gate'
GATE = re.compile(
    r'(?m)^([ \t]*)sget-boolean\s+([vp]\d+),\s+'
    r'L(?:miui/os/(?:x?Build);->(?:IS_INTERNATIONAL_BUILD|IS_MIUI)|'
    r'com/projectryu/Build;->IS_RYU_BUILD):Z[ \t]*$')


def method_span(text, signature):
    starts = [m for m in re.finditer(r'(?m)^\.method[^\n]*$', text)
              if m.group().split()[-1] == signature]
    if len(starts) != 1:
        raise ValueError(f'{signature}: expected one method, found {len(starts)}')
    start = starts[0].start()
    end = text.find('\n.end method', starts[0].end())
    if end < 0:
        raise ValueError(f'{signature}: missing .end method')
    return start, end + len('\n.end method')


def next_instruction(tail):
    for line in tail.splitlines():
        stmt = line.strip()
        if stmt and not stmt.startswith(('.', '#', ':')):
            return re.sub(r':\w+', ':LABEL', stmt).replace('const-string/jumbo ', 'const-string ')
    raise ValueError('Gate has no following instruction')


def gate_opcode(body, reg, signature):
    declaration = re.search(r'(?m)^\s*\.(locals|registers) (\d+)\s*$', body)
    if declaration is None:
        raise ValueError('Missing register declaration')
    args = signature.split('(', 1)[1].split(')', 1)[0]
    types = re.findall(r'\[*(?:L[^;]+;|[ZBSCIFJD])', args)
    slots = sum(2 if t in ('J', 'D') else 1 for t in types)
    slots += 0 if ' static ' in body.splitlines()[0] else 1
    count = int(declaration[2])
    total = count + slots if declaration[1] == 'locals' else count
    if total < slots or (reg.startswith('p') and int(reg[1:]) >= slots):
        raise ValueError('Invalid parameter register layout')
    index = int(reg[1:]) + (total - slots if reg.startswith('p') else 0)
    if index < 0 or index >= total or index > 255:
        raise ValueError(f'{reg}: gate register is out of range')
    return 'const/4' if index < 16 else 'const/16'


def transform(text, entry, verify=False):
    start, end = method_span(text, entry['method'])
    body = text[start:end]
    regs = entry['registers']
    patched = list(re.finditer(
        rf'(?m)^[ \t]*{re.escape(MARKER)}\n[ \t]*const/(?:4|16) ([vp]\d+), 0x1[ \t]*$', body))
    if patched:
        if [m[1] for m in patched] != regs or GATE.search(body):
            raise ValueError(f"{entry['method']}: corrupt or mixed patched gates")
        if [next_instruction(body[m.end():]) for m in patched] != entry['next']:
            raise ValueError(f"{entry['method']}: patched branch layout changed")
        for match in patched:
            opcode = gate_opcode(body, match[1], entry['method'])
            if f'{opcode} {match[1]}, 0x1' not in match.group():
                raise ValueError('Patched constant has invalid register encoding')
        return text
    if verify:
        raise ValueError(f"{entry['method']}: audited gate missing")
    gates = list(GATE.finditer(body))
    # Older HyperMOS replaces this one entry gate with false for Taplus.
    # TNM instead takes the international early exit, skipping its whitelist.
    if not gates and entry['method'] == 'updateContentCatcherWhitelist()V':
        if 'update taplus clipboard whitelist error, build international' not in body:
            raise ValueError('ContentCatcher: missing original early-exit log')
        gates = list(re.finditer(r'(?m)^([ \t]*)const/4 (v0), 0x0[ \t]*$', body))[:1]
        prefix = body[:gates[0].start()] if gates else ''
        instructions = [s.strip() for s in prefix.splitlines()
                        if s.strip() and not s.strip().startswith(('.', '#'))]
        if instructions:
            raise ValueError('ContentCatcher: false gate is not at method entry')
    if [m[2] for m in gates] != regs:
        raise ValueError(f"{entry['method']}: gate register/count mismatch")
    if [next_instruction(body[m.end():]) for m in gates] != entry['next']:
        raise ValueError(f"{entry['method']}: unexpected gate neighbors")
    for match in reversed(gates):
        reg = match[2]
        opcode = gate_opcode(body, reg, entry['method'])
        change = f'{match[1]}{MARKER}\n{match[1]}{opcode} {reg}, 0x1'
        body = body[:match.start()] + change + body[match.end():]
    result = text[:start] + body + text[end:]
    transform(result, entry, verify=True)
    return result


def apply(root, jar, verify=False, entries=None):
    if not root.is_dir():
        raise ValueError(f'Missing decoded directory: {root}')
    if entries is None:
        entries = json.loads(MANIFEST.read_text())['entries']
    entries = [e for e in entries if e['jar'] == jar]
    if not entries:
        raise ValueError(f'No manifest entries for {jar}')
    pending = {}
    # apk_ops.sh may expose both copies (classes + smali, classesN +
    # smali_classesN) instead of symlinks. They are mirrors of ONE DEX slot,
    # not duplicate definitions. Patch both copies atomically when identical;
    # reject divergent mirrors or duplicate classes across different DEXes.
    dex_dirs = [root] + [p for p in root.iterdir() if p.is_dir()]
    for entry in entries:
        paths = [d / (entry['class'] + '.smali') for d in dex_dirs]
        paths = sorted({p.resolve() for p in paths if p.is_file()})
        if not paths:
            raise ValueError(f"{entry['class']}: expected one class, found 0")
        slots = set()
        for path in paths:
            rel = path.relative_to(root.resolve())
            top = rel.parts[0] if len(rel.parts) > 1 else ''
            alias = re.fullmatch(r'(?:smali(?:_classes)?|classes)([2-9]\d*)?', top)
            slots.add(('dex', alias[1] or '1') if alias else ('other', top))
        if len(slots) != 1:
            raise ValueError(f"{entry['class']}: duplicate class across DEX slots: {sorted(slots)}")
        bodies = {path: pending.get(path, path.read_text(encoding='utf-8'))
                  for path in paths}
        if len(set(bodies.values())) != 1:
            raise ValueError(f"{entry['class']}: divergent DEX alias copies")
        for path, text in bodies.items():
            pending[path] = transform(text, entry, verify=verify)
    if not verify:
        for path, text in pending.items():
            path.write_text(text, encoding='utf-8')
    print(f'[TNM-TNM] {jar}: {len(entries)} methods / '
          f'{sum(len(e["registers"]) for e in entries)} exact build gates verified')


if __name__ == '__main__':
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument('root', type=Path)
    cli.add_argument('jar', choices=['miui-services', 'miui-framework'])
    cli.add_argument('--verify', action='store_true')
    args = cli.parse_args()
    try:
        apply(args.root, args.jar, args.verify)
    except ValueError as exc:
        cli.exit(1, f'[TNM-TNM] ERROR: {exc}\n')
