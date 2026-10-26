#!/usr/bin/env python3
"""EU Android 16 selective ZK304 method port from raw class/*.dex donors.
One patcher contains original per-method notification, Greeze/Doze and
PowerKeeper policies. No compressed donor, JSON file or SHA checking.
Compile and ABI verification are retained; runtime testing remains necessary.
"""
import argparse
import json
import re
import shutil
import subprocess
import tempfile
import zipfile
from pathlib import Path

def _module_contentcatcher():
    #!/usr/bin/env python3
    """Patch only Xiaomi.eu A16 ProcessPolicy.updateContentCatcherWhitelist region gate."""
    import argparse
    import json
    import re
    from pathlib import Path
    
    RELATIVE = "com/android/server/am/ProcessPolicy.smali"
    METHOD = re.compile(
        r"(?ms)^\.method[^\n]*\bupdateContentCatcherWhitelist\(\)V[^\n]*\n.*?^\.end method[ \t]*$"
    )
    READ = re.compile(
        r"(?m)^([ \t]*)sget-boolean[ \t]+([vp]\d+),[ \t]+"
        r"Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z([ \t]*(?:#.*)?)$"
    )
    ALREADY = re.compile(
        r"(?m)^[ \t]*const/4[ \t]+([vp]\d+),[ \t]+0x0[ \t]*(?:#.*)?$\n"
        # Baksmali inserts a blank line between instructions after CorePatch
        # reassembles this JAR. Accept only blank/comment lines, then require the
        # conditional to consume the exact same register.
        r"(?:^[ \t]*(?:#.*)?$\n)*"
        r"^[ \t]*if-(?:eqz|nez)[ \t]+\1,[ \t]+:[^\n]+$"
    )
    
    
    def patch_source(source):
        blocks = list(METHOD.finditer(source))
        if len(blocks) != 1:
            raise ValueError("Expected exactly one updateContentCatcherWhitelist()V")
        method = blocks[0].group()
        reads = list(READ.finditer(method))
        if not reads:
            if len(ALREADY.findall(method)) != 1:
                raise ValueError("No auditable ContentCatcher region gate or existing false gate")
            return source, "already_false"
        if len(reads) != 1 or reads[0].group(2) != "v0":
            raise ValueError("Unexpected ContentCatcher read count/register")
        gate = reads[0]
        indent, register, suffix = gate.groups()
        changed = method[:gate.start()] + f"{indent}const/4 {register}, 0x0{suffix}" + method[gate.end():]
        result = source[:blocks[0].start()] + changed + source[blocks[0].end():]
        if result.replace(changed, method, 1) != source:
            raise ValueError("Unexpected change outside ContentCatcher method")
        return result, "patched"
    
    
    def patch_directory(root):
        matches = [p for p in root.glob("smali*/" + RELATIVE) if p.is_file()]
        if len(matches) != 1:
            raise ValueError("Expected exactly one ProcessPolicy.smali")
        path = matches[0]
        original = path.read_text(encoding="utf-8")
        modified, status = patch_source(original)
        if modified != original:
            path.write_text(modified, encoding="utf-8")
        return {"scope": "xiaomi_eu_a16", "target": RELATIVE,
                "method": "updateContentCatcherWhitelist()V",
                "region_gate": False, "status": status, "other_methods_changed": False}
    
    
    def main():
        parser = argparse.ArgumentParser()
        parser.add_argument("decoded", type=Path)
        parser.add_argument("--report", required=True, type=Path)
        args = parser.parse_args()
        result = patch_directory(args.decoded)
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
        print("[EU CONTENTCATCHER A16] " + json.dumps(result))
    return locals()


