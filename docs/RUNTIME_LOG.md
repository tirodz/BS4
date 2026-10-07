# Runtime log

No QEMU guest launch or PS4 kernel boot has been attempted in BS4 as of 2026-10-07. No serial guest output, guest crash, Safe Mode frame, or screen evidence exists.

## 2026-10-07 10:51 +01:00 — Launcher preflight only

- Command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Run-Orbital500.ps1` (Windows PowerShell 5.1 preflight subprocess).
- Configuration: historical 5.00 target.
- Inputs: official 5.00 system PUP present; no staged decrypted kernel/SFLASH/VBIOS/HDD/USB/SAMU inputs; BIOS/GRUB build images absent.
- Process behavior: launcher stopped before starting QEMU as designed.
- Exit: preflight blocked (exit 2); see `logs/orbital-m0/launcher-windows-powershell-20261007.log` and `preflight-windows-powershell-20261007.log`.
- Observed: missing-input report only. This is not a kernel boot failure and not evidence of guest behavior.
- Next: complete build/runtime preparation and rerun preflight.
