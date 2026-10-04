#!/usr/bin/env bash
# patcher_a16.sh - Android 16 framework/services patcher
work_dir=$(pwd)
WORK_DIR="$work_dir"
BACKUP_DIR="$WORK_DIR/backup"
SCRIPT_DIR="$work_dir/bin/package/COREPATCH"
TOOLS_DIR="$work_dir/bin/apktool"
source "${SCRIPT_DIR}/helper.sh"
regionTYPE=$(cat $work_dir/bin/ddevice/device_type.txt)
# Create backup directory
mkdir -p "$BACKUP_DIR"

# API level for baksmali/smali v2
API_LEVEL=36

# ============================================
# Feature Flags (set by command-line arguments)
# ============================================
FEATURE_DISABLE_SIGNATURE_VERIFICATION=0
FEATURE_CN_NOTIFICATION_FIX=0
FEATURE_DISABLE_SECURE_FLAG=0
FEATURE_MICTS_POWER_KEY=0
FEATURE_PASSKEY=0

parse_feature_flags() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --disable-signature-verification)
        FEATURE_DISABLE_SIGNATURE_VERIFICATION=1
        ;;
      --cn-notification-fix)
        FEATURE_CN_NOTIFICATION_FIX=1
        ;;
      --disable-secure-flag)
        FEATURE_DISABLE_SECURE_FLAG=1
        ;;
      --micts-power-key)
        FEATURE_MICTS_POWER_KEY=1
        ;;
      --passkey)
        FEATURE_PASSKEY=1
        ;;
      *)
        err "Unknown Android 16 COREPATCH option: $1"
        return 1
        ;;
    esac
    shift
  done

  log "Android 16 COREPATCH features:"
  [ "$FEATURE_DISABLE_SIGNATURE_VERIFICATION" -eq 1 ] && log "  [PATCH] Disable Signature Verification"
  [ "$FEATURE_CN_NOTIFICATION_FIX" -eq 1 ] && log "  [PATCH] CN Notification Fix"
  [ "$FEATURE_DISABLE_SECURE_FLAG" -eq 1 ] && log "  [PATCH] Disable Secure Flag"
  [ "$FEATURE_MICTS_POWER_KEY" -eq 1 ] && log "  [PATCH] Long Press Power -> MiCTS"
  [ "$FEATURE_PASSKEY" -eq 1 ] && log "  [PATCH] Google Passkey / Credential Manager"

  if [ "$FEATURE_DISABLE_SIGNATURE_VERIFICATION" -eq 0 ] &&
     [ "$FEATURE_CN_NOTIFICATION_FIX" -eq 0 ] &&
     [ "$FEATURE_DISABLE_SECURE_FLAG" -eq 0 ] &&
     [ "$FEATURE_MICTS_POWER_KEY" -eq 0 ] &&
     [ "$FEATURE_PASSKEY" -eq 0 ]; then
    warn "No Android 16 COREPATCH feature selected"
  fi
}

# ----------------------------------------------
# Internal helpers (python-powered transformations)
# ----------------------------------------------

insert_line_before_all() {
  local file="$1"
  local pattern="$2"
  local new_line="$3"

  python3 - "$file" "$pattern" "$new_line" << 'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
pattern = sys.argv[2]
new_line = sys.argv[3]

if not path.exists():
    sys.exit(4)

lines = path.read_text().splitlines()
matched = False
changed = False

i = 0
while i < len(lines):
    line = lines[i]
    if pattern in line:
        matched = True
        indent = re.match(r"\s*", line).group(0)
        candidate = f"{indent}{new_line}"
        if i > 0 and lines[i - 1].strip() == new_line.strip():
            i += 1
            continue
        lines.insert(i, candidate)
        changed = True
        i += 2
    else:
        i += 1

if not matched:
    sys.exit(3)

if changed:
    path.write_text("\n".join(lines) + "\n")
PY

  local status=$?
  case "$status" in
    0)
      log "Inserted '${new_line}' before lines containing pattern '${pattern##*/}' in $(basename "$file")"
      ;;
    3)
      warn "Pattern '${pattern}' not found in $(basename "$file")"
      ;;
    4)
      warn "File not found: $file"
      ;;
    *)
      err "Failed to insert '${new_line}' in $file (status $status)"
      return 1
      ;;
  esac

  return 0
}

insert_const_before_condition_near_string() {
  local file="$1"
  local search_string="$2"
  local condition_prefix="$3"
  local register="$4"
  local value="$5"

  python3 - "$file" "$search_string" "$condition_prefix" "$register" "$value" << 'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
search_string = sys.argv[2]
condition_prefix = sys.argv[3]
register = sys.argv[4]
value = sys.argv[5]

if not path.exists():
    sys.exit(4)

lines = path.read_text().splitlines()
matched = False
changed = False

for idx, line in enumerate(lines):
    if search_string in line:
        matched = True
        start = max(0, idx - 20)
        for j in range(idx - 1, start - 1, -1):
            stripped = lines[j].strip()
            if stripped.startswith(condition_prefix):
                indent = re.match(r"\s*", lines[j]).group(0)
                insert_line = f"{indent}const/4 {register}, 0x{value}"
                if j == 0 or lines[j - 1].strip() != f"const/4 {register}, 0x{value}":
                    lines.insert(j, insert_line)
                    changed = True
                break

if not matched:
    sys.exit(3)

if changed:
    path.write_text("\n".join(lines) + "\n")
PY

  local status=$?
  case "$status" in
    0)
      log "Inserted const for ${register} near condition '${condition_prefix}' in $(basename "$file")"
      ;;
    3)
      warn "Search string '${search_string}' not found in $(basename "$file")"
      ;;
    4)
      warn "File not found: $file"
      ;;
    *)
      err "Failed to patch condition in $file (status $status)"
      return 1
      ;;
  esac

  return 0
}

replace_move_result_after_invoke() {
  local file="$1"
  local invoke_pattern="$2"
  local replacement="$3"

  python3 - "$file" "$invoke_pattern" "$replacement" << 'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
invoke_pattern = sys.argv[2]
replacement = sys.argv[3]

if not path.exists():
    sys.exit(4)

lines = path.read_text().splitlines()
matched = False
changed = False

i = 0
while i < len(lines):
    line = lines[i]
    if invoke_pattern in line:
        matched = True
        for j in range(i + 1, min(i + 6, len(lines))):
            target = lines[j].strip()
            if target.startswith('move-result'):
                indent = re.match(r"\s*", lines[j]).group(0)
                desired = f"{indent}{replacement}"
                if target == replacement:
                    break
                if lines[j].strip() == replacement:
                    break
                lines[j] = desired
                changed = True
                break
        i = i + 1
    else:
        i += 1

if not matched:
    sys.exit(3)

if changed:
    path.write_text("\n".join(lines) + "\n")
PY

  local status=$?
  case "$status" in
    0)
      log "Replaced move-result after invoke '${invoke_pattern##*/}' in $(basename "$file")"
      ;;
    3)
      warn "Invoke pattern '${invoke_pattern}' not found in $(basename "$file")"
      ;;
    4)
      warn "File not found: $file"
      ;;
    *)
      err "Failed to replace move-result in $file (status $status)"
      return 1
      ;;
  esac

  return 0
}

force_methods_return_const() {
  local file="$1"
  local method_substring="$2"
  local ret_val="$3"

  if [ -z "$file" ]; then
    warn "force_methods_return_const: skipped empty file path for '${method_substring}'"
    return 0
  fi

  if [ ! -f "$file" ]; then
    warn "force_methods_return_const: file not found $file"
    return 0
  fi

  python3 - "$file" "$method_substring" "$ret_val" << 'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
method_key = sys.argv[2]
ret_val = sys.argv[3]

if not path.exists():
    sys.exit(4)

lines = path.read_text().splitlines()
found = 0
modified = 0
const_line = f"const/4 v0, 0x{ret_val}"

i = 0
while i < len(lines):
    stripped = lines[i].lstrip()
    if stripped.startswith('.method') and method_key in stripped:
        if ')V' in stripped:
            i += 1
            continue
        found += 1
        j = i + 1
        while j < len(lines) and not lines[j].lstrip().startswith('.end method'):
            j += 1
        if j >= len(lines):
            break
        body = lines[i:j+1]
        already = (
            len(body) >= 4
            and body[1].strip() == '.registers 8'
            and body[2].strip() == const_line
            and body[3].strip().startswith('return')
        )
        if already:
            i = j + 1
            continue
        stub = [
            lines[i],
            '    .registers 8',
            f'    {const_line}',
            '    return v0',
            '.end method'
        ]
        lines[i:j+1] = stub
        modified += 1
        i = i + len(stub)
    else:
        i += 1

if modified:
    path.write_text('\n'.join(lines) + '\n')

if found == 0:
    sys.exit(3)
PY

  local status=$?
  case "$status" in
    0)
      log "Set return constant 0x${ret_val} for methods containing '${method_substring}' in $(basename "$file")"
      ;;
    3)
      warn "No methods containing '${method_substring}' found in $(basename "$file")"
      ;;
    4)
      warn "File not found: $file"
      ;;
    *)
      err "Failed to rewrite methods '${method_substring}' in $file (status $status)"
      return 1
      ;;
  esac

  return 0
}

