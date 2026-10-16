#!/usr/bin/env python3
"""Second-stage static forensics for the EliteRom installer.

The input executables are never run. No flashing, decryption, guessing or key
printing. Deliberately distinguish import capability from proven call paths.
"""
import argparse
import hashlib
import json
import struct
from pathlib import Path

from trace_eliterom_crypto import ElfView, PT_LOAD, entropy

LITERALS = (b"custom.img", b"Salted__", b"firmware-update")
INTERESTING = (
    "PKCS5_PBKDF2_HMAC", "EVP_aes_256_cbc", "EVP_DecryptInit_ex",
    "EVP_DecryptUpdate", "EVP_DecryptFinal_ex", "EVP_md5", "EVP_sha256",
    "fopen", "fread", "fwrite", "popen", "system", "getenv",
    "getchar", "getcwd", "access", "remove", "unlink",
)
CHUNK = 512 * 1024


def phdrs(data):
    if data[:6] != b"\x7fELF\x02\x01":
        raise ValueError("Expected little-endian ELF64")
    off = struct.unpack_from("<Q", data, 32)[0]
    size, count = struct.unpack_from("<HH", data, 54)
    if size < 56 or count > 256 or off + size * count > len(data):
        raise ValueError("Invalid program header table")
    result = []
    for n in range(count):
        kind, flags, offset, va, _, filesz, memsz, alignment = struct.unpack_from(
            "<IIQQQQQQ", data, off + n * size)
        if offset + filesz > len(data):
            raise ValueError("Invalid file-backed segment")
        if kind == PT_LOAD:
            result.append(dict(flags=flags, file_offset=offset, virtual_address=va,
                               file_size=filesz, memory_size=memsz,
                               readable=bool(flags & 4), writable=bool(flags & 2),
                               executable=bool(flags & 1)))
    return result


def direct_entry_edges(data, elf):
    """Resolve a few *verified instruction boundaries*, not arbitrary byte scans."""
    addr = elf.entry
    head = elf.at(addr, 32)
    if not head.startswith(b"\xf3\x0f\x1e\xfa"):
        return dict(entry=hex(addr), recognized=False, branches=[])
    branches = []
    pos = 4
    # The actual entry stub begins with ENDBR64 and an x86 E8 call.
    if head[pos] == 0xE8:
        displacement = struct.unpack_from("<i", head, pos + 1)[0]
        branches.append(dict(instruction="call rel32", source=hex(addr + pos),
                             target=hex(addr + pos + 5 + displacement)))
        pos += 5
    # This installer has a MOV EBX, imm32 followed by an E9 jump.
    if head[pos] == 0xBB:
        pos += 5
    if head[pos] == 0xE9:
        displacement = struct.unpack_from("<i", head, pos + 1)[0]
        branches.append(dict(instruction="jmp rel32", source=hex(addr + pos),
                             target=hex(addr + pos + 5 + displacement)))
    return dict(entry=hex(addr), recognized=True, branches=branches)


def windows_protection_sections(data):
    if len(data) < 0x100 or data[:2] != b"MZ":
        return {"format": "not-pe", "sections": []}
    offset = struct.unpack_from("<I", data, 0x3c)[0]
    if offset + 24 > len(data) or data[offset:offset+4] != b"PE\0\0":
        return {"format": "invalid-pe", "sections": []}
    count = struct.unpack_from("<H", data, offset + 6)[0]
    optsize = struct.unpack_from("<H", data, offset + 20)[0]
    base = offset + 24 + optsize
    if count > 96 or base + count * 40 > len(data):
        raise ValueError("Invalid PE section headers")
    names = []
    for n in range(count):
        name = data[base+n*40:base+n*40+8].rstrip(b"\0").decode("ascii","replace")
        names.append(name)
    return {"format": "pe", "sections": names,
            "has_themida_named_section": any("themida" in x.lower() for x in names)}


