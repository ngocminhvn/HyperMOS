#!/usr/bin/env python3
"""Read-only SHA256 and text diff of RYU and Xiaomi stock thermal/perf configs."""
import argparse
import csv
import difflib
import hashlib
import json
import re
from collections import Counter
from pathlib import Path

def relevant(p):
    p = p.lower()
    return "/etc/perf/" in p or "thermal" in p or "powerhint" in p or "power_hint" in p or "sconfig" in Path(p).name

def load(root):
    path = root / "manifest.json"
    if not path.exists():
        raise SystemExit("Missing manifest: " + str(path))
    result = {}
    for item in json.loads(path.read_text(encoding="utf-8")):
        key = item["partition"] + item["original_path"]
        if not relevant(key):
            continue
        source = root / item["artifact_path"]
        if not source.is_file():
            raise SystemExit("Missing config: " + str(source))
        digest = hashlib.sha256(source.read_bytes()).hexdigest()
        if digest != item["sha256"]:
            raise SystemExit("SHA256 mismatch: " + str(source))
        if key in result:
            raise SystemExit("Duplicate config: " + key)
        result[key] = (source, digest, source.stat().st_size)
    if not result:
        raise SystemExit("No thermal/performance configs in " + str(root))
    return result

def readable(path):
    buf = path.read_bytes()
    if len(buf) > 3000000 or b"\0" in buf[:8192]:
        return None
    try:
        content = buf.decode("utf-8")
    except UnicodeDecodeError:
        return None
    if content and sum(ord(c) < 32 and c not in "\r\n\t" for c in content)/len(content) > .01:
        return None
    return content

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ryu", type=Path, required=True)
    ap.add_argument("--stock", type=Path, required=True)
    ap.add_argument("--out", type=Path, required=True)
    args = ap.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    (args.out / "diffs").mkdir(exist_ok=True)
    a, b = load(args.ryu), load(args.stock)
    rows, counts = [], Counter()
    for key in sorted(a.keys() | b.keys()):
        r, s = a.get(key), b.get(key)
        state = ("ONLY_STOCK" if not r else "ONLY_RYU" if not s
                 else "IDENTICAL" if r[1] == s[1] else "MODIFIED")
        counts[state] += 1
        row = dict(path=key, status=state, ryu_sha256=r[1] if r else "",
                   stock_sha256=s[1] if s else "", ryu_bytes=r[2] if r else "",
                   stock_bytes=s[2] if s else "", diff_file="")
        if state == "MODIFIED":
            old, new = readable(s[0]), readable(r[0])
            if old is not None and new is not None:
                safe = re.sub(r"[^A-Za-z0-9._-]", "_", key)
                output = args.out / "diffs" / (safe + ".diff")
                output.write_text("".join(difflib.unified_diff(
                    old.splitlines(True), new.splitlines(True),
                    fromfile="STOCK/"+key, tofile="RYU/"+key, n=3)), encoding="utf-8")
                row["diff_file"] = output.relative_to(args.out).as_posix()
        rows.append(row)
    with (args.out / "comparison.csv").open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    (args.out / "summary.json").write_text(json.dumps(dict(
        stock_version="OS3.0.308.0.WOBCNXM",
        ryu_label="RYUOS_HAOTIAN_OS3.0.309.0.WOBCNXM_CN261005",
        counts=dict(counts), files=rows), indent=2, ensure_ascii=False)+"\n", encoding="utf-8")
    lines = [
        "# RYU vs Xiaomi Stock thermal/performance audit", "",
        "- STOCK: OS3.0.308.0.WOBCNXM (official China Fastboot).",
        "- RYU label: RYUOS_HAOTIAN_OS3.0.309.0.WOBCNXM_CN261005.",
        "- Scope: thermal, powerhint, perf, sconfig in vendor/odm/etc etc.",
        "- Different ROM version labels can also explain modified files.",
        "- A changed file is NOT proof of better battery efficiency.",
        "- Encrypted/binary thermal profiles are compared by SHA256 only.",
        "- Unified diffs show STOCK -> RYU changes.", "",
        "## Summary", "", "| Status | Files |", "|---|---:|"
    ]
    for state in ("MODIFIED", "IDENTICAL", "ONLY_RYU", "ONLY_STOCK"):
        lines.append("| "+state+" | "+str(counts[state])+" |")
    lines += ["", "## File-by-file", "",
              "| File | Status | Bytes RYU / STOCK | Diff |",
              "|---|---|---:|---|"]
    for row in rows:
        detail = ("[View diff]("+row["diff_file"]+")" if row["diff_file"]
                  else "Opaque/binary" if row["status"] == "MODIFIED" else "—")
        lines.append("| \`"+row["path"]+"\` | "+row["status"]+" | "+
                     str(row["ryu_bytes"])+"/"+str(row["stock_bytes"])+" | "+detail+" |")
    (args.out / "report.md").write_text("\n".join(lines)+"\n", encoding="utf-8")
    print(json.dumps(dict(counts), indent=2))

if __name__ == "__main__":
    main()
