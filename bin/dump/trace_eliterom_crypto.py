#!/usr/bin/env python3
"""Read-only ELF64 import/PLT trace for EliteRom Linux installer.

Never runs the executable, flashes a partition, or attempts decryption.
No key/password bytes are extracted or written to reports.
"""
import argparse
import hashlib
import json
import math
import re
import struct
from collections import Counter
from pathlib import Path

PT_LOAD, PT_DYNAMIC = 1, 2
DT_NULL, DT_PLTRELSZ, DT_STRTAB, DT_SYMTAB = 0, 2, 5, 6
DT_STRSZ, DT_SYMENT, DT_JMPREL = 10, 11, 23
JUMP_SLOT = 7
CRYPTO_PREFIXES = ("EVP_", "PKCS5_", "OPENSSL_", "RAND_")
LITERALS = (b"custom.img", b"Salted__", b"firmware-update", b"openssl enc")


def entropy(data):
    if not data:
        return 0.0
    values = Counter(data).values()
    return -sum((n / len(data)) * math.log2(n / len(data)) for n in values)


class ElfView:
    def __init__(self, data):
        self.data = data
        if data[:4] != b"\x7fELF" or data[4:6] != b"\x02\x01":
            raise ValueError("Expected little-endian ELF64")
        self.machine = struct.unpack_from("<H", data, 18)[0]
        if self.machine != 62:
            raise ValueError("Expected x86-64 installer ELF")
        self.entry = struct.unpack_from("<Q", data, 24)[0]
        self.sections = struct.unpack_from("<H", data, 60)[0]
        phoff = struct.unpack_from("<Q", data, 32)[0]
        phsize, phnum = struct.unpack_from("<HH", data, 54)
        if phnum > 256 or phsize < 56 or phoff + phsize * phnum > len(data):
            raise ValueError("Malformed ELF program headers")
        self.segments = []
        for i in range(phnum):
            kind, flags, off, va, _pa, size, _msize, align = struct.unpack_from(
                "<IIQQQQQQ", data, phoff + i * phsize
            )
            if off + size > len(data):
                raise ValueError("Segment extends beyond input file")
            self.segments.append(dict(kind=kind, flags=flags, off=off,
                                      va=va, size=size, align=align))

    def at(self, addr, size):
        matched = [s for s in self.segments if s["kind"] == PT_LOAD
                   and s["va"] <= addr and addr + size <= s["va"] + s["size"]]
        if not matched:
            raise ValueError("Unmapped file-backed address " + hex(addr))
        segment = min(matched, key=lambda item: item["size"])
        off = segment["off"] + addr - segment["va"]
        return self.data[off:off+size]

    def dynamics(self):
        segment = next((s for s in self.segments if s["kind"] == PT_DYNAMIC), None)
        if segment is None:
            raise ValueError("Missing PT_DYNAMIC segment")
        tags = {}
        for off in range(segment["off"], segment["off"] + segment["size"] - 15, 16):
            tag, value = struct.unpack_from("<qQ", self.data, off)
            if tag == DT_NULL:
                break
            tags.setdefault(tag, []).append(value)
        return tags

    def imports(self, tags):
        required = (DT_JMPREL, DT_PLTRELSZ, DT_STRTAB, DT_SYMTAB,
                    DT_STRSZ, DT_SYMENT)
        if any(item not in tags for item in required):
            raise ValueError("ELF lacks dynamic relocation metadata")
        size = tags[DT_PLTRELSZ][0]
        if size % 24 or size > 1024*1024:
            raise ValueError("Malformed JUMP_SLOT array")
        raw = self.at(tags[DT_JMPREL][0], size)
        string_table = self.at(tags[DT_STRTAB][0], tags[DT_STRSZ][0])
        got = {}
        for off in range(0, len(raw), 24):
            address, info, _addend = struct.unpack_from("<QQq", raw, off)
            if (info & 0xffffffff) != JUMP_SLOT:
                continue
            index = info >> 32
            symbol = self.at(tags[DT_SYMTAB][0] +
                             index * tags[DT_SYMENT][0], 24)
            name_off = struct.unpack_from("<I", symbol)[0]
            if name_off >= len(string_table):
                raise ValueError("Invalid symbol string offset")
            end = string_table.find(b"\0", name_off)
            got[address] = string_table[name_off:end].decode("utf-8", "replace")
        return got


