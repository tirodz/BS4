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

## 2026-10-07 — GCC cross-compiler attempts

- GCC source: GNU GCC 15.2.0, `tools/downloads/gcc-15.2.0.tar.xz`; observed SHA-256 `438FD996826B0C82485A29DA03A72D71D6E3541A83EC702DF4271F6FE025D24E`. GCC's `contrib/download_prerequisites` script completed and its checks passed. Build-only files remain under ignored `tools/`.
- First configure/build: `tools/gcc-build/`, `--build=x86_64-w64-mingw32 --host=x86_64-w64-mingw32 --target=i686-elf`, `make -j6 all-gcc`. This was inconsistent with the actual `/usr/bin/gcc` MSYS compiler; it failed in `libiberty/pex-win32.c` with missing `_O_RDONLY`, `_O_BINARY`, `_read`, `_open`, `_dup`, `_pipe` and related Win32 declarations. Logs: `gcc-configure-20261007.log`, `gcc-build-20261007.log`.
- Corrected attempt: configure in `tools/gcc-build-mingw/` with `PATH=/mingw64/bin:/usr/bin:$PATH`, `CC=/mingw64/bin/gcc`, `CXX=/mingw64/bin/g++`, same declared build/host/target and local GNU `as-new.exe`/`ld-new.exe`. Configure exited 0 (`gcc-configure-mingw-20261007.log`). `make -j6 all-gcc` failed in GCC 15.2 bundled `libcody/client.cc:329`: `u8""` is `const char8_t*` under the installed MinGW GCC/libstdc++ 16.2, but the overload expects `size_t`. The remaining make jobs were stopped after the error was captured. This is not a successful compiler build. Evidence: `gcc-build-mingw-20261007.log`.
- Next test: reconfigure/rebuild with host `CXXFLAGS=-fno-char8_t` if supported by this MinGW compiler, or use a compatible older MinGW host compiler. Do not patch Orbital for this host-toolchain issue. If GCC succeeds, run `make install-gcc`, verify `i686-elf-gcc -dumpmachine`, and retry BIOS. BIOS and GRUB images remain unbuilt.