def _module_broadcast():
    #!/usr/bin/env python3
    """EU A16 ZKOS 304 parity: no global forced build or CN_MODEL flags.
    
    ZK304 and original EU309 share the same four BroadcastQueue methods, reading
    the native IS_INTERNATIONAL_BUILD boolean. Their PolicyManager.<clinit>
    sets CN_MODEL dynamically from (ro.miui.region == "CN"). Preserve those
    conditions; if a donor alias IS_ZK_BUILD occurs, map to IS_INTERNATIONAL_BUILD.
    The prior constant-true/false patch was NOT a bytecode-equivalent ZK port.
    """
    import argparse
    import json
    import re
    from pathlib import Path
    
    BROADCAST = "com/android/server/am/BroadcastQueueModernStubImpl.smali"
    POLICY = "com/miui/server/greeze/PolicyManager.smali"
    TARGETS = ("checkApplicationAutoStart", "checkReceiverAppDealBroadcast",
               "isInternationalSpecialAction", "updateBlockBroadcast")
    METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
    NATIVE = "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z"
    READ = re.compile(r"(?m)^([ \t]*)sget-boolean\s+(v\d+),\s+(\S+)([ \t]*(?:#.*)?)$")
    LEGACY = re.compile(r"(?m)^([ \t]*)const/(?:4|16)\s+(v\d+),\s+0x1\s+# HYPERMOS_EU_ZK_BROADCAST_A16[ \t]*$")
    ALIAS = ("Lmiui/zk/Build;->IS_ZK_BUILD:Z", "Lmiui/os/Build;->IS_ZK_BUILD:Z")
    WRITE = re.compile(r"(?m)^([ \t]*)sput-boolean\s+(v\d+),\s+Lcom/miui/server/greeze/PolicyManager;->CN_MODEL:Z[ \t]*$")
    FORCED_REGION = re.compile(r"(?m)^([ \t]*)const/(?:4|16)\s+(v\d+),\s+0x0\s+# HYPERMOS_EU_ZK_GREEZE_A16[^\n]*\n")
    
    def method_name(block):
        head = block.split("\n", 1)[0]
        match = re.search(r"([\w<>$-]+)\(", head)
        return match.group(1) if match else None
    
    
    def find_class(root, rel):
        hits = list(root.glob("smali*/" + rel))
        if len(hits) != 1:
            raise ValueError(f"{rel}: expected one class, got {len(hits)}")
        return hits[0]
    
    
    def patch_broadcast(text):
        counts = dict.fromkeys(TARGETS, 0)
        actions = {}
        parts, last = [], 0
        for match in METHOD.finditer(text):
            parts.append(text[last:match.start()])
            block = match.group()
            name = method_name(block)
            if name in counts:
                counts[name] += 1
                if counts[name] != 1:
                    raise ValueError("Duplicate BroadcastQueue method: " + name)
                found = [r for r in READ.finditer(block) if r.group(3) in (NATIVE,) + ALIAS]
                legacy = list(LEGACY.finditer(block))
                if len(found) + len(legacy) != 1:
                    raise ValueError(f"{name}: expected exactly one ZK-compatible read or known legacy marker")
                if legacy:
                    old = legacy[0]
                    replacement = f"{old.group(1)}sget-boolean {old.group(2)}, {NATIVE}"
                    block = block[:old.start()] + replacement + block[old.end():]
                    actions[name] = "reverted_forced_true"
                else:
                    old = found[0]
                    if old.group(3) in ALIAS:
                        replacement = f"{old.group(1)}sget-boolean {old.group(2)}, {NATIVE}{old.group(4)}"
                        block = block[:old.start()] + replacement + block[old.end():]
                        actions[name] = "mapped_IS_ZK_BUILD_to_IS_INTERNATIONAL_BUILD"
                    else:
                        actions[name] = "already_ZK_exact"
                if len([r for r in READ.finditer(block) if r.group(3) == NATIVE]) != 1:
                    raise ValueError(name + ": native flag read not recovered")
                if "HYPERMOS_EU_ZK_BROADCAST_A16" in block:
                    raise ValueError(name + ": stale forced-gate marker")
            parts.append(block)
            last = match.end()
        parts.append(text[last:])
        if any(count != 1 for count in counts.values()):
            raise ValueError("BroadcastQueue method inventory changed: " + str(counts))
        return "".join(parts), actions
    
    
    def patch_policy(text):
        matches = [m for m in METHOD.finditer(text) if method_name(m.group()) == "<clinit>"]
        if len(matches) != 1:
            raise ValueError("PolicyManager: expected exactly one <clinit>")
        m = matches[0]
        block = m.group()
        if block.count('"ro.miui.region"') != 1 or block.count('"CN"') != 1:
            raise ValueError("PolicyManager: donor's region/CN check missing")
        equals_count = (block.count("Ljava/lang/Object;->equals(Ljava/lang/Object;)Z")
                        + block.count("Ljava/lang/String;->equals(Ljava/lang/Object;)Z"))
        if equals_count != 1:
            raise ValueError("PolicyManager: unexpected region comparison count")
        writes = list(WRITE.finditer(block))
        if len(writes) != 1:
            raise ValueError("PolicyManager: expected exactly one CN_MODEL assignment")
        forced = list(FORCED_REGION.finditer(block))
        if len(forced) > 1:
            raise ValueError("PolicyManager: duplicated forced false assignment")
        if forced:
            if forced[0].group(2) != writes[0].group(2):
                raise ValueError("PolicyManager: register mismatch")
            block = block[:forced[0].start()] + block[forced[0].end():]
        required = (r"(?m)^\s*move-result\s+" + re.escape(writes[0].group(2))
                    + r"\s*\n\s*sput-boolean\s+" + re.escape(writes[0].group(2))
                    + r",\s+Lcom/miui/server/greeze/PolicyManager;->CN_MODEL:Z")
        if not re.search(required, block):
            raise ValueError("PolicyManager: CN_MODEL must be assigned the region equals result")
        if "HYPERMOS_EU_ZK_GREEZE_A16" in block:
            raise ValueError("PolicyManager: stale forced-region marker")
        return text[:m.start()] + block + text[m.end():]
    
    
    def apply(root, report):
        targets = {rel: find_class(root, rel) for rel in (BROADCAST, POLICY)}
        originals = {rel: path.read_text(encoding="utf-8") for rel, path in targets.items()}
        broadcast, actions = patch_broadcast(originals[BROADCAST])
        greeze = patch_policy(originals[POLICY])
        # Fail closed: validate both original classes before touching either.
        for rel, content in ((BROADCAST, broadcast), (POLICY, greeze)):
            if content != originals[rel]:
                targets[rel].write_text(content, encoding="utf-8")
        result = {
            "scope": "xiaomi_eu_A16_ZK304_semantic_parity",
            "broadcast_queue": actions,
            "CN_MODEL": "dynamic_ro.miui.region_equals_CN",
            "native_build_field": NATIVE,
            "greeze_isAllowBroadcast_changed": False,
            "greeze_isRestrictReceiver_changed": False,
            "services_jar_changed": False,
            "powerkeeper_changed": False,
            "status": "ZK-equivalent-gates; NOT notification-delivery proof"
        }
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        return result
    
    
    def main():
        parser = argparse.ArgumentParser()
        parser.add_argument("decoded", type=Path)
        parser.add_argument("--report", required=True, type=Path)
        args = parser.parse_args()
        print("[EU ZK PARITY] " + json.dumps(apply(args.decoded, args.report)))
    return locals()


