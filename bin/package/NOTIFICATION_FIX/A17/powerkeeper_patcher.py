#!/usr/bin/env python3
"""Android 17 / OS4 PowerKeeper patcher and identity preserver.

1. Smali patching: disables the outgoing Google-network limiter, configures
   International cloud sync to jupiter.intl.sys.miui.com with model 2412DPN6CG (xuanyuan)
   and rgn-GLOBAL, and clears app network restrictions.
2. Identity preservation: retains Xiaomi official certificate identity and v1 metadata
   (CERT.RSA, CERT.SF, MANIFEST.MF) while transplanting patched classes.dex.
"""
import argparse
import copy
import hashlib
import json
import os
import re
import subprocess
import tempfile
import zipfile
from pathlib import Path

XIAOMI = 'c9009d01ebf9f5d0302bc71b2fe9aa9a47a432bba17308a3111b75d7b2149025'
DEX = re.compile(r'classes(?:[2-9]|[1-9]\d+)?\.dex\Z')

GMS_OBSERVER = "com/miui/powerkeeper/utils/GmsObserver.smali"
INTERNATIONAL_ADAPTER = "com/miui/powerkeeper/utils/InternationalAdapter.smali"
LOCAL_UPDATE_UTILS = "com/miui/powerkeeper/cloudcontrol/LocalUpdateUtils.smali"
UTILS = "com/miui/powerkeeper/utils/Utils.smali"
DEVICE = "com/miui/powerkeeper/utils/Device.smali"


def locate(root: Path, relative: str, required=True):
    matches = [path for path in root.glob("smali*/" + relative) if path.is_file()]
    direct = root / relative
    if not matches and direct.is_file():
        matches = [direct]
    if not matches and not required:
        return None
    if len(matches) != 1:
        raise ValueError(f"expected one {relative}, got {len(matches)}")
    return matches[0]


def method_pattern(signature: str):
    return re.compile(
        rf"(?ms)^\.method[^\n]*\b{re.escape(signature)}[^\n]*\n.*?^\.end method[ \t]*$"
    )


def force_boolean_parameter(source: str, signature: str, parameter: str, value: int):
    methods = list(method_pattern(signature).finditer(source))
    if len(methods) != 1:
        raise ValueError(f"expected one {signature}, got {len(methods)}")
    block = methods[0].group()
    registers = re.search(r"(?m)^([ \t]*)\.(?:registers|locals)[ \t]+\d+[ \t]*$", block)
    if not registers:
        raise ValueError(f"{signature}: missing registers declaration")
    instruction = f"{registers.group(1)}const/4 {parameter}, 0x{value:x}"
    following = block[registers.end():]
    already_forced = re.match(
        rf"\s*const/4[ \t]+{re.escape(parameter)},[ \t]+0x{value:x}\b", following)
    if not already_forced:
        at = registers.end()
        block = block[:at] + "\n\n" + instruction + block[at:]
    return source[:methods[0].start()] + block + source[methods[0].end():]


