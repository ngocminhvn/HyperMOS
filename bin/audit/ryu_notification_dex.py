#!/usr/bin/env python3
"""Compute notification-related DEX method digests without exporting bytecode."""
import argparse
import collections
import hashlib
import json
import re
import struct
import zipfile
from pathlib import Path

PATTERN = re.compile(
    r"(?i)(notification|deviceidle|appstandby|powerkeeper|millet|alarmmanager|"
    r"broadcastqueue|broadcastdispatcher|wakelock|batterysaver|killprocess|"
    r"processmanager|gmsobserver|systemserver|networkpolicy|appops|greezer|"
    r"jobservicecontext|jobscheduler|activitymanager|activitythread)"
)

def u32(b, p):
    return struct.unpack_from("<I", b, p)[0]

def u16(b, p):
    return struct.unpack_from("<H", b, p)[0]

def leb(b, p):
    result = 0
    for shift in range(0, 35, 7):
        value = b[p]
        p += 1
        result |= (value & 127) << shift
        if not value & 128:
            return result, p
    raise ValueError("Invalid ULEB128")

def fingerprint_dex(b):
    if not b.startswith(b"dex\n"):
        raise ValueError("Not a DEX")
    n_strings, off_strings = u32(b, 56), u32(b, 60)
    strings = []
    for i in range(n_strings):
        off = u32(b, off_strings + i * 4)
        _, off = leb(b, off)
        end = b.index(b"\0", off)
        strings.append(b[off:end].decode("utf-8", "replace"))
    n_types, off_types = u32(b, 64), u32(b, 68)
    types = [strings[u32(b, off_types + i * 4)] for i in range(n_types)]
    n_proto, off_proto = u32(b, 72), u32(b, 76)
    protos = []
    for i in range(n_proto):
        _, ret, p_off = struct.unpack_from("<III", b, off_proto + i * 12)
        parameters = ""
        if p_off:
            parameters = "".join(
                types[u16(b, p_off + 4 + j * 2)]
                for j in range(u32(b, p_off))
            )
        protos.append("(" + parameters + ")" + types[ret])
    n_methods, off_methods = u32(b, 88), u32(b, 92)
    method_ids = []
    for i in range(n_methods):
        cl, proto, name = struct.unpack_from("<HHI", b, off_methods + i * 8)
        method_ids.append(types[cl] + "->" + strings[name] + protos[proto])
    n_classes, off_classes = u32(b, 96), u32(b, 100)
    out = {}
    for i in range(n_classes):
        cl, _, _, _, _, _, c_off, _ = struct.unpack_from(
            "<8I", b, off_classes + 32 * i
        )
        if not c_off or not PATTERN.search(types[cl]):
            continue
        p = c_off
        counts = []
        for _ in range(4):
            value, p = leb(b, p)
            counts.append(value)
        for _ in range(counts[0] + counts[1]):
            for unused in range(2):
                _, p = leb(b, p)
        for count in (counts[2], counts[3]):
            idx = 0
            for _ in range(count):
                diff, p = leb(b, p)
                idx += diff
                _, p = leb(b, p)
                code, p = leb(b, p)
                if not code:
                    continue
                words = u32(b, code + 12)
                raw = b[code:code + 16 + words * 2]
                out[method_ids[idx]] = hashlib.sha256(raw).hexdigest()[:24]
    return out

def scan_jar(path):
    data = {
        "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
        "methods": {},
        "dex": {},
    }
    with zipfile.ZipFile(path) as z:
        for name in z.namelist():
            if re.fullmatch(r"classes\d*\.dex", name):
                b = z.read(name)
                data["dex"][name] = hashlib.sha256(b).hexdigest()
                data["methods"].update(fingerprint_dex(b))
    return data

def scan(folder, output):
    files = {}
    for name in (
        "framework.jar", "miui-services.jar", "services.jar",
        "PowerKeeper.apk", "MiuiSystemUI.apk", "SecurityCenter.apk",
    ):
        matches = list(folder.rglob(name))
        if not matches:
            continue
        path = min(matches, key=lambda p: len(str(p)))
        try:
            files[name] = scan_jar(path)
        except (ValueError, OSError, zipfile.BadZipFile) as e:
            print("WARNING:", name, str(e))
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        json.dumps({"files": files}, sort_keys=True, indent=2) + "\n",
        encoding="utf-8",
    )
    print({k: len(v["methods"]) for k, v in files.items()})

def compare(stock, ryu, output):
    baseline = json.loads(stock.read_text(encoding="utf-8"))["files"]
    current = json.loads(ryu.read_text(encoding="utf-8"))["files"]
    lines = [
        "# RYUOS HAOTIAN Notification / Power audit",
        "",
        "Baseline stock JARs supplied by user may be from OS3.0.308.0,",
        "while RYUOS is OS3.0.309.0. A changed method is NOT proof of a notification patch.",
        "",
        "| File | Stock SHA-256 | RYU SHA-256 |",
        "|---|---|---|",
    ]
    for name, old in baseline.items():
        new = current.get(name)
        lines.append(
            "| `" + name + "` | `" + old["sha256"][:16] +
            "` | " + ("`" + new["sha256"][:16] + "`" if new else "NOT FOUND") + " |"
        )
    lines += ["", "## Notification-related changed methods", ""]
    for name, old in baseline.items():
        new = current.get(name)
        if not new:
            continue
        before = old.get("methods", {})
        after = new.get("methods", {})
        changed = sorted(k for k in before.keys() & after.keys() if before[k] != after[k])
        only_stock = sorted(before.keys() - after.keys())
        only_ryu = sorted(after.keys() - before.keys())
        lines.append("### " + name)
        lines.append(
            f"Matched methods changed: **{len(changed)}**; stock-only: "
            f"**{len(only_stock)}**; RYU-only: **{len(only_ryu)}**."
        )
        lines.append("")
        for signature in changed[:120]:
            lines.append("- `" + signature.replace("`", "") + "`")
        if len(changed) > 120:
            lines.append(f"- ...plus {len(changed)-120} others (see JSON)")
        lines.append("")
    lines += [
        "## Interpretation rules",
        "",
        "- Compare with a matching stock OS3.0.309.0 build before attributing differences to RYU modifications.",
        "- Investigate PowerKeeper.apk separately: it is not among the three stock JARs.",
        "- Keep notification fixes limited to verified methods; do not auto-port unknown framework hooks.",
        "- Compare runtime battery/FCM measurements before incorporating patches in HyperMOS main.",
        "",
    ]
    output.write_text("\n".join(lines), encoding="utf-8")

def main():
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="command", required=True)
    scan_p = sub.add_parser("scan")
    scan_p.add_argument("--input", required=True, type=Path)
    scan_p.add_argument("--output", required=True, type=Path)
    cmp_p = sub.add_parser("compare")
    cmp_p.add_argument("--stock", required=True, type=Path)
    cmp_p.add_argument("--ryu", required=True, type=Path)
    cmp_p.add_argument("--output", required=True, type=Path)
    args = p.parse_args()
    if args.command == "scan":
        scan(args.input, args.output)
    else:
        compare(args.stock, args.ryu, args.output)

if __name__ == "__main__":
    main()
