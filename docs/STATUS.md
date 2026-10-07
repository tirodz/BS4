# BS4 status

Last updated: 2026-10-07

## VERIFIED

- Orbital root is pinned locally at `8f51aea60ee15a15dcf3f1fe09d93912f4539259`; QEMU, BIOS, GRUB, keycodemapdb and glslang revisions are in `DEPENDENCIES.md`.
- Historical QEMU clean rebuild succeeded on Windows/MSYS2. `qemu-system-ps4.exe` reports 2.11.91, lists the `ps4` machine/devices, and custom `qemu-img.exe` has `create-ps4`. Evidence: `logs/orbital-m0/qemu-clean-rebuild-20261007.log`.
- User supplied the official 5.00 system-update PUP. Local files are `PS4UPDATE.PUP` and byte-identical copy `firmware/official/PS4UPDATE-5.00-system.PUP`; size 374,669,312 bytes, SHA-256 `089168A7CC702FD45B65E8C8271FDFA0386BD1969509A06DC2FE94B03B978501`. Both are ignored by Git. Hash/size and `SLB2` header match the expected package; this local check is not independent Sony signature verification.
- Preflight sees the PUP and clearly reports missing staged runtime inputs. Launcher stops before QEMU; no guest was started.
- BIOS Kconfig succeeds after LF normalization of `orbital-bios/src/Kconfig` and `vgasrc/Kconfig`.
- User-requested README GIF/title update was committed and pushed in `f9cf006` and `f910f2e`.

## IN PROGRESS

- No compile or runtime process is currently running. The next work is the narrow GCC host compatibility retry recorded below; no emulator source changes for the GCC `libcody` error are justified.

## BLOCKED

- Full historical runner is not built: `ubios.bin` and `boot.img` are absent. Clang's i386 build fails on GCC x86 inline-assembly constraints `Q` and `=Qi`; see ERR-0004. The first GCC attempt used an MSYS compiler inconsistent with its declared MinGW host and failed in `libiberty/pex-win32.c` with missing `_O_*`, `_read`, `_open`, and related declarations. The MinGW-selected retry then failed in bundled `libcody` at `client.cc:329` on `char8_t`/`size_t`; see ERR-0005.
- GNU GCC 15.2 cross compiler retry did not complete. With the corrected MinGW compiler selection, `make -j6 all-gcc` failed in `gcc-15.2.0/libcody/client.cc:329` because `u8""` is `const char8_t*` with the installed MinGW GCC 16.2 and cannot initialize a `size_t` parameter. The make session was stopped after this error was captured. See `logs/orbital-m0/gcc-build-mingw-20261007.log`.
- Isolated GRUB configure with native MinGW fails `none of __bss_start, edata or _edata is defined`: PE/COFF host linker output does not satisfy its ELF linker probe. No GRUB build with the newly built GNU ELF linker has yet been verified.
- Runtime preflight lacks `sflash/orbisys-500`, `sflash.bin`, `vbios.bin`, HDD/USB inputs, SAMU blobs and a complete decrypted userland set. See `FIRMWARE_REQUIREMENTS.md`.

## UNKNOWN

- Whether `CXXFLAGS=-fno-char8_t` resolves GCC 15.2's bundled `libcody` host build error, or a matching MinGW host compiler is needed; whether any GCC cross compiler can then build the pinned BIOS.
- Exact full Safe Mode userland ELF/SELF/SPRX set and complete creation recipe/internal layout for `usb/usb-pup-500rec.qcow2`.
- Whether a suitable legitimate recovery PUP is available to supply `preinst.img`, `recovery.img` and recovery USB material.
- Kernel boot, mini-syscore, Safe Mode, video output, and any real Shell/Home execution. None has been attempted or verified.

## DO NOT REPEAT

- Do not redownload the 5.00 PUP or put any Sony package, keys, dumps, decrypted binary, image, or SAMU data in Git.
- Do not use third-party decrypted firmware/dumps or claim PUP signature verification from size/hash alone.
- Do not rerun the initial GCC command without explicitly selecting `/mingw64/bin/gcc`; that selected the wrong host compiler.
- Do not treat QEMU-only build, launcher preflight, or a host toolchain build as a PS4 boot.

## Exact next actions

1. Retry the GCC 15.2 build using an explicitly tested compatibility option such as `CXXFLAGS=-fno-char8_t` for its host C++ build, or use a supported older MinGW host compiler. Do not edit Orbital BIOS for this toolchain mismatch.
2. If successful, run `make install-gcc`, verify `tools/i686-elf/bin/i686-elf-gcc -dumpmachine` prints `i686-elf`, then build BIOS with both Kconfig files kept LF and the GNU ELF binutils.
3. Configure/build pinned GRUB with host tools for Windows and ELF target linker, in an isolated build directory, then verify `boot.img`.
4. Only after QEMU, BIOS and GRUB artifacts pass preflight, prepare legitimate runtime inputs. Matching `eap.img`, `system.img`, and `system_ex.img` are documented as extractable from the supplied 5.00 PUP after console-side `ps4-pup_decrypt` and host `ps4-pup_unpack`; none is currently staged. Keep encrypted/decrypted distinctions and provenance in the manifest.
5. Run the one-command launcher; M0 succeeds only with captured real kernel → mini-syscore → Safe Mode evidence and a clean second invocation.

The official PUP itself is present and is not the current blocker. The actual boot boundary still requires legitimately sourced/prepared Sony runtime material.