# Function to replace an entire method with a custom implementation
replace_entire_method() {
  local method_signature="$1"
  local decompile_dir="$2"
  local new_method_body="$3"
  local specific_class="$4" # Optional: specific class name to search in
  local file

  # If specific class provided, search in that class file
  if [ -n "$specific_class" ]; then
    file=$(find "$decompile_dir" -type f -path "*/${specific_class}.smali" | head -n 1)
    if [ -z "$file" ]; then
      warn "Class file $specific_class.smali not found"
      return 0
    fi
    # Verify method exists in this file
    if ! grep -s -q "\.method.* ${method_signature}" "$file" 2> /dev/null; then
      warn "Method $method_signature not found in $specific_class"
      return 0
    fi
  else
    # Search across all smali files
    file=$(find "$decompile_dir" -type f -name "*.smali" -exec grep -s -l "\.method.* ${method_signature}" {} + 2> /dev/null | head -n 1)
  fi

  [ -z "$file" ] && {
    warn "Method $method_signature not found in decompile directory"
    return 0
  }

  local start
  start=$(grep -n "^[[:space:]]*\.method.* ${method_signature}" "$file" | cut -d: -f1 | head -n1)
  [ -z "$start" ] && {
    warn "Method $method_signature start not found in $(basename "$file")"
    return 0
  }

  local total_lines end=0 i="$start" line
  total_lines=$(wc -l < "$file")
  while [ "$i" -le "$total_lines" ]; do
    line=$(sed -n "${i}p" "$file")
    [[ "$line" == *".end method"* ]] && {
      end="$i"
      break
    }
    i=$((i + 1))
  done

  [ "$end" -eq 0 ] && {
    warn "Method $method_signature end not found in $(basename "$file")"
    return 0
  }

  local method_head
  method_head=$(sed -n "${start}p" "$file")
  method_head_escaped=$(printf "%s\n" "$method_head" | sed 's/\\/\\\\/g')

  # Replace the entire method with the new body
  sed -i "${start},${end}c\\
$method_head_escaped\\
$new_method_body\\
.end method" "$file"

  log "✓ Replaced entire method $method_signature in $(basename "$file")"
  return 0
}

replace_if_block_in_strict_jar_file() {
  local file="$1"

  python3 - "$file" << 'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
if not path.exists():
    sys.exit(4)

lines = path.read_text().splitlines()
changed = False

for idx, line in enumerate(lines):
    if 'invoke-virtual {p0, v5}, Landroid/util/jar/StrictJarFile;->findEntry(Ljava/lang/String;)Ljava/util/zip/ZipEntry;' in line:
        # locate if-eqz v6
        if_idx = None
        for j in range(idx + 1, min(idx + 12, len(lines))):
            stripped = lines[j].strip()
            if stripped.startswith('if-eqz v6, :cond_'):
                if_idx = j
                break
        if if_idx is not None:
            del lines[if_idx]
            changed = True
        # adjust label
        for j in range(idx + 1, min(idx + 20, len(lines))):
            stripped = lines[j].strip()
            if re.match(r':cond_[0-9a-zA-Z_]+', stripped):
                indent = re.match(r'\s*', lines[j]).group(0)
                label = stripped
                # ensure a nop directly after label
                if j + 1 < len(lines) and lines[j + 1].strip() == 'nop':
                    break
                lines.insert(j + 1, f'{indent}nop')
                lines[j] = f'{indent}{label}'
                changed = True
                break
        break

if changed:
    path.write_text('\n'.join(lines) + '\n')
PY

  local status=$?
  case "$status" in
    0)
      log "Removed if-eqz guard in $(basename "$file")"
      ;;
    4)
      warn "StrictJarFile.smali not found"
      ;;
    *)
      err "Failed to adjust StrictJarFile (status $status)"
      return 1
      ;;
  esac

  return 0
}

patch_reconcile_clinit() {
  local file="$1"

  python3 - "$file" << 'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
if not path.exists():
    sys.exit(4)

lines = path.read_text().splitlines()
changed = False

for idx, line in enumerate(lines):
    if '.method static constructor <clinit>()V' in line:
        for j in range(idx + 1, len(lines)):
            stripped = lines[j].strip()
            if stripped == '.end method':
                break
            if stripped == 'const/4 v0, 0x0':
                lines[j] = lines[j].replace('0x0', '0x1')
                changed = True
                break
        break

if changed:
    path.write_text('\n'.join(lines) + '\n')
PY

  local status=$?
  case "$status" in
    0)
      log "Updated <clinit> constant in $(basename "$file")"
      ;;
    4)
      warn "ReconcilePackageUtils.smali not found"
      ;;
    *)
      err "Failed to patch ReconcilePackageUtils (status $status)"
      return 1
      ;;
  esac

  return 0
}

ensure_const_before_if_for_register() {
  local file="$1"
  local invoke_pattern="$2"
  local condition_prefix="$3"
  local register="$4"
  local value="$5"

  python3 - "$file" "$invoke_pattern" "$condition_prefix" "$register" "$value" << 'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
invoke_pattern = sys.argv[2]
condition_prefix = sys.argv[3]
register = sys.argv[4]
value = sys.argv[5]

if not path.exists():
    sys.exit(4)

lines = path.read_text().splitlines()
matched = False
changed = False

for idx, line in enumerate(lines):
    if invoke_pattern in line:
        matched = True
        for j in range(max(0, idx - 1), max(0, idx - 10), -1):
            stripped = lines[j].strip()
            if stripped.startswith(condition_prefix):
                indent = re.match(r'\s*', lines[j]).group(0)
                insert_line = f'{indent}const/4 {register}, 0x{value}'
                if j == 0 or lines[j - 1].strip() != f'const/4 {register}, 0x{value}':
                    lines.insert(j, insert_line)
                    changed = True
                break

if not matched:
    sys.exit(3)

if changed:
    path.write_text('\n'.join(lines) + '\n')
PY

  local status=$?
  case "$status" in
    0)
      log "Forced ${register} to 0x${value} before condition '${condition_prefix}' in $(basename "$file")"
      ;;
    3)
      warn "Invoke pattern '${invoke_pattern}' not found in $(basename "$file")"
      ;;
    4)
      warn "File not found: $file"
      ;;
    *)
      err "Failed to enforce const on ${register} in $file (status $status)"
      return 1
      ;;
  esac

  return 0
}

# ----------------------------------------------
# Framework patches (Android 16)
# ----------------------------------------------

