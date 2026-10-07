# Error register

## ERR-0001 — GRUB configure sees PE/COFF instead of ELF

Status: RESOLVED (local build workaround)

- Environment: Windows MSYS2/MINGW64; pinned GRUB `bc159e3fbd976ba30897db6307a618d9d8de6911` in isolated copy.
- Command: `./configure --target=x86_64 --disable-werror && make -j4` after isolated bootstrap.
- Expected: configure/linker check accepts the target needed for GRUB's image build.
- Observed: `configure: error: none of __bss_start, edata or _edata is defined`.
- Root cause: confirmed linker target mismatch. Native MinGW reports PE/COFF (`-mi386pe`); GRUB's probe needs ELF symbols.
- Evidence: `logs/orbital-m0/grub-build-isolated-20261007.log`; GNU binutils `ld-new.exe -V` supports `elf_i386`.
- Attempts: isolated gettext `AM_GNU_GETTEXT_VERSION([0.18.1])` adjustment let autoreconf/bootstrap proceed. No change to pinned source.
- Result: configure still fails; no `boot.img`.
- Next: configure with the locally built GNU ELF linker and a compatible target while keeping host build tools native.

## ERR-0002 — BIOS Kconfig help text parsed as options

Status: INVESTIGATING

- Environment: Windows MSYS2, pinned BIOS `bb0e19a5c026ad5ca833afe16e2deed025d4419d`.
- Command: BIOS clean build/Kconfig `olddefconfig`; exact command is in `logs/orbital-m0/bios-kconfig-clean-20261007.log`.
- Expected: `src/Kconfig` help blocks parse normally.
- Observed: CRLF Kconfig inputs triggered syntax errors at lines 133, 328, 533 and `unknown option "Currently"`, `"Disabling"`, `"Set"`.
- Root cause: confirmed line-ending incompatibility. The pinned lexer expects LF input; Windows checkout supplied CRLF.
- Evidence: `bios-kconfig-clean-20261007.log` fails; a verified LF-only scratch input parsed the help sections; normalizing pinned `src/Kconfig` and `vgasrc/Kconfig` to LF let `olddefconfig` pass (`bios-kconfig-lf-fixed-20261007.log`).
- Attempts: clean `out/`, compile host conf with MSYS GCC, regenerate scanner from pinned `zconf.l`, then normalize Kconfig sources to LF.
- Result: Kconfig configuration succeeds. No `ubios.bin` yet; compilation then reached a separate Clang constraint error.
- Next: make LF normalization part of the reproducible Windows build procedure and continue with GCC cross compiler.

## ERR-0003 — QEMU historical dependency/API mismatch

Status: RESOLVED FOR QEMU BUILD

- Environment: current MSYS2/MINGW64 packages versus QEMU 2.11.91-era source.
- Expected: configure and compile with available dependencies.
- Observed: current glslang removed old `SPIRV/SpvBuilder.h` API; current Nettle removed an expected header/API; modern GCC surfaced source/API declaration errors.
- Root cause: verified version/API incompatibility plus Windows compiler diagnostics.
- Evidence/attempts/fixes: see `research/ORBITAL_WINDOWS_BUILD.md`, QEMU build logs, and listed source modifications.
- Result: local glslang 7.11.3214 and libgcrypt plus narrow compatibility edits yielded a clean QEMU rebuild. This does not produce BIOS/GRUB or prove runtime.
- Next: retain current working result; review/document compatibility edits before any upstream contribution.

## ERR-0004 — Clang rejects legacy GCC x86 inline-assembly constraints

Status: INVESTIGATING

- Environment: Windows MSYS2; pinned BIOS; Clang targeting `i386-unknown-elf` with local GNU ELF binutils.
- Command: BIOS `make -j4` with local compiler adapter, `/usr/bin/gcc` for host helpers, GNU `as-new.exe` and GNU `ld-new.exe`.
- Expected: historical BIOS compiles and links into `out/bios.bin`.
- Observed: 14 errors among many warnings, including `invalid input size for constraint 'Q'` and `invalid output size for constraint '=Qi'` in `src/block.c`, `src/disk.c`, `src/system.c`, and `src/hw/usb-hid.c`.
- Root cause: confirmed compiler compatibility issue: these are GCC-specific x86 constraints not accepted by Clang. The `-fno-integrated-as` workaround only resolves the `asm-offsets.c` marker extraction and not these constraints.
- Evidence: `logs/orbital-m0/bios-full-build-20261007-retry.log`.
- Attempts: Clang emits i386 ELF and GNU ld passes the BIOS alignment test, but BIOS C compilation fails on its GCC inline assembly.
- Result: no `ubios.bin`.
- Next: build/use a small GCC cross compiler targeting i686-elf with the existing local GNU ELF binutils; avoid architecture changes.
