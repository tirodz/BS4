# Fresh-session handoff

Last updated: 2026-10-07. This file is written for a developer with no access to the previous chat.

## Goal

Finish building the exact historical Orbital baseline on Windows, then run only with legitimate user-provided/prepared Sony material. Milestone M0 is the real PS4 5.00 kernel → mini-syscore → Safe Mode. Do not implement the Shell/Home path before M0.

## VERIFIED

- Project root: `C:\Users\Syf\Desktop\BS4`.
- Public source-of-truth: `https://github.com/tirodz/BS4`, branch `main`. Last verified remote commit at handoff start: `f910f2e1e9a742813d38218d934c6d84cc72c065` (README title correction). Documentation baseline commit: `2e4647a9a5706c36e1cc949b98d88e6344dde744`; README GIF commit: `f9cf006390409368b4084872d653a4a37de2959a`.
- Orbital root snapshot: `8f51aea60ee15a15dcf3f1fe09d93912f4539259`. Component revisions: QEMU `8f4e40e628b40d0a78d41438afa59eb7ccc326ce`; BIOS `bb0e19a5c026ad5ca833afe16e2deed025d4419d`; GRUB `bc159e3fbd976ba30897db6307a618d9d8de6911`; keycodemapdb `6b3d716e2b6472eb7189d3220552280ef3d832ce`; glslang 7.11.3214 / `c11e3156af2297f89a23c8db3f5e2323733ee556`.
- QEMU clean build passed with narrow local Windows/API compatibility edits saved as `patches/orbital-root-windows.patch` and `patches/orbital-qemu-windows.patch`. Reverse-apply checks passed from their respective component directories. Output: `orbital-500/orbital-qemu/ps4-softmmu/qemu-system-ps4.exe`; QEMU 2.11.91, PS4 machine/devices; custom `qemu-img.exe` has `create-ps4`.
- User supplied the official encrypted/signed 5.00 system-update PUP. Original: `C:\Users\Syf\Desktop\BS4\PS4UPDATE.PUP`; preserved identical local copy: `firmware\official\PS4UPDATE-5.00-system.PUP`. Size 374,669,312 bytes; SHA-256 `089168A7CC702FD45B65E8C8271FDFA0386BD1969509A06DC2FE94B03B978501`; header `SLB2`. User supplied provenance plus size/hash match; local script did not independently verify Sony signature. `.gitignore` excludes both. Never stage them.
- Windows PowerShell 5.1 preflight and one-command launcher work and report missing files before starting QEMU: `firmware\tools\Test-Orbital500Inputs.ps1`, `scripts\Run-Orbital500.ps1`. Preflight log `logs\orbital-m0\preflight-windows-powershell-20261007.log`; launcher log `logs\orbital-m0\launcher-windows-powershell-20261007.log`.
- Repo does not contain proprietary Sony payloads. User source system PUP is only local.

## LATEST GCC ATTEMPT — FAILED, LOGGED

A GNU GCC 15.2 cross compiler is being built for target `i686-elf`, to address old BIOS GCC-only asm constraints. Source archive: `tools\downloads\gcc-15.2.0.tar.xz`; GCC's own `contrib/download_prerequisites` populated prerequisite sources beneath ignored `tools\gcc-15.2.0/`. The initial configure/build in `tools\gcc-build\` used the wrong host compiler; it failed on Windows `_O_*`, `_read`, `_open` declarations in `libiberty/pex-win32.c`.

