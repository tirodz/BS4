# Orbital historical Windows build record

Date: 2026-10-07  
Root snapshot: `8f51aea60ee15a15dcf3f1fe09d93912f4539259`  
Target: Windows x86-64, historical `ps4-softmmu` QEMU.

## Pinned source revisions

| Component | Revision |
|---|---|
| Orbital | `8f51aea60ee15a15dcf3f1fe09d93912f4539259` |
| Orbital QEMU | `8f4e40e628b40d0a78d41438afa59eb7ccc326ce` |
| Orbital BIOS | `bb0e19a5c026ad5ca833afe16e2deed025d4419d` |
| Orbital GRUB | `bc159e3fbd976ba30897db6307a618d9d8de6911` |
| QEMU `keycodemapdb` submodule | `6b3d716e2b6472eb7189d3220552280ef3d832ce` |
| glslang needed by this QEMU source | `7.11.3214` / `c11e3156af2297f89a23c8db3f5e2323733ee556` |

The Orbital root commit is exact, but the QEMU working tree contains the narrowly scoped compiler/runtime compatibility edits listed below. No commit was created.

## Build environment

All build tools and dependencies are staged below `tools/msys64/msys64` and `tools/glslang-*` inside BS4. The active shell is MSYS2 MINGW64, with `/mingw64/bin` before `/usr/bin`; `CC=/mingw64/bin/gcc` is required to avoid accidentally selecting the MSYS/Cygwin-target compiler.

Installed MSYS2 package versions include:

| Package | Version |
|---|---|
| base-devel | `2026.08-3` |
| Python | `3.12.14-1` |
| Autoconf / Automake | `2.73` / `1.18.1` wrappers |
| libtool | `2.6.2-1` |
| gettext | `0.22.5-1` |
| pkgconf | `3.0.7-1` |
| NASM | `3.02-1` |
| MinGW-w64 GCC | `16.2.0-4` |
| GLib / Pixman | `2.90.0-1` / `0.46.4-3` |
| SDL2 | `2.32.10-1` |
| Vulkan headers / loader | `1.4.363.0-1` / `1.4.363.0-1` |
| current packaged glslang | `16.3.0-1` (not API-compatible with this QEMU revision) |
| libzip / libusb / DTC / libgcrypt | `1.11.4-1` / `1.0.30-1` / `1.8.1-1` / `1.12.4-1` |

Current CMake and Ninja are also installed under the local tools tree. Orbital QEMU 2.11 requires the old `SPIRV/SpvBuilder.h` API removed from current glslang. The matching Khronos glslang source was built into `tools/glslang-install` with CMake/Ninja and `-DCMAKE_POLICY_VERSION_MINIMUM=3.5`; no Sony material is involved.

## Commands

From PowerShell at the BS4 root, the equivalent MSYS invocation is:

```powershell
& 'tools/msys64/msys64/usr/bin/bash.exe' -lc 'export PATH=/mingw64/bin:/usr/bin:$PATH; export CC=/mingw64/bin/gcc; cd /c/Users/Syf/Desktop/BS4/orbital-500; ./build.sh'
```

Orbital's script configures QEMU for `ps4-softmmu` with SDL, Vulkan, debug support, HAX, and libusb. The Windows-compatible crypto flags used here are `--disable-nettle --enable-gcrypt`; C flags include `-std=gnu11 -Wno-error=implicit-function-declaration` plus the local pinned glslang include path. `LDFLAGS` points to the local glslang static library.

The exact clean command used for the reproducibility check is `./build.sh --clean`, followed by the build command above. The clean rebuild is being recorded in `logs/orbital-m0/qemu-clean-rebuild-20261007.log`.

## Compatibility fixes in the pinned source

These fixes address concrete failures observed with the present Windows toolchain; they do not replace or redesign the emulator:

