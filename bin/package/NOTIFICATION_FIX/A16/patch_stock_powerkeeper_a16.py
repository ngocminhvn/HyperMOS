#!/usr/bin/env python3
"""Apply audited, equal-size boolean gates to the Xiaomi China stock PowerKeeper DEX.

No Xiaomi.eu/RYU/ZKOS bytecode is imported. A failed precondition aborts the
build; changing APK DEX invalidates its original cryptographic signature.
"""
import argparse
import copy
import hashlib
import json
import re
import struct
import zipfile
import zlib
from pathlib import Path

FIELD = ("Lmiui/os/Build;", "IS_INTERNATIONAL_BUILD", "Z")
APPROVED = {
    ("Lcom/miui/powerkeeper/utils/GmsObserver;", "<init>", "(Landroid/content/Context;)V"),
    ("Lcom/miui/powerkeeper/utils/GmsObserver;", "updateGoogleSync", "(Z)V"),
    ("Lcom/miui/powerkeeper/controller/DeviceIdleController$1;", "<init>", "()V"),
    ("Lcom/miui/powerkeeper/controller/DeviceIdleController$2;", "<init>", "()V"),
}
UNTOUCHED = (
    "Lcom/miui/powerkeeper/statemachine/DisplayFrameSetting;",
    "Lcom/miui/powerkeeper/controller/KillProcessController;",
    "Lcom/miui/powerkeeper/controller/ActiveStateController;",
)
DEX_NAME = re.compile(r"classes(?:[2-9]\d*)?\.dex\Z")


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def load_manifest(path):
    config = json.loads(path.read_text(encoding="utf-8"))
    if config.get("schema_version") != 1 or config.get("source") != "xiaomi_china_stock":
        raise ValueError("Unexpected stock PowerKeeper patch manifest")
    if tuple(config.get("field", [])) != FIELD:
        raise ValueError("Unexpected build field; refusing arbitrary DEX patch")
    gates = config.get("gates")
    if not isinstance(gates, list) or len(gates) != len(APPROVED):
        raise ValueError("Exactly four separately audited GMS/Doze gates required")
    keys = set()
    for gate in gates:
        if set(gate) != {"class", "method", "prototype", "expected_reads", "value", "reason"}:
            raise ValueError("Gate has unknown/missing properties")
        key = (gate["class"], gate["method"], gate["prototype"])
        if key not in APPROVED or key in keys or type(gate["expected_reads"]) is not int or gate["expected_reads"] != 1 or gate["value"] is not True:
            raise ValueError("Unapproved/duplicate/non-boolean stock gate: " + repr(key))
        keys.add(key)
    if keys != APPROVED or tuple(config.get("untouched_classes", [])) != UNTOUCHED:
        raise ValueError("Required stock-preserved method/class policy differs")
    return gates


