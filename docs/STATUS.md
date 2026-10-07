# Project status

Last updated: 2026-10-07

## What are we trying to achieve?

Boot genuine Sony PS4 system software on Windows, using historical Orbital as the primary route. Current milestone M0 is real 5.00 Orbis kernel → mini-syscore → Safe Mode. It is not the Dynamic Menu milestone.

## What currently works?

- Local Orbital root checkout is pinned at `8f51aea60ee15a15dcf3f1fe09d93912f4539259`; component revisions are listed in `docs/DEPENDENCIES.md`.
- The historical QEMU component clean-rebuild completed and produced `orbital-qemu/ps4-softmmu/qemu-system-ps4.exe`; it reports version 2.11.91 and lists the `ps4` machine and PS4 devices.
- The custom `qemu-img.exe` is built and exposes `create-ps4`.
- The official user-provided 5.00 system-update PUP is present locally: 374,669,312 bytes; SHA-256 `089168A7CC702FD45B65E8C8271FDFA0386BD1969509A06DC2FE94B03B978501`. It is outside Git. Size/hash are recorded; no Sony signature verification was performed by the local preflight.
- Firmware preflight and one-command launcher exist. Launcher tests have only reached preflight and correctly stopped before QEMU due to missing runtime assets.

## What currently fails?

- Full historical runner preparation is incomplete. `ubios.bin` and `boot.img` are not built.
- BIOS Kconfig parses after normalizing the two Kconfig inputs from Windows CRLF to LF. GNU ELF binutils pass the BIOS linker probe. The BIOS compile then fails because Clang rejects legacy GCC-only inline-assembly constraints (`Q`, `=Qi`); an i686-elf GCC toolchain has not yet been built.
- GRUB configure in the isolated test fails because its linker probe sees MinGW PE/COFF instead of an ELF target (`none of __bss_start, edata or _edata is defined`).
- No guest launch/boot has been attempted; kernel, mini-syscore, and Safe Mode are unverified.

## What files do we have?

- Official 5.00 system-update PUP: `firmware/official/PS4UPDATE-5.00-system.PUP` (byte-identical copy of user-provided `PS4UPDATE.PUP`).
- Historical Orbital source and built QEMU outputs under local-only `orbital-500/`.
- MSYS2, glslang and ELF/binutils experiments under local-only `tools/`.
- Build/preflight logs under `logs/orbital-m0/`.
- Research reports under `research/`.

## What files are missing?

At minimum for the documented launch configuration: `firmware/orbital-5.00/sflash/orbisys-500`, `sflash.bin`, `vbios.bin`, `hdd/system.img`, `hdd/system_ex.img`, `usb/usb-pup-500rec.qcow2`, and `crypto/blobs.zip`; historical HDD staging also lists `hdd/eap.img`, `hdd/preinst.img`, and `hdd/recovery.img`. See `docs/FIRMWARE_REQUIREMENTS.md` for what the supplied system PUP can derive and which provenance remains user-specific. Build outputs `ubios.bin` and `boot.img` are also absent.

## Current blocker

Two independent blockers remain: the Windows BIOS/GRUB toolchain build is incomplete, and Orbital runtime inputs have not been prepared from the user's material. The official PUP itself is present and is not a blocker.

## Last successful action

The pinned BIOS `olddefconfig` step now passes after converting `src/Kconfig` and `vgasrc/Kconfig` to LF, logged in `logs/orbital-m0/bios-kconfig-lf-fixed-20261007.log`. The latest successful complete component build remains QEMU clean rebuild at `logs/orbital-m0/qemu-clean-rebuild-20261007.log` (exit 0).

## Last failed action

The first full BIOS compile reached source compilation but failed on unsupported Clang inline-assembly constraints in legacy code. Earlier Kconfig errors are understood: the parser receives CRLF files on Windows and requires LF; normalizing both inputs let `olddefconfig` pass. GRUB still fails its ELF-linker probe under MinGW PE/COFF. Logs: `bios-full-build-20261007-retry.log`, `bios-kconfig-lf-fixed-20261007.log`, and `grub-build-isolated-20261007.log`.

## Next exact action

Build a small i686-elf GCC cross-compiler against the local GNU ELF binutils; then rerun the BIOS build. Preserve LF for BIOS Kconfig inputs in the reproducible build command. Continue the separate GRUB ELF-target investigation.

## Evidence

See `docs/BUILD_LOG.md`, `docs/ERRORS.md`, `docs/RUNTIME_LOG.md`, `docs/FIRMWARE.md`, `research/ORBITAL_WINDOWS_BUILD.md`, and raw logs under `logs/orbital-m0/`. No genuine PS4 runtime success is recorded.