# Apply signature verification bypass patches to framework.jar (Android 16)
apply_framework_signature_patches() {
  local decompile_dir="$1"

  log "Applying signature verification patches to framework.jar (Android 16)..."

  local pkg_parser_file
  pkg_parser_file=$(find "$decompile_dir" -type f -path "*/android/content/pm/PackageParser.smali" | head -n1)
  if [ -n "$pkg_parser_file" ]; then
    insert_line_before_all "$pkg_parser_file" "ApkSignatureVerifier;->unsafeGetCertsWithoutVerification" "const/4 v1, 0x1"
    insert_const_before_condition_near_string "$pkg_parser_file" '<manifest> specifies bad sharedUserId name' "if-nez v14, :" "v14" "1"
  else
    warn "PackageParser.smali not found"
  fi

  local pkg_parser_exception_file
  pkg_parser_exception_file=$(find "$decompile_dir" -type f -path "*/android/content/pm/PackageParser\$PackageParserException.smali" | head -n1)
  if [ -n "$pkg_parser_exception_file" ]; then
    insert_line_before_all "$pkg_parser_exception_file" "iput p1, p0, Landroid/content/pm/PackageParser\$PackageParserException;->error:I" "const/4 p1, 0x0"
  else
    warn "PackageParser\$PackageParserException.smali not found"
  fi

  local pkg_signing_details_file
  pkg_signing_details_file=$(find "$decompile_dir" -type f -path "*/android/content/pm/PackageParser\$SigningDetails.smali" | head -n1)
  if [ -n "$pkg_signing_details_file" ]; then
    force_methods_return_const "$pkg_signing_details_file" "checkCapability" "1"
  else
    warn "PackageParser\$SigningDetails.smali not found"
  fi

  local signing_details_file
  signing_details_file=$(find "$decompile_dir" -type f -path "*/android/content/pm/SigningDetails.smali" | head -n1)
  if [ -n "$signing_details_file" ]; then
    force_methods_return_const "$signing_details_file" "checkCapability" "1"
    force_methods_return_const "$signing_details_file" "checkCapabilityRecover" "1"
    force_methods_return_const "$signing_details_file" "hasAncestorOrSelf" "1"
  else
    warn "SigningDetails.smali not found"
  fi

  local apk_sig_scheme_v2_file
  apk_sig_scheme_v2_file=$(find "$decompile_dir" -type f -path "*/android/util/apk/ApkSignatureSchemeV2Verifier.smali" | head -n1)
  if [ -n "$apk_sig_scheme_v2_file" ]; then
    replace_move_result_after_invoke "$apk_sig_scheme_v2_file" "invoke-static {v8, v4}, Ljava/security/MessageDigest;->isEqual([B[B)Z" "const/4 v0, 0x1"
  else
    warn "ApkSignatureSchemeV2Verifier.smali not found"
  fi

  local apk_sig_scheme_v3_file
  apk_sig_scheme_v3_file=$(find "$decompile_dir" -type f -path "*/android/util/apk/ApkSignatureSchemeV3Verifier.smali" | head -n1)
  if [ -n "$apk_sig_scheme_v3_file" ]; then
    replace_move_result_after_invoke "$apk_sig_scheme_v3_file" "invoke-static {v9, v3}, Ljava/security/MessageDigest;->isEqual([B[B)Z" "const/4 v0, 0x1"
  else
    warn "ApkSignatureSchemeV3Verifier.smali not found"
  fi

  local apk_signature_verifier_file
  apk_signature_verifier_file=$(find "$decompile_dir" -type f -path "*/android/util/apk/ApkSignatureVerifier.smali" | head -n1)
  if [ -n "$apk_signature_verifier_file" ]; then
    force_methods_return_const "$apk_signature_verifier_file" "getMinimumSignatureSchemeVersionForTargetSdk" "0"
    insert_line_before_all "$apk_signature_verifier_file" "ApkSignatureVerifier;->verifyV1Signature" "const p3, 0x0"
  else
    warn "ApkSignatureVerifier.smali not found"
  fi

  local apk_signing_block_utils_file
  apk_signing_block_utils_file=$(find "$decompile_dir" -type f -path "*/android/util/apk/ApkSigningBlockUtils.smali" | head -n1)
  if [ -n "$apk_signing_block_utils_file" ]; then
    replace_move_result_after_invoke "$apk_signing_block_utils_file" "invoke-static {v5, v6}, Ljava/security/MessageDigest;->isEqual([B[B)Z" "const/4 v7, 0x1"
  else
    warn "ApkSigningBlockUtils.smali not found"
  fi

  local strict_jar_verifier_file
  strict_jar_verifier_file=$(find "$decompile_dir" -type f -path "*/android/util/jar/StrictJarVerifier.smali" | head -n1)
  if [ -n "$strict_jar_verifier_file" ]; then
    force_methods_return_const "$strict_jar_verifier_file" "verifyMessageDigest" "1"
  else
    warn "StrictJarVerifier.smali not found"
  fi

  local strict_jar_file_file
  strict_jar_file_file=$(find "$decompile_dir" -type f -path "*/android/util/jar/StrictJarFile.smali" | head -n1)
  if [ -n "$strict_jar_file_file" ]; then
    replace_if_block_in_strict_jar_file "$strict_jar_file_file"
  else
    warn "StrictJarFile.smali not found"
  fi

  local parsing_package_utils_file
  parsing_package_utils_file=$(find "$decompile_dir" -type f -path "*/com/android/internal/pm/pkg/parsing/ParsingPackageUtils.smali" | head -n1)
  if [ -n "$parsing_package_utils_file" ]; then
    insert_const_before_condition_near_string "$parsing_package_utils_file" '<manifest> specifies bad sharedUserId name' "if-eqz v4, :" "v4" "0"
  else
    warn "ParsingPackageUtils.smali not found"
  fi

  log "Signature verification patches applied to framework.jar (Android 16)"
}