class Dex:
    """Read DEX class/method/code tables without recompilation."""
    def __init__(self, data):
        self.raw = data
        if len(data) < 112 or not data.startswith(b"dex\n"):
            raise ValueError("Invalid stock DEX header")
        if struct.unpack_from("<I", data, 32)[0] != len(data):
            raise ValueError("Invalid stock DEX file size")
        self.strings = []
        ssize, soff = struct.unpack_from("<II", data, 0x38)
        for i in range(ssize):
            off = struct.unpack_from("<I", data, soff + i * 4)[0]
            _, off = self.uleb(off)
            end = data.index(b"\0", off)
            self.strings.append(data[off:end].decode("utf-8", "replace"))
        tsize, toff = struct.unpack_from("<II", data, 0x40)
        types = [self.strings[struct.unpack_from("<I", data, toff + i * 4)[0]]
                 for i in range(tsize)]
        psize, poff = struct.unpack_from("<II", data, 0x48)
        protos = []
        for i in range(psize):
            _, result, args_offset = struct.unpack_from("<III", data, poff + i * 12)
            args = []
            if args_offset:
                count = struct.unpack_from("<I", data, args_offset)[0]
                args = [types[struct.unpack_from("<H", data, args_offset + 4 + j * 2)[0]]
                        for j in range(count)]
            protos.append("(" + "".join(args) + ")" + types[result])
        fsize, foff = struct.unpack_from("<II", data, 0x50)
        self.fields = []
        for i in range(fsize):
            cl, typ, name = struct.unpack_from("<HHI", data, foff + i * 8)
            self.fields.append((types[cl], self.strings[name], types[typ]))
        msize, moff = struct.unpack_from("<II", data, 0x58)
        methods = []
        for i in range(msize):
            cl, proto, name = struct.unpack_from("<HHI", data, moff + i * 8)
            methods.append((types[cl], self.strings[name], protos[proto]))
        csize, coff = struct.unpack_from("<II", data, 0x60)
        self.codes = {}
        for i in range(csize):
            _, _, _, _, _, _, class_data, _ = struct.unpack_from(
                "<IIIIIIII", data, coff + i * 32)
            if not class_data:
                continue
            pos = class_data
            counts = []
            for _ in range(4):
                value, pos = self.uleb(pos)
                counts.append(value)
            for _ in range(counts[0] + counts[1]):
                _, pos = self.uleb(pos)
                _, pos = self.uleb(pos)
            for count in counts[2:]:
                method_idx = 0
                for _ in range(count):
                    delta, pos = self.uleb(pos)
                    method_idx += delta
                    _, pos = self.uleb(pos)
                    code_off, pos = self.uleb(pos)
                    if code_off:
                        registers = struct.unpack_from("<H", data, code_off)[0]
                        units = struct.unpack_from("<I", data, code_off + 12)[0]
                        begin = code_off + 16
                        if begin + units * 2 > len(data):
                            raise ValueError("Method code extends beyond DEX")
                        key = methods[method_idx]
                        if key in self.codes:
                            raise ValueError("Duplicate DEX method definition")
                        self.codes[key] = (begin, units, registers)

    def uleb(self, pos):
        out = shift = 0
        while True:
            if pos >= len(self.raw) or shift > 35:
                raise ValueError("Invalid ULEB128")
            byte = self.raw[pos]
            pos += 1
            out |= (byte & 127) << shift
            if not byte & 128:
                return out, pos
            shift += 7

    def gate_hits(self, key):
        if key not in self.codes:
            raise ValueError("Required China stock method not found: " + repr(key))
        field_ids = [i for i, f in enumerate(self.fields) if f == FIELD]
        if len(field_ids) != 1:
            raise ValueError("China stock DEX build field not uniquely defined")
        field_id = field_ids[0]
        offset, count, registers = self.codes[key]
        found = []
        # 0x63 = sget-boolean, format 21c; following unit is field_id.
        for unit in range(count - 1):
            insn = struct.unpack_from("<H", self.raw, offset + unit * 2)[0]
            if insn & 0xff == 0x63 and struct.unpack_from(
                "<H", self.raw, offset + unit * 2 + 2)[0] == field_id:
                reg = insn >> 8
                if reg >= registers or reg > 15:
                    raise ValueError("Gate register is incompatible with const/4")
                found.append((offset + unit * 2, reg))
        return found


def rewrite_gate(data, offset, register):
    """2-unit sget-boolean -> const/4 #true + nop; no size/branch changes."""
    if register not in range(16) or not 0 <= offset <= len(data) - 4:
        raise ValueError("Invalid bounded gate")
    struct.pack_into("<HH", data, offset, 0x1012 | (register << 8), 0)