def analyze(path):
    data = path.read_bytes()
    elf = ElfView(data)
    got = elf.imports(elf.dynamics())
    crypto = {addr: name for addr, name in got.items()
              if name.startswith(CRYPTO_PREFIXES)}
    executable = [s for s in elf.segments if s["kind"] == PT_LOAD
                  and s["flags"] & 1 and s["size"] > 0]
    if not executable:
        raise ValueError("No file-backed executable segment")
    segment = max(executable, key=lambda item: item["size"])
    first, last = segment["off"], segment["off"] + segment["size"]
    plt = {}
    prefix = b"\xf3\x0f\x1e\xfa\xff\x25"  # endbr64; jmp [rip + disp32]
    pos = first
    while True:
        pos = data.find(prefix, pos, last)
        if pos < 0 or pos + 10 > last:
            break
        slot = (segment["va"] + pos - first + 10
                + struct.unpack_from("<i", data, pos + 6)[0])
        if slot in got:
            plt[segment["va"] + pos - first] = (slot, got[slot])
        pos += 1

    refs = {"direct_call_plt": [], "direct_call_got": [],
            "direct_jmp_got_non_plt": []}
    # Byte-pattern scanning is not a complete instruction/control-flow graph.
    # A zero count does not exclude indirect imports, packed or rewritten code.
    chunk = memoryview(data)[first:last]
    for i in range(len(chunk) - 6):
        off, va = first + i, segment["va"] + i
        if chunk[i] == 0xe8:
            dest = va + 5 + struct.unpack_from("<i", data, off + 1)[0]
            if dest in plt:
                refs["direct_call_plt"].append(
                    dict(site=hex(va), imported=plt[dest][1]))
        if chunk[i] == 0xff and chunk[i+1] in (0x15, 0x25):
            dest = va + 6 + struct.unpack_from("<i", data, off + 2)[0]
            if dest not in got:
                continue
            jump = chunk[i+1] == 0x25
            if jump and va - 4 in plt:
                continue  # Exclude the PLT trampoline itself.
            key = "direct_jmp_got_non_plt" if jump else "direct_call_got"
            refs[key].append(dict(site=hex(va), imported=got[dest]))

    imported = []
    for slot, name in sorted(crypto.items(), key=lambda item: item[1]):
        imported.append({
            "name": name, "got": hex(slot),
            "plt": [hex(addr) for addr, record in plt.items()
                    if record[0] == slot]
        })
    return {
        "file": path.name,
        "sha256": hashlib.sha256(data).hexdigest(),
        "format": "ELF64 x86-64 PIE",
        "entry_point_virtual": hex(elf.entry),
        "section_header_count": elf.sections,
        "dynamic_jumps_imported": len(got),
        "plt_stubs_matched": len(plt),
        "imported_crypto_functions": imported,
        "static_reference_scan": {
            "method": "E8 rel32, FF15/FF25 RIP-relative (largest executable PT_LOAD)",
            "coverage": f"{hex(first)}-{hex(last)}",
            "results": refs,
        },
        "literal_occurrences": {
            raw.decode(): len(re.findall(re.escape(raw), data, flags=re.I))
            for raw in LITERALS
        },
        "largest_executable_segment": {
            "file_offset": hex(first),
            "virtual_base": hex(segment["va"]),
            "size_bytes": segment["size"],
            "rwx": bool(segment["flags"] & 7 == 7),
            "entropy_first_512k": round(entropy(
                data[first:min(first+512*1024, last)]), 4),
        },
        "limitations": [
            "Imported OpenSSL functions do not prove runtime use for custom.img.",
            "Missing direct calls does not exclude indirect calls, unpacking, or obfuscated control flow.",
            "Key source, password, PBKDF2 iteration count and exact cipher settings are not determined.",
            "No installer execution, flashing or ROM image decryption was performed.",
        ],
    }


def markdown(report):
    output = [
        "# EliteRom Linux installer: OpenSSL linkage trace", "",
        "Read-only static ELF inspection; no installer execution or decryption.", "",
        f"Installer SHA-256: {report['sha256']}", "",
        f"Entry VA: {report['entry_point_virtual']}; "
        f"section headers: {report['section_header_count']}; "
        f"PLT imports/stubs: {report['dynamic_jumps_imported']}/"
        f"{report['plt_stubs_matched']}.", "",
        "## OpenSSL imports and verified trampoline addresses", "",
        "| Symbol | GOT | PLT |", "|---|---|---|",
    ]
    for entry in report["imported_crypto_functions"]:
        output.append(
            f"| {entry['name']} | {entry['got']} | "
            f"{', '.join(entry['plt']) or 'not found'} |")
    scan = report["static_reference_scan"]
    output += ["", "## Limited static direct-call search", "",
               f"Scanned file range {scan['coverage']} using {scan['method']}."]
    for name, sites in scan["results"].items():
        output.append(f"- {name}: {len(sites)}")
        for site in sites[:20]:
            output.append(f"  - {site['site']} -> {site['imported']}")
    output += ["", "## Literal references", ""]
    output += [f"- {name}: {count}" for name, count
               in report["literal_occurrences"].items()]
    output += ["", "## What cannot be concluded", ""]
    output += ["- " + item for item in report["limitations"]]
    return "\n".join(output) + "\n"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--installer", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    report = analyze(args.installer)
    (args.output / "crypto-trace.json").write_text(json.dumps(report, indent=2) + "\n")
    (args.output / "crypto-trace.md").write_text(markdown(report))
    print("[TRACE] ELF SHA256", report["sha256"])
    print("[TRACE] PLT stubs", report["plt_stubs_matched"])
    print("[TRACE] Imported crypto symbols", len(report["imported_crypto_functions"]))
    print("[TRACE] Direct crypto call-site search:")
    for key, value in report["static_reference_scan"]["results"].items():
        print("[TRACE]", key, len(value))
    print("[TRACE] Read-only crypto linkage report generated")


if __name__ == "__main__":
    main()
