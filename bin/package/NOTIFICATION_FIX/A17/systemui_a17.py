"""Apply notification channel defaults inside the A17 SystemUI settings reader."""

import argparse
import copy
import hashlib
from pathlib import Path
import re
import struct
import zipfile

from preserve_powerkeeper_identity import XIAOMI
from smali_a17 import edit_method, replace_site

MANAGER = "Lcom/miui/systemui/notification/NotificationSettingsManager;"
OPTIONS = {
    "canSound": "Sound",
    "canVibrate": "Vibrate",
    "canShowOnKeyguard": "Keyguard",
    "canFloat": "Float",
}
SIGNATURE = r"\(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;\)Z"
DEX = re.compile(r"classes(?:[2-9]|[1-9]\d+)?\.dex")


def patch(source):
    original = source
    for method, key in OPTIONS.items():
        # This branch is reached only after the package-level policy allows
        # the feature and the channel key is absent from app_notification.
        stock = (
            r"(^    invoke-static \{p2, p3\}, " + re.escape(MANAGER[:-1] + "$Prefs;")
            + rf"->get{key}Key\(Ljava/lang/String;Ljava/lang/String;\)Ljava/lang/String;"
            r"\s+move-result-object p3\s+const-string v0, \"app_notification\""
            r"\s+const/4 v1, 0x4"
            r"\s+invoke-virtual \{p1, v0, v1\}, Landroid/content/Context;->getSharedPreferences"
            r"\(Ljava/lang/String;I\)Landroid/content/SharedPreferences;"
            r"\s+move-result-object p1\s+invoke-interface \{p1, p3\},"
            r" Landroid/content/SharedPreferences;->contains\(Ljava/lang/String;\)Z"
            r"\s+move-result v0\s+if-eqz v0, (:\w+))"
        )
        # Insert at the absent-channel label, where v0 is dead before the
        # existing fallback. Leave explicit channel and app settings intact.
        def edit(block):
            if "->hypermosDefaultChannel(Ljava/lang/String;)Z" in block:
                return block
            guards = list(re.finditer(stock, block, re.MULTILINE))
            if len(guards) != 1:
                raise ValueError(f"{method}: channel preferences guard missing or ambiguous")
            label = guards[0][2]
            return replace_site(
                block,
                rf"(^    {re.escape(label)}\s*\n)(    sget-boolean p1, "
                + re.escape(MANAGER) + r"->USE_WHITE_LISTS:Z)$",
                r"\1    invoke-direct {p0, p2}, " + MANAGER
                + "->hypermosDefaultChannel(Ljava/lang/String;)Z\n\n"
                "    move-result v0\n\n"
                "    if-eqz v0, :hypermos_channel_stock\n\n"
                "    return v0\n\n"
                "    :hypermos_channel_stock\n"
                r"\2",
                method + " channel defaults",
            )

        source = edit_method(source, method + SIGNATURE, edit)

    if ".method private hypermosDefaultChannel(" not in source:
        if source == original:
            raise ValueError("SystemUI defaults hook exists without its implementation")
        source += DEFAULT_CHANNEL
    return source


DEFAULT_CHANNEL = f"""
.method private hypermosDefaultChannel(Ljava/lang/String;)Z
    .locals 3

    const/4 v0, 0x0
    sget-boolean v1, {MANAGER}->USE_WHITE_LISTS:Z
    if-eqz v1, :no

    const-string v1, "com.google.android.gms"
    invoke-virtual {{v1, p1}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-nez v1, :yes
    if-eqz p1, :no

    :try_start
    iget-object v1, p0, {MANAGER}->mContext:Landroid/content/Context;
    invoke-virtual {{v1}}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;
    move-result-object v1
    invoke-virtual {{v1, p1, v0}}, Landroid/content/pm/PackageManager;->getApplicationInfo(Ljava/lang/String;I)Landroid/content/pm/ApplicationInfo;
    move-result-object v1
    iget v2, v1, Landroid/content/pm/ApplicationInfo;->flags:I
    and-int/lit8 v2, v2, 0x1
    :try_end
    .catch Landroid/content/pm/PackageManager$NameNotFoundException; {{:try_start .. :try_end}} :missing

    if-nez v2, :no

    :yes
    const/4 v0, 0x1

    :no
    return v0

    :missing
    move-exception v1
    return v0
.end method
"""


def signing_block(path, offset):
    with path.open("rb") as apk:
        apk.seek(offset - 24)
        size, magic = struct.unpack("<Q16s", apk.read(24))
        if magic != b"APK Sig Block 42" or size + 8 > offset:
            raise ValueError(f"{path}: Xiaomi signing block missing")
        apk.seek(offset - size - 8)
        return apk.read(size + 8)


