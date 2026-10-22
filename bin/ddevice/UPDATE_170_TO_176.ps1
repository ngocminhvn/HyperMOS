# HyperMOS EU HAOTIAN #170 -> #176: unattended, non-wiping update.
# Requires images and SHA256SUMS from the exact comparison artifact.
# Launch through UPDATE_170_TO_176.bat from BOOTLOADER fastboot, not fastbootd.
# Does not format data, erase partitions, or change active slot.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$expected = @(
    'system_a.img',
    'system_ext_a.img',
    'product_a.img',
    'firmware/init_boot.img'
)
$fastbootCandidates = @(
    (Join-Path $Root 'fastboot.exe'),
    (Join-Path $Root 'platform-tools/fastboot.exe')
)
$Fastboot = $null
foreach ($candidate in $fastbootCandidates) {
    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
        $Fastboot = $candidate
        break
    }
}
if (-not $Fastboot) {
    $command = Get-Command fastboot.exe -ErrorAction SilentlyContinue
    if ($command) { $Fastboot = $command.Source }
}
if (-not $Fastboot) {
    throw 'fastboot.exe missing. Put the script inside platform-tools, or add platform-tools to PATH.'
}

function Invoke-Fastboot {
    param([string[]] $Arguments, [switch] $AllowFailure, [switch] $Silent)
    # On Windows PowerShell 5.1, fastboot's getvar writes normally to STDERR.
    # Temporarily allowing stderr prevents a misleading NativeCommandError.
    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $response = (& $Fastboot @Arguments 2>&1 | Out-String)
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousPreference
    }
    if (-not $Silent -and $response.Trim()) { Write-Host $response.Trim() }
    if (-not $AllowFailure -and $exitCode -ne 0) {
        throw ('fastboot ' + ($Arguments -join ' ') + ' failed (exit ' + $exitCode + ')')
    }
    return $response
}

function Read-FastbootVar([string] $Name) {
    $response = Invoke-Fastboot -Arguments @('getvar', $Name) -AllowFailure
    $escaped = [regex]::Escape($Name)
    $match = [regex]::Match($response, '(?im)^\s*(?:\(bootloader\)\s*)?' +
        $escaped + ':\s*(\S+)\s*$')
    if (-not $match.Success) { throw ('Cannot reliably read fastboot variable: ' + $Name) }
    return $match.Groups[1].Value.ToLowerInvariant()
}