# Apply CN notification fix patches to miui-services.jar
apply_miui_services_cn_notification_fix() {
  local decompile_dir="$1"
  local class="
$decompile_dir/smali*/com/android/server/am/ActivityManagerServiceImpl.smali
$decompile_dir/smali*/com/android/server/am/BroadcastQueueModernStubImpl.smali
$decompile_dir/smali*/com/android/server/am/MiProcessTracker.smali
$decompile_dir/smali*/com/android/server/am/MutableActivityManagerShellCommandStubImpl.smali
$decompile_dir/smali*/com/android/server/am/PreStartFeedbackImpl.smali
$decompile_dir/smali*/com/android/server/am/ProcessManagerService.smali
$decompile_dir/smali*/com/android/server/am/ProcessPolicy.smali
$decompile_dir/smali*/com/android/server/am/ProcessSceneCleaner.smali
$decompile_dir/smali*/com/android/server/alarm/AlarmManagerServiceStubImpl.smali
$decompile_dir/smali*/com/android/server/audio/AudioServiceStubImpl.smali
$decompile_dir/smali*/com/android/server/clipboard/ClipboardChecker.smali
$decompile_dir/smali*/com/android/server/clipboard/ClipboardServiceStubImpl.smali
$decompile_dir/smali*/com/android/server/devicepolicy/DevicePolicyManagerServiceStubImpl.smali
$decompile_dir/smali*/com/android/server/input/InputManagerServiceStubImpl.smali
$decompile_dir/smali*/com/android/server/inputmethod/InputMethodManagerServiceImpl.smali
$decompile_dir/smali*/com/android/server/inputmethod/SogouInputMethodSwitcher.smali
$decompile_dir/smali*/com/android/server/job/JobServiceContextImpl.smali
$decompile_dir/smali*/com/android/server/location/gnss/datacollect/GnssEventTrackingImpl.smali
$decompile_dir/smali*/com/android/server/location/gnss/enhance/EnhanceUtils.smali
$decompile_dir/smali*/com/android/server/location/gnss/gnssSelfRecovery/Utils.smali
$decompile_dir/smali*/com/android/server/location/gnss/operators/GnssForKtCustomImpl.smali
$decompile_dir/smali*/com/android/server/location/gnss/GnssLocationProviderImpl.smali
$decompile_dir/smali*/com/android/server/location/util/GnssCustFeatureHelper.smali
$decompile_dir/smali*/com/android/server/location/GnssCollectDataImpl.smali
$decompile_dir/smali*/com/android/server/location/MiuiBlurLocationManagerImpl.smali
$decompile_dir/smali*/com/android/server/notification/NotificationManagerServiceImpl.smali
$decompile_dir/smali*/com/android/server/pm/PackageManagerServiceImpl.smali
$decompile_dir/smali*/com/android/server/policy/MiuiShortcutTriggerHelper\$ShortcutSettingsObserver.smali
$decompile_dir/smali*/com/android/server/wm/ActivityTaskSupervisorImpl.smali
$decompile_dir/smali*/com/android/server/wm/MiuiSplitInputMethodImpl.smali
$decompile_dir/smali*/com/android/server/wm/WindowManagerServiceImpl.smali
$decompile_dir/smali*/com/android/server/DeviceIdleControllerStubImpl.smali
$decompile_dir/smali*/com/android/server/ForceDarkAppListManager.smali
$decompile_dir/smali*/com/android/server/AppOpsServiceStubImpl.smali
$decompile_dir/smali*/com/miui/server/greeze/PolicyManager.smali
$decompile_dir/smali*/com/miui/server/security/AppBehaviorService.smali
$decompile_dir/smali*/com/miui/server/smartpower/policy/SmartArtRuntimePolicy.smali
$decompile_dir/smali*/com/miui/server/smartpower/FlingOptimizeManager.smali
$decompile_dir/smali*/com/miui/server/turbosched/TurboSchedManagerService.smali
$decompile_dir/smali*/com/xiaomi/NetworkBoost/slaservice/GameLatencyPredict.smali
$decompile_dir/smali*/com/xiaomi/NetworkBoost/slaservice/SLAAppLib.smali
$decompile_dir/smali*/com/xiaomi/NetworkBoost/slaservice/SLAAppLib\$2.smali
$decompile_dir/smali*/miui/app/ActivitySecurityHelper.smali
"
  for i in $class; do
    [ -f "$i" ] || continue
    sed -i 's/com.baidu.input_mi/com.google.android.inputmethod.latin/g' "$i"
    sed -i -E 's|(sget-boolean[[:space:]]+)([vp][0-9]+),[[:space:]]+Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z|\1\2, Lmiui/os/Build;->IS_MIUI:Z|g' "$i"
  done
  # PenguinOS A16 behavior uses the MIUI path for CN background policy.
  # HyperMOS additionally forces Greeze PolicyManager.CN_MODEL=false without
  # changing ro.miui.region, so the rest of Xiaomi regional behavior stays CN.
  local policy_file
  policy_file=$(find "$decompile_dir" -type f -path '*/com/miui/server/greeze/PolicyManager.smali' -print -quit)
  if [ -z "$policy_file" ] || [ ! -f "$policy_file" ]; then
    err "CN Notification Fix: PolicyManager.smali not found"
    return 1
  fi

  POLICY_FILE="$policy_file" python3 <<'PY'
from pathlib import Path
import os
import re
import sys

path = Path(os.environ["POLICY_FILE"])
lines = path.read_text(encoding="utf-8").splitlines()

pat = re.compile(
    r"^(\s*)sput-boolean\s+([vp]\d+),\s+"
    r"Lcom/miui/server/greeze/PolicyManager;->CN_MODEL:Z\s*$"
)
matches = []
for idx, line in enumerate(lines):
    m = pat.match(line)
    if m:
        matches.append((idx, m.group(1), m.group(2)))

# Fail closed on an unknown Xiaomi layout instead of patching the wrong field.
if len(matches) != 1:
    print(f"unexpected CN_MODEL assignment count: {len(matches)}", file=sys.stderr)
    sys.exit(3)

idx, indent, reg = matches[0]
force = f"{indent}const/4 {reg}, 0x0"

if idx == 0 or lines[idx - 1].strip() != f"const/4 {reg}, 0x0":
    lines.insert(idx, force)

out = "\n".join(lines) + "\n"

# Verify the exact CN_MODEL write is now immediately preceded by false.
verify = re.compile(
    rf"(?m)^\s*const/4\s+{re.escape(reg)},\s+0x0\s*$\n"
    rf"^\s*sput-boolean\s+{re.escape(reg)},\s+"
    rf"Lcom/miui/server/greeze/PolicyManager;->CN_MODEL:Z\s*$"
)
if not verify.search(out):
    print("CN_MODEL=false verification failed", file=sys.stderr)
    sys.exit(4)

path.write_text(out, encoding="utf-8")
PY
  if [ $? -ne 0 ]; then
    err "CN Notification Fix: failed to force PolicyManager.CN_MODEL=false"
    return 1
  fi
  log "[PATCH] PolicyManager.CN_MODEL=false -> Done"

  # HyperMOS FCM Live delta: do not defer Google's reconnect/heartbeat broadcasts.
  # Only patch the two narrow boolean gates used by Xiaomi Greeze. Keep all other
  # Greeze/SmartPower behavior stock.
  DECOMPILE_DIR="$decompile_dir" python3 <<'PY'
from pathlib import Path
import os
import re
import sys

root = Path(os.environ["DECOMPILE_DIR"])
targets = (
    ("com/miui/server/greeze/GreezeManagerService.smali", "deferBroadcastForMiui"),
    ("com/miui/server/greeze/DomesticPolicyManager.smali", "deferBroadcast"),
)
actions = (
    "com.google.android.intent.action.GCM_RECONNECT",
    "com.google.android.gcm.DISCONNECTED",
    "com.google.android.gcm.CONNECTED",
    "com.google.android.gms.gcm.HEARTBEAT_ALARM",
)

patched = 0
found = 0
verified = 0

for rel, method_name in targets:
    matches = list(root.glob(f"smali*/{rel}"))
    if not matches:
        print(f"optional FCM gate class missing: {rel}")
        continue
    path = matches[0]
    text = path.read_text(encoding="utf-8")

    pat = re.compile(
        rf"(?ms)^\.method\b([^\n]*)\b{re.escape(method_name)}\(Ljava/lang/String;\)Z\s*$.*?^\.end method\s*$"
    )
    m = pat.search(text)
    if not m:
        print(f"optional FCM gate missing: {path.name}#{method_name}(String)")
        continue
    found += 1
    method = m.group(0)
    if "hypermos_fcm_no_defer" in method:
        verified += 1
        continue

    head, body = method.split("\n", 1)
    static_method = " static " in f" {head} "
    arg_reg = "p0" if static_method else "p1"
    lines = body.splitlines()

    reg_idx = next(
        (i for i, line in enumerate(lines)
         if line.strip().startswith(".locals") or line.strip().startswith(".registers")),
        None,
    )
    if reg_idx is None:
        print(f"register directive missing in {path.name}#{method_name}", file=sys.stderr)
        sys.exit(51)

    directive = lines[reg_idx].strip()
    if directive.startswith(".locals"):
        n = int(directive.split()[1])
        temp = f"v{n}"
        indent = re.match(r"\s*", lines[reg_idx]).group(0)
        lines[reg_idx] = f"{indent}.locals {n + 1}"
    else:
        total = int(directive.split()[1])
        # one String argument + optional this register
        params = 1 if static_method else 2
        local_count = total - params
        if local_count < 0:
            print(f"invalid .registers in {path.name}#{method_name}", file=sys.stderr)
            sys.exit(52)
        temp = f"v{local_count}"
        indent = re.match(r"\s*", lines[reg_idx]).group(0)
        lines[reg_idx] = f"{indent}.registers {total + 1}"

    tag = f"hypermos_fcm_no_defer_{method_name.lower()}"
    inject = [
        "",
        "    # hypermos_fcm_no_defer",
        f"    if-eqz {arg_reg}, :{tag}_continue",
    ]
    for action in actions:
        inject += [
            f'    const-string {temp}, "{action}"',
            f"    invoke-virtual {{{temp}, {arg_reg}}}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z",
            f"    move-result {temp}",
            f"    if-nez {temp}, :{tag}_allow",
        ]
    inject += [
        f"    goto :{tag}_continue",
        f":{tag}_allow",
        f"    const/4 {temp}, 0x0",
        f"    return {temp}",
        f":{tag}_continue",
    ]

    lines[reg_idx + 1:reg_idx + 1] = inject
    replacement = head + "\n" + "\n".join(lines)
    text = text[:m.start()] + replacement + text[m.end():]
    path.write_text(text, encoding="utf-8")
    patched += 1
    verified += 1

if found != len(targets):
    print(
        f"required Greeze FCM defer gates missing: found={found}/{len(targets)}",
        file=sys.stderr,
    )
    sys.exit(53)

if verified != len(targets):
    print(
        f"Greeze FCM defer verification incomplete: verified={verified}/{len(targets)}",
        file=sys.stderr,
    )
    sys.exit(54)

print(f"HyperMOS FCM Greeze delta patched={patched} verified={verified}")
PY
  if [ $? -ne 0 ]; then
    err "CN Notification Fix: FCM Greeze defer patch failed"
    return 1
  fi
  log "[PATCH] Greeze GCM reconnect/heartbeat defer -> disabled"

  for i in $decompile_dir/smali*/com/android/server/am/ActivityManagerServiceImpl.smali; do
    [ -f "$i" ] || continue
    sed -i '/Lmiui\/drm\/DrmBroadcast;->getInstance/{N;N;N;N;d}' "$i"
  done
}

apply_miui_services_global_patch() {
  local decompile_dir="$1"
  local class="
$decompile_dir/smali*/com/android/server/devicepolicy/DevicePolicyManagerServiceStubImpl.smali
$decompile_dir/smali*/com/android/server/input/InputManagerServiceStubImpl.smali
$decompile_dir/smali*/com/android/server/inputmethod/InputMethodManagerServiceImpl.smali
$decompile_dir/smali*/com/android/server/wm/ActivityTaskSupervisorImpl.smali
$decompile_dir/smali*/com/android/server/wm/MiuiSplitInputMethodImpl.smali
$decompile_dir/smali*/com/miui/server/security/AppBehaviorService.smali
"
  for i in $decompile_dir/smali*/com/android/server/am/ProcessPolicy.smali; do
    replace_line_contains_in_smali_method "IS_INTERNATIONAL_BUILD" "updateContentCatcherWhitelist()V" "    const/4 v0, 0x0" $i
  done
  for i in $decompile_dir/smali*/com/android/server/am/ActivityManagerServiceImpl.smali; do
    [ -f "$i" ] || continue
    sed -i '/Lmiui\/drm\/DrmBroadcast;->getInstance/{N;N;N;N;d}' "$i"
  done
}

apply_miui_framework_cn_notification_fix() {
  local decompile_dir="$1"
  local class="
$decompile_dir/smali*/android/app/AppOpsManagerInjector.smali
$decompile_dir/smali*/android/inputmethodservice/InputMethodServiceInjector.smali
$decompile_dir/smali*/android/view/inputmethod/InputMethodManagerStubImpl.smali
$decompile_dir/smali*/com/android/internal/os/AnrEnhanceImpl.smali
$decompile_dir/smali*/com/miui/mishare/app/NearbyUtils.smali
$decompile_dir/smali*/miui/hardware/input/shortcut/ShortcutFunctionManager.smali
$decompile_dir/smali*/miui/util/font/SymlinkUtils.smali
$decompile_dir/smali*/miui/util/font/MultiLangHelper.smali
"
  for i in $class; do
    [ -f "$i" ] || continue
    sed -i 's/com.baidu.input_mi/com.google.android.inputmethod.latin/g' "$i"
    sed -i -E 's|(sget-boolean[[:space:]]+)([vp][0-9]+),[[:space:]]+Lmiui/os/Build;->IS_INTERNATIONAL_BUILD:Z|\1\2, Lmiui/os/xBuild;->IS_INTERNATIONAL_BUILD:Z|g' "$i"
  done
  cp -rf "$SCRIPT_DIR/miui" "$decompile_dir/smali"
}