def sized32(blob):
    size, = struct.unpack_from("<I", blob)
    if size > len(blob) - 4:
        raise ValueError("truncated SystemUI signer data")
    return blob[4:4 + size], blob[4 + size:]


def verify_xiaomi_v3(block):
    pairs = block[8:-24]
    while pairs:
        size, kind = struct.unpack_from("<QI", pairs)
        if size < 4 or size > len(pairs) - 8:
            raise ValueError("invalid SystemUI signature pair")
        if kind == 0xF05368C0:
            signers, rest = sized32(pairs[12:8 + size])
            signer, other_signers = sized32(signers)
            if rest or other_signers:
                raise ValueError("expected one Xiaomi v3 signer")
            signed_data, _ = sized32(signer)
            _, signed_data = sized32(signed_data)
            certs, _ = sized32(signed_data)
            certificate, _ = sized32(certs)
            if hashlib.sha256(certificate).hexdigest() != XIAOMI:
                raise ValueError("unexpected SystemUI v3 certificate")
            return
        pairs = pairs[8 + size:]
    raise ValueError("SystemUI v3 signing identity missing")


def repack(stock, dex, output):
    if not DEX.fullmatch(dex.name):
        raise ValueError("expected an original classesN.dex name")
    with zipfile.ZipFile(stock) as source, stock.open("rb") as raw:
        if dex.name not in source.namelist():
            raise ValueError("target DEX missing from SystemUI APK")
        block = signing_block(stock, source.start_dir)
        verify_xiaomi_v3(block)
        with zipfile.ZipFile(output, "w") as target:
            target.comment = source.comment
            for entry in source.infolist():
                info = copy.copy(entry)
                data = dex.read_bytes() if entry.filename == dex.name else source.read(entry)
                if entry.compress_type == zipfile.ZIP_STORED:
                    raw.seek(entry.header_offset + 26)
                    name_len, extra_len = struct.unpack("<HH", raw.read(4))
                    original = entry.header_offset + 30 + name_len + extra_len
                    alignment = 16384 if entry.filename.endswith(".so") else 4
                    offset = target.fp.tell() + 30 + len(entry.filename.encode()) + len(info.extra)
                    padding = (original - offset) % alignment
                    if padding:
                        padding = (padding - 4) % alignment
                        info.extra += struct.pack("<HH", 0xD935, padding) + bytes(padding)
                target.writestr(info, data)
            target.fp.write(block)
            target.start_dir = target.fp.tell()
    verify(stock, output)


def verify(stock, patched):
    with zipfile.ZipFile(stock) as before, zipfile.ZipFile(patched) as after:
        if set(before.namelist()) != set(after.namelist()) or after.testzip():
            raise ValueError("SystemUI APK entries changed or are corrupted")
        if signing_block(stock, before.start_dir) != signing_block(patched, after.start_dir):
            raise ValueError("SystemUI APK signing block changed")
        modified = []
        for name in before.namelist():
            if before.read(name) != after.read(name):
                if not DEX.fullmatch(name):
                    raise ValueError(f"SystemUI non-DEX entry changed: {name}")
                modified.append(name)
        if len(modified) != 1:
            raise ValueError(f"expected one changed SystemUI DEX, got {modified}")


def verify_corepatch(block):
    if not re.search(
        r"(?m)^    invoke-static \{v5, v6\}, Ljava/security/MessageDigest;->isEqual\(\[B\[B\)Z"
        r"\s+const/4 v7, 0x1\s+if-eqz v7, :\w+",
        block,
    ):
        raise ValueError("A17 channel defaults: existing framework CorePatch not detected")
    return block


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("path", type=Path)
    parser.add_argument("--verify", type=Path)
    parser.add_argument("--repack", nargs=2, type=Path, metavar=("DEX", "OUTPUT"))
    parser.add_argument("--corepatch", action="store_true")
    args = parser.parse_args()
    if args.corepatch:
        source = args.path.read_text(encoding="utf-8")
        edit_method(
            source,
            r"verifyIntegrityFor1MbChunkBasedAlgorithm\(Ljava/util/Map;Ljava/io/FileDescriptor;"
            r"Landroid/util/apk/SignatureInfo;\)V",
            verify_corepatch,
        )
    elif args.repack:
        repack(args.path, *args.repack)
    elif args.verify:
        verify(args.path, args.verify)
    else:
        files = list(args.path.rglob("NotificationSettingsManager.smali"))
        files = [file for file in files if file.as_posix().endswith(
            "com/miui/systemui/notification/NotificationSettingsManager.smali")]
        if len(files) != 1:
            raise ValueError(f"expected one SystemUI notification settings manager, got {len(files)}")
        file = files[0]
        original = file.read_text(encoding="utf-8")
        result = patch(original)
        if result == original:
            print("already patched")
        else:
            file.write_text(result, encoding="utf-8")
            print("patched")


if __name__ == "__main__":
    main()
