# Troubleshooting

## `MISSING` entries in firmware preflight

The official PUP does not stand in for all Orbital runtime paths. See `FIRMWARE_REQUIREMENTS.md` for exact expected paths and whether the existing PUP can provide each file. Preflight validates visible headers/container readability and declared versions; it does not authenticate Sony data.

## Launcher stops before QEMU

This is expected while preflight or generated boot images are missing. Inspect the timestamped log under `logs/orbital-m0/`. No guest boot evidence results from this check.

## BIOS help text errors

The Kconfig failure occurred because Windows line endings reached the historical lexer. Normalize `src/Kconfig` and `vgasrc/Kconfig` to LF; verified `olddefconfig` then passed (`bios-kconfig-lf-fixed-20261007.log`). The current BIOS compiler failure is Clang rejecting GCC-only x86 constraints `Q` and `=Qi`; see ERR-0004.

## GRUB linker symbol check

Current failure: `none of __bss_start, edata or _edata is defined`, caused by native MinGW PE/COFF output. See ERR-0001. Do not treat an ELF linker availability check as a completed GRUB build.

## QEMU machine not listed

Confirm the executable is from the pinned `orbital-qemu` build, then run `qemu-system-ps4.exe -machine help` and `-device help`. Verified local build reported QEMU 2.11.91 and `ps4` machine/devices.

## Safe Mode not reached

No guest run has been attempted yet. Once it is, append exact command, input inventory, exit code, logs, observed serial/display behavior, and interpretation to `RUNTIME_LOG.md` before diagnosing.