# Apply disable secure flag patches to framework.jar (Android 16)
apply_framework_disable_secure_flag() {
  local decompile_dir="$1"

  log "Applying disable secure flag patches to framework.jar (Android 16)..."

  # Note: For Android 16, disable secure flag does not require framework.jar patches
  # Only services.jar and miui-services.jar are affected
  log "Disable secure flag: No framework.jar patches required for Android 16"

  log "Disable secure flag patches applied to framework.jar (Android 16)"
}

# Route Android Credential Manager's OEM chooser to the Google Password Manager UI.
# We only replace the OEM component string inside IntentFactory; Android's original
# enabled/exported checks and IntentCreationResult bookkeeping remain intact.
apply_framework_passkey() {
  local decompile_dir="$1"
  local target
  target=$(find "$decompile_dir" -type f -path '*/android/credentials/selection/IntentFactory.smali' -print -quit)

  if [ -z "$target" ] || [ ! -f "$target" ]; then
    err "Passkey: IntentFactory.smali not found"
    return 1
  fi

  PASSKEY_INTENT_FACTORY="$target" python3 <<'PY'
from pathlib import Path
import os
import re
import sys

path = Path(os.environ["PASSKEY_INTENT_FACTORY"])
text = path.read_text(encoding="utf-8")

m = re.search(
    r"(?ms)^\.method\b[^\n]*\bgetOemOverrideComponentName\([^\n]*\)Landroid/content/ComponentName;\s*$.*?^\.end method\s*$",
    text,
)
if not m:
    print("getOemOverrideComponentName not found", file=sys.stderr)
    sys.exit(81)

method = m.group(0)
component = "com.google.android.gms/.identitycredentials.ui.CredentialChooserActivity"

if f'const-string' in method and component in method:
    sys.exit(0)

lines = method.splitlines()
inserted = False
for i, line in enumerate(lines):
    if "Landroid/content/res/Resources;->getString(I)Ljava/lang/String;" not in line:
        continue
    # The result register carries config_oemCredentialManagerDialogComponent.
    for j in range(i + 1, min(i + 5, len(lines))):
        mm = re.match(r"\s*move-result-object\s+([vp]\d+)\s*$", lines[j])
        if mm:
            reg = mm.group(1)
            indent = re.match(r"\s*", lines[j]).group(0)
            lines.insert(j + 1, f'{indent}const-string {reg}, "{component}"')
            inserted = True
            break
    if inserted:
        break

if not inserted:
    print("OEM credential component resource read not found", file=sys.stderr)
    sys.exit(82)

replacement = "\n".join(lines)
text = text[:m.start()] + replacement + text[m.end():]

check = re.search(
    r"(?ms)^\.method\b[^\n]*\bgetOemOverrideComponentName\([^\n]*\)Landroid/content/ComponentName;\s*$.*?^\.end method\s*$",
    text,
)
if not check or component not in check.group(0):
    print("IntentFactory Passkey verification failed", file=sys.stderr)
    sys.exit(83)

path.write_text(text, encoding="utf-8")
PY
  [ $? -eq 0 ] || {
    err "Passkey: IntentFactory patch failed"
    return 1
  }
  log "[PATCH] Credential Manager OEM UI -> Google"
}

# Main framework patching function (Android 16)
patch_framework() {
  local framework_path="$work_dir/build/baserom/images/system/system/framework/framework.jar"

  if [ ! -f "$framework_path" ]; then
    err "framework.jar not found at $framework_path"
    return 1
  fi

  log "Starting Android 16 framework.jar patch"
  local decompile_dir
  decompile_dir=$(decompile_jar "$framework_path") || return 1

  # Build #24 compatibility:
  # framework.jar signature bypass is always applied.
  # Keep services.jar / miui-services.jar signature bypass flag-controlled,
  # so they remain stock unless explicitly requested elsewhere.
  apply_framework_signature_patches "$decompile_dir" || return 1

  if [ "$FEATURE_DISABLE_SECURE_FLAG" -eq 1 ]; then
    apply_framework_disable_secure_flag "$decompile_dir" || return 1
  fi

  if [ "$FEATURE_PASSKEY" -eq 1 ]; then
    apply_framework_passkey "$decompile_dir" || return 1
  fi

  # Apply invoke-custom patches (common to all features)
  # modify_invoke_custom_methods "$decompile_dir"

  recompile_jar "$framework_path" > /dev/null || { err "framework.jar recompile failed"; return 1; }

  rm -rf "$decompile_dir" "$WORK_DIR/framework"

  if [ ! -f "framework_patched.jar" ]; then
    err "Critical Error: framework_patched.jar was not created."
    return 1
  fi
  log "Completed framework.jar patching"
}

# ----------------------------------------------
# Services patches (Android 16)
# ----------------------------------------------

# Apply signature verification bypass patches to services.jar (Android 16)
apply_services_signature_patches() {
  local decompile_dir="$1"

  log "Applying signature verification patches to services.jar (Android 16)..."

  # Resolve smali files across classes*/ to handle layout differences in CI
  resolve_smali_file() {
    # $1: relative path like com/android/server/pm/PackageManagerServiceUtils.smali
    local rel="$1"
    local cand
    for d in "$decompile_dir/classes" "$decompile_dir/classes2" "$decompile_dir/classes3" "$decompile_dir/classes4"; do
      cand="$d/$rel"
      [ -f "$cand" ] && {
        printf "%s\n" "$cand"
        return 0
      }
    done
    # fallback to find to be safe
    find "$decompile_dir" -type f -path "*/$rel" | head -n1
  }

  local pms_utils_file
  pms_utils_file=$(resolve_smali_file "com/android/server/pm/PackageManagerServiceUtils.smali")
  local install_package_helper_file
  install_package_helper_file=$(resolve_smali_file "com/android/server/pm/InstallPackageHelper.smali")
  local reconcile_package_utils_file
  reconcile_package_utils_file=$(resolve_smali_file "com/android/server/pm/ReconcilePackageUtils.smali")

  # checkDowngrade → return-void (all overloads)
  if [ -n "$pms_utils_file" ] && [ -f "$pms_utils_file" ]; then
    patch_return_void_methods_all "checkDowngrade" "$decompile_dir"
    force_methods_return_const "$pms_utils_file" "verifySignatures" "0"
    # force_methods_return_const "$pms_utils_file" "compareSignatures" "0"
    force_methods_return_const "$pms_utils_file" "matchSignaturesCompat" "1"
  else
    warn "PackageManagerServiceUtils.smali not found"
  fi

  # shouldCheckUpgradeKeySetLocked may live outside PMS utils on some builds – try to pin first, then fallback to search
  local should_check_file
  should_check_file=$(resolve_smali_file "com/android/server/pm/KeySetManagerService.smali")
  if [ -n "$should_check_file" ] && [ -f "$should_check_file" ]; then
    force_methods_return_const "$should_check_file" "shouldCheckUpgradeKeySetLocked" "0"
  else
    method_file=$(find_smali_method_file "$decompile_dir" "shouldCheckUpgradeKeySetLocked")
    if [ -n "$method_file" ]; then
      force_methods_return_const "$method_file" "shouldCheckUpgradeKeySetLocked" "0"
    else
      warn "shouldCheckUpgradeKeySetLocked not found"
    fi
  fi

  # Apply shared-user guard in known file path (InstallPackageHelper)
  local invoke_pattern="invoke-interface {p5}, Lcom/android/server/pm/pkg/AndroidPackage;->isLeavingSharedUser()Z"
  if [ -n "$install_package_helper_file" ] && [ -f "$install_package_helper_file" ]; then
    ensure_const_before_if_for_register "$install_package_helper_file" "$invoke_pattern" "if-eqz v3, :" "v3" "1"
  else
    # Fallback to repo-wide search if layout differs
    local fallback_file
    fallback_file=$(grep -s -rl --include='*.smali' "$invoke_pattern" "$decompile_dir" 2> /dev/null | head -n1)
    if [ -n "$fallback_file" ]; then
      ensure_const_before_if_for_register "$fallback_file" "$invoke_pattern" "if-eqz v3, :" "v3" "1"
    else
      warn "InstallPackageHelper.smali not found and pattern not located"
    fi
  fi

  if [ -n "$reconcile_package_utils_file" ] && [ -f "$reconcile_package_utils_file" ]; then
    patch_reconcile_clinit "$reconcile_package_utils_file"
  else
    warn "ReconcilePackageUtils.smali not found"
  fi

  # modify_invoke_custom_methods "$decompile_dir"

  # Emit robust verification logs for CI (avoid brittle hardcoded file paths)
  log "[VERIFY] services: locating isLeavingSharedUser invoke (context)"
  grep -s -R -n --include='*.smali' \
    'invoke-interface {p5}, Lcom/android/server/pm/pkg/AndroidPackage;->isLeavingSharedUser()Z' \
    "$decompile_dir" | head -n 1 || true

  log "[VERIFY] services: verifySignatures/compareSignatures/matchSignaturesCompat presence"
  grep -s -R -n --include='*.smali' '^[[:space:]]*\\.method.* verifySignatures' "$decompile_dir" | head -n 1 || true
  grep -s -R -n --include='*.smali' '^[[:space:]]*\\.method.* compareSignatures' "$decompile_dir" | head -n 1 || true
  grep -s -R -n --include='*.smali' '^[[:space:]]*\\.method.* matchSignaturesCompat' "$decompile_dir" | head -n 1 || true

  log "[VERIFY] services: checkDowngrade methods now return-void"
  grep -s -R -n --include='*.smali' '^[[:space:]]*\.method.*checkDowngrade' "$decompile_dir" | head -n 5 || true

  log "[VERIFY] services: ReconcilePackageUtils <clinit> toggle lines"
  local rpu_file
  rpu_file=$(find "$decompile_dir" -type f -path "*/com/android/server/pm/ReconcilePackageUtils.smali" | head -n1)
  if [ -n "$rpu_file" ]; then
    grep -n '^[[:space:]]*\\.method static constructor <clinit>()V' "$rpu_file" || true
    grep -n 'const/4 v0, 0x[01]' "$rpu_file" | head -n 5 || true
  fi

  log "Signature verification patches applied to services.jar (Android 16)"
}

