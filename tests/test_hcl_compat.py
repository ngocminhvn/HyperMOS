"""Isolated Android fixtures; run with unittest discover -s tests -p test_hcl_compat.py."""
import json
import os
import re
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

SRC = Path(__file__).resolve().parents[1] / 'bin/modfile/UpdateFile/HCL_Compat'
FP = 'Xiaomi/haotian/haotian:16/BP2A.250605.031/OS3.0.308.0.WOBCNXM:user/release-keys'
MOCK = '''#!/usr/bin/python3
import json, os, pathlib, sys
root=pathlib.Path(os.environ['HCL_TEST_ROOT']); db=root/'props.json'
p=json.loads(db.read_text()); name=pathlib.Path(sys.argv[0]).name; a=sys.argv[1:]
if name=='getprop': print(p.get(a[0],''))
elif name=='resetprop':
    with (root/'calls').open('a') as f: f.write(json.dumps([name]+a)+'\\n')
    if os.environ.get('DENY_PROP')==a[-2]: sys.exit(1)
    p[a[-2]]=a[-1]; db.write_text(json.dumps(p))
elif name=='ksu_susfs':
    with (root/'calls').open('a') as f: f.write(json.dumps([name]+a)+'\\n')
    if a==['show','version']:
        print(os.environ.get('SUSFS_VERSION','v2.3.0')); sys.exit(int(os.environ.get('SUSFS_UNSUPPORTED','0')))
    if a==['show','enabled_features']: print(os.environ.get('SUSFS_FEATURES','CONFIG_KSU_SUSFS_SUS_PATH\\nCONFIG_KSU_SUSFS_OPEN_REDIRECT'))
    elif a and a[0]=='add_open_redirect':
        old=os.environ.get('SUSFS_VERSION','v2.3.0').startswith(('v1.5.','v2.0.'))
        sys.exit(0 if len(a)==(3 if old else 4) else 2)
elif name=='chcon': sys.exit(0)
'''

class RuntimeTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory(); self.addCleanup(self.temp.cleanup)
        self.root=Path(self.temp.name); self.bin=self.root/'bin'; self.bin.mkdir()
        self.state=self.root/'data/adb/hypermos_hcl'; self.state.mkdir(parents=True)
        self.defaults=self.root/'default.conf'; shutil.copy(SRC/'default.conf',self.defaults)
        props={'ro.product.vendor.device':'haotian','ro.product.vendor.model':'2410DPN6CC',
               'ro.product.vendor.name':'haotian_cn','ro.product.vendor.brand':'Xiaomi',
               'ro.product.vendor.manufacturer':'Xiaomi','ro.build.version.release':'16',
               'ro.mi.os.version.name':'OS3.0','ro.build.fingerprint':'qti/missi/missi:16/ID/1:user/release-keys',
               'ro.vendor.build.fingerprint':FP,'ro.system.build.fingerprint':'old',
               'ro.product.model':'mainline','ro.product.device':'missi','ro.product.name':'missi',
               'ro.product.brand':'Android','ro.product.manufacturer':'unknown',
               'ro.product.system.device':'generic','ro.build.product':'missi',
               'ro.boot.flash.locked':'0','ro.boot.verifiedbootstate':'orange',
               'ro.build.version.security_patch':'2026-09-01'}
        self.db=self.root/'props.json'; self.db.write_text(json.dumps(props))
        (self.root/'system').mkdir()
        (self.root/'system/build.prop').write_text('# preserved\nro.product.system.device=generic\nro.build.fingerprint=old\nro.boot.flash.locked=0\nother=missi & qssi\n')
        (self.root/'product/app/XiaomiEUInject').mkdir(parents=True)
        for name in ('getprop','chcon'): self.mock(self.bin/name)
        self.reset=self.root/'data/adb/ksu/bin/resetprop'; self.susfs=self.root/'data/adb/ksu/bin/ksu_susfs'
        self.mock(self.reset); self.mock(self.susfs)
        self.ctl=self.bin/'hcl-compatctl'
        script=(SRC/'hcl-compatctl').read_text().replace('@HCL_DEFAULTS@',str(self.defaults)).replace('@HCL_CTL@',str(self.ctl))
        script=re.sub(r'/data/adb/|/system/|/system_ext/|/product/|/mnt/vendor/|/vendor/', lambda m: str(self.root)+m[0], script)
        (self.root/'mnt/vendor').mkdir(parents=True)
        script='\n'.join('PATH='+str(self.bin)+':/usr/bin:/bin' if s.startswith('PATH=') else s for s in script.splitlines())+'\n'
        self.ctl.write_text(script); shutil.copy(SRC/'hcl-diagnostics',self.bin/'hcl-diagnostics')
        self.env=dict(os.environ,HCL_TEST_ROOT=str(self.root))
    def mock(self,path):
        path.parent.mkdir(parents=True,exist_ok=True); path.write_text(MOCK); path.chmod(0o755)
    def run_ctl(self,*args):
        return subprocess.run(['sh',str(self.ctl),*args],env=self.env,text=True,capture_output=True,timeout=30)
    def status(self): return dict(s.split('=',1) for s in (self.state/'status').read_text().splitlines())
    def calls(self):
        p=self.root/'calls'; return [json.loads(s) for s in p.read_text().splitlines()] if p.exists() else []
    def test_apply_idempotence_and_security_preservation(self):
        before=json.loads(self.db.read_text()); r=self.run_ctl('apply'); self.assertEqual(r.returncode,0,r.stderr)
        after=json.loads(self.db.read_text())
        self.assertEqual(after['ro.product.device'],'haotian'); self.assertEqual(after['ro.product.name'],'haotian_cn')
        self.assertEqual(after['ro.build.fingerprint'],FP); self.assertEqual(after['ro.system.build.fingerprint'],FP)
        self.assertNotIn('ro.odm_dlkm.build.fingerprint',after)
        for k in ('ro.boot.flash.locked','ro.boot.verifiedbootstate','ro.build.version.security_patch'): self.assertEqual(before[k],after[k])
        view=(self.state/'compat_build.prop').read_text()
        for s in ('ro.product.system.device=haotian','other=missi & qssi','ro.boot.flash.locked=0'): self.assertIn(s,view)
        self.assertEqual(self.status()['susfs_redirect'],'applied')
        self.assertFalse(any(c[1] in ('set_uname','set_cmdline_or_bootconfig') for c in self.calls()))
        n=len([c for c in self.calls() if c[0]=='resetprop']); self.run_ctl('apply')
        self.assertEqual(n,len([c for c in self.calls() if c[0]=='resetprop']))
    def test_no_kernel_support(self):
        self.env['SUSFS_UNSUPPORTED']='1'; self.run_ctl('apply')
        self.assertEqual(self.status()['susfs'],'unsupported_or_unavailable')
        self.assertFalse(any(c[0]=='ksu_susfs' and c[1].startswith('add_') for c in self.calls()))
        self.assertFalse((self.root/'mnt/vendor/susfs4ksu').exists())
    def test_no_backends(self):
        self.reset.unlink(); self.susfs.unlink(); before=self.db.read_text(); self.run_ctl('apply')
        self.assertEqual(self.db.read_text(),before); self.assertEqual(self.status()['resetprop'],'unavailable')
        self.assertIn('ro.product.system.device=generic',(self.state/'compat_build.prop').read_text())
    def test_denied_property(self):
        self.env['DENY_PROP']='ro.product.system.device'; self.run_ctl('apply')
        self.assertEqual(self.status()['properties_failed'],'1')
        self.assertIn('ro.product.system.device=generic',(self.state/'compat_build.prop').read_text())
    def test_wrong_android_fingerprint(self):
        p=json.loads(self.db.read_text()); p['ro.vendor.build.fingerprint']=FP.replace(':16/',':15/'); self.db.write_text(json.dumps(p))
        self.run_ctl('apply'); self.assertEqual(json.loads(self.db.read_text())['ro.system.build.fingerprint'],'old')
        self.assertEqual(self.status()['fingerprint'],'no_matching_candidate')
    def test_invalid_config_is_not_code(self):
        marker=self.root/'injected'; (self.state/'config.conf').write_text(f'enabled=$(touch {marker})\n')
        self.run_ctl('apply'); self.assertFalse(marker.exists()); self.assertFalse(self.calls())
        self.assertEqual(self.status()['result'],'invalid_config')
    def test_disable_readonly_and_excluded_keys(self):
        self.assertEqual(self.run_ctl('set','enabled','false').returncode,0); self.run_ctl('apply')
        self.assertEqual(self.status()['result'],'disabled')
        for cmd in ('status','matrix','security','features','all','config','help'): self.assertEqual(self.run_ctl(cmd).returncode,0,cmd)
        self.assertFalse(self.calls()); self.assertEqual(self.run_ctl('set','spoof_uname','true').returncode,2)
    def test_susfs_old_abi_and_feature_gate(self):
        self.env['SUSFS_VERSION']='v1.5.12'; self.run_ctl('apply'); self.assertEqual(self.status()['susfs_redirect'],'applied')
        self.env['SUSFS_FEATURES']='CONFIG_KSU_SUSFS_SUS_PATH'; self.run_ctl('apply')
        self.assertEqual(self.status()['susfs_redirect'],'unsupported')
    def test_switches_and_missing_source(self):
        for key in ('normalize_identity','normalize_fingerprint','susfs'): self.run_ctl('set',key,'false')
        before=self.db.read_text(); self.run_ctl('apply'); self.assertEqual(before,self.db.read_text()); self.assertFalse(self.calls())
        (self.root/'system/build.prop').unlink(); self.run_ctl('apply')
        self.assertEqual(self.status()['compat'],'missing_source'); self.assertFalse((self.state/'compat_build.prop').exists())

class InstallTests(unittest.TestCase):
    def test_layouts_and_repeat_install(self):
        for layout in ('system_ext','product','system/system','system'):
            with self.subTest(layout=layout), tempfile.TemporaryDirectory() as d:
                root=Path(d); dst=root/'build/baserom/images'/layout; dst.mkdir(parents=True)
                shutil.copytree(SRC,root/'bin/modfile/UpdateFile/HCL_Compat')
                (root/'functions.sh').write_text('mods() { :; }; warn() { :; }; error() { echo "$*" >&2; }\n')
                for _ in range(2): subprocess.run(['bash',str(SRC/'update.sh')],cwd=root,check=True,capture_output=True)
                rc=(dst/'etc/init/hcl-compat.rc').read_text()
                for s in ('oneshot','timeout_period 45','seclabel u:r:su:s0'): self.assertIn(s,rc)
                self.assertNotIn('@HCL_',rc); self.assertFalse(list(SRC.glob('hcl*.sh')))
                subprocess.run(['sh','-n',str(dst/'bin/hcl-compatctl')],check=True)
                self.assertFalse(list((root/'build').rglob('build.prop')))

if __name__=='__main__': unittest.main()