The corrected attempt uses `tools\gcc-build-mingw\`, explicit `PATH=/mingw64/bin:/usr/bin:$PATH`, `CC=/mingw64/bin/gcc`, `CXX=/mingw64/bin/g++`, host/build `x86_64-w64-mingw32`, target `i686-elf`, and `make -j6 all-gcc`. Configure exited 0. The build failed in GCC 15.2's `libcody/client.cc:329`: `u8""` is `const char8_t*` under installed MinGW GCC/libstdc++ 16.2, but this `Cody::Packet` overload expects `size_t`. The make session exited nonzero after remaining jobs were stopped. Evidence: `logs\orbital-m0\gcc-build-mingw-20261007.log`; configure log: `gcc-configure-mingw-20261007.log`. First wrong-host attempt is `gcc-build-20261007.log` and `gcc-configure-20261007.log`.

The official GCC tarball was downloaded from GNU's public FTP into ignored `tools\downloads\`; the observed SHA-256 is `438FD996826B0C82485A29DA03A72D71D6E3541A83EC702DF4271F6FE025D24E`. GNU's directory listing was browsed to confirm the archive URL/size; the detached `.sig` was not locally checked. GCC is a build tool, not Sony material.

## BLOCKED / UNKNOWN

- BIOS `ubios.bin` and GRUB `boot.img` are not built. Root Orbital `build.sh` skips both under MSYS and its success only means QEMU.
- BIOS Kconfig `olddefconfig` succeeds after normalizing `orbital-bios/src/Kconfig` and `vgasrc/Kconfig` to LF; pinned source checkout had Windows CRLF. Clang subsequently rejected constraints `Q` and `=Qi` in BIOS C code. GNU ELF binutils 2.46 source/build exists locally and `ld-new.exe` passes i386 ELF linker/alignment probe.
- Isolated GRUB bootstrap succeeded after adding the gettext version declaration `0.18.1` in an isolated copy. MinGW configure then fails `none of __bss_start, edata or _edata is defined` because its linker emits PE/COFF; GNU linker supports `elf_i386`, but a successful GRUB cross configuration/build is unverified.
- No QEMU guest run was attempted. Kernel, mini-syscore, Safe Mode and graphics are all unverified. Launcher currently stops before QEMU due absent assets/build images.
- No full decrypted Safe Mode userland file list is established; exact filenames and recovery USB QCOW2 creation/layout remain UNKNOWN.
- Missing runtime inputs listed in `FIRMWARE_REQUIREMENTS.md`. From the official system PUP, `eap.img`, `system.img`, and `system_ex.img` can be prepared for matching 5.00 after the documented console-side decryption and host unpack workflow. They are not staged. `preinst.img` and `recovery.img` need recovery PUP material per upstream README. Kernel ELF (`sflash/orbisys-500`), `sflash.bin`, `vbios.bin`, SAMU blob output and decrypted userland assets are separate documented console-derived requirements. Do not guess a derivation from the PUP.

## Exact next steps

1. Retry GCC 15.2 with an explicitly tested C++ compatibility option such as `CXXFLAGS=-fno-char8_t` (verify MinGW GCC 16.2 supports it), or build with a compatible older MinGW host compiler. The error is in GCC's bundled host `libcody`, not Orbital; do not modify the emulator for it.
2. Re-run the pinned BIOS configuration/build using GCC target `i686-elf` and GNU ELF `as`/`ld`; retain LF normalization of the two Kconfig files. Capture whether `ubios.bin` is produced.
3. Configure pinned GRUB with a Windows-native host compiler but ELF target linker from `tools/binutils-build/ld/ld-new.exe`; work in ignored isolated build directory. Verify output `boot.img`.
4. Re-run PowerShell preflight and launcher. Do not launch QEMU while required build/runtime inputs are absent.
5. For actual M0, only after legitimate inputs are staged, run and capture QEMU, serial, Orbital, GPU and screen logs under `logs/orbital-m0/`; prove real kernel → mini-syscore → Safe Mode, then repeat cleanly.

## Repro commands / paths

Historical QEMU build from PowerShell root (MINGW64 `CC` is intentional):

```powershell
& 'tools/msys64/msys64/usr/bin/bash.exe' -lc 'export PATH=/mingw64/bin:/usr/bin:$PATH; export CC=/mingw64/bin/gcc; cd /c/Users/Syf/Desktop/BS4/orbital-500; ./build.sh --clean'
& 'tools/msys64/msys64/usr/bin/bash.exe' -lc 'export PATH=/mingw64/bin:/usr/bin:$PATH; export CC=/mingw64/bin/gcc; cd /c/Users/Syf/Desktop/BS4/orbital-500; ./build.sh'
```

The most recent GCC cross attempt was configured and built with these MSYS commands (the build failed at bundled `libcody/client.cc:329`; see the exact log):

```bash
PATH=/mingw64/bin:/usr/bin:$PATH CC=/mingw64/bin/gcc CXX=/mingw64/bin/g++ ../gcc-15.2.0/configure \
  --build=x86_64-w64-mingw32 --host=x86_64-w64-mingw32 --target=i686-elf \
  --prefix=/c/Users/Syf/Desktop/BS4/tools/i686-elf \
  --disable-nls --disable-shared --disable-threads --disable-libssp \
  --disable-libquadmath --disable-libgomp --disable-libatomic \
  --enable-languages=c --without-headers --with-newlib \
  --with-as=/c/Users/Syf/Desktop/BS4/tools/binutils-build/gas/as-new.exe \
  --with-ld=/c/Users/Syf/Desktop/BS4/tools/binutils-build/ld/ld-new.exe
PATH=/mingw64/bin:/usr/bin:$PATH CC=/mingw64/bin/gcc CXX=/mingw64/bin/g++ make -j6 all-gcc
```

The retry should preserve the separate `tools/gcc-build-mingw/` directory and test `CXXFLAGS=-fno-char8_t` or use a compatible older MinGW compiler. A passing GCC build has not been achieved.

Check missing firmware, no launch if blocked:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\firmware\tools\Test-Orbital500Inputs.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Run-Orbital500.ps1
```

Keep all downloaded toolchains and source under ignored `tools\`; firmware under ignored `firmware\`; capture logs under `logs\orbital-m0\`. Before each commit run `git status --short`, inspect staged paths and confirm no `.PUP`, `.elf`, `.self`, `.sprx`, image, key, or console dump is staged. Use `git check-ignore -v PS4UPDATE.PUP firmware/official/PS4UPDATE-5.00-system.PUP`.

## DO NOT REPEAT

- Do not download another 5.00 system PUP; it is supplied and hash-consistent.
- Do not download random decrypted firmware, keys or dumps.
- Do not run GCC build with MSYS `/usr/bin/gcc` while claiming a MinGW host; use explicit `/mingw64/bin/gcc`.
- Do not infer boot success from compilation/preflight.
- Do not begin SceSysCore/SceShellCore/Shell UI/NPXS20001/Mono/PUI/Home work before reproducible M0.