# Apply disable secure flag patches to services.jar (Android 16)
apply_services_disable_secure_flag() {
  local decompile_dir="$1"

  log "Applying disable secure flag patches to services.jar (Android 16)..."

  # Android 16: Patch WindowState.isSecureLocked()
  log "Patching WindowState.isSecureLocked()..."
  local method_body="    .registers 6\n\n    const/4 v0, 0x0\n\n    return v0"
  replace_entire_method "isSecureLocked()Z" "$decompile_dir" "$method_body" "com/android/server/wm/WindowState"

  log "Disable secure flag patches applied to services.jar (Android 16)"
}

# Force the hybrid Credential Manager provider used by RequestSession to GMS.
# This is scoped to the Credential Manager session constructor and does not alter
# package identity, build region, or other services.
apply_services_passkey() {
  local decompile_dir="$1"
  local target
  target=$(find "$decompile_dir" -type f -path '*/com/android/server/credentials/RequestSession.smali' -print -quit)

  if [ -z "$target" ] || [ ! -f "$target" ]; then
    err "Passkey: RequestSession.smali not found"
    return 1
  fi

  PASSKEY_REQUEST_SESSION="$target" python3 <<'PY'
from pathlib import Path
import os
import re
import sys

path = Path(os.environ["PASSKEY_REQUEST_SESSION"])
text = path.read_text(encoding="utf-8")
field = "Lcom/android/server/credentials/RequestSession;->mHybridService:Ljava/lang/String;"
service = "com.google.android.gms/.auth.api.credentials.credman.service.RemoteService"

if field not in text:
    print("RequestSession.mHybridService field not found", file=sys.stderr)
    sys.exit(84)

methods = list(re.finditer(
    r"(?ms)^\.method\b[^\n]* constructor <init>\([^\n]*\)V\s*$.*?^\.end method\s*$",
    text,
))
if not methods:
    print("RequestSession constructor not found", file=sys.stderr)
    sys.exit(85)

patched = 0

def parse_params(desc):
    out = []
    i = 0
    while i < len(desc):
        start = i
        while i < len(desc) and desc[i] == '[':
            i += 1
        if i >= len(desc):
            break
        if desc[i] == 'L':
            end = desc.find(';', i)
            if end < 0:
                raise ValueError("bad descriptor")
            i = end + 1
        else:
            i += 1
        out.append(desc[start:i])
    return out

for m in reversed(methods):
    method = m.group(0)
    # Patch the constructor that initializes/uses mHybridService.
    if field not in method and "SessionLifetime" not in method:
        continue
    if service in method:
        continue

    lines = method.splitlines()
    header = lines[0]
    reg_idx = next(
        (i for i, line in enumerate(lines)
         if line.strip().startswith(".locals") or line.strip().startswith(".registers")),
        None,
    )
    if reg_idx is None:
        print("RequestSession constructor register directive missing", file=sys.stderr)
        sys.exit(86)

    directive = lines[reg_idx].strip()
    indent = re.match(r"\s*", lines[reg_idx]).group(0)
    if directive.startswith(".locals"):
        n = int(directive.split()[1])
        temp = f"v{n}"
        lines[reg_idx] = f"{indent}.locals {n + 1}"
    else:
        total = int(directive.split()[1])
        desc = header.split("<init>(", 1)[1].split(")", 1)[0]
        params = parse_params(desc)
        param_regs = 1 + sum(2 if p in ("J", "D") else 1 for p in params)  # this + args
        locals_count = total - param_regs
        if locals_count < 0:
            print("invalid RequestSession .registers", file=sys.stderr)
            sys.exit(87)
        temp = f"v{locals_count}"
        lines[reg_idx] = f"{indent}.registers {total + 1}"

    returns = [i for i, line in enumerate(lines) if line.strip() == "return-void"]
    if not returns:
        print("RequestSession constructor return missing", file=sys.stderr)
        sys.exit(88)
    r = returns[-1]
    lines[r:r] = [
        f'    const-string {temp}, "{service}"',
        f"    iput-object {temp}, p0, {field}",
        "",
    ]
    replacement = "\n".join(lines)
    text = text[:m.start()] + replacement + text[m.end():]
    patched += 1

if patched == 0 and service not in text:
    print("no RequestSession constructor patched", file=sys.stderr)
    sys.exit(89)

path.write_text(text, encoding="utf-8")
print(f"RequestSession Passkey constructors patched={patched}")
PY
  [ $? -eq 0 ] || {
    err "Passkey: RequestSession patch failed"
    return 1
  }
  log "[PATCH] Credential Manager hybrid provider -> GMS"
}

# Main services patching function (Android 16)
patch_services() {
  local services_path="$work_dir/build/baserom/images/system/system/framework/services.jar"

  # Allow using a pre-existing decompile dir for verification/patching
  local external_dir_flag=0
  local external_dir=""
  if [ -n "${SERVICES_DECOMPILE_DIR:-}" ] && [ -d "${SERVICES_DECOMPILE_DIR}" ]; then
    external_dir_flag=1
    external_dir="${SERVICES_DECOMPILE_DIR}"
  elif [ -d "${WORK_DIR}/services_decompile" ]; then
    external_dir_flag=1
    external_dir="${WORK_DIR}/services_decompile"
  fi

  if [ $external_dir_flag -eq 0 ] && [ ! -f "$services_path" ]; then
    err "services.jar not found at $services_path and no SERVICES_DECOMPILE_DIR provided"
    return 1
  fi

  log "Starting Android 16 services.jar patch"
  local decompile_dir
  if [ $external_dir_flag -eq 1 ]; then
    log "Using existing services decompile dir: $external_dir"
    decompile_dir="$external_dir"
  else
    decompile_dir=$(decompile_jar "$services_path") || return 1
  fi

  # Apply feature-specific patches based on flags
  if [ "$FEATURE_DISABLE_SIGNATURE_VERIFICATION" -eq 1 ]; then
    apply_services_signature_patches "$decompile_dir" || return 1
  fi

  if [ "$FEATURE_DISABLE_SECURE_FLAG" -eq 1 ]; then
    apply_services_disable_secure_flag "$decompile_dir" || return 1
  fi

  if [ "$FEATURE_PASSKEY" -eq 1 ]; then
    apply_services_passkey "$decompile_dir" || return 1
  fi

  # Apply invoke-custom patches (common to all features)
  # modify_invoke_custom_methods "$decompile_dir"

  if [ $external_dir_flag -eq 0 ]; then
    recompile_jar "$services_path" > /dev/null || { err "services.jar recompile failed"; return 1; }

    rm -rf "$decompile_dir" "$WORK_DIR/services"
    log "Completed services.jar patching"
  else
    log "Verification completed on existing services decompile dir (no rebuild)"
  fi
}

# ----------------------------------------------
# MIUI services patches (Android 16)
# ----------------------------------------------

# Apply signature verification bypass patches to miui-services.jar (Android 16)
apply_miui_services_signature_patches() {
  local decompile_dir="$1"

  log "Applying signature verification patches to miui-services.jar (Android 16)..."

  # According to the miui-services guide: force specific methods to return-void
  patch_return_void_methods_all "verifyIsolationViolation" "$decompile_dir"
  patch_return_void_methods_all "canBeUpdate" "$decompile_dir"

  # Targeted verification that won't hang
  log "[VERIFY] miui-services: verifyIsolationViolation/canBeUpdate return-void"
  grep -s -R -n --include='*.smali' '^[[:space:]]*\.method.*verifyIsolationViolation' "$decompile_dir" | head -n 5 || true
  grep -s -R -n --include='*.smali' '^[[:space:]]*\.method.*canBeUpdate' "$decompile_dir" | head -n 5 || true

  log "Signature verification patches applied to miui-services.jar (Android 16)"
}

