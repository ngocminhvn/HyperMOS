#!/usr/bin/env python3
"""Read-only Android DEX signature-related method inspection.

Prints exact instruction words, without rewriting the DEX, to distinguish
constant-return framework patches from stock verification code.
"""
import json
import struct
import sys
import zipfile
from pathlib import Path

TARGETS = {
    ("Landroid/content/pm/SigningDetails;", "checkCapability"),
    ("Landroid/content/pm/SigningDetails;", "hasAncestorOrSelf"),
    ("Landroid/content/pm/PackageParser$SigningDetails;", "checkCapability"),
    ("Landroid/util/apk/ApkSignatureVerifier;", "getMinimumSignatureSchemeVersionForTargetSdk"),
    ("Landroid/util/jar/StrictJarVerifier;", "verifyMessageDigest"),
}

def uleb(data, pos):
    value = 0
    for shift in range(0, 35, 7):
        part = data[pos]
        pos += 1
        value |= (part & 127) << shift
        if part < 128:
            return value, pos
    raise ValueError("Malformed unsigned LEB128")

def inspect_dex(data, dex_name):
    u32 = lambda at: struct.unpack_from("<I", data, at)[0]
    string_count, string_off = u32(56), u32(60)
    type_count, type_off = u32(64), u32(68)
    method_count, method_off = u32(88), u32(92)
    class_count, class_off = u32(96), u32(100)
    strings = []
    for i in range(string_count):
        pos = u32(string_off + i * 4)
        _, pos = uleb(data, pos)
        end = data.index(b"\0", pos)
        strings.append(data[pos:end].decode("utf8", "replace"))
    types = [strings[u32(type_off + i * 4)] for i in range(type_count)]
    method_names = []
    for i in range(method_count):
        class_idx, _, name_idx = struct.unpack_from("<HHI", data, method_off + i * 8)
        method_names.append((types[class_idx], strings[name_idx]))
    output = []
    for i in range(class_count):
        cls_idx, _, _, _, _, _, classdata, _ = struct.unpack_from(
            "<8I", data, class_off + i * 32
        )
        if not classdata or types[cls_idx] not in {c for c, _ in TARGETS}:
            continue
        pos = classdata
        counts = []
        for _ in range(4):
            n, pos = uleb(data, pos)
            counts.append(n)
        for _ in range(counts[0] + counts[1]):
            _, pos = uleb(data, pos)
            _, pos = uleb(data, pos)
        for n_methods in counts[2:]:
            idx = 0
            for _ in range(n_methods):
                delta, pos = uleb(data, pos)
                idx += delta
                _, pos = uleb(data, pos)
                code_off, pos = uleb(data, pos)
                name = method_names[idx]
                if name not in TARGETS or not code_off:
                    continue
                n_words = u32(code_off + 12)
                words = struct.unpack_from(
                    "<" + "H" * min(n_words, 12), data, code_off + 16
                )
                constant = None
                if n_words == 2 and words[1] == 0x000f and words[0] in (0x0012, 0x1012):
                    constant = 0 if words[0] == 0x0012 else 1
                output.append({
                    "class": name[0], "method": name[1],
                    "dex": dex_name, "instruction_count": n_words,
                    "instruction_words": [f"{w:04x}" for w in words],
                    "returns_constant": constant,
                })
    return output

def main():
    target = Path(sys.argv[1])
    output = Path(sys.argv[2])
    rows = []
    with zipfile.ZipFile(target) as archive:
        dex_names = [x for x in archive.namelist()
                     if Path(x).name.startswith("classes") and x.endswith(".dex")]
        for name in dex_names:
            rows.extend(inspect_dex(archive.read(name), name))
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps({
        "binary": target.name,
        "warning": "Two DEX opcodes proving constant return, not runtime application permissions",
        "methods": rows,
        "missing": [{"class": cl, "method": method} for cl, method in sorted(
            TARGETS - {(r["class"], r["method"]) for r in rows})],
    }, ensure_ascii=False, indent=2) + "\n")
    for row in rows:
        print(row["class"], row["method"], "constant", row["returns_constant"],
              "instructions", row["instruction_count"])

if __name__ == "__main__":
    main()
