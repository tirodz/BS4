[CmdletBinding()]
param(
    [string]$FirmwareRoot = ''
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($FirmwareRoot)) {
    $FirmwareRoot = Join-Path (Split-Path -Parent $PSScriptRoot) 'orbital-5.00'
}
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$FirmwareRoot = [IO.Path]::GetFullPath($FirmwareRoot)
$workspaceRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$versionManifest = Join-Path $FirmwareRoot 'firmware-manifest.json'
$issues = [Collections.Generic.List[string]]::new()
$items = @(
    @{ Path = 'sflash/orbisys-500'; Label = 'decrypted 5.00 kernel ELF'; Version = '5.00'; Kind = 'elf'; Alternatives = @('orbital-500/bin/sflash/orbisys-500', 'orbital/bin/sflash/orbisys-500') },
    @{ Path = 'sflash.bin'; Label = 'raw writable sflash input'; Version = '5.00'; Kind = 'opaque'; Alternatives = @('orbital-500/bin/sflash.bin', 'orbital/bin/sflash.bin') },
    @{ Path = 'vbios.bin'; Label = '5.00 VBIOS ROM'; Version = '5.00'; Kind = 'opaque'; Alternatives = @('orbital-500/bin/vbios.bin', 'orbital/bin/vbios.bin') },
    @{ Path = 'hdd/eap.img'; Label = 'documented HDD eap partition image'; Version = '5.00'; Kind = 'opaque'; Alternatives = @('orbital-500/bin/hdd/eap.img', 'orbital/bin/hdd/eap.img') },
    @{ Path = 'hdd/preinst.img'; Label = 'documented HDD preinst partition image'; Version = 'any-recovery'; Kind = 'opaque'; Alternatives = @('orbital-500/bin/hdd/preinst.img', 'orbital/bin/hdd/preinst.img') },
    @{ Path = 'hdd/recovery.img'; Label = 'documented HDD recovery partition image'; Version = 'any-recovery'; Kind = 'opaque'; Alternatives = @('orbital-500/bin/hdd/recovery.img', 'orbital/bin/hdd/recovery.img') },
    @{ Path = 'hdd/system.img'; Label = '5.00 system partition image'; Version = '5.00'; Kind = 'opaque'; Alternatives = @('orbital-500/bin/hdd/system.img', 'orbital/bin/hdd/system.img') },
    @{ Path = 'hdd/system_ex.img'; Label = '5.00 system_ex partition image'; Version = '5.00'; Kind = 'opaque'; Alternatives = @('orbital-500/bin/hdd/system_ex.img', 'orbital/bin/hdd/system_ex.img') },
    @{ Path = 'usb/usb-pup-500rec.qcow2'; Label = '5.00 recovery USB qcow2 image'; Version = '5.00'; Kind = 'qcow2'; Alternatives = @('orbital-500/bin/usb/usb-pup-500rec.qcow2', 'orbital/bin/usb/usb-pup-500rec.qcow2') },
    @{ Path = 'crypto/blobs.zip'; Label = 'SAMU crypto blob archive'; Version = '5.00'; Kind = 'blobs'; Alternatives = @('orbital-500/bin/crypto/blobs.zip', 'orbital/bin/crypto/blobs.zip') }
)

Write-Output "Orbital 5.00 firmware preflight"
Write-Output "Target directory: $FirmwareRoot"

$pupCandidates = @(
    (Join-Path (Join-Path $workspaceRoot 'firmware') 'official\PS4UPDATE-5.00-system.PUP'),
    (Join-Path $workspaceRoot 'PS4UPDATE.PUP')
)
$seenPupHashes = @{}
foreach ($pupPath in $pupCandidates) {
    if (Test-Path -LiteralPath $pupPath -PathType Leaf) {
        try {
            $pupInfo = Get-Item -LiteralPath $pupPath
            $pupHash = (Get-FileHash -LiteralPath $pupPath -Algorithm SHA256).Hash
            if ($seenPupHashes.ContainsKey($pupHash)) {
                Write-Output "PUP IDENTICAL COPY: SHA256 $pupHash; $pupPath"
                continue
            }
            $seenPupHashes[$pupHash] = $true
            if ($pupInfo.Length -eq 374669312) {
                Write-Output "PUP PRESENT: size matches the published 5.00 system package ($($pupInfo.Length) bytes); encrypted/signed; not a direct Orbital runtime input; SHA256 $pupHash; $pupPath"
            } else {
                Write-Output "PUP PRESENT: version not identified by known 5.00 system-package size ($($pupInfo.Length) bytes); encrypted/signed; not a direct Orbital runtime input; SHA256 $pupHash; $pupPath"
            }
        } catch {
            Write-Output "PUP UNREADABLE: $pupPath ($($_.Exception.Message))"
        }
    }
}

if (-not (Test-Path -LiteralPath $FirmwareRoot -PathType Container)) {
    Write-Output "MISSING DIRECTORY: $FirmwareRoot"
    $issues.Add("Firmware root directory is missing: $FirmwareRoot")
}