def patch_smali(root: Path):
    if not root.is_dir():
        raise ValueError(f"Missing decompiled PowerKeeper smali dir: {root}")

    details = {}
    total = 0

    # 1. GmsObserver: force outgoing notification-limit bit false
    gms = locate(root, GMS_OBSERVER)
    gms.write_text(
        force_boolean_parameter(
            gms.read_text(encoding="utf-8"),
            "updateFrameworkGmsNetStatus(Z)Z", "p1", 0),
        encoding="utf-8")
    details[GMS_OBSERVER] = {"gms_network_limit_forced_false": True}
    total += 1

    # 2. InternationalAdapter: empty initRestrictPkgs and clear sNetworkAllowApps
    ia_file = locate(root, INTERNATIONAL_ADAPTER, required=False)
    if ia_file is not None:
        ia_text = ia_file.read_text(encoding="utf-8")
        irp_re = re.compile(
            r"(?ms)^\.method[^\n]*\binitRestrictPkgs\([^\n]*\n.*?^\.end method[ \t]*$"
        )
        if irp_re.search(ia_text):
            new_irp = (
                ".method public static initRestrictPkgs(Landroid/content/Context;)V\n"
                "    .registers 1\n\n"
                "    return-void\n"
                ".end method"
            )
            ia_text = irp_re.sub(new_irp, ia_text)
        ia_text = re.sub(
            r'(?m)^(\.field public static sNetworkAllowApps:Ljava/lang/String; = )".*?"',
            r'\1""',
            ia_text
        )
        ia_text = re.sub(
            r'(?m)^([ \t]*const-string[ \t]+[vp]\d+,[ \t]+)"com\.xiaomi\.xmsf.*?"(\s*\n[ \t]*sput-object[ \t]+[vp]\d+,[ \t]+Lcom/miui/powerkeeper/utils/InternationalAdapter;->sNetworkAllowApps:Ljava/lang/String;)',
            r'\1""\2',
            ia_text
        )
        ia_file.write_text(ia_text, encoding="utf-8")
        details[INTERNATIONAL_ADAPTER] = {
            "init_restrict_pkgs_noop": True,
            "network_allow_apps_emptied": True,
        }
        total += 1

    # 3. Direct PowerKeeper Cloud Sync to International Endpoint
    lu_file = locate(root, LOCAL_UPDATE_UTILS, required=False)
    if lu_file is not None:
        lu_text = lu_file.read_text(encoding="utf-8")
        set_server_re = re.compile(
            r"(?ms)^\.method private static setServerConfigurations\([^\n]*\n.*?^\.end method[ \t]*$"
        )
        if set_server_re.search(lu_text):
            new_set_server = (
                ".method private static setServerConfigurations(Landroid/content/Context;)V\n"
                "    .registers 2\n\n"
                '    const-string/jumbo v0, "https://jupiter.intl.sys.miui.com/api/profile/getProfile.do?"\n\n'
                "    sput-object v0, Lcom/miui/powerkeeper/cloudcontrol/Constants;->CLOUD_NEW_SERVER:Ljava/lang/String;\n\n"
                '    const-string/jumbo v0, "wdFSzmfNh"\n\n'
                "    sput-object v0, Lcom/miui/powerkeeper/cloudcontrol/Constants;->CLOUD_POWER_NEW_SID:Ljava/lang/String;\n\n"
                '    const-string/jumbo v0, "kxIu9S9Wi"\n\n'
                "    sput-object v0, Lcom/miui/powerkeeper/cloudcontrol/Constants;->CLOUD_PERF_ENGINE_SID:Ljava/lang/String;\n\n"
                '    const-string/jumbo v0, "J6G4oVvvp"\n\n'
                "    sput-object v0, Lcom/miui/powerkeeper/cloudcontrol/Constants;->CLOUD_THERMAL_NEW_SID:Ljava/lang/String;\n\n"
                '    const-string/jumbo v0, "MGdeXyMDu"\n\n'
                "    sput-object v0, Lcom/miui/powerkeeper/cloudcontrol/Constants;->CLOUD_PERF_SHIELDER_SID:Ljava/lang/String;\n\n"
                "    return-void\n"
                ".end method"
            )
            lu_text = set_server_re.sub(new_set_server, lu_text)
            lu_file.write_text(lu_text, encoding="utf-8")
            details[LOCAL_UPDATE_UTILS] = {"cloud_server_forced_international": True}
            total += 1

    # 4. Scope-isolated Utils.getRegion(): returns GLOBAL
    utils_file = locate(root, UTILS, required=False)
    if utils_file is not None:
        u_text = utils_file.read_text(encoding="utf-8")
        get_rgn_re = re.compile(
            r"(?ms)^\.method static getRegion\(\)Ljava/lang/String;\s*\n.*?^\.end method[ \t]*$"
        )
        if get_rgn_re.search(u_text):
            new_get_rgn = (
                ".method static getRegion()Ljava/lang/String;\n"
                "    .registers 1\n\n"
                '    const-string/jumbo v0, "GLOBAL"\n\n'
                "    return-object v0\n"
                ".end method"
            )
            u_text = get_rgn_re.sub(new_get_rgn, u_text)
            utils_file.write_text(u_text, encoding="utf-8")
            details[UTILS] = {"region_forced_global": True}
            total += 1

    # 5. Scope-isolated Device.getModel(): maps model to 2412DPN6CG (xuanyuan Global)
    dev_file = locate(root, DEVICE, required=False)
    if dev_file is not None:
        d_text = dev_file.read_text(encoding="utf-8")
        get_mod_re = re.compile(
            r"(?ms)^\.method public static getModel\(\)Ljava/lang/String;\s*\n.*?^\.end method[ \t]*$"
        )
        if get_mod_re.search(d_text):
            new_get_mod = (
                ".method public static getModel()Ljava/lang/String;\n"
                "    .registers 1\n\n"
                '    const-string/jumbo v0, "2412DPN6CG"\n\n'
                "    return-object v0\n"
                ".end method"
            )
            d_text = get_mod_re.sub(new_get_mod, d_text)
            dev_file.write_text(d_text, encoding="utf-8")
            details[DEVICE] = {"model_mapped_xuanyuan_global": True}
            total += 1

    if total == 0:
        raise ValueError("no Android 17 PowerKeeper gates were patched")

    return {
        "status": "success",
        "target_apk": "PowerKeeper.apk",
        "gates_replaced": total,
        "patched_files": details,
        "perfhook_omitted": True,
    }


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def cert_present(blob):
    pos = 0
    while pos < len(blob):
        start = pos
        tag = blob[pos]
        pos += 1
        if pos >= len(blob):
            raise ValueError('Truncated DER')
        size = blob[pos]
        pos += 1
        if size & 128:
            count = size & 127
            if not count or count > 4 or pos + count > len(blob):
                raise ValueError('Invalid DER length')
            size = int.from_bytes(blob[pos:pos + count], 'big')
            pos += count
        end = pos + size
        if end > len(blob):
            raise ValueError('Truncated DER object')
        if tag == 0x30 and hashlib.sha256(blob[start:end]).hexdigest() == XIAOMI:
            return True
        if tag & 32 and cert_present(blob[pos:end]):
            return True
        pos = end
    return False