def inspect(linux, windows=None):
    data = Path(linux).read_bytes()
    elf = ElfView(data)
    dyn = elf.dynamics()
    got = elf.imports(dyn)
    imports = sorted(set(got.values()))
    segments = phdrs(data)
    entropy_windows = []
    for segment in segments:
        if not (segment["executable"] and segment["file_size"]):
            continue
        start = segment["file_offset"]
        end = start + segment["file_size"]
        for at in range(start, end, CHUNK):
            group = data[at:min(at+CHUNK,end)]
            entropy_windows.append({"offset":hex(at),
                                    "length":len(group),
                                    "bits_per_byte":round(entropy(group),5)})
    imported = [f for f in INTERESTING if f in imports]
    rwx = [s for s in segments if s["readable"] and s["writable"]
           and s["executable"] and s["file_size"]]
    result = {
        "source_sha256": hashlib.sha256(data).hexdigest(),
        "file_length": len(data),
        "entry": hex(elf.entry),
        "no_elf_section_headers": elf.sections == 0,
        "elf_file_backed_segments": segments,
        "large_rwx_file_region_bytes": sum(s["file_size"] for s in rwx),
        "high_entropy_windows_over_7_99": sum(
            item["bits_per_byte"] > 7.99 for item in entropy_windows),
        "executable_entropy_windows": entropy_windows,
        "entry_direct_edges": direct_entry_edges(data,elf),
        "imported_functions_of_interest": imported,
        "literal_strings_present": {
            x.decode(): x in data for x in LITERALS
        },
        "warning": (
            "The ELF has no section headers and an unusually large RWX region "
            "with high-entropy windows. These are consistent with protection or "
            "obfuscation but do not identify the packer or prove code is encrypted. "
            "Importing OpenSSL/file/command functions does NOT prove an operational "
            "call chain between them. Key source, KDF parameters and output targets "
            "remain unknown."
        ),
        "inspection_executed_installer": False,
    }
    if windows is not None:
        payload = Path(windows).read_bytes()
        result["windows"] = {
            "sha256": hashlib.sha256(payload).hexdigest(),
            **windows_protection_sections(payload)
        }
    return result


def report_markdown(result):
    s = [
        "# EliteRomLite: second-stage static loader/flow analysis", "",
        "Read-only forensic analysis; no ROM installer was executed.", "",
        "- Linux SHA256: "+result["source_sha256"],
        "- Size: "+str(result["file_length"])+" bytes",
        "- ELF entry VA: "+result["entry"],
        "- Section headers absent: "+str(result["no_elf_section_headers"]),
        "- File-backed RWX bytes: "+str(result["large_rwx_file_region_bytes"]),
        "- Entropy samples above 7.99 bits/byte: "+
          str(result["high_entropy_windows_over_7_99"]), "",
        "## Startup stub branches", "",
    ]
    for row in result["entry_direct_edges"]["branches"]:
        s.append("- "+row["source"]+" "+row["instruction"]+" -> "+row["target"])
    s.extend(["", "## Imported capabilities (not proven execution)", "",
              ", ".join(result["imported_functions_of_interest"]), "",
              "## Plaintext literal check", ""])
    for name,present in result["literal_strings_present"].items():
        s.append("- "+name+": "+str(present))
    s.extend(["", "## Windows PE section names", ""])
    if "windows" in result:
        s.append(", ".join(result["windows"]["sections"]))
        s.append("Themida-named section: "+str(
            result["windows"]["has_themida_named_section"]))
    s.extend(["", "## Evidence limits", "", result["warning"], "",
              "This analysis **does not** recover or disclose any passphrase/key."])
    return "\n".join(s)+"\n"


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--linux",required=True,type=Path)
    parser.add_argument("--windows",type=Path)
    parser.add_argument("--output",required=True,type=Path)
    args=parser.parse_args()
    args.output.mkdir(parents=True,exist_ok=True)
    findings=inspect(args.linux,args.windows)
    (args.output/"loader-analysis.json").write_text(json.dumps(findings,indent=2)+"\n")
    (args.output/"loader-analysis.md").write_text(report_markdown(findings))
    print("[LOADER] RWX file bytes:",findings["large_rwx_file_region_bytes"])
    print("[LOADER] near-random entropy windows:",findings["high_entropy_windows_over_7_99"])
    print("[LOADER] entry direct branches:",findings["entry_direct_edges"]["branches"])
    print("[LOADER] known plaintext path names:",findings["literal_strings_present"])
    print("[LOADER] analysis complete; installer not executed")


if __name__=="__main__":
    main()