$manifest = $null
function Get-DeclaredArtifactVersion([string]$RelativePath) {
    if ($null -eq $manifest -or $null -eq $manifest.artifacts) { return $null }
    $property = $manifest.artifacts.PSObject.Properties[$RelativePath]
    if ($null -eq $property) { return $null }
    return [string]$property.Value
}
if (Test-Path -LiteralPath $versionManifest -PathType Leaf) {
    try {
        $manifest = Get-Content -LiteralPath $versionManifest -Raw | ConvertFrom-Json
        if ($manifest.firmwareVersion -ne '5.00' -or $null -eq $manifest.artifacts) {
            Write-Output "WRONG VERSION/MANIFEST: $versionManifest must declare firmwareVersion '5.00' and an artifacts map."
            $issues.Add('Firmware version declaration is invalid.')
            $manifest = $null
        } else {
            Write-Output "PRESENT: version manifest declares firmware 5.00 ($versionManifest)"
        }
    } catch {
        Write-Output "UNREADABLE/CORRUPT: version manifest cannot be parsed ($versionManifest): $($_.Exception.Message)"
        $issues.Add('Firmware version manifest is unreadable or malformed.')
    }
} else {
    Write-Output "VERSION UNKNOWN: missing user provenance declaration $versionManifest"
    $issues.Add('Firmware version is not declared; create firmware-manifest.json after staging user-owned files.')
}

foreach ($item in $items) {
    $relative = $item.Path.Replace('/', [IO.Path]::DirectorySeparatorChar)
    $path = Join-Path $FirmwareRoot $relative
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $foundElsewhere = $null
        foreach ($alternative in $item.Alternatives) {
            $candidate = Join-Path $workspaceRoot ($alternative.Replace('/', [IO.Path]::DirectorySeparatorChar))
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { $foundElsewhere = $candidate; break }
        }
        if ($null -ne $foundElsewhere) {
            Write-Output "WRONG LOCATION: $($item.Label) found at $foundElsewhere; expected $path"
            $issues.Add("Wrong location for $($item.Path).")
        } else {
            Write-Output "MISSING: $($item.Label) — expected $path"
            $issues.Add("Missing $($item.Path).")
        }
        continue
    }

    try {
        $stream = [IO.File]::Open($path, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
        if ($stream.Length -eq 0) { throw 'file is empty' }
        if ($item.Kind -eq 'blobs') {
            $stream.Dispose()
            $stream = $null
            $archive = [IO.Compression.ZipFile]::OpenRead($path)
            try {
                $entries = @($archive.Entries | Where-Object { $_.FullName -match '^[0-9A-F]{32}\.bin$' })
                if ($entries.Count -eq 0) { throw 'ZIP has no root entries named <32 uppercase hex MD5>.bin' }
                foreach ($entry in $entries) {
                    if ($entry.Length -eq 0) { throw "empty crypto blob entry $($entry.FullName)" }
                    $entryStream = $entry.Open()
                    try { $entryStream.CopyTo([IO.Stream]::Null) } finally { $entryStream.Dispose() }
                }
            } finally { $archive.Dispose() }
            Write-Output ('PRESENT: {0} ({1}; {2} hash-named entries; ZIP entries decompressed successfully; encrypted input matching not checked)' -f $item.Label, $path, $entries.Count)
        } else {
            $header = [byte[]]::new([Math]::Min(64, [int]$stream.Length))
            [void]$stream.Read($header, 0, $header.Length)
            if ($item.Kind -eq 'elf' -and ($header.Length -lt 20 -or $header[0] -ne 0x7f -or $header[1] -ne 0x45 -or $header[2] -ne 0x4c -or $header[3] -ne 0x46 -or $header[4] -ne 2 -or $header[5] -ne 1 -or $header[18] -ne 0x3e -or $header[19] -ne 0)) {
                throw 'not a little-endian ELF64 x86-64 image (expected ELF class 2, data 1, machine 0x003e)'
            }
            if ($item.Kind -eq 'qcow2') {
                if ($header.Length -lt 8 -or $header[0] -ne 0x51 -or $header[1] -ne 0x46 -or $header[2] -ne 0x49 -or $header[3] -ne 0xfb) { throw 'not a qcow2 image (QFI signature missing)' }
                $qcowVersion = ([uint32]$header[4] * 16777216) + ([uint32]$header[5] * 65536) + ([uint32]$header[6] * 256) + [uint32]$header[7]
                if ($qcowVersion -lt 2 -or $qcowVersion -gt 3) { throw ('unsupported/invalid qcow2 version {0}' -f $qcowVersion) }
            }
            Write-Output ('PRESENT: {0} ({1}; {2} bytes; readable; content semantics not cryptographically validated)' -f $item.Label, $path, $stream.Length)
        }
    } catch {
        if ($stream) { $stream.Dispose() }
        Write-Output "UNREADABLE/CORRUPT/WRONG TYPE: $($item.Label) ($path): $($_.Exception.Message)"
        $issues.Add("Invalid $($item.Path).")
        continue
    } finally {
        if ($stream) { $stream.Dispose() }
    }

    $declared = Get-DeclaredArtifactVersion $item.Path
    if ($null -eq $declared) {
        Write-Output "VERSION UNKNOWN: no manifest version for $($item.Path)"
        $issues.Add("Undeclared version for $($item.Path).")
    } elseif ($item.Version -ne 'any-recovery' -and $declared -ne $item.Version) {
        Write-Output "WRONG VERSION: $($item.Path) declares '$declared'; expected '$($item.Version)'"
        $issues.Add("Wrong version for $($item.Path).")
    }
}

Write-Output 'NOTE: opaque Sony partition, sflash, and VBIOS data can only be checked for existence, readability, and declared provenance here; no proprietary cryptographic validation is guessed.'
Write-Output 'NOTE: runtime-loaded decrypted userland ELFs and SAMU blob coverage are firmware-dependent; Orbital does not name a complete static Safe Mode file list.'
if ($issues.Count -gt 0) {
    Write-Output "PREFLIGHT: BLOCKED — $($issues.Count) issue(s); no emulator was started."
    exit 2
}
Write-Output 'PREFLIGHT: PASS — required inputs are present, readable, structurally plausible, and declared for the target version.'
exit 0
