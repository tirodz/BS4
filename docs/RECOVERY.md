# Recovery and continuation guide

## Current goal

Reproduce historical Orbital's real 5.00 PS4 boot through kernel, mini-syscore and Safe Mode on Windows. This does not mean implementing a new emulator or reaching Home immediately.

## Current state

- QEMU and custom qemu-img build successfully on Windows using pinned source plus documented compatibility edits.
- BIOS does not yet produce `ubios.bin`; Kconfig passes after LF normalization, but Clang fails on GCC-specific `Q`/`=Qi` inline-assembly constraints.
- GRUB does not yet produce `boot.img`; tested MinGW linker output is PE/COFF where GRUB expects ELF.
- Official user-provided 5.00 system-update PUP is present locally, encrypted, excluded from Git. It can supply some matching system partition images after the documented console decryption/host unpacking route.
- Runtime console dump inputs are not staged. No guest runtime boot has occurred.

## Source revisions

See `DEPENDENCIES.md`. Primary Orbital root: `8f51aea60ee15a15dcf3f1fe09d93912f4539259`. Do not switch component revisions silently.

## Exact paths

- Project root: `C:\Users\Syf\Desktop\BS4`
- Orbital source: `orbital-500\`
- local firmware: `firmware\official\` and `firmware\orbital-5.00\` (never commit)
- build/runtime logs: `logs\orbital-m0\`
- docs/research: `docs\`, `research\`
- local toolchain: `tools\`

## Build and reproduce current state

From PowerShell at project root:

```powershell
& 'tools/msys64/msys64/usr/bin/bash.exe' -lc 'export PATH=/mingw64/bin:/usr/bin:$PATH; export CC=/mingw64/bin/gcc; cd /c/Users/Syf/Desktop/BS4/orbital-500; ./build.sh --clean'
& 'tools/msys64/msys64/usr/bin/bash.exe' -lc 'export PATH=/mingw64/bin:/usr/bin:$PATH; export CC=/mingw64/bin/gcc; cd /c/Users/Syf/Desktop/BS4/orbital-500; ./build.sh'
```

QEMU-only output was verified. The root script skips BIOS/GRUB under MSYS. Do not interpret that as a complete build. Latest BIOS/GRUB failure reproduction and logs are in `BUILD_LOG.md`, `ERRORS.md`, `research/ORBITAL_WINDOWS_BUILD.md`.

## Preflight and runtime

```powershell
pwsh -NoProfile -File .\firmware\tools\Test-Orbital500Inputs.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Run-Orbital500.ps1
```

The launcher runs preflight and stops before QEMU if requirements/build outputs are absent. It writes timestamped diagnostics to `logs\orbital-m0\`. The QEMU guest has not yet been launched.

## What not to repeat

- Do not redownload the 5.00 PUP; the user-provided package is already present.
- Do not fetch random decrypted firmware, keys or console dumps.
- Do not change historical QEMU/BIOS/GRUB revisions before recording a reason and result.
- Do not treat QEMU build pass or launcher process start as a kernel boot.
- Do not start Shell/Home work before reproducible M0.

## Next investigation

1. Build a small i686-elf GCC cross compiler using the local GNU ELF binutils; Clang's rejection of GCC x86 constraints blocks the BIOS.
2. Make Kconfig LF normalization part of the repeatable Windows build procedure; `olddefconfig` passes with both Kconfig files in LF form.
3. Configure GRUB's host/target tools separately so ELF target code links with the local GNU linker.
4. Process matching partition images from the existing PUP only through the pinned documented route, and establish legitimacy/availability of console-side tooling before execution.
5. Complete the per-input inventory and only then request missing console-specific data.

## Success definition

M0 requires captured evidence that the real 5.00 Orbis kernel runs, mini-syscore executes, and Safe Mode is reached. It must be repeated from a clean launcher invocation. No such evidence exists yet.