def _module_notification():
    #!/usr/bin/env python3
    """Exact ZKOS HAOTIAN 304 NotificationManager initializer port for EU309 A16.
    
    Original audited donor ZK304 has no cached static IS_INTERNATIONAL_BUILD write
    in NotificationManagerServiceImpl.<clinit> (65 code units); EU309 has two
    additional 2-unit read/write instructions (69 units). Preserve all remaining
    instructions and every EU-only method. Never spoof build or region globally.
    """
    import argparse
    import json
    import re
    from pathlib import Path
    
    REL = "com/android/server/notification/NotificationManagerServiceImpl.smali"
    OWNER = "Lcom/android/server/notification/NotificationManagerServiceImpl;"
    BUILD = "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z"
    METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
    READ = re.compile(r"(?m)^([ \t]*)sget-boolean\s+(v\d+),\s+" + re.escape(BUILD) + r"\s*$")
    WRITE = re.compile(r"(?m)^([ \t]*)sput-boolean\s+(v\d+),\s+" +
                       re.escape(OWNER + "->IS_INTERNATIONAL_BUILD:Z") + r"\s*$")
    TARGET_OTHER = (
        ("com/android/server/DeviceIdleControllerStubImpl.smali", "<clinit>()V"),
        ("com/android/server/am/BroadcastQueueModernStubImpl.smali",
         "checkApplicationAutoStart("),
        ("com/android/server/am/BroadcastQueueModernStubImpl.smali",
         "checkReceiverAppDealBroadcast("),
        ("com/android/server/am/BroadcastQueueModernStubImpl.smali",
         "isInternationalSpecialAction("),
        ("com/android/server/am/BroadcastQueueModernStubImpl.smali",
         "updateBlockBroadcast("),
        ("com/android/server/am/ProcessManagerService.smali", "isForceStopEnable("),
        ("com/android/server/am/ProcessSceneCleaner.smali", "handleSwipeKill("),
        ("com/android/server/am/ProcessSceneCleaner.smali", "killAppForHasOtherTask("),
        ("com/android/server/job/JobServiceContextImpl.smali", "checkIfCancelJob("),
        ("com/android/server/notification/NotificationManagerServiceImpl.smali",
         "checkFullScreenIntent("),
    )
    ZK_ALIAS = "Lmiui/zk/Build;->IS_ZK_BUILD:Z"
    
    
    def one(root, rel):
        paths = list(root.glob("smali*/" + rel))
        if len(paths) != 1:
            raise ValueError(f"Expected one {rel}, found {len(paths)}")
        return paths[0]
    
    
    def find_method(src, name):
        matches = [m for m in METHOD.finditer(src)
                   if m.group().splitlines()[0].strip().split()[-1].startswith(name)]
        if len(matches) != 1:
            raise ValueError(f"Expected one method {name}, found {len(matches)}")
        return matches[0]
    
    
    def normalize(block):
        return tuple(line.strip() for line in block.splitlines()
                     if line.strip() and not line.strip().startswith(
                         ("#", ".line", ".prologue", ".local", ".end local", ".restart local")))
    
    
    def patch_clinit(src, donor=None):
        m = find_method(src, "<clinit>()V")
        block = m.group()
        reads, writes = list(READ.finditer(block)), list(WRITE.finditer(block))
        if not reads and not writes:
            edited = block
            state = "already_zk"
        elif len(reads) == 1 and len(writes) == 1:
            r, w = reads[0], writes[0]
            if r.group(2) != w.group(2) or r.end() > w.start():
                raise ValueError("Unexpected NotificationManager region-gate register/order")
            between = block[r.end():w.start()]
            if any(s.strip() and not s.strip().startswith((".", "#"))
                   for s in between.splitlines()):
                raise ValueError("Unexpected executable code between region-gate instructions")
            edited = block
            for sub in sorted((r, w), key=lambda x: x.start(), reverse=True):
                edited = edited[:sub.start()] + edited[sub.end():]
            state = "ported_zk304"
        else:
            raise ValueError(f"Unexpected gate inventory: reads={len(reads)} writes={len(writes)}")
        if donor is not None:
            z = find_method(donor, "<clinit>()V").group()
            if normalize(edited) != normalize(z):
                raise ValueError("Post-port method differs from real ZK304 donor")
        return src[:m.start()] + edited + src[m.end():], state
    
    
    def verify_other_gates(root):
        result = {}
        for rel, signature in TARGET_OTHER:
            path = one(root, rel)
            m = find_method(path.read_text(encoding="utf-8"), signature)
            block = m.group()
            native = block.count(BUILD)
            if native != 1 or ZK_ALIAS in block:
                raise ValueError(f"{rel}/{signature}: expected one native international-build read, got {native}")
            result[rel + "/" + signature] = "native_IS_INTERNATIONAL_BUILD"
        return result
    
    
    def apply(root, donor_root, report):
        original = one(root, REL)
        zk = one(donor_root, REL)
        src = original.read_text(encoding="utf-8")
        donor = zk.read_text(encoding="utf-8")
        edited, state = patch_clinit(src, donor)
        gates = verify_other_gates(root)
        if src != edited:
            original.write_text(edited, encoding="utf-8")
        result = {
            "source": "ZKOS_HAOTIAN_OS3.0.304.0 donor",
            "target": "Xiaomi.eu A16 original",
            "notification_initializer": state,
            "other_native_gate_methods_verified": len(gates),
            "gates": gates,
            "region_CN_MODEL": "dynamic_and_unchanged",
            "greeze_freeze_thaw_logic": "unchanged",
            "powerkeeper": "not_in_this_patcher",
            "runtime_tested": False
        }
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
        return result
    
    
    def main():
        parser = argparse.ArgumentParser()
        parser.add_argument("decoded_eu", type=Path)
        parser.add_argument("decoded_zk", type=Path)
        parser.add_argument("--report", required=True, type=Path)
        args = parser.parse_args()
        try:
            print("[EU ZK304 NOTIFICATION POLICY] " +
                  json.dumps(apply(args.decoded_eu, args.decoded_zk, args.report)))
        except (ValueError, OSError) as e:
            raise SystemExit("[EU ZK304 NOTIFICATION POLICY] FAIL: " + str(e))
    return locals()