def metadata(reference):
    with zipfile.ZipFile(reference) as z:
        names = [n for n in z.namelist() if n.upper().startswith('META-INF/') and not n.endswith('/')]
        if len(names) != len(set(names)):
            raise ValueError('Duplicate reference metadata')
        result = {n: z.read(n) for n in names}
    if not {'META-INF/CERT.RSA', 'META-INF/CERT.SF', 'META-INF/MANIFEST.MF'} <= result.keys():
        raise ValueError('Reference v1 metadata missing')
    if not cert_present(result['META-INF/CERT.RSA']):
        raise ValueError('Reference does not contain the expected Xiaomi certificate')
    return result


def verify(apk, reference):
    expected = metadata(reference)
    with zipfile.ZipFile(apk) as z:
        names = z.namelist()
        if len(names) != len(set(names)) or z.testzip():
            raise ValueError('Duplicate or damaged APK entries')
        actual = {n: z.read(n) for n in names if n.upper().startswith('META-INF/') and not n.endswith('/')}
        if actual != expected:
            raise ValueError('Xiaomi v1 metadata differs from verified stock')
        with apk.open('rb') as fh:
            fh.seek(max(0, z.start_dir - 16))
            if fh.read(16) == b'APK Sig Block 42':
                raise ValueError('Unexpected v2/v3 signing block in preserved-identity APK')
        if not any(DEX.fullmatch(n) for n in names):
            raise ValueError('APK contains no DEX')
    return {
        'mode': 'xiaomi-certificate-preserved-patched-v1',
        'certificate_sha256': XIAOMI,
        'sha256': sha(apk),
        'metadata_sha256': {n: hashlib.sha256(data).hexdigest() for n, data in actual.items()},
        'cryptographic_signature_valid': False,
        'requires_rom_v1_digest_bypass': True,
        'runtime_tested': False,
    }


def verify_base(base, signer, java, allow_stripped=False):
    command = [java, '-jar', str(signer), 'verify', '--verbose',
               '--print-certs', str(base)]
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode:
        combined = result.stdout + result.stderr
        stripped = ('no such signature was found' in combined and
                    'Signature stripped?' in combined)
        if not stripped or not allow_stripped:
            raise subprocess.CalledProcessError(
                result.returncode, command, result.stdout, result.stderr)
        metadata(base)
        return 'pinned-xiaomi-v1-metadata-stripped-v2-v3'
    check = result.stdout
    certs = re.findall(r'^Signer #\d+ certificate SHA-256 digest: (\S+)', check, re.M)
    if certs != [XIAOMI]:
        raise ValueError('Base APK must be verified Xiaomi stock, not an Android/testkey rebuild')
    return 'apksigner-verified'


