# Session handoff

Last updated: 2026-10-07

## Current goal and state

Reproduce pinned Orbital 5.00 through genuine Orbis kernel → mini-syscore → Safe Mode on Windows. QEMU builds; BIOS source compilation and GRUB ELF target remain blocked. User-provided official encrypted 5.00 system-update PUP is present. The documented runtime tree remains unstaged, and no guest boot has been attempted.

## Last successful action

The BIOS Kconfig `olddefconfig` step passed after converting `src/Kconfig` and `vgasrc/Kconfig` from CRLF to LF (`logs/orbital-m0/bios-kconfig-lf-fixed-20261007.log`). The clean historical QEMU rebuild also passed, exit 0, log `logs/orbital-m0/qemu-clean-rebuild-20261007.log`.

## Last failed action

The BIOS compile reached C sources and failed on Clang's rejection of GCC-only `Q`/`=Qi` inline-assembly constraints. GRUB isolated configure separately fails ELF symbol probe due MinGW PE/COFF. See `ERRORS.md`.

## Revisions and exact commands

Pinned revisions and exact MSYS build commands are in `DEPENDENCIES.md`, `BUILD_LOG.md`, and `research/ORBITAL_WINDOWS_BUILD.md`. The root Orbital build script skips BIOS/GRUB under MSYS; its successful QEMU output is not full build readiness.

## Local-only material

- Source checkout `orbital-500/`
- Toolchains/source archives `tools/`
- official PUP `firmware/official/PS4UPDATE-5.00-system.PUP`
- optional original `PS4UPDATE.PUP` at workspace root
- no decrypted kernel/SFLASH/VBIOS/images/USB QCOW/SAMU files presently confirmed

None of the above proprietary payloads or large local build trees belong in the BS4 GitHub repository. Check `.gitignore` before staging.

## Preflight

Run `pwsh -NoProfile -File .\firmware\tools\Test-Orbital500Inputs.ps1`. It expects `firmware\orbital-5.00\` and a local provenance manifest. Run the launcher with `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Run-Orbital500.ps1`; it must stop before QEMU while checks fail.

## What not to repeat

Do not redownload the official PUP, fetch third-party decrypted proprietary material, switch historical submodules without decision records, or begin shell implementation. Do not call an unexecuted launch or QEMU build a PS4 boot.

## Next exact actions

1. Build/use GCC targeting i686-elf with existing GNU ELF binutils, since Clang rejects GCC-only x86 constraints.
2. Preserve LF on BIOS Kconfig files in the repeatable Windows build command and continue the separate GRUB host/target investigation.
3. Separately process only the matching 5.00 images documented as derivable from the supplied PUP using the user's legitimate console-assisted method; then inventory genuinely console-specific files.
4. Update these records after every result. M0 is complete only with captured real kernel, mini-syscore and Safe Mode evidence and a second clean invocation.