# Apply disable secure flag patches to miui-services.jar (Android 16)
apply_miui_services_disable_secure_flag() {
  local decompile_dir="$1"

  log "Applying disable secure flag patches to miui-services.jar (Android 16)..."

  # Android 16: Patch WindowManagerServiceImpl.notAllowCaptureDisplay()
  log "Patching WindowManagerServiceImpl.notAllowCaptureDisplay()..."
  local method_body="    .registers 9\n\n    const/4 v0, 0x0\n\n    return v0"
  replace_entire_method "notAllowCaptureDisplay(Lcom/android/server/wm/RootWindowContainer;I)Z" "$decompile_dir" "$method_body" "com/android/server/wm/WindowManagerServiceImpl"

  log "Disable secure flag patches applied to miui-services.jar (Android 16)"
}

# Apply Gboard patches
apply_miui_services_gboard() {
  local decompile_dir="$1"

  # Add Gboard
  sed -i 's/com.baidu.input_mi/com.google.android.inputmethod.latin/g' "$decompile_dir/smali/com/android/server/devicepolicy/DevicePolicyManagerServiceStubImpl.smali"
  sed -i 's/com.baidu.input_mi/com.google.android.inputmethod.latin/g' "$decompile_dir/smali/com/android/server/input/InputManagerServiceStubImpl.smali"
  sed -i 's/com.baidu.input_mi/com.google.android.inputmethod.latin/g' "$decompile_dir/smali/com/android/server/inputmethod/InputMethodManagerServiceImpl.smali"
  sed -i 's/com.baidu.input_mi/com.google.android.inputmethod.latin/g' "$decompile_dir/smali/com/android/server/wm/ActivityTaskSupervisorImpl.smali"
  sed -i 's/com.baidu.input_mi/com.google.android.inputmethod.latin/g' "$decompile_dir/smali/com/android/server/wm/MiuiSplitInputMethodImpl.smali"
  sed -i 's/com.baidu.input_mi/com.google.android.inputmethod.latin/g' "$decompile_dir/smali/com/miui/server/security/AppBehaviorService.smali"

  echo "Gboard patches applied to miui-services.jar"
}

# Apply ContentExtension patches
apply_miui_services_contentextension() {
  local decompile_dir="$1"
  replace_line_contains_in_smali_method "IS_INTERNATIONAL_BUILD" "updateContentCatcherWhitelist()V" "    const/4 v0, 0x0" "$decompile_dir/smali/com/android/server/am/ProcessPolicy.smali"
  echo "ContentExtension patches applied to miui-services.jar"
}

# Apply floating
apply_miui_services_floating() {
  local decompile_dir="$1"
  for i in "$decompile_dir/"*"/com/android/server/wm/MiuiFreeFormStackDisplayStrategy.smali"; do
    patch_method_in_file "getMaxMiuiFreeFormStackCount(Ljava/lang/String;Lcom/android/server/wm/MiuiFreeFormActivityStack;)I" 6 "$i"
  done
}

# Redirect Xiaomi's resolved long-press power shortcut to MiCTS.
# The patch is applied inside ShortCutActionsUtils.triggerFunction(), after Xiaomi has
# already recognized the key gesture. If MiCTS cannot launch, the original assistant
# call is allowed to continue (fail-open).
apply_miui_services_micts_power_key() {
  local decompile_dir="$1"
  local target
  target=$(find "$decompile_dir" -type f \
    -path '*/com/miui/server/input/util/ShortCutActionsUtils.smali' \
    -print -quit)

  if [ -z "$target" ] || [ ! -f "$target" ]; then
    err "MiCTS power key: ShortCutActionsUtils.smali not found"
    return 1
  fi

  if ! grep -q 'Lcom/hypermos/micts/PowerTrigger;->trigger' "$target"; then
    MICTS_TARGET="$target" python3 <<'PY'
from pathlib import Path
import os
import re
import sys

path = Path(os.environ["MICTS_TARGET"])
lines = path.read_text(encoding="utf-8").splitlines()

method_ranges = []
i = 0
while i < len(lines):
    s = lines[i].strip()
    if s.startswith(".method") and " triggerFunction(" in s and s.endswith(")Z"):
        j = i + 1
        while j < len(lines) and not lines[j].strip().startswith(".end method"):
            j += 1
        if j >= len(lines):
            print("unterminated triggerFunction method", file=sys.stderr)
            sys.exit(2)
        method_ranges.append((i, j))
        i = j + 1
    else:
        i += 1

if not method_ranges:
    print("triggerFunction methods not found", file=sys.stderr)
    sys.exit(3)

patterns = (
    ("voice", "->launchVoiceAssistant(Ljava/lang/String;Landroid/os/Bundle;)Z"),
    ("google", "->launchGoogleSearch(Ljava/lang/String;)Z"),
)

candidates = []
serial = 0
for start, end in method_ranges:
    for idx in range(start, end):
        line = lines[idx]
        kind = None
        for candidate_kind, pattern in patterns:
            if pattern in line and "invoke-" in line:
                kind = candidate_kind
                break
        if kind is None:
            continue

        reg_match = re.search(r"\{([^}]*)\}", line)
        if not reg_match:
            print(f"cannot parse invoke registers at line {idx + 1}", file=sys.stderr)
            sys.exit(4)
        regs = [r.strip() for r in reg_match.group(1).split(",") if r.strip()]
        if len(regs) < 2:
            print(f"unexpected invoke register list at line {idx + 1}", file=sys.stderr)
            sys.exit(5)
        action_reg = regs[1]

        move_idx = None
        result_reg = None
        for j in range(idx + 1, min(idx + 5, end)):
            m = re.match(r"\s*move-result\s+([vp]\d+)\s*$", lines[j])
            if m:
                move_idx = j
                result_reg = m.group(1)
                break
        if move_idx is None or result_reg is None:
            print(f"move-result missing after {kind} invoke", file=sys.stderr)
            sys.exit(6)

        serial += 1
        label = f":hypermos_micts_after_{kind}_{serial}"
        candidates.append((idx, move_idx, action_reg, result_reg, label, kind))

if not candidates:
    print("MiCTS target invokes not found in triggerFunction", file=sys.stderr)
    sys.exit(7)

# Apply from the bottom of the file upward so saved indexes remain valid.
for invoke_idx, move_idx, action_reg, result_reg, label, kind in sorted(
    candidates, key=lambda item: item[0], reverse=True
):
    indent = re.match(r"\s*", lines[invoke_idx]).group(0)
    injection = [
        f"{indent}iget-object {result_reg}, p0, Lcom/miui/server/input/util/ShortCutActionsUtils;->mContext:Landroid/content/Context;",
        f"{indent}invoke-static {{{result_reg}, {action_reg}}}, Lcom/hypermos/micts/PowerTrigger;->trigger(Landroid/content/Context;Ljava/lang/String;)Z",
        f"{indent}move-result {result_reg}",
        f"{indent}if-nez {result_reg}, {label}",
    ]

    lines[move_idx + 1:move_idx + 1] = [f"{indent}{label}"]
    lines[invoke_idx:invoke_idx] = injection

out = "\n".join(lines) + "\n"

if "Lcom/hypermos/micts/PowerTrigger;->trigger" not in out:
    print("MiCTS injection verification failed", file=sys.stderr)
    sys.exit(8)

path.write_text(out, encoding="utf-8")
print(f"patched {len(candidates)} Xiaomi shortcut dispatch path(s)")
PY
    if [ $? -ne 0 ]; then
      err "MiCTS power key: ShortCutActionsUtils patch failed"
      return 1
    fi
  else
    log "[PATCH] MiCTS power key already present"
  fi

  local helper_src="$SCRIPT_DIR/micts/PowerTrigger.smali"
  if [ ! -f "$helper_src" ]; then
    err "MiCTS power key: helper missing at $helper_src"
    return 1
  fi

  local smali_root
  smali_root="${target%/com/miui/server/input/util/ShortCutActionsUtils.smali}"
  local helper_dst="$smali_root/com/hypermos/micts/PowerTrigger.smali"

  mkdir -p "$(dirname "$helper_dst")"
  cp -f "$helper_src" "$helper_dst"

  if ! grep -q 'com.parallelc.micts.ui.activity.MainActivity' "$helper_dst"; then
    err "MiCTS power key: helper verification failed"
    return 1
  fi

  log "[PATCH] Long press power -> MiCTS (fallback: original Xiaomi action)"
}