def _module_greeze():
    #!/usr/bin/env python3
    """Port scoped *original ZK304* freeze/broadcast/Doze methods to EU309.
    
    No full-class transplantation: preserves every EU-only method, field and
    constructor. ZK custom boolean is mapped to stock IS_INTERNATIONAL_BUILD.
    Rejects unresolvable intra-framework field/method references; no blanket
    allowlisted apps, background wakelocks, polling, or freezer disabling.
    """
    import argparse
    import json
    import re
    from pathlib import Path
    
    METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
    FIELD = re.compile(r"(?m)^\.field[^\n]*?\s+([\w$<>-]+:[^\s=]+)")
    OWNER = re.compile(r"(?m)^\.class[^\n]*?\s+(L[^;\s]+;)\s*$")
    REFERENCES = re.compile(r"(L[\w/$-]+;)->([\w$<>-]+(?:\([^)]*\)[VZBCSIJFDL\[/;$0-9a-zA-Z_<>-]*|:[^\s,}{]+))")
    TARGETS = {
        "com/miui/server/greeze/GreezeManagerService.smali": (
            "freezeAction(", "freezeUids(", "isAllowBroadcast(",
            "updateDynamicIsLandInfo(",
        ),
        "com/miui/server/greeze/InternationalPolicyManager.smali": (
            "updateDeviceIdleApps(",
        ),
        "com/android/server/DeviceIdleControllerStubImpl.smali": (
            "isLowPowerDozeEnable(",
        ),
        "com/android/server/am/ProcessManagerService.smali": (
            "notifyProcessStarted(",
        ),
    }
    KEEP_EU = {
        "com/miui/server/greeze/InternationalPolicyManager.smali": (
            "getImportantApps()Ljava/util/List;",
        ),
    }
    ALIASES = {
        "Lmiui/zk/Build;->IS_ZK_BUILD:Z":
            "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z",
    }
    # Do not transplant constructors, EU static field initialization, or an
    # unrelated Android system class from a different base version.
    ZK_PRIVATE = ("Lcom/zk/", "Lmiui/zk/")
    
    
    def one(root, suffix):
        found = list(root.glob("smali*/" + suffix))
        if len(found) != 1:
            raise ValueError(f"{suffix}: expected exactly one class, got {len(found)}")
        return found[0]
    
    
    def method_info(block):
        signature = block.splitlines()[0].strip().split()[-1]
        return signature, signature.split("(", 1)[0]
    
    
    def members(root, suffix):
        f = one(root, suffix)
        src = f.read_text(encoding="utf-8")
        owner_match = OWNER.search(src)
        if not owner_match:
            raise ValueError("Class declaration missing in " + suffix)
        methods = {}
        for match in METHOD.finditer(src):
            signature, _ = method_info(match.group())
            if signature in methods:
                raise ValueError("Duplicate " + signature + " in " + suffix)
            methods[signature] = match.group()
        return {"path": f, "source": src, "owner": owner_match.group(1),
                "methods": methods, "fields": set(FIELD.findall(src))}
    
    
    def normalize(block):
        return tuple(line.strip() for line in block.splitlines()
                     if line.strip() and not line.strip().startswith(
                        ("#", ".line", ".param", ".prologue", ".local",
                         ".end local", ".restart local", ".source")))
    
    
    def verify_internal_dependencies(block, eu):
        for marker in ZK_PRIVATE:
            if marker in block:
                raise ValueError("Unsupported ZK-private API: " + marker)
        # Only same-class references can be resolved here. Other framework
        # references remain original EU types and are checked by smali assembly.
        for own, member in REFERENCES.findall(block):
            if own != eu["owner"]:
                continue
            if "(" in member:
                if member not in eu["methods"]:
                    raise ValueError("Missing EU method: " + own + "->" + member)
            elif member not in eu["fields"]:
                raise ValueError("Missing EU field: " + own + "->" + member)
    
    
    def patch_pair(eu, zk, names):
        pending = {}
        statuses = {}
        for prefix in names:
            if prefix.startswith("<"):
                raise ValueError("Never port constructors/initializers with this helper")
            donors = [(k, v) for k, v in zk["methods"].items()
                      if k.startswith(prefix)]
            originals = [(k, v) for k, v in eu["methods"].items()
                         if k.startswith(prefix)]
            if len(donors) != 1 or len(originals) != 1 or donors[0][0] != originals[0][0]:
                raise ValueError(f"{eu['owner']}/{prefix}: method signature mismatch")
            signature, body = donors[0]
            for old, new in ALIASES.items():
                body = body.replace(old, new)
            verify_internal_dependencies(body, eu)
            target = originals[0][1]
            statuses[signature] = ("already_equal" if normalize(body) == normalize(target)
                                   else "ported_zk304")
            pending[signature] = body
        source = eu["source"]
        parts, last = [], 0
        for m in METHOD.finditer(source):
            parts.append(source[last:m.start()])
            sig, _ = method_info(m.group())
            parts.append(pending.get(sig, m.group()))
            last = m.end()
        parts.append(source[last:])
        edited = "".join(parts)
        # Existing EU method inventory and class declaration must be preserved.
        methods_after = [method_info(m.group())[0] for m in METHOD.finditer(edited)]
        if set(methods_after) != set(eu["methods"]) or len(methods_after) != len(eu["methods"]):
            raise ValueError("EU method inventory changed unexpectedly")
        if OWNER.search(edited).group(1) != eu["owner"]:
            raise ValueError("EU class identity changed")
        if set(FIELD.findall(edited)) != eu["fields"]:
            raise ValueError("EU field inventory changed")
        return edited, statuses
    
    
    def port(eu_root, zk_root, report):
        planned, results = {}, {}
        for rel, target_names in TARGETS.items():
            eu = members(eu_root, rel)
            zk = members(zk_root, rel)
            for signature in KEEP_EU.get(rel, ()):
                if signature not in eu["methods"]:
                    raise ValueError("Missing stock EU method to preserve: " + rel + "->" + signature)
            if eu["owner"] != zk["owner"]:
                raise ValueError("Mismatched owner class: " + rel)
            edited, statuses = patch_pair(eu, zk, target_names)
            planned[eu["path"]] = edited
            results[rel] = statuses
        count = sum(v == "ported_zk304" for methods in results.values()
                    for v in methods.values())
        if count == 0:
            raise ValueError("No ZK-specific changes found; refusing false-success")
        # Fail closed: no output is written until all targets pass their checks.
        for path, src in planned.items():
            if path.read_text(encoding="utf-8") != src:
                path.write_text(src, encoding="utf-8")
        result = {
            "source": "ZK304 original miui-services.jar",
            "eu_runtime_classes_preserved": True,
            "eu_only_apis_preserved": True,
            "mode": "selective_donor_method_body_port",
            "changed_methods": count,
            "method_results": results,
            "preserved_eu_methods": KEEP_EU,
            "policy_source_build_flag": "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z",
            "apk_powerkeeper": "unchanged_by_this_step",
            "runtime_verified": False,
            "note": "Not a whole-JAR port. Greeze constructors and EU-only callbacks remain EU309."
        }
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
        return result
    return locals()


