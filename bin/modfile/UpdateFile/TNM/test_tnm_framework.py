#!/usr/bin/env python3
"""TNMFramework shell safety/contract smoke tests using mocked Android services."""
from pathlib import Path
from tempfile import TemporaryDirectory
import os
import shutil
import subprocess

src=Path("bin/modfile/UpdateFile/TNM/tnm-frameworkctl").read_text()
assert "TNMFramework v1" in src
assert "No daemon" not in src or "on-demand" in src
for forbidden in ("thermal-nolimits.conf", "setenforce 0", "chmod 777", "pm grant", "service call"):
    assert forbidden not in src, forbidden
assert 'root approval' not in src or '$(id -u)' in src
assert "RYU=/system_ext/bin/ryu-thermalctl" in src
assert "power.saver" in src and "thermal.perapp" in src
assert "display.mode" in src
assert "notifications.status" in src

with TemporaryDirectory() as temp:
    p=Path(temp)
    mock=p/"mock"
    mock.mkdir()
    for key,value in {
      "system-peak_refresh_rate":"120.0",
      "system-min_refresh_rate":"60.0",
      "system-projectryu_thermal_per_app":"0",
      "system-projectryu_thermal_sconfig":"0",
      "system-projectryu_thermal_profiles":"",
      "global-low_power":"0",
    }.items():
        (mock/key).write_text(value)
    settings=p/"settings"
    settings.write_text("""#!/bin/sh
[ "$1" = --user ] && shift 2
command="$1"; shift
table="$1"; shift
key="$1"; shift
file="$MOCK/$table-$key"
case "$command" in
 get) cat "$file" 2>/dev/null || echo null ;;
 put) printf '%s' "$1" > "$file" ;;
 *) exit 2 ;;
esac
""")
    cmd=p/"cmd"
    cmd.write_text("""#!/bin/sh
case "$1" in
 power)
   [ "$2" = set-mode ] || exit 2
   printf '%s' "$3" > "$MOCK/global-low_power"
   ;;
 deviceidle) echo "system,other.example" ;;
 *) exit 2 ;;
esac
""")
    ryu=p/"ryu"
    ryu.write_text("""#!/bin/sh
printf '%s\n' "$*" >> "$MOCK/ryu_calls"
""")
    for f in (settings,cmd,ryu): f.chmod(0o755)
    code=src
    code=code.replace('$(id -u)', '0') # only in temporary test fixture
    code=code.replace('/system_ext/bin/ryu-thermalctl',str(ryu))
    code=code.replace('/system/bin/settings',str(settings))
    code=code.replace('/system/bin/cmd',str(cmd))
    code=code.replace('/system/bin/grep',shutil.which('grep'))
    code=code.replace('/system/bin/pidof',shutil.which('false'))
    code=code.replace('/system/bin/am',shutil.which('echo'))
    code=code.replace('/data/adb/tnm/state',str(p/'state'))
    runner=p/"tnm-frameworkctl"
    runner.write_text(code)
    env={**os.environ,"MOCK":str(mock)}
    def run(*args):
        return subprocess.run(["sh",str(runner),*args],text=True,capture_output=True,env=env)
    subprocess.run(["sh","-n",str(runner)],check=True)
    assert run("protocol").stdout.strip()=="1"
    assert "tnm_framework=1" in run("status").stdout
    assert run("thermal.global","normal").returncode==0
    assert run("thermal.global","nolimits").returncode!=0
    assert run("thermal.perapp","com.example.game:game").returncode==0
    assert run("thermal.perapp","com.bad;id:game").returncode!=0
    assert run("power.saver","on").returncode==0
    assert (mock/"global-low_power").read_text()=="1"
    assert run("power.saver","off").returncode==0
    assert run("display.mode","60").returncode==0
    assert (mock/"system-peak_refresh_rate").read_text()=="60"
    assert run("display.mode","auto").returncode==0
    assert (mock/"system-peak_refresh_rate").read_text()=="120.0"
    assert run("display.mode","999").returncode!=0
    assert run("unsupported.action").returncode!=0
print("TNMFramework mock ROM safety/protocol tests: PASS")
