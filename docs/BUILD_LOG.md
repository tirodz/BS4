# Build log

Chronological record; raw output is under `logs/orbital-m0/`.

## 2026-10-06 — Baseline inspection

- Source: Orbital `8f51aea60ee15a15dcf3f1fe09d93912f4539259`.
- Host: Windows, MSYS2/MINGW64.
- Command: historical `./build.sh` (attempt details in `logs/orbital-m0/build-resume-20261007-01.log`).
- Result: initial dependency/compatibility failures; further attempts recorded next day.
- Artifact: no verified full runner at this stage.

## 2026-10-07 — QEMU clean rebuild

- Source: pinned root revision and QEMU submodule `8f4e40e628b40d0a78d41438afa59eb7ccc326ce`, with documented local Windows compatibility edits.
- Host: Windows 11 (inferred from build environment), MSYS2 MINGW64, local dependencies under `tools/`.
- Command: `./build.sh --clean`, followed by the documented MSYS build command in `research/ORBITAL_WINDOWS_BUILD.md`.
- Result: PASS for QEMU. Exit 0; Windows `qemu-system-ps4.exe` exists. `qemu-img.exe` supports `create-ps4`.
- Artifact: QEMU executable and image tool. Raw log: `logs/orbital-m0/qemu-clean-rebuild-20261007.log`.
- Next: BIOS/GRUB images remain required for runner.

## 2026-10-07 — BIOS build attempts

- Source: BIOS submodule `bb0e19a5c026ad5ca833afe16e2deed025d4419d`.
- Host: MSYS2/MINGW64; clang/LLVM and GNU binutils 2.46 experiments stored locally.
- Commands: see `research/ORBITAL_WINDOWS_BUILD.md` and logs `bios-build-20261007.log`, `bios-kconfig-20261007.log`, `bios-kconfig-clean-20261007.log`, and binutils logs.
- Result: FAIL. Kconfig parser reports syntax errors at lines 133/328/533 and treats help prose as options. GNU `ld-new.exe` passes the BIOS ELF alignment probe (`test-build.sh`), but full BIOS link has not been reached.
- Additional attempt: regenerated the scanner from pinned `scripts/kconfig/zconf.l` with local Flex 2.6.4 and rebuilt `conf` using `/usr/bin/gcc`. The same parse errors occurred (`bios-kconfig-regenerated-20261007b.log`).
- Follow-up diagnosis: the first supposed LF-normalized scratch file still contained CRLF and was not valid evidence. A true LF-only scratch Kconfig parsed its help blocks; normalizing pinned `src/Kconfig` and `vgasrc/Kconfig` to LF let `olddefconfig` pass (`bios-kconfig-lf-fixed-20261007.log`). The subsequent full compile then failed on Clang incompatibility with legacy GCC x86 constraints `Q`/`=Qi` (`bios-full-build-20261007-retry.log`).
- Artifact: no `ubios.bin` verified.
- Next: use an i686-elf GCC cross compiler with local GNU ELF binutils; retain LF Kconfig normalization in the build procedure.

## 2026-10-07 — GRUB isolated build

- Source: GRUB submodule `bc159e3fbd976ba30897db6307a618d9d8de6911`, tested in isolated `tools/orbital-grub-build` copy.
- Command: bootstrap/configure with native MinGW target; see `logs/orbital-m0/grub-build-isolated-20261007.log`.
- Result: bootstrap workaround got through gettext generation; configure FAIL because PE/COFF linker lacks the ELF symbols expected by GRUB (`none of __bss_start, edata or _edata is defined`).
- Artifact: no `boot.img` verified.
- Next: use the locally built GNU ELF linker and a suitable cross target without contaminating pinned GRUB source.

## Runtime boundary

No QEMU guest boot occurred. Launcher attempts stopped at preflight because required runtime assets/build images were absent. These are preparation checks, not runtime attempts; see `docs/RUNTIME_LOG.md`.