def _module_power():
    #!/usr/bin/env python3
    """Port ZK304 PowerKeeper policy *methods* into the original EU PowerKeeper DEX.
    
    Preserve EU classes, fields, methods and APK resources; replace only compatible
    method bodies in power/notification policy controllers. A rejected ZK method is
    reported, not silently copied. Compile/boot/on-device verification is required.
    """
    import argparse
    import json
    import re
    from pathlib import Path
    
    METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
    CLASS = re.compile(r"(?m)^\.class[^\n]*\s+(L[^;\s]+;)[ \t]*$")
    FIELD = re.compile(r"(?m)^\.field[^\n]*\s+([\w$<>-]+:[^\s=]+)")
    MEMBER_REF = re.compile(r"(L[\w/$-]+;)->([^\s,{}\t\r\n]+)")
    CLASS_REF = re.compile(r"Lcom/miui/powerkeeper/[^;\s]+;")
    TARGETS = (
        "Lcom/miui/powerkeeper/utils/GmsObserver;",
        "Lcom/miui/powerkeeper/controller/DeviceIdleController;",
        "Lcom/miui/powerkeeper/controller/DeviceIdleController$1;",
        "Lcom/miui/powerkeeper/controller/DeviceIdleController$2;",
        "Lcom/miui/powerkeeper/controller/ActiveStateController;",
        "Lcom/miui/powerkeeper/controller/KillProcessController;",
    )
    # Keep these exact methods from the stock EU DEX; never replace with ZK.
    KEEP_EU_METHODS = {
        "Lcom/miui/powerkeeper/controller/KillProcessController;": (
            "setUidState(IZ)V",
        ),
    }
    # ZK_BUILD is a renamed native international property in the EU integration.
    ZK_FIELD = "Lmiui/zk/Build;->IS_ZK_BUILD:Z"
    NATIVE_FIELD = "Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z"
    ZK_THERMAL = "/sys/class/thermal/thermal_message/zk_state"
    NATIVE_THERMAL = "/sys/class/thermal/thermal_message/temp_state"
    
    
    def index(root):
        entries = {}
        for path in root.rglob("*.smali"):
            source = path.read_text(encoding="utf-8")
            hit = CLASS.search(source)
            if not hit:
                continue
            owner = hit.group(1)
            if owner in entries:
                raise ValueError("Duplicate smali class: " + owner)
            methods = {}
            for m in METHOD.finditer(source):
                signature = m.group().splitlines()[0].strip().split()[-1]
                if signature in methods:
                    raise ValueError("Duplicate method: " + owner + "->" + signature)
                methods[signature] = m.group()
            fields = set(FIELD.findall(source))
            entries[owner] = {"path": path, "source": source,
                              "methods": methods, "fields": fields}
        return entries
    
    
    def dependencies_ok(method, eu):
        if "Lcom/zk/" in method or "Lmiui/zk/" in method.replace(ZK_FIELD, ""):
            return "requires_ZK_private_API"
        for cls in CLASS_REF.findall(method):
            if cls not in eu:
                return "missing_EU_class:" + cls
        for owner, member in MEMBER_REF.findall(method):
            if not owner.startswith("Lcom/miui/powerkeeper/"):
                continue
            if owner not in eu:
                return "missing_EU_owner:" + owner
            if "(" in member:
                if member not in eu[owner]["methods"]:
                    return "missing_EU_method:" + owner + "->" + member
            elif ":" in member and member not in eu[owner]["fields"]:
                return "missing_EU_field:" + owner + "->" + member
        return None
    
    
    def normalized(method):
        return tuple(line.strip() for line in method.splitlines()
                     if line.strip() and not line.strip().startswith(
                         ("#", ".line", ".prologue", ".local", ".end local", ".restart local")))
    
    
    def transform(donor):
        donor = donor.replace(ZK_FIELD, NATIVE_FIELD)
        donor = donor.replace(ZK_THERMAL, NATIVE_THERMAL)
        if ZK_FIELD in donor or ZK_THERMAL in donor:
            raise ValueError("ZK-specific compatibility rewrite failed")
        return donor
    
    
    def port(eu_root, zk_root):
        eu, zk = index(eu_root), index(zk_root)
        pending, changed, skipped, unchanged, missing = {}, [], [], [], []
        preserved = []
        for owner in TARGETS:
            if owner not in eu or owner not in zk:
                missing.append(owner)
                continue
            src = eu[owner]["source"]
            keep = KEEP_EU_METHODS.get(owner, ())
            for signature in keep:
                if signature not in eu[owner]["methods"]:
                    raise ValueError(f"Missing stock EU method to preserve: {owner}->{signature}")
                preserved.append(owner + "->" + signature)
            replacements = {}
            for signature, donor in zk[owner]["methods"].items():
                key = owner + "->" + signature
                if signature not in eu[owner]["methods"]:
                    missing.append(key)
                    continue
                if signature in keep:
                    continue  # Preserve exact Xiaomi.eu original body and dependencies.
                donor = transform(donor)
                original = eu[owner]["methods"][signature]
                if normalized(original) == normalized(donor):
                    unchanged.append(key)
                    continue
                problem = dependencies_ok(donor, eu)
                if problem is not None:
                    skipped.append({"method": key, "reason": problem})
                    continue
                replacements[signature] = donor
                changed.append(key)
            if replacements:
                parts, last = [], 0
                for m in METHOD.finditer(src):
                    parts.append(src[last:m.start()])
                    signature = m.group().splitlines()[0].strip().split()[-1]
                    parts.append(replacements.get(signature, m.group()))
                    last = m.end()
                parts.append(src[last:])
                pending[eu[owner]["path"]] = "".join(parts)
        # All target classes must be present. Missing donor methods are acceptable
        # only because EU must preserve ABI, not because a whole-class swap is safe.
        if any(x in TARGETS for x in missing):
            raise ValueError("Missing mandatory policy class: " + str(missing))
        if len(changed) < 1:
            raise ValueError("No compatible ZK policy methods to port; refusing false success")
        for path, content in pending.items():
            path.write_text(content, encoding="utf-8")
        return {
            "donor": "original_ZK304_PowerKeeper",
            "method_level_merge": True,
            "eu_original_classes_methods_fields_preserved": True,
            "ported_count": len(changed),
            "ported_methods": changed,
            "preserved_eu_methods": preserved,
            "unchanged_count": len(unchanged),
            "rejected_count": len(skipped),
            "rejected_methods": skipped,
            "eu_missing_donor_signatures": missing,
            "mapped_IS_ZK_BUILD_to_IS_INTERNATIONAL_BUILD": True,
            "stock_thermal_device_node": True,
            "not_byte_identical_to_ZK": True,
            "runtime_tested": False
        }
    
    
    def main():
        p = argparse.ArgumentParser()
        p.add_argument("--eu", type=Path, required=True)
        p.add_argument("--zk", type=Path, required=True)
        p.add_argument("--report", type=Path, required=True)
        args = p.parse_args()
        try:
            report = port(args.eu, args.zk)
            args.report.parent.mkdir(parents=True, exist_ok=True)
            args.report.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n")
            print("[EU ZK304 POWERKEEPER] " + json.dumps({k: v for k, v in report.items()
                 if k not in ("ported_methods", "rejected_methods", "eu_missing_donor_signatures")}))
        except (OSError, ValueError) as exc:
            raise SystemExit("[EU ZK304 POWERKEEPER] FAIL: " + str(exc))
    return locals()