# Main miui-services patching function (Android 16)
patch_miui_services() {
  local miui_services_path="$work_dir/build/baserom/images/system_ext/framework/miui-services.jar"

  # Support external decompile dir like services
  local external_dir_flag=0
  local external_dir=""
  if [ -n "${MIUI_SERVICES_DECOMPILE_DIR:-}" ] && [ -d "${MIUI_SERVICES_DECOMPILE_DIR}" ]; then
    external_dir_flag=1
    external_dir="${MIUI_SERVICES_DECOMPILE_DIR}"
  elif [ -d "${WORK_DIR}/miui-services_decompile" ]; then
    external_dir_flag=1
    external_dir="${WORK_DIR}/miui-services_decompile"
  fi

  if [ $external_dir_flag -eq 0 ] && [ ! -f "$miui_services_path" ]; then
    err "miui-services.jar not found at $miui_services_path and no MIUI_SERVICES_DECOMPILE_DIR provided"
    return 1
  fi

  log "Starting Android 16 miui-services.jar patch"
  local decompile_dir
  if [ $external_dir_flag -eq 1 ]; then
    log "Using existing miui-services decompile dir: $external_dir"
    decompile_dir="$external_dir"
  else
    decompile_dir=$(decompile_jar "$miui_services_path") || return 1
  fi

  # Existing HyperMOS patches
  apply_miui_services_floating "$decompile_dir" || return 1
  apply_miui_services_contentextension "$decompile_dir" || return 1

  # Feature-specific patches
  if [ "$FEATURE_DISABLE_SIGNATURE_VERIFICATION" -eq 1 ]; then
    apply_miui_services_signature_patches "$decompile_dir" || return 1
  fi

  if [[ $regionTYPE == *"Global"* ]];then
    apply_miui_services_global_patch "$decompile_dir" || return 1
  else
    if [ "$FEATURE_CN_NOTIFICATION_FIX" -eq 1 ]; then
      apply_miui_services_cn_notification_fix "$decompile_dir" || return 1
    fi
    apply_miui_services_gboard "$decompile_dir" || return 1
  fi

  if [ "$FEATURE_DISABLE_SECURE_FLAG" -eq 1 ]; then
    apply_miui_services_disable_secure_flag "$decompile_dir" || return 1
  fi

  if [ "$FEATURE_MICTS_POWER_KEY" -eq 1 ]; then
    apply_miui_services_micts_power_key "$decompile_dir" || return 1
  fi

  # Apply invoke-custom patches (common to all features)
  # modify_invoke_custom_methods "$decompile_dir"

  if [ $external_dir_flag -eq 0 ]; then
    recompile_jar "$miui_services_path" > /dev/null || { err "miui-services.jar recompile failed"; return 1; }

    rm -rf "$decompile_dir" "$WORK_DIR/miui-services"
    log "Completed miui-services.jar patching"
  else
    log "Verification completed on existing miui-services decompile dir (no rebuild)"
  fi
}

# ============================================
# Feature-specific patch functions for miui-framework.jar
# ============================================

# Apply Gboard patches
apply_miui_framework_gboard() {
  local decompile_dir="$1"

  # Add Gboard
  sed -i 's/com.baidu.input_mi/com.google.android.inputmethod.latin/g' "$decompile_dir/smali/android/inputmethodservice/InputMethodServiceInjector.smali"
  sed -i 's/com.baidu.input_mi/com.google.android.inputmethod.latin/g' "$decompile_dir/smali/android/view/inputmethod/InputMethodManagerStubImpl.smali"
  # FrameworkPatcher compatibility: treat Gboard as the Baidu IME replacement
  # in Xiaomi's display/input-specific path too.
  local display_info_file
  display_info_file=$(find "$decompile_dir" -type f -path '*/android/view/DisplayInfoInjector$2.smali' -print -quit)
  if [ -z "$display_info_file" ] || [ ! -f "$display_info_file" ]; then
    err "Gboard patch: DisplayInfoInjector\$2.smali not found"
    return 1
  fi

  if ! grep -q 'com.baidu.input_mi' "$display_info_file"; then
    err "Gboard patch: Baidu IME target not found in DisplayInfoInjector\$2.smali"
    return 1
  fi

  sed -i 's/com.baidu.input_mi/com.google.android.inputmethod.latin/g' "$display_info_file"

  if grep -q 'com.baidu.input_mi' "$display_info_file"; then
    err "Gboard patch: DisplayInfoInjector\$2 replacement verification failed"
    return 1
  fi

  log "[PATCH] DisplayInfoInjector\$2 -> Gboard"
  sed -i 's/com.baidu.input_mi/com.google.android.inputmethod.latin/g' "$decompile_dir/smali/com/android/internal/os/AnrEnhanceImpl.smali"
  sed -i 's/com.baidu.input_mi/com.google.android.inputmethod.latin/g' "$decompile_dir/smali/miui/util/HapticFeedbackUtil.smali"

  echo "Gboard patches applied to miui-framework.jar"
}

# Main miui-framework patching function
patch_miui_framework() {
  local miui_framework_path="$work_dir/build/baserom/images/system_ext/framework/miui-framework.jar"

  # Support external decompile dir like framework
  local external_dir_flag=0
  local external_dir=""
  if [ -n "${MIUI_FRAMEWORK_DECOMPILE_DIR:-}" ] && [ -d "${MIUI_FRAMEWORK_DECOMPILE_DIR}" ]; then
    external_dir_flag=1
    external_dir="${MIUI_FRAMEWORK_DECOMPILE_DIR}"
  elif [ -d "${WORK_DIR}/miui-framework_decompile" ]; then
    external_dir_flag=1
    external_dir="${WORK_DIR}/miui-framework_decompile"
  fi

  if [ $external_dir_flag -eq 0 ] && [ ! -f "$miui_framework_path" ]; then
    err "miui-framework.jar not found at $miui_framework_path and no MIUI_FRAMEWORK_DECOMPILE_DIR provided"
    return 1
  fi

  log "Starting Android 16 miui-framework.jar patch"
  local decompile_dir
  if [ $external_dir_flag -eq 1 ]; then
    log "Using existing miui-framework decompile dir: $external_dir"
    decompile_dir="$external_dir"
  else
    decompile_dir=$(decompile_jar "$miui_framework_path") || return 1
  fi

  # Existing HyperMOS Gboard patch
  apply_miui_framework_gboard "$decompile_dir" || return 1

  # CN notification related xBuild substitutions are only enabled by the feature flag.
  if [ "$FEATURE_CN_NOTIFICATION_FIX" -eq 1 ]; then
    apply_miui_framework_cn_notification_fix "$decompile_dir" || return 1
  fi

  # Apply invoke-custom patches (common to all features)
  # modify_invoke_custom_methods "$decompile_dir"

  if [ $external_dir_flag -eq 0 ]; then
    recompile_jar "$miui_framework_path" > /dev/null || { err "miui-framework.jar recompile failed"; return 1; }

    rm -rf "$decompile_dir" "$WORK_DIR/miui-framework"
    log "Completed miui-framework.jar patching"
  else
    log "Verification completed on existing miui-framework decompile dir (no rebuild)"
  fi
}

# Main function
# Parse requested features, then initialize environment and tools.
parse_feature_flags "$@" || exit 1
init_env || { err "FAST-FAIL: init_env failed"; exit 1; }
ensure_tools || { err "FAST-FAIL: required tools unavailable"; exit 1; }

# Patch requested JARs. Every stage is required on the A16 HyperMOS stack:
# never continue with a half-patched ROM.
patch_framework || { err "FAST-FAIL: framework.jar patch failed"; exit 1; }
patch_services || { err "FAST-FAIL: services.jar patch failed"; exit 1; }
patch_miui_services || { err "FAST-FAIL: miui-services.jar patch failed"; exit 1; }
patch_miui_framework || { err "FAST-FAIL: miui-framework.jar patch failed"; exit 1; }

# Add patched JARs only after all four stages completed successfully.
install_patched_jar() {
  local src="$1"
  local dst="$2"
  local label="$3"

  if [ ! -s "$src" ]; then
    err "FAST-FAIL: $label output missing or empty: $src"
    exit 1
  fi

  mv -f "$src" "$dst" || {
    err "FAST-FAIL: failed to install patched $label"
    exit 1
  }

  if [ ! -s "$dst" ]; then
    err "FAST-FAIL: installed $label is missing or empty"
    exit 1
  fi
}

install_patched_jar "framework_patched.jar" "$work_dir/build/baserom/images/system/system/framework/framework.jar" "framework.jar"
install_patched_jar "services_patched.jar" "$work_dir/build/baserom/images/system/system/framework/services.jar" "services.jar"
install_patched_jar "miui-services_patched.jar" "$work_dir/build/baserom/images/system_ext/framework/miui-services.jar" "miui-services.jar"
install_patched_jar "miui-framework_patched.jar" "$work_dir/build/baserom/images/system_ext/framework/miui-framework.jar" "miui-framework.jar"
