import importlib.util, pathlib, tempfile, subprocess, shutil, os
root=pathlib.Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('props',root/'bin/package/KAORIOS_TOOLBOX/normalize_fakelock_props.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
payload=root/'bin/package/KAORIOS_TOOLBOX/prop/build.prop'
with tempfile.TemporaryDirectory() as d:
    p=pathlib.Path(d)/'build.prop'
    p.write_text('ro.build.tags=release-keys\nro.oem_unlock_supported=1\nro.product.first_api_level=35\n#PlayIntegrityFix\nro.oem_unlock_supported=0\ninit.svc.adbd=stopped\nro.build.keys=release-keys\nro.secureboot.lockstate=unknown\ncustom.keep=1\n')
    m.update(p,payload);first=p.read_text();m.update(p,payload)
    assert p.read_text()==first
    assert 'ro.oem_unlock_supported=1\n' in first and 'ro.oem_unlock_supported=0' not in first
    assert 'init.svc.adbd' not in first and 'custom.keep=1' in first
    assert first.count('ro.secureboot.lockstate=locked')==1
for mode in ('success','unpack_fail','missing_output'):
    with tempfile.TemporaryDirectory() as d:
        p=pathlib.Path(d);hma=p/'bin/package/DISABLE_AVB/HMATools';hma.mkdir(parents=True);(hma/'aosp').mkdir()
        shutil.copy(root/'bin/package/DISABLE_AVB/HMATools/start',hma/'start')
        (p/'functions.sh').write_text('info() { echo "$*"; }; error() { echo "$*"; }; disable_avb_verify() { :; }\n')
        images=p/'build/baserom/images';images.mkdir(parents=True);(images/'boot.img').write_text('original')
        mock=p/'mock';mock.mkdir();java=mock/'java'
        java.write_text('''#!/bin/bash
case "$3" in
clear) rm -rf build; rm -f *.signed;;
unpack) [ "$MODE" != unpack_fail ] || { echo diagnostic-unpack; exit 7; }; mkdir -p build/unzip_boot;;
pack) [ "$MODE" != missing_output ] || exit 0; printf modified > boot.img.signed;;
esac
''');java.chmod(0o755)
        env=dict(os.environ,PATH=str(mock)+':'+os.environ['PATH'],MODE=mode)
        r=subprocess.run(['bash',str(hma/'start')],env=env,capture_output=True,text=True)
        assert (r.returncode==0)==(mode=='success'), (mode,r.stdout,r.stderr)
        assert (images/'boot.img').read_text()==('modified' if mode=='success' else 'original')
        if mode=='unpack_fail': assert 'diagnostic-unpack' in r.stderr
print('PASS: property migration/idempotence/stock preservation; HMATools success, unpack failure, missing output')