def rebuild(base, patched, reference, output, signer, java, allow_stripped=False):
    base_verification = verify_base(base, signer, java, allow_stripped)
    meta = metadata(reference)
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=output.parent, prefix='powerkeeper-identity-') as folder:
        candidate = Path(folder) / 'PowerKeeper.apk'
        with zipfile.ZipFile(base) as original:
            if len(original.namelist()) != len(set(original.namelist())) or original.testzip():
                raise ValueError('Duplicate or corrupted base ZIP')
            dex = {n for n in original.namelist() if DEX.fullmatch(n)}

            if patched.is_file() and patched.suffix == '.dex':
                dex_bytes = patched.read_bytes()
                if len(dex_bytes) < 112 or not dex_bytes.startswith(b"dex\n"):
                    raise ValueError('Invalid patched DEX file')
                rebuilt_dex = {'classes.dex'}
                with zipfile.ZipFile(candidate, 'w') as dest:
                    dest.comment = original.comment
                    for member in original.infolist():
                        if member.filename.upper().startswith('META-INF/'):
                            continue
                        raw = dex_bytes if member.filename == 'classes.dex' else original.read(member)
                        dest.writestr(copy.copy(member), raw)
                    for name, raw in meta.items():
                        dest.writestr(name, raw, compress_type=zipfile.ZIP_DEFLATED)
                compiled_hashes = {'classes.dex': hashlib.sha256(dex_bytes).hexdigest()}
            else:
                with zipfile.ZipFile(patched) as rebuilt:
                    if len(rebuilt.namelist()) != len(set(rebuilt.namelist())) or rebuilt.testzip():
                        raise ValueError('Duplicate or corrupted rebuilt ZIP')
                    rebuilt_dex = {n for n in rebuilt.namelist() if DEX.fullmatch(n)}
                    if not dex or not dex.issubset(rebuilt_dex):
                        raise ValueError('Compiled DEX set differs from stock')
                    with zipfile.ZipFile(candidate, 'w') as dest:
                        dest.comment = original.comment
                        for member in original.infolist():
                            if member.filename.upper().startswith('META-INF/'):
                                continue
                            raw = rebuilt.read(member.filename) if member.filename in rebuilt_dex else original.read(member)
                            dest.writestr(copy.copy(member), raw)
                        for name, raw in meta.items():
                            dest.writestr(name, raw, compress_type=zipfile.ZIP_DEFLATED)
                    compiled_hashes = {n: hashlib.sha256(rebuilt.read(n)).hexdigest() for n in sorted(rebuilt_dex)}

            report = verify(candidate, reference)
            with zipfile.ZipFile(candidate) as final:
                for n in original.namelist():
                    if n not in rebuilt_dex and not n.upper().startswith('META-INF/'):
                        if final.read(n) != original.read(n):
                            raise ValueError('Non-DEX content changed: ' + n)
            report['base_sha256'] = sha(base)
            report['base_verification'] = base_verification
            report['compiled_dex_sha256'] = compiled_hashes
        os.replace(candidate, output)
    return report


def main():
    p = argparse.ArgumentParser()
    p.add_argument('smali_dir', nargs='?', type=Path)
    p.add_argument('--patch-smali', type=Path)
    p.add_argument('--reference', type=Path)
    p.add_argument('--apk', type=Path)
    p.add_argument('--base', type=Path)
    p.add_argument('--patched', type=Path)
    p.add_argument('--apksigner', type=Path)
    p.add_argument('--java', default='java')
    p.add_argument('--report', type=Path)
    p.add_argument('--check-base', action='store_true')
    p.add_argument('--allow-stripped-base', action='store_true')
    p.add_argument('--verify', action='store_true')
    p.add_argument('--rebuild', action='store_true')
    a = p.parse_args()

    smali_target = a.patch_smali or a.smali_dir
    if smali_target:
        result = patch_smali(smali_target)
        if a.report:
            a.report.parent.mkdir(parents=True, exist_ok=True)
            a.report.write_text(json.dumps(result, indent=2) + '\n')
        print("[POWERKEEPER A17] " + json.dumps(result))
        return

    if a.check_base:
        if not a.apksigner or not a.apk:
            p.error('--check-base requires --apksigner and --apk')
        base_verification = verify_base(
            a.apk, a.apksigner, a.java, a.allow_stripped_base)
        metadata(a.apk)
        result = {'mode': 'verified-xiaomi-base',
                  'base_verification': base_verification,
                  'certificate_sha256': XIAOMI, 'sha256': sha(a.apk)}
    elif a.base or a.rebuild:
        if not a.base or not a.patched or not a.apksigner or not a.apk or not a.reference:
            p.error('--rebuild requires --base, --patched, --apk, --reference and --apksigner')
        result = rebuild(a.base, a.patched, a.reference, a.apk, a.apksigner,
                         a.java, a.allow_stripped_base)
    elif a.apk and a.reference:
        result = verify(a.apk, a.reference)
    else:
        p.error("Unrecognized operation")

    if a.report:
        a.report.parent.mkdir(parents=True, exist_ok=True)
        a.report.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
