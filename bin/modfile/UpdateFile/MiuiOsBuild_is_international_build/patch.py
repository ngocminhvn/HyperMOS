#!/usr/bin/env python3
"""
Patch MiuiOsBuild_is_international_build in libhyper_os_system_public.so
to always return true (1) with ARMv8.5 PAC/BTI compatibility.
"""
import sys
import os

def patch_so(so_path: str):
    if not os.path.isfile(so_path):
        print(f"Error: file not found: {so_path}", file=sys.stderr)
        return 1

    with open(so_path, "rb") as f:
        data = bytearray(f.read())

    # Replacement 16 bytes:
    # paciasp       (3f 23 03 d5)
    # mov w0, #1    (20 00 80 52)
    # autiasp       (bf 23 03 d5)
    # ret           (c0 03 5f d6)
    target_patch = bytes.fromhex("3f2303d520008052bf2303d5c0035fd6")

    # Search symbol MiuiOsBuild_is_international_build in ELF dynsym / symtab
    offset = None

    # Check known standard offset first (0x12e50)
    default_offset = 0x12e50
    if len(data) > default_offset + 16:
        curr_bytes = bytes(data[default_offset:default_offset+16])
        if curr_bytes == target_patch:
            print(f"Already patched at offset 0x{default_offset:x}")
            return 0
        # Stock start is paciasp: 3f 23 03 d5
        if curr_bytes[:4] == bytes.fromhex("3f2303d5"):
            offset = default_offset

    # Parse ELF dynsym if offset is not confirmed or to verify symbol
    # ELF64 header: e_shoff at 40, e_shentsize at 58, e_shnum at 60, e_shstrndx at 62
    try:
        if data[:4] == b"\x7fELF" and data[4] == 2:  # ELF64
            e_shoff = int.from_bytes(data[40:48], "little")
            e_shentsize = int.from_bytes(data[58:60], "little")
            e_shnum = int.from_bytes(data[60:62], "little")
            e_shstrndx = int.from_bytes(data[62:64], "little")

            shstr_hdr = e_shoff + e_shstrndx * e_shentsize
            shstr_offset = int.from_bytes(data[shstr_hdr+24:shstr_hdr+32], "little")

            dynsym_hdr = None
            dynstr_hdr = None

            for i in range(e_shnum):
                hdr = e_shoff + i * e_shentsize
                sh_name_idx = int.from_bytes(data[hdr:hdr+4], "little")
                name_end = data.find(b"\x00", shstr_offset + sh_name_idx)
                sname = data[shstr_offset + sh_name_idx:name_end].decode(errors="ignore")
                sh_type = int.from_bytes(data[hdr+4:hdr+8], "little")
                if sh_type == 11 or sname == ".dynsym":  # SHT_DYNSYM
                    dynsym_hdr = hdr
                elif sname == ".dynstr":
                    dynstr_hdr = hdr

            if dynsym_hdr and dynstr_hdr:
                sym_offset = int.from_bytes(data[dynsym_hdr+24:dynsym_hdr+32], "little")
                sym_size = int.from_bytes(data[dynsym_hdr+32:dynsym_hdr+40], "little")
                str_offset = int.from_bytes(data[dynstr_hdr+24:dynstr_hdr+32], "little")

                # Elf64_Sym is 24 bytes
                num_syms = sym_size // 24
                for idx in range(num_syms):
                    entry = sym_offset + idx * 24
                    st_name = int.from_bytes(data[entry:entry+4], "little")
                    if st_name != 0:
                        name_end = data.find(b"\x00", str_offset + st_name)
                        sym_name = data[str_offset + st_name:name_end].decode(errors="ignore")
                        if sym_name == "MiuiOsBuild_is_international_build":
                            st_value = int.from_bytes(data[entry+8:entry+16], "little")
                            offset = st_value
                            break
    except Exception as e:
        print(f"Warning: ELF parsing exception: {e}", file=sys.stderr)

    if offset is None:
        print("Error: Could not locate symbol MiuiOsBuild_is_international_build", file=sys.stderr)
        return 1

    print(f"Located MiuiOsBuild_is_international_build at offset: 0x{offset:x}")
    curr = bytes(data[offset:offset+16])
    if curr == target_patch:
        print("Function already patched.")
        return 0

    # Ensure function starts with paciasp or bti
    if curr[:4] not in (bytes.fromhex("3f2303d5"), bytes.fromhex("5f2403d5")):
        print(f"Warning: Unexpected prologue at 0x{offset:x}: {curr[:4].hex()}", file=sys.stderr)

    data[offset:offset+16] = target_patch

    with open(so_path, "wb") as f:
        f.write(data)

    print(f"Successfully patched {so_path} at offset 0x{offset:x}")
    return 0

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: patch.py <path_to_libhyper_os_system_public.so>", file=sys.stderr)
        sys.exit(1)
    sys.exit(patch_so(sys.argv[1]))