def _module_global_taiwan():
    """Port the seven PowerKeeper behavior differences shared by Global303
    and Taiwan303 to EU309, without a second APK/DEX donor or tablet changes.

    Each change is scoped to its exact EU method and checked before writing.
    Existing GMS, thermal resources, APK members and other methods are retained.
    """
    import re
    from pathlib import Path

    METHOD = re.compile(r"(?ms)^\.method[^\n]*\n.*?^\.end method[ \t]*$")
    ROOT = "com/miui/powerkeeper/"

    def unique(root, rel):
        candidates = list(root.glob("smali*/" + rel))
        if len(candidates) != 1:
            raise ValueError("Global/TW PowerKeeper class missing/ambiguous: " + rel)
        return candidates[0]

    def change_method(source, signature, change, label):
        matches = [m for m in METHOD.finditer(source)
                   if m.group().splitlines()[0].split()[-1] == signature]
        if len(matches) != 1:
            raise ValueError("Global/TW missing/ambiguous EU method: " + label)
        match = matches[0]
        original = match.group()
        transformed = change(original)
        if original == transformed:
            raise ValueError("Global/TW did not change EU method: " + label)
        return source[:match.start()] + transformed + source[match.end():]

    def required_replace(text, pattern, repl, name):
        new, count = re.subn(pattern, repl, text, count=1, flags=re.M)
        if count != 1:
            raise ValueError("Global/TW expected EU pattern absent: " + name)
        return new

    def cloud_receiver(body):
        if "Lmiui/os/Build;->IS_DEBUGGABLE:Z" in body:
            raise ValueError("CloudUpdateReceiver not original EU policy")
        marker = re.search(
            r'(?m)^([ \t]*)const-string(?:/jumbo)?[ \t]+v\d+,[ \t]*"76937"[ \t]*\n'
            r'(?:[^\n]*\n){2}[ \t]*if-eqz[ \t]+(v\d+),[ \t]*(:[\w$]+)[ \t]*\n',
            body
        )
        if marker is None or ":hm_cloud_secret_allowed" in body:
            raise ValueError("CloudUpdateReceiver EU secret-code gate mismatch")
        indent, reg, reject = marker.group(1), marker.group(2), marker.group(3)
        extra = (
            f"{indent}sget-boolean {reg}, Lmiui/os/Build;->IS_DEBUGGABLE:Z\n"
            f"{indent}if-nez {reg}, :hm_cloud_secret_allowed\n"
            f"{indent}sget-boolean {reg}, Lmiui/os/Build;->IS_STABLE_VERSION:Z\n"
            f"{indent}if-nez {reg}, {reject}\n"
            f"    :hm_cloud_secret_allowed\n"
        )
        return body[:marker.end()] + extra + body[marker.end():]

    def get_cloud_server(body):
        return required_replace(
            body,
            r'(?m)^[ \t]*invoke-static[ \t]+\{\},[ \t]*Landroid/miui/AppOpsUtils;->isXOptMode\(\)Z[ \t]*\n'
            r'[ \t]*move-result[ \t]+(v\d+)[ \t]*\n'
            r'[ \t]*if-eqz[ \t]+\1,[ \t]*:[\w$]+[ \t]*\n',
            "", "LocalUpdateUtils.getCloudServer/XOpt"
        )

    def set_server_config(body):
        return required_replace(
            body,
            r'(?m)^[ \t]*invoke-static[ \t]+\{\},[ \t]*Landroid/miui/AppOpsUtils;->isXOptMode\(\)Z[ \t]*\n'
            r'[ \t]*move-result[ \t]+(v\d+)[ \t]*\n'
            r'[ \t]*if-eqz[ \t]+\1,[ \t]*:[\w$]+[ \t]*\n',
            "", "LocalUpdateUtils.setServerConfigurations/XOpt"
        )

    def empty_array_init(body, owner, field):
        if field not in body or "filled-new-array" not in body:
            raise ValueError("Global/TW unexpected EU static array: " + field)
        header = body.splitlines()[0]
        return (
            header + "\n"
            "    .registers 1\n\n"
            "    const/4 v0, 0x0\n"
            "    new-array v0, v0, [Ljava/lang/String;\n"
            f"    sput-object v0, L{owner};->{field}:[Ljava/lang/String;\n\n"
            "    return-void\n"
            ".end method"
        )

    def google_maps_array_init(body):
        owner = ROOT + "utils/PowerModeAdapter"
        if "mGpsPkgName" not in body or "filled-new-array" not in body:
            raise ValueError("PowerModeAdapter original EU map array not found")
        header = body.splitlines()[0]
        return (
            header + "\n"
            "    .registers 1\n\n"
            '    const-string v0, "com.google.android.apps.maps"\n'
            "    filled-new-array {v0}, [Ljava/lang/String;\n"
            "    move-result-object v0\n"
            f"    sput-object v0, L{owner};->mGpsPkgName:[Ljava/lang/String;\n\n"
            "    return-void\n"
            ".end method"
        )

    def default_sleep_ui(body):
        if "Lmiui/os/HyperOSCustFeatureResolve;->getBoolean(Ljava/lang/String;Z)Z" not in body:
            raise ValueError("Global/TW EU Sleep Mode feature gate missing")
        return required_replace(
            body,
            r'(?m)(^[ \t]*const-string(?:/jumbo)?[ \t]+v0,[ \t]*"support_sleep_mode"[ \t]*\n'
            r'[ \t]*const/4[ \t]+v1,[ \t]*)0x1(?=[ \t]*$)',
            r'\g<1>0x0', "Utils.isSleepModeViewVisable"
        )


    def dynamic_turbo_region(body):
        # Global/Taiwan gates DynamicTurboPower on ro.miui.region == cn.
        # Insert before EU's sole context load, keeping registers/labels intact.
        context = r'Lf/p;->b:Landroid/content/Context;'
        if "Le/f;->f()Z" not in body or "ro.miui.region" in body:
            raise ValueError("Global/TW DynamicTurboPower original EU gate mismatch")
        loads = list(re.finditer(
            r'(?m)^[ \t]*iget-object[ \t]+v6,[ \t]*v5,[ \t]*' +
            re.escape(context) + r'[ \t]*$', body))
        if len(loads) != 1:
            raise ValueError("Global/TW DynamicTurboPower context load count mismatch")
        match = loads[0]
        gates = list(re.finditer(
            r'(?m)^[ \t]*if-eqz[ \t]+v6,[ \t]*(:[\w$]+)[ \t]*$',
            body[:match.start()]))
        if len(gates) != 1:
            raise ValueError("Global/TW DynamicTurboPower early return gate mismatch")
        exit_label = gates[0].group(1)
        addition = (
            '    const-string v6, "ro.miui.region"\n'
            '    const-string v0, "unknown"\n'
            '    invoke-static {v6, v0}, Landroid/os/SystemProperties;->get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;\n'
            '    move-result-object v6\n'
            '    const-string v0, "cn"\n'
            '    invoke-virtual {v6, v0}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z\n'
            '    move-result v6\n'
            '    if-eqz v6, ' + exit_label + '\n'
        )
        return body[:match.start()] + addition + body[match.start():]

    def static_string(source, field, value):
        pattern = (
            r'(?m)^([ \t]*\.field[^\n]*\b' + re.escape(field) +
            r':Ljava/lang/String;)(?:[ \t]*=[ \t]*"[^"\n]*")?[ \t]*$'
        )
        return required_replace(source, pattern,
                                lambda match: match.group(1) + ' = "' + value + '"',
                                "InternationalAdapter." + field)

    def apply(root):
        plans = {}
        actions = (
            ("cloudcontrol/CloudUpdateReceiver.smali",
             "onReceive(Landroid/content/Context;Landroid/content/Intent;)V",
             cloud_receiver),
            ("cloudcontrol/LocalUpdateUtils.smali",
             "getCloudServer(Landroid/content/Context;)Ljava/lang/String;",
             get_cloud_server),
            ("cloudcontrol/LocalUpdateUtils.smali",
             "setServerConfigurations(Landroid/content/Context;)V",
             set_server_config),
            ("utils/InternationalAdapter.smali", "<clinit>()V",
             lambda b: empty_array_init(b, ROOT + "utils/InternationalAdapter", "mRestrictPkgs")),
            ("utils/PowerModeAdapter.smali", "<clinit>()V",
             google_maps_array_init),
            ("utils/Utils.smali", "isSleepModeViewVisable()Z", default_sleep_ui),
            ("f/h.smali", "c(Landroid/content/Context;)Lf/j;", dynamic_turbo_region),
        )
        methods = []
        for rel, signature, transform in actions:
            file = unique(root, ROOT + rel if not rel.startswith("f/") else rel)
            source = plans.get(file, file.read_text(encoding="utf-8"))
            plans[file] = change_method(source, signature, transform, rel)
            methods.append(rel + "->" + signature)
        file = unique(root, ROOT + "utils/InternationalAdapter.smali")
        source = plans[file]
        source = static_string(source, "sNetworkAllowApps", "")
        source = static_string(source, "AWEME_APP", "")
        plans[file] = source
        # All seven methods + two global static defaults must pass before writing.
        for file, source in plans.items():
            file.write_text(source, encoding="utf-8")
        return {
            "source": "Global303/Taiwan303 common behavior (EU-relative DEX audit)",
            "ported_methods": methods,
            "ported_count": len(methods),
            "global_taiwan_static_defaults": ["sNetworkAllowApps", "AWEME_APP"],
            "power_mode_gps_packages": ["com.google.android.apps.maps"],
            "taiwan_only_tablet_methods": "excluded",
            "gms_observer": "unchanged_by_global_taiwan_layer",
            "eu_killprocess_setUidState": "preserved",
            "other_powerkeeper_methods": "unchanged_by_global_taiwan_layer",
            "apk_resources": "preserved",
            "ported_via": "fail_closed_EU_smali_structural_edits",
            "runtime_tested": False
        }
    return locals()

