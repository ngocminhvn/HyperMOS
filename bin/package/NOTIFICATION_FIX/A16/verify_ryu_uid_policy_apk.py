#!/usr/bin/env python3
"""Check UID policy is present as class definitions, not just DEX references."""
import argparse
import struct
import zipfile
from pathlib import Path

IFACE = ("Lcom/miui/powerkeeper/PowerKeeperInterface$l;",
         "getUidPolicy", "(I)Landroid/os/Bundle;")
IMPL = ("Lcom/miui/powerkeeper/AppRuleChecker;",
        "getUidPolicy", "(I)Landroid/os/Bundle;")
HELPER = ("Lcom/miui/powerkeeper/AppRuleChecker$j;", "d", "()Landroid/os/Bundle;")
CALLER = ("Lcom/miui/powerkeeper/controller/KillProcessController;",
          "shouldKillByCheckerPolicy", "(I)Z")


def entries(blob: bytes):
    if not blob.startswith(b"dex\n"):
        raise ValueError("APK has a non-DEX classes entry")
    u16 = lambda off: struct.unpack_from("<H", blob, off)[0]
    u32 = lambda off: struct.unpack_from("<I", blob, off)[0]

    def leb(pos):
        value = 0
        for shift in range(0, 35, 7):
            b = blob[pos]
            pos += 1
            value |= (b & 127) << shift
            if b < 128:
                return value, pos
        raise ValueError("Invalid ULEB128")

    ssize, soff = u32(0x38), u32(0x3c)
    tsize, toff = u32(0x40), u32(0x44)
    psize, poff = u32(0x48), u32(0x4c)
    msize, moff = u32(0x58), u32(0x5c)
    csize, coff = u32(0x60), u32(0x64)
    strings = []
    for i in range(ssize):
        pos = u32(soff + i * 4)
        _, pos = leb(pos)
        end = blob.index(0, pos)
        strings.append(blob[pos:end].decode("utf-8", "replace"))
    types = [strings[u32(toff + i * 4)] for i in range(tsize)]
    protos = []
    for i in range(psize):
        _, ret, args = struct.unpack_from("<III", blob, poff + i * 12)
        params = ""
        if args:
            params = "".join(types[u16(args + 4 + j * 2)]
                             for j in range(u32(args)))
        protos.append("(" + params + ")" + types[ret])
    methodids = []
    for i in range(msize):
        cls, proto, name = struct.unpack_from("<HHI", blob, moff + i * 8)
        methodids.append((types[cls], strings[name], protos[proto]))
    results = {}
    for i in range(csize):
        class_idx, _, _, _, _, _, data_off, _ = struct.unpack_from(
            "<IIIIIIII", blob, coff + 32 * i
        )
        if not data_off:
            continue
        counts = []
        for _ in range(4):
            value, data_off = leb(data_off)
            counts.append(value)
        for count in counts[:2]:
            field_idx = 0
            for _ in range(count):
                delta, data_off = leb(data_off)
                field_idx += delta
                _, data_off = leb(data_off)
        for count in counts[2:]:
            method_idx = 0
            for _ in range(count):
                delta, data_off = leb(data_off)
                method_idx += delta
                _, data_off = leb(data_off)
                code, data_off = leb(data_off)
                key = methodids[method_idx]
                if key[0] != types[class_idx]:
                    raise ValueError("Class method index mismatch")
                if key in results:
                    raise ValueError("Duplicate method definition")
                results[key] = code
    return results


def main(apk: Path):
    found = {}
    with zipfile.ZipFile(apk) as archive:
        names = [name for name in archive.namelist()
                 if name == "classes.dex" or (
                     name.startswith("classes") and name.endswith(".dex")
                     and name[7:-4].isdigit())]
        if not names:
            raise ValueError("No APK classes.dex")
        for name in names:
            decoded = entries(archive.read(name))
            duplicate = set(found) & set(decoded)
            if duplicate:
                raise ValueError("Duplicate defined method: " + repr(duplicate))
            found.update(decoded)
    for key, expected_code in [(IFACE, False), (IMPL, True), (HELPER, True), (CALLER, True)]:
        if key not in found:
            raise ValueError("Missing defined method " + repr(key))
        if bool(found[key]) != expected_code:
            raise ValueError("Incorrect method code/abstract status: " + repr(key))
    print("[RYU UID POLICY] PASS: interface abstract, AppRuleChecker and Bundle helper concrete, controller linked")
    print("[RYU UID POLICY] Compiled APK:", apk)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--apk", type=Path, required=True)
    args = parser.parse_args()
    main(args.apk)