function Wait-ForFastboot([string] $Expected) {
    for ($i = 0; $i -lt 45; $i++) {
        $devices = Invoke-Fastboot -Arguments @('devices') -AllowFailure -Silent
        if ($devices -match '(?m)^\S+\s+fastboot\s*
        Start-Sleep -Seconds 2
    }
    throw ('Device not reachable in expected fastboot mode: is-userspace=' + $Expected)
}

function Verify-Images {
    $manifest = Join-Path $Root 'SHA256SUMS'
    if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
        throw 'SHA256SUMS is missing. Extract the FULL build #176 upgrade artifact.'
    }
    $known = @{}
    foreach ($line in Get-Content -LiteralPath $manifest) {
        if ($line -notmatch '^([0-9a-fA-F]{64})\s+(\S+\.img)\s*$') {
            throw ('Invalid checksum manifest entry: ' + $line)
        }
        $key = $Matches[2].Replace('\', '/')
        if ($known.ContainsKey($key)) { throw ('Duplicate hash: ' + $key) }
        $known[$key] = $Matches[1].ToLowerInvariant()
    }
    if ($known.Count -ne $expected.Count) {
        throw 'Unexpected IMG count. This script is pinned to the 4 changes verified for builds #170 -> #176.'
    }
    foreach ($name in $expected) {
        if (-not $known.ContainsKey($name)) { throw ('IMG absent from manifest: ' + $name) }
        $path = Join-Path $Root ($name.Replace('/', '\'))
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw ('Missing image: ' + $name)
        }
        $real = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant()
        if ($real -ne $known[$name]) { throw ('Corrupt/incorrect #176 IMG: ' + $name) }
        Write-Host ('[SHA256 OK] ' + $name)
    }
    foreach ($name in $known.Keys) {
        if ($expected -notcontains $name) { throw ('Unrecognized IMG: ' + $name) }
    }
}

function Check-PartitionSize([string] $Partition, [string] $Filename) {
    $given = Read-FastbootVar ('partition-size:' + $Partition)
    if ($given -match '^0x[0-9a-f]+$') {
        $available = [Convert]::ToInt64($given.Substring(2), 16)
    } elseif ($given -match '^\d+$') {
        $available = [long]$given
    } else {
        throw ('Unknown partition size format: ' + $Partition + ' = ' + $given)
    }
    $size = (Get-Item -LiteralPath (Join-Path $Root $Filename)).Length
    Write-Host ('[SIZE] ' + $Partition + ': image=' + $size + ' partition=' + $available)
    if ($available -le 0 -or $size -gt $available) {
        throw ('Image exceeds the #170 partition allocation for ' + $Partition +
               '. Stop: requires verified dynamic partition resize or full super layout update.')
    }
}

Write-Host 'HyperMOS EU HAOTIAN #170 -> #176 (data-preserving attempt)'
Write-Host 'Requires unlocked bootloader, matching #170 ROM, and a tested #170 rollback.'
Write-Host 'No userdata erase, no metadata erase, no slot switching.'
Verify-Images

Write-Host '[CHECK] Bootloader fastboot / HAOTIAN / active slot A'
Wait-ForFastboot 'no'
if ((Read-FastbootVar 'product') -ne 'haotian') { throw 'Wrong device (expected HAOTIAN)' }
if ((Read-FastbootVar 'current-slot') -ne 'a') {
    throw 'Active slot is NOT A. Build #176 artifact contains only populated _a partitions; nothing flashed.'
}
$oldSnapshot = Invoke-Fastboot -Arguments @('getvar', 'snapshot-update-status') -AllowFailure
if ($oldSnapshot -match '(?im)snapshot-update-status:\s*(\S+)') {
    if ($Matches[1].ToLowerInvariant() -ne 'none') {
        throw 'A snapshot update is in progress. Nothing flashed.'
    }
}

Write-Host '[MODE] Entering userspace fastboot (fastbootd)'
Invoke-Fastboot -Arguments @('reboot', 'fastboot') | Out-Null
Wait-ForFastboot 'yes'
if ((Read-FastbootVar 'product') -ne 'haotian') { throw 'Device identity changed in fastbootd' }
if ((Read-FastbootVar 'current-slot') -ne 'a') { throw 'Slot changed; abort.' }
if ((Read-FastbootVar 'snapshot-update-status') -ne 'none') {
    throw 'Snapshot update is not NONE. Refusing to flash dynamic partitions.'
}
foreach ($partition in @('system_a', 'system_ext_a', 'product_a')) {
    Check-PartitionSize $partition ($partition + '.img')
}

Write-Host '[FLASH] Updating all three changed logical partitions, WITHOUT wiping data'
foreach ($partition in @('system_a', 'system_ext_a', 'product_a')) {
    $img = Join-Path $Root ($partition + '.img')
    Invoke-Fastboot -Arguments @('flash', $partition, $img) | Out-Null
}

Write-Host '[MODE] Returning to bootloader fastboot for init_boot'
Invoke-Fastboot -Arguments @('reboot', 'bootloader') | Out-Null
Wait-ForFastboot 'no'
if ((Read-FastbootVar 'product') -ne 'haotian' -or
    (Read-FastbootVar 'current-slot') -ne 'a') {
    throw 'Unexpected device/slot before init_boot flash. Stop.'
}
Write-Host '[FLASH] Updating init_boot_a from build #176'
Invoke-Fastboot -Arguments @('flash', 'init_boot_a',
    (Join-Path $Root 'firmware/init_boot.img')) | Out-Null
Write-Host '[DONE] All 4 image flashes reported success. Rebooting without wiping.'
Invoke-Fastboot -Arguments @('reboot') | Out-Null
Write-Host 'Completed. First boot may take longer. This is not a guarantee of boot compatibility.'
) {
            $response = Invoke-Fastboot -Arguments @('getvar', 'is-userspace') -AllowFailure -Silent
            if ($response -match ('(?im)is-userspace:\s*' + $Expected + '\s*
        Start-Sleep -Seconds 2
    }
    throw ('Device not reachable in expected fastboot mode: is-userspace=' + $Expected)
}

function Verify-Images {
    $manifest = Join-Path $Root 'SHA256SUMS'
    if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
        throw 'SHA256SUMS is missing. Extract the FULL build #176 upgrade artifact.'
    }
    $known = @{}
    foreach ($line in Get-Content -LiteralPath $manifest) {
        if ($line -notmatch '^([0-9a-fA-F]{64})\s+(\S+\.img)\s*$') {
            throw ('Invalid checksum manifest entry: ' + $line)
        }
        $key = $Matches[2].Replace('\', '/')
        if ($known.ContainsKey($key)) { throw ('Duplicate hash: ' + $key) }
        $known[$key] = $Matches[1].ToLowerInvariant()
    }
    if ($known.Count -ne $expected.Count) {
        throw 'Unexpected IMG count. This script is pinned to the 4 changes verified for builds #170 -> #176.'
    }
    foreach ($name in $expected) {
        if (-not $known.ContainsKey($name)) { throw ('IMG absent from manifest: ' + $name) }
        $path = Join-Path $Root ($name.Replace('/', '\'))
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw ('Missing image: ' + $name)
        }
        $real = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant()
        if ($real -ne $known[$name]) { throw ('Corrupt/incorrect #176 IMG: ' + $name) }
        Write-Host ('[SHA256 OK] ' + $name)
    }
    foreach ($name in $known.Keys) {
        if ($expected -notcontains $name) { throw ('Unrecognized IMG: ' + $name) }
    }
}

function Check-PartitionSize([string] $Partition, [string] $Filename) {
    $given = Read-FastbootVar ('partition-size:' + $Partition)
    if ($given -match '^0x[0-9a-f]+$') {
        $available = [Convert]::ToInt64($given.Substring(2), 16)
    } elseif ($given -match '^\d+$') {
        $available = [long]$given
    } else {
        throw ('Unknown partition size format: ' + $Partition + ' = ' + $given)
    }
    $size = (Get-Item -LiteralPath (Join-Path $Root $Filename)).Length
    Write-Host ('[SIZE] ' + $Partition + ': image=' + $size + ' partition=' + $available)
    if ($available -le 0 -or $size -gt $available) {
        throw ('Image exceeds the #170 partition allocation for ' + $Partition +
               '. Stop: requires verified dynamic partition resize or full super layout update.')
    }
}

Write-Host 'HyperMOS EU HAOTIAN #170 -> #176 (data-preserving attempt)'
Write-Host 'Requires unlocked bootloader, matching #170 ROM, and a tested #170 rollback.'
Write-Host 'No userdata erase, no metadata erase, no slot switching.'
Verify-Images

Write-Host '[CHECK] Bootloader fastboot / HAOTIAN / active slot A'
Wait-ForFastboot 'no'
if ((Read-FastbootVar 'product') -ne 'haotian') { throw 'Wrong device (expected HAOTIAN)' }
if ((Read-FastbootVar 'current-slot') -ne 'a') {
    throw 'Active slot is NOT A. Build #176 artifact contains only populated _a partitions; nothing flashed.'
}
$oldSnapshot = Invoke-Fastboot -Arguments @('getvar', 'snapshot-update-status') -AllowFailure
if ($oldSnapshot -match '(?im)snapshot-update-status:\s*(\S+)') {
    if ($Matches[1].ToLowerInvariant() -ne 'none') {
        throw 'A snapshot update is in progress. Nothing flashed.'
    }
}

Write-Host '[MODE] Entering userspace fastboot (fastbootd)'
Invoke-Fastboot -Arguments @('reboot', 'fastboot') | Out-Null
Wait-ForFastboot 'yes'
if ((Read-FastbootVar 'product') -ne 'haotian') { throw 'Device identity changed in fastbootd' }
if ((Read-FastbootVar 'current-slot') -ne 'a') { throw 'Slot changed; abort.' }
if ((Read-FastbootVar 'snapshot-update-status') -ne 'none') {
    throw 'Snapshot update is not NONE. Refusing to flash dynamic partitions.'
}
foreach ($partition in @('system_a', 'system_ext_a', 'product_a')) {
    Check-PartitionSize $partition ($partition + '.img')
}

Write-Host '[FLASH] Updating all three changed logical partitions, WITHOUT wiping data'
foreach ($partition in @('system_a', 'system_ext_a', 'product_a')) {
    $img = Join-Path $Root ($partition + '.img')
    Invoke-Fastboot -Arguments @('flash', $partition, $img) | Out-Null
}

Write-Host '[MODE] Returning to bootloader fastboot for init_boot'
Invoke-Fastboot -Arguments @('reboot', 'bootloader') | Out-Null
Wait-ForFastboot 'no'
if ((Read-FastbootVar 'product') -ne 'haotian' -or
    (Read-FastbootVar 'current-slot') -ne 'a') {
    throw 'Unexpected device/slot before init_boot flash. Stop.'
}
Write-Host '[FLASH] Updating init_boot_a from build #176'
Invoke-Fastboot -Arguments @('flash', 'init_boot_a',
    (Join-Path $Root 'firmware/init_boot.img')) | Out-Null
Write-Host '[DONE] All 4 image flashes reported success. Rebooting without wiping.'
Invoke-Fastboot -Arguments @('reboot') | Out-Null
Write-Host 'Completed. First boot may take longer. This is not a guarantee of boot compatibility.'
)) {
                return
            }
        }
        Start-Sleep -Seconds 2
    }
    throw ('Device not reachable in expected fastboot mode: is-userspace=' + $Expected)
}

