[CmdletBinding()]
param(
    [string]$FirmwareRoot = '',
    [ValidateSet('tcg', 'hax')]
    [string]$Accelerator = 'tcg',
    [string]$LogsRoot = ''
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($FirmwareRoot)) { $FirmwareRoot = Join-Path $PSScriptRoot '..\firmware\orbital-5.00' }
if ([string]::IsNullOrWhiteSpace($LogsRoot)) { $LogsRoot = Join-Path $PSScriptRoot '..\logs\orbital-m0' }
$workspaceRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$repoRoot = Join-Path $workspaceRoot 'orbital-500'
$FirmwareRoot = [IO.Path]::GetFullPath($FirmwareRoot)
$LogsRoot = [IO.Path]::GetFullPath($LogsRoot)
New-Item -ItemType Directory -Force -Path $LogsRoot | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$consoleLog = Join-Path $LogsRoot "$stamp-qemu-console.log"
$debugLog = Join-Path $LogsRoot "$stamp-qemu-debug.log"
$uartLog = Join-Path $LogsRoot "$stamp-guest-uart.log"
$preflightLog = Join-Path $LogsRoot "$stamp-preflight.log"

Write-Output "Orbital 5.00 launch at $(Get-Date -Format o)"
Write-Output "Firmware staging: $FirmwareRoot"
Write-Output "Logs: $LogsRoot"

$preflight = Join-Path $workspaceRoot 'firmware\tools\Test-Orbital500Inputs.ps1'
$pwshCommand = Get-Command powershell.exe -ErrorAction SilentlyContinue
if ($null -eq $pwshCommand) { $pwshCommand = Get-Command pwsh.exe -ErrorAction SilentlyContinue }
$powerShellExe = $null
if ($null -ne $pwshCommand) {
    $powerShellExe = $pwshCommand.Source
} else {
    Write-Output 'LAUNCH: BLOCKED — PowerShell is required to run the firmware preflight.'
    exit 5
}
& $powerShellExe -NoProfile -ExecutionPolicy Bypass -File $preflight -FirmwareRoot $FirmwareRoot 2>&1 | Tee-Object -FilePath $preflightLog
$preflightExit = $LASTEXITCODE
if ($preflightExit -ne 0) {
    Write-Output "LAUNCH: BLOCKED — firmware preflight exit code $preflightExit. No emulator process started."
    exit $preflightExit
}

$buildBin = Join-Path $repoRoot 'bin'
$qemuExe = Join-Path $buildBin 'qemu-system-ps4.exe'
$qemuImg = Join-Path $repoRoot 'orbital-qemu\qemu-img.exe'
$bios = Join-Path $buildBin 'ubios.bin'
$grubImage = Join-Path $buildBin 'boot.img'
$msysBin = Join-Path $workspaceRoot 'tools\msys64\msys64\mingw64\bin'
foreach ($requiredBuildFile in @($qemuExe, $qemuImg, $bios, $grubImage)) {
    if (-not (Test-Path -LiteralPath $requiredBuildFile -PathType Leaf)) {
        Write-Error "BUILD OUTPUT MISSING: $requiredBuildFile. Build the pinned snapshot with orbital-500/build.sh first."
        exit 3
    }
}

foreach ($source in @(@{ Source = $bios; Name = 'ubios.bin' }, @{ Source = $grubImage; Name = 'boot.img' })) {
    $destination = Join-Path $FirmwareRoot $source.Name
    if (Test-Path -LiteralPath $destination -PathType Leaf) {
        $sourceHash = (Get-FileHash -LiteralPath $source.Source -Algorithm SHA256).Hash
        $destinationHash = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash
        if ($sourceHash -ne $destinationHash) {
            Write-Error "REFUSING TO OVERWRITE DIFFERENT staged build output: $destination"
            exit 3
        }
    } else {
        Copy-Item -LiteralPath $source.Source -Destination $destination
    }
}

$hddImage = Join-Path $FirmwareRoot 'hdd.qcow2'
if (-not (Test-Path -LiteralPath $hddImage -PathType Leaf)) {
    Write-Output 'Creating the historical 200 GB sparse PS4 system disk from the staged HDD images.'
    Push-Location $FirmwareRoot
    try {
        & $qemuImg create-ps4 --data .\hdd -f qcow2 .\hdd.qcow2 200G 2>&1 | Tee-Object -FilePath (Join-Path $LogsRoot "$stamp-qemu-img.log")
        if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $hddImage -PathType Leaf)) {
            Write-Error "HDD image creation failed. Inspect $(Join-Path $LogsRoot "$stamp-qemu-img.log")."
            exit 4
        }
    } finally { Pop-Location }
}
$hddStream = [IO.File]::OpenRead($hddImage)
try {
    $hddHeader = [byte[]]::new(8)
    if ($hddStream.Length -lt 72 -or $hddStream.Read($hddHeader, 0, 8) -ne 8 -or
        $hddHeader[0] -ne 0x51 -or $hddHeader[1] -ne 0x46 -or $hddHeader[2] -ne 0x49 -or $hddHeader[3] -ne 0xfb) {
        Write-Output "GENERATED DISK INVALID: $hddImage is not a readable QCOW2 image."
        exit 4
    }
} finally { $hddStream.Dispose() }

$oldPath = $env:PATH
$oldUartLog = $env:ORBITAL_UART_LOG
$env:PATH = "$msysBin;$oldPath"
$env:ORBITAL_UART_LOG = $uartLog
$qemuArgs = @(
    '-bios', '.\ubios.bin',
    '-kernel', '.\boot.img',
    '-drive', 'if=none,id=hdd,file=.\hdd.qcow2',
    '-drive', 'if=none,id=usb,file=.\usb\usb-pup-500rec.qcow2,read-only=on',
    '-drive', 'if=ide,index=0,media=cdrom',
    '-device', 'usb-storage,drive=hdd,bus=axhci1.0,port=1',
    '-device', 'usb-storage,drive=usb,bus=axhci2.0',
    '-monitor', 'stdio',
    '-smp', '8',
    '-display', 'orbital',
    '-accel', $Accelerator,
    '-d', 'guest_errors,unimp',
    '-D', $debugLog
)

Write-Output "QEMU console log: $consoleLog"
Write-Output "QEMU debug log: $debugLog"
Write-Output "Guest UART byte log: $uartLog"
Write-Output 'Press Ctrl+C or close the Orbital display to stop. The QEMU monitor is interactive on this console.'
Push-Location $FirmwareRoot
try {
    & $qemuExe @qemuArgs 2>&1 | Tee-Object -FilePath $consoleLog
    $qemuExit = $LASTEXITCODE
} finally {
    Pop-Location
    $env:PATH = $oldPath
    if ($null -eq $oldUartLog) { Remove-Item Env:ORBITAL_UART_LOG -ErrorAction SilentlyContinue } else { $env:ORBITAL_UART_LOG = $oldUartLog }
}
Write-Output "QEMU exited with code $qemuExit."
exit $qemuExit
