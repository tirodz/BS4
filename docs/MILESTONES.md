# Milestones

| Date | Milestone | Status | Evidence |
|---|---|---|---|
| 2026-10-06 | Historical Orbital baseline identified | VERIFIED | `research/ORBITAL_BASELINE.md`; pinned root commit. |
| 2026-10-06 | Historical Orbital checked out | VERIFIED | `orbital-500` checkout and submodule hashes; see `DEPENDENCIES.md`. |
| 2026-10-06 | Missing public `core` integration investigated | VERIFIED | `research/ORBITAL_CORE_INVESTIGATION.md`. |
| 2026-10-07 | Local MSYS2 toolchain prepared | VERIFIED | local `tools/msys64`; package table in `research/ORBITAL_WINDOWS_BUILD.md`. |
| 2026-10-07 | QEMU configured for Windows | VERIFIED | `logs/orbital-m0/configure-20261007.log` and build record. |
| 2026-10-07 | Historical QEMU clean build | VERIFIED | exit 0, clean rebuild log, executable checks. |
| 2026-10-07 | Official 5.00 system-update PUP supplied | VERIFIED BY USER + LOCAL FILE CHECK | file size/hash in `docs/FIRMWARE.md`; signature not independently checked. |
| 2026-10-07 | Firmware preflight recognizes PUP | VERIFIED | Re-run under Windows PowerShell 5.1; `logs/orbital-m0/preflight-windows-powershell-20261007.log`. |
| 2026-10-07 | Runtime inputs classified | PARTIAL | source-backed derivation distinctions in `FIRMWARE_REQUIREMENTS.md`; executable list and recovery QCOW construction remain unknown. |
| 2026-10-07 | BIOS Kconfig | VERIFIED | `olddefconfig` passes after LF normalization; `bios-kconfig-lf-fixed-20261007.log`. Full BIOS remains blocked on Clang/GCC asm compatibility. |
| 2026-10-07 | GRUB build | BLOCKED | PE/COFF vs ELF error in `grub-build-isolated-20261007.log`. |
| 2026-10-07 | i686-elf GCC toolchain | BLOCKED | GNU GCC 15.2 `all-gcc` fails in bundled libcody against MinGW GCC/libstdc++ 16.2 at `client.cc:329`; see `gcc-build-mingw-20261007.log`. |
| UNKNOWN | First M0 guest launch | NOT ATTEMPTED | launcher stopped at preflight; no QEMU runtime record. |
| UNKNOWN | Real kernel / mini-syscore / Safe Mode | NOT VERIFIED | no guest logs/screenshots. |
| UNKNOWN | First system-service, Shell, or genuine Home boot | NOT VERIFIED | beyond current milestone. |