function Verify-Images {
    $manifest = Join-Path $Root 'SHA256SUMS'
    if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
        throw 'SHA256SUMS is missing. Extract the FULL build #176 upgrade artifact.'
    }
    $known = @{}
    foreach ($line in Get-Content -LiteralPath $manifest) {
        if ($line -notmatch '^([0-9a-fA-F]{64})\s+(\S+\.img)\s*$') {
            throw ('Invalid checksum manifest entry: ' + $line)
        }
        $key = $Matches[2].Replace('\', '/')
        if ($known.ContainsKey($key)) { throw ('Duplicate hash: ' + $key) }
        $known[$key] = $Matches[1].ToLowerInvariant()
    }
    if ($known.Count -ne $expected.Count) {
        throw 'Unexpected IMG count. This script is pinned to the 4 changes verified for builds #170 -> #176.'
    }
    foreach ($name in $expected) {
        if (-not $known.ContainsKey($name)) { throw ('IMG absent from manifest: ' + $name) }
        $path = Join-Path $Root ($name.Replace('/', '\'))
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw ('Missing image: ' + $name)
        }
        $real = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant()
        if ($real -ne $known[$name]) { throw ('Corrupt/incorrect #176 IMG: ' + $name) }
        Write-Host ('[SHA256 OK] ' + $name)
    }
    foreach ($name in $known.Keys) {
        if ($expected -notcontains $name) { throw ('Unrecognized IMG: ' + $name) }
    }
}

function Check-PartitionSize([string] $Partition, [string] $Filename) {
    $given = Read-FastbootVar ('partition-size:' + $Partition)
    if ($given -match '^0x[0-9a-f]+$') {
        $available = [Convert]::ToInt64($given.Substring(2), 16)
    } elseif ($given -match '^\d+$') {
        $available = [long]$given
    } else {
        throw ('Unknown partition size format: ' + $Partition + ' = ' + $given)
    }
    $size = (Get-Item -LiteralPath (Join-Path $Root $Filename)).Length
    Write-Host ('[SIZE] ' + $Partition + ': image=' + $size + ' partition=' + $available)
    if ($available -le 0 -or $size -gt $available) {
        throw ('Image exceeds the #170 partition allocation for ' + $Partition +
               '. Stop: requires verified dynamic partition resize or full super layout update.')
    }
}

Write-Host 'HyperMOS EU HAOTIAN #170 -> #176 (data-preserving attempt)'
Write-Host 'Requires unlocked bootloader, matching #170 ROM, and a tested #170 rollback.'
Write-Host 'No userdata erase, no metadata erase, no slot switching.'
Verify-Images

Write-Host '[CHECK] Bootloader fastboot / HAOTIAN / active slot A'
Wait-ForFastboot 'no'
if ((Read-FastbootVar 'product') -ne 'haotian') { throw 'Wrong device (expected HAOTIAN)' }
if ((Read-FastbootVar 'current-slot') -ne 'a') {
    throw 'Active slot is NOT A. Build #176 artifact contains only populated _a partitions; nothing flashed.'
}
$oldSnapshot = Invoke-Fastboot -Arguments @('getvar', 'snapshot-update-status') -AllowFailure
if ($oldSnapshot -match '(?im)snapshot-update-status:\s*(\S+)') {
    if ($Matches[1].ToLowerInvariant() -ne 'none') {
        throw 'A snapshot update is in progress. Nothing flashed.'
    }
}

Write-Host '[MODE] Entering userspace fastboot (fastbootd)'
Invoke-Fastboot -Arguments @('reboot', 'fastboot') | Out-Null
Wait-ForFastboot 'yes'
if ((Read-FastbootVar 'product') -ne 'haotian') { throw 'Device identity changed in fastbootd' }
if ((Read-FastbootVar 'current-slot') -ne 'a') { throw 'Slot changed; abort.' }
if ((Read-FastbootVar 'snapshot-update-status') -ne 'none') {
    throw 'Snapshot update is not NONE. Refusing to flash dynamic partitions.'
}
foreach ($partition in @('system_a', 'system_ext_a', 'product_a')) {
    Check-PartitionSize $partition ($partition + '.img')
}

Write-Host '[FLASH] Updating all three changed logical partitions, WITHOUT wiping data'
foreach ($partition in @('system_a', 'system_ext_a', 'product_a')) {
    $img = Join-Path $Root ($partition + '.img')
    Invoke-Fastboot -Arguments @('flash', $partition, $img) | Out-Null
}

Write-Host '[MODE] Returning to bootloader fastboot for init_boot'
Invoke-Fastboot -Arguments @('reboot', 'bootloader') | Out-Null
Wait-ForFastboot 'no'
if ((Read-FastbootVar 'product') -ne 'haotian' -or
    (Read-FastbootVar 'current-slot') -ne 'a') {
    throw 'Unexpected device/slot before init_boot flash. Stop.'
}
Write-Host '[FLASH] Updating init_boot_a from build #176'
Invoke-Fastboot -Arguments @('flash', 'init_boot_a',
    (Join-Path $Root 'firmware/init_boot.img')) | Out-Null
Write-Host '[DONE] All 4 image flashes reported success. Rebooting without wiping.'
Invoke-Fastboot -Arguments @('reboot') | Out-Null
Write-Host 'Completed. First boot may take longer. This is not a guarantee of boot compatibility.'