def _cmd(*parts):
    subprocess.run([str(p) for p in parts], check=True, stdout=subprocess.DEVNULL)

def _donor_directories(root, directory, tools):
    """Decode original ZK304 DEX class files from the local donor directory."""
    sources = {
        "services": root / "miui-services",
        "power": root / "powerkeeper"
    }
    result = {}
    for family, path in sources.items():
        if not path.is_dir():
            raise ValueError("ZK donor class directory missing: " + str(path))
        files = sorted(p for p in path.iterdir()
                       if p.is_file() and re.fullmatch(r"classes\d*\.dex", p.name))
        if not files or (family == "power" and len(files) != 1):
            raise ValueError("ZK donor DEX inventory invalid: " + str(path))
        if "classes.dex" not in {p.name for p in files}:
            raise ValueError("Primary classes.dex missing in " + str(path))
        if any(p.name not in {f"classes{n}.dex" for n in range(2, len(files) + 1)}
               | {"classes.dex"} for p in files):
            raise ValueError("ZK donor DEX numbering gap in " + str(path))
        out = directory / family
        for file in files:
            data = file.read_bytes()
            if len(data) < 112 or not data.startswith(b"dex\n"):
                raise ValueError("Malformed DEX header: " + str(file))
            group = "smali" if file.name == "classes.dex" else "smali_" + file.stem
            _cmd("java", "-jar", tools / "baksmaliv2.jar", "d", "--api", "36",
                 file, "-o", out / group)
        result[family] = out
    return result["services"], result["power"]