- QEMU `configure`: recognize MSYS2's `MINGW64_NT-*` host string as MinGW.
- `include/sysemu/hax.h`: expose HAX synchronization declarations consumed by generic QEMU code under modern GCC.
- `ui/orbital-stats.cpp`: include `<string>` for its `std::string` use.
- `hw/ps4/aeolia_xhci.c`: include the declaration for `qdev_set_id`, return a status from an integer function's status-TRB branch, and pass `DEVICE(dev)` to the `DeviceState *` API.
- `hw/ps4/aeolia/aeolia_hpet.c`: use the integer migration pre-save callback signature and return success.
- `hw/ps4/liverpool/sam/modules/sbl_pupmgr.c`: pass the byte address expected by SAMU's buffer API rather than an unrelated structure pointer type.
- Root `build.sh`: use libgcrypt rather than the incompatible current Nettle API and supply the pinned local glslang headers/library.
- `ui/orbital.c`: when `ORBITAL_UART_LOG` is set, persist guest UART bytes to the requested log file under a lock and flush them as they arrive.

The compile log records the initial failures and the subsequent link of `ps4-softmmu/qemu-system-ps4.exe` in `logs/orbital-m0/qemu-build-20261007-final.log` and `qemu-build-20261007-rebuild.log`.

## Verification so far

- The Windows executable reports QEMU `2.11.91`.
- `-machine help` lists the historical `ps4` machine.
- `-accel help` lists TCG, HAX, KVM and Xen; this Windows run uses TCG. KVM is Linux-only, and HAX requires the separate Orbital HAXM driver plus supported/enabled CPU virtualization. Neither is needed for building the TCG executable. WHPX is not enabled by this pinned QEMU configuration.
- `-device help` lists Orbital Aeolia and Liverpool devices.
- The custom `qemu-img.exe` reports the historical `create-ps4` image command.
- No firmware was opened or booted. The staged 5.00 directory is missing the Sony inputs; the preflight and launcher both report this before starting QEMU. Their output is in `logs/orbital-m0/preflight-20261007.log` and the timestamped launcher preflight log.

## BIOS and GRUB status on Windows

The pinned `build.sh` explicitly skips both `orbital-bios` and `orbital-grub` when `uname -o` is `Msys`. Thus its successful MSYS path builds QEMU only; it does not produce `bin/ubios.bin` or `bin/boot.img`.

The pinned BIOS build was attempted locally. Its Kconfig helper was first compiled with MinGW and then linked against the MSYS/Cygwin host runtime, producing unresolved `__mingw_printf`, `__imp___acrt_iob_func`, and related symbols. The Kconfig parse issue was traced to CRLF line endings in `src/Kconfig` and `vgasrc/Kconfig`; converting those tracked build inputs to LF allowed `olddefconfig` to complete. The BIOS target itself requires 32-bit ELF output (`-m32`, `ld32bit_flag=-melf_i386`), while installed MinGW is configured `--disable-multilib` and emits PE/COFF. A Clang-based attempt then compiled until legacy x86 inline assembly constraints `Q` and `=Qi` were rejected. No target GCC compiler is installed yet.

GRUB bootstrap initially failed because the current `autopoint` required a gettext version declaration. The pinned GRUB `gnulib-comp.m4` identifies `0.18.1`; adding that declaration and forcing autoreconf in an isolated copy let bootstrap finish. Configure then identified MinGW's PE/COFF target (`-mi386pe`) and failed its GRUB ELF-linker symbol check: `none of __bss_start, edata or _edata is defined`. The exact configure/build log is `logs/orbital-m0/grub-build-isolated-20261007.log`. The pinned GRUB `build.sh` checkout was not left with generated source churn; the isolated experimental copy is under `tools/orbital-grub-build`.

These are verified build-toolchain blockers for the open-source BIOS/GRUB images. GNU ELF binutils have since been built locally and passed the BIOS i386 ELF alignment probe; an i686-elf GCC cross compiler is the next attempted route for BIOS compilation. The GRUB build also needs an ELF target rather than MinGW PE/COFF. These are separate from proprietary runtime inputs. The current launcher refuses to start until the QEMU executable, `ubios.bin`, and `boot.img` all exist.