def patch_stock(raw, gates):
    source = Dex(raw)
    edits = []
    for gate in gates:
        key = gate["class"], gate["method"], gate["prototype"]
        hits = source.gate_hits(key)
        if len(hits) != gate["expected_reads"]:
            raise ValueError("China stock gate count differs: " + repr((key, len(hits))))
        for offset, reg in hits:
            edits.append((key, offset, reg))
    positions = [off for _, off, _ in edits]
    if len(positions) != 4 or len(set(positions)) != len(positions):
        raise ValueError("Unexpected/overlapping stock gate positions")
    changed = bytearray(raw)
    for _, offset, register in edits:
        rewrite_gate(changed, offset, register)
    changed[12:32] = hashlib.sha1(changed[32:]).digest()
    struct.pack_into("<I", changed, 8, zlib.adler32(changed[12:]) & 0xffffffff)
    output = bytes(changed)
    verified = Dex(output)
    if set(source.codes) != set(verified.codes):
        raise ValueError("Patched DEX changed method inventory")
    for key, _, _ in edits:
        if verified.gate_hits(key):
            raise ValueError("An original stock build gate remains: " + repr(key))
    allowed = set(range(8, 32))
    for offset in positions:
        allowed.update(range(offset, offset + 4))
    if any(idx not in allowed for idx, (a, b) in enumerate(zip(raw, output)) if a != b):
        raise ValueError("DEX changed outside approved gate sites and header")
    untouched = {}
    for cls in UNTOUCHED:
        pairs = [(key, code) for key, code in source.codes.items() if key[0] == cls]
        if not pairs:
            raise ValueError("Expected untouched China class not found: " + cls)
        digest = hashlib.sha256()
        for key, (offset, units, _) in sorted(pairs):
            original = raw[offset:offset + 2 * units]
            after_offset, after_units, _ = verified.codes[key]
            if after_units != units or output[after_offset:after_offset + 2 * units] != original:
                raise ValueError("Protected China stock method modified: " + repr(key))
            digest.update(repr(key).encode())
            digest.update(original)
        untouched[cls] = {"method_count": len(pairs), "sha256": digest.hexdigest()}
    report = {
        "source": "verified_china_stock_classes.dex",
        "stock_dex_sha256": sha256(raw),
        "patched_dex_sha256": sha256(output),
        "changed_gates": len(edits),
        "modified_methods": [{"class": k[0], "method": k[1], "prototype": k[2]}
                             for k, _, _ in edits],
        "unchanged_stock_classes": untouched,
        "display_frame_setting_patched": False,
        "eu_ryu_zk_dex_imported": False,
        "other_dex_bytes_untouched_except_checksum": True,
        "runtime_tested": False,
    }
    return output, report


def read_stock_dex(apk):
    with zipfile.ZipFile(apk) as archive:
        names = archive.namelist()
        if len(names) != len(set(names)) or archive.testzip():
            raise ValueError("Invalid stock PowerKeeper APK")
        if {n for n in names if DEX_NAME.fullmatch(n)} != {"classes.dex"}:
            raise ValueError("Expected exactly one stock PowerKeeper classes.dex")
        return archive.read("classes.dex")


def prepare_wrapper(apk, dex_path, output):
    """Temporary input only: stock non-DEX members plus selectively patched DEX."""
    dex = dex_path.read_bytes()
    if len(dex) < 112 or not dex.startswith(b"dex\n"):
        raise ValueError("Invalid staged DEX")
    with zipfile.ZipFile(apk) as stock, zipfile.ZipFile(output, "w") as dest:
        if stock.testzip():
            raise ValueError("Invalid input APK ZIP")
        for info in stock.infolist():
            if info.filename.upper().startswith("META-INF/"):
                continue
            dest.writestr(copy.copy(info), dex if info.filename == "classes.dex"
                          else stock.read(info.filename))


def main():
    p = argparse.ArgumentParser()
    p.add_argument("operation", choices=["patch", "wrap"])
    p.add_argument("--apk", type=Path, required=True)
    p.add_argument("--manifest", type=Path)
    p.add_argument("--dex", type=Path)
    p.add_argument("--output", type=Path, required=True)
    p.add_argument("--report", type=Path)
    a = p.parse_args()
    a.output.parent.mkdir(parents=True, exist_ok=True)
    if a.operation == "patch":
        if a.manifest is None or a.report is None:
            p.error("patch requires --manifest and --report")
        gates = load_manifest(a.manifest)
        patched, report = patch_stock(read_stock_dex(a.apk), gates)
        a.output.write_bytes(patched)
        a.report.parent.mkdir(parents=True, exist_ok=True)
        a.report.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        print("[POWERKEEPER STOCK] " + json.dumps(report))
    else:
        if a.dex is None:
            p.error("wrap requires --dex")
        prepare_wrapper(a.apk, a.dex, a.output)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, IndexError, struct.error, zipfile.BadZipFile) as e:
        raise SystemExit("[POWERKEEPER STOCK] FAIL: " + str(e))