def _dex_extract(target, base, root, tools):
    with zipfile.ZipFile(target) as archive:
        infos=archive.infolist()
        names=[x.filename for x in infos]
        if len(names)!=len(set(names)):
            raise ValueError("Duplicate archive member: "+str(target))
        dexes=[n for n in names if re.fullmatch(r"classes\d*\.dex",n)]
        if not dexes: raise ValueError("No DEX in "+str(target))
        contents={x.filename:archive.read(x.filename) for x in infos}
        comment=archive.comment
    for n in dexes:
        input_dex=base/n
        input_dex.write_bytes(contents[n])
        _cmd("java","-jar",tools/"baksmaliv2.jar","d","--api","36",input_dex,
             "-o",root/("smali" if n=="classes.dex" else "smali_"+n[:-4]))
    return infos,contents,comment,dexes

def _dex_rebuild(infos, contents, comment, dexes, base, root, tools, output):
    compiled={}
    verified=base/"verified"
    for n in dexes:
        label="smali" if n=="classes.dex" else "smali_"+n[:-4]
        new_dex=base/("patched-"+n)
        _cmd("java","-jar",tools/"smaliv2.jar","a","--api","36",root/label,"-o",new_dex)
        _cmd("java","-jar",tools/"baksmaliv2.jar","d","--api","36",new_dex,
             "-o",verified/label)
        compiled[n]=new_dex.read_bytes()
    for f in verified.rglob("*.smali"):
        txt=f.read_text(encoding="utf-8")
        if "Lmiui/zk/Build;->IS_ZK_BUILD:Z" in txt:
            raise ValueError("Unmapped private ZK build flag remains after rebuild "+str(f))
    with zipfile.ZipFile(output,"w") as archive:
        archive.comment=comment
        for info in infos:
            archive.writestr(info,compiled.get(info.filename,contents[info.filename]))
    with zipfile.ZipFile(output) as archive:
        if archive.namelist()!=[info.filename for info in infos]:
            raise ValueError("Member inventory changed in "+str(output))
        if any(archive.read(n)!=v for n,v in contents.items() if n not in dexes):
            raise ValueError("Non-DEX content was modified unexpectedly")
    return verified

def _run(options):
    tools = options.tools.resolve() if options.tools else Path(__file__).resolve().parents[4] / "apktool"
    if not all((tools / f).is_file() for f in ("baksmaliv2.jar", "smaliv2.jar")):
        raise ValueError("HyperMOS smali tools missing: " + str(tools))
    donor = Path(__file__).resolve().parent / "class"
    if options.check_donor_only:
        with tempfile.TemporaryDirectory(prefix="zk304-donor-check-") as folder:
            services, power = _donor_directories(donor, Path(folder), tools)
            classes = [*services.rglob("*.smali"), *power.rglob("*.smali")]
            if not classes:
                raise ValueError("Raw DEX donor decoded without classes")
            print("[EU ZK304] PASS: raw DEX parsed, classes:", len(classes))
        return
    if not options.images or not options.report:
        raise ValueError("--images and --report required")
    images = options.images.resolve()
    def find_one(name):
        matches = list(images.rglob(name))
        if len(matches) != 1:
            raise ValueError(f"Expected one {name}, found {len(matches)}")
        return matches[0]
    jar, apk = find_one("miui-services.jar"), find_one("PowerKeeper.apk")
    report = options.report.resolve()
    # Prepare and verify both targets before replacing either image.
    with tempfile.TemporaryDirectory(prefix="zk304-eu-") as folder:
        temp = Path(folder)
        services, power = _donor_directories(donor, temp / "donor", tools)
        changes, pending = {}, []
        modules = {name: globals()["_module_" + name]() for name in
                   ("contentcatcher", "broadcast", "notification", "greeze", "power", "global_taiwan")}
        for index, source in enumerate((jar, apk)):
            work = temp / str(index)
            work.mkdir()
            decoded = work / "decoded"
            infos, content, comment, dexes = _dex_extract(source, work, decoded, tools)
            if source == jar:
                changes["contentcatcher"] = modules["contentcatcher"]["patch_directory"](decoded)
                changes["broadcast"] = modules["broadcast"]["apply"](decoded, work / "broadcast.json")
                changes["notification"] = modules["notification"]["apply"](decoded, services, work / "notification.json")
                changes["greeze"] = modules["greeze"]["port"](decoded, services, work / "greeze.json")
            else:
                changes["power"] = modules["power"]["port"](decoded, power)
                changes["global_taiwan"] = modules["global_taiwan"]["apply"](decoded)
            built = work / ("patched-" + source.name)
            verified = _dex_rebuild(infos, content, comment, dexes, work, decoded, tools, built)
            if source == jar:
                modules["notification"]["verify_other_gates"](verified)
            else:
                aligned = work / "aligned.apk"
                _cmd("zipalign", "-p", "-f", "4", built, aligned)
                _cmd("zipalign", "-c", "-p", "4", aligned)
                with zipfile.ZipFile(aligned) as zipped:
                    if zipped.namelist() != [x.filename for x in infos]:
                        raise ValueError("Aligned PowerKeeper changed ZIP membership")
                    if any(zipped.read(n) != v for n, v in content.items() if n not in dexes):
                        raise ValueError("Aligned PowerKeeper changed non-DEX content: invalid")
                built = aligned
            pending.append((source, built))
        for source, built in pending:
            shutil.copyfile(built, source)
            if source == apk:
                shutil.rmtree(apk.parent / "oat", ignore_errors=True)
        result = {
            "donor": "ZK304 class/*.dex",
            "status": "patched_and_compiled",
            "method_scope": "original notification, Greeze/Doze, PowerKeeper port algorithms",
            "complete_zk_rom_parity": False,
            "original_apk_signature_still_valid": False,
            "apk_non_dex_content_preserved": True,
            "runtime_tested": False,
            "changes": changes
        }
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print("[EU ZK304] PASS: all compatible method ports built, original EU JAR/APK only")

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--check-donor-only",action="store_true")
    parser.add_argument("--images",type=Path)
    parser.add_argument("--tools",type=Path)
    parser.add_argument("--report",type=Path)
    
    args=parser.parse_args()
    _run(args)

if __name__=="__main__":
    try:main()
    except (OSError,ValueError,subprocess.CalledProcessError,KeyError,zipfile.BadZipFile) as exc:
        raise SystemExit("[EU ZK304] FAIL: "+str(exc))
