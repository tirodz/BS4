# Orbital core integration investigation

Date: 2026-10-06
Workspace checkout: `C:\Users\Syf\Desktop\BS4\orbital`
Current checkout: `cc408367da6a6ebbf5ac1ac559fefeadc73b2831` (`master`, 2024-03-04)

## FINDING

A complete **older public Orbital build/run stack** is recoverable from the original Git history. The best candidate found is commit [`8f51aea60ee15a15dcf3f1fe09d93912f4539259`](https://github.com/AlexAltea/orbital/tree/8f51aea60ee15a15dcf3f1fe09d93912f4539259), dated 2020-01-14. It pins public `orbital-qemu`, `orbital-bios`, and `orbital-grub` submodules, and has the old `build.sh`, `bin/run.sh`, Windows manual, and 5.00 GRUB boot config. Its runner launches `qemu-system-ps4` directly. This architecture predates the later C++ `core` integration, so it does not need `externals/core.h` or `externals/core.cmake`.

The **missing core integration itself was never committed in the upstream Orbital history**. It was an ignored external dependency. This does not invalidate recovery option A for the historical M0 target; it means the 2024 C++ architecture cannot be built from public Orbital sources without recovering or reimplementing that separate layer. The January 2020 snapshot is an older, separate architecture and is not source-compatible with current `master`.

No firmware was downloaded or inspected. No emulator code was changed, and no firmware boot was attempted.

## EVIDENCE

### Git history and timing

The checkout is not shallow: `git rev-list --all --count` returns 300. Its reachable upstream refs are `master` and `origin/master`; there are no tags. `git log --all --full-history` and the object walk show no committed path `externals/core.h` or `externals/core.cmake`, no `.gitmodules` entry for a `core` library, and no commit deleting either core file.

The actual transition is:

| Date | Commit | Finding |
|---|---|---|
| 2020-01-14 | `8f51aea60ee15a15dcf3f1fe09d93912f4539259` | Last inspected pre-CMake snapshot. Public QEMU/BIOS/GRUB gitlinks, shell build and direct QEMU runner are present. |
| 2020-05-18 11:17 +0200 | `5ea59d68472a4aa6f241754b2e609889048c4ff5` | Adds the modern CMake project and `.gitignore` rule `externals`; CMake references `externals/core.cmake` from its first version. The `externals` directory is intentionally excluded from Git. |
| 2020-05-18 12:06 +0200 | `578c7c2174102efe54be277a615ff05c75f49f8f` | Removes the public `orbital-qemu` submodule. |
| 2020-05-18 12:28 +0200 | `6f28780ba863b34dab3c9ab56a3d88a04e22487f` | Removes the QEMU build steps from `build.sh`. |
| 2020-05-21 13:28 +0200 | `ac7d89140bc01132cd2f531b68c40d555f3e17cd` | Removes the public BIOS and GRUB submodules. |
| 2021-10-22 17:25 +0200 | `25b9def7f531b24c60328575e35b2cae5940c3ac` | Adds the explicit “unreleased third-party library” fatal message and a public `src/orbital/core.h` shim which errors when `externals/core.h` is missing. |

This is not a case where public core files were later deleted: the 2020 CMake commit added the dependency while the path was gitignored. The later disclaimer says to wait for the “upcoming release” or implement a replacement which includes/links QEMU. The root history provides no release or source snapshot of that library.

Relevant exact locations:

- Current [`CMakeLists.txt`](https://github.com/AlexAltea/orbital/blob/master/CMakeLists.txt): `ORBITAL_DIR_EXTERNALS` at line 13; package dependencies at lines 20–31; executable sources and common library links at lines 36–67; `externals/core.cmake` include / fatal error at lines 68–76.
- Current [`src/orbital/core.h`](https://github.com/AlexAltea/orbital/blob/master/src/orbital/core.h): includes `../externals/core.h` at line 14 and errors at line 16 if it is absent.
- Current [`.gitignore`](https://github.com/AlexAltea/orbital/blob/master/.gitignore): ignores the entire `externals` directory at line 26.
- The same-day [CMake introduction](https://github.com/AlexAltea/orbital/commit/5ea59d68472a4aa6f241754b2e609889048c4ff5), [QEMU removal](https://github.com/AlexAltea/orbital/commit/578c7c2174102efe54be277a615ff05c75f49f8f), and [BIOS/GRUB removal](https://github.com/AlexAltea/orbital/commit/ac7d89140bc01132cd2f531b68c40d555f3e17cd).

### Recoverable historical stack

At commit `8f51aea...`, `.gitmodules` pins:

- QEMU: `8f4e40e628b40d0a78d41438afa59eb7ccc326ce` from [`AlexAltea/orbital-qemu`](https://github.com/AlexAltea/orbital-qemu/tree/8f4e40e628b40d0a78d41438afa59eb7ccc326ce).
- BIOS: `bb0e19a5c026ad5ca833afe16e2deed025d4419d` from [`AlexAltea/orbital-bios`](https://github.com/AlexAltea/orbital-bios/tree/bb0e19a5c026ad5ca833afe16e2deed025d4419d).
- GRUB: `bc159e3fbd976ba30897db6307a618d9d8de6911` from [`AlexAltea/orbital-grub`](https://github.com/AlexAltea/orbital-grub/tree/bc159e3fbd976ba30897db6307a618d9d8de6911).

The exact QEMU pin is still readable on GitHub, including `hw/ps4/ps4.c`. The QEMU repository contains the PS4 softmmu machine and Aeolia/Liverpool device code; it is a QEMU fork, not the missing `core` C++ library.

At that root commit:

- [`build.sh`](https://github.com/AlexAltea/orbital/blob/8f51aea60ee15a15dcf3f1fe09d93912f4539259/build.sh) builds QEMU as `ps4-softmmu` with SDL/Vulkan, debug, HAXM, and USB; it builds BIOS/GRUB and packages the GRUB memdisk on non-MSYS hosts.
- [`bin/run.sh`](https://github.com/AlexAltea/orbital/blob/8f51aea60ee15a15dcf3f1fe09d93912f4539259/bin/run.sh) directly starts `qemu-system-ps4`, loads `ubios.bin` and `boot.img`, attaches HDD and recovery USB images, requests 8 CPUs, and uses the Orbital display.
- [`docs/manual-windows.md`](https://github.com/AlexAltea/orbital/blob/8f51aea60ee15a15dcf3f1fe09d93912f4539259/docs/manual-windows.md) documents MSYS2 dependencies, the HAXM build/install, `-accel hax`, and TCG fallback. WHPX is mentioned as optional with Windows SDK headers.
- The root contains `resources/boot/grub/env-500.cfg` and `boot.cfg`; README says 4.55 and 5.00 decrypted kernels were tested. The [archived roadmap](https://github.com/AlexAltea/orbital/wiki/Roadmap) reports 5.00 progress through `/mini-syscore.elf` and `/safemode.elf`. Historical reports are not proof of a new run on this Windows host.

The earlier snapshot's remaining burden is still real: build the old pinned projects on this host, install a compatible hypervisor backend, and supply lawful extracted firmware/system files. But it avoids the missing modern core implementation entirely.

### GitHub sources, forks, mirrors, and search

- GitHub’s repository search and exact-text web searches found no public match for `externals/core.cmake`, `externals/core.h`, or the distinctive fatal-message text other than the upstream source itself. One generic `core.cmake` result belonged to OsmAnd and is unrelated.
- GitHub’s public fork listing reported 278 fork records. The unauthenticated API rate limit stopped a full API page walk; 200 fork default branches returned before that limit were checked for the two exact paths and returned 404s. The public five-year fork listing exposed 123 more/recent candidates; both `master` and `main` were checked for both paths (492 raw-file requests; all returned 404). These sets may overlap; this is a positive-match search, not a claim that every historic fork branch on GitHub was exhaustively fetched.
- Known non-fork mirror/copy candidates checked directly included [`AtlasCoCo/PlayStation_4_Emulator_Orbital`](https://github.com/AtlasCoCo/PlayStation_4_Emulator_Orbital), [`gmh5225/PS4-emulator-orbital`](https://github.com/gmh5225/PS4-emulator-orbital), and [`zephirusgit/orbital`](https://github.com/zephirusgit/orbital). None has either exact path on its `master` or `main` branch. The AtlasCoCo tree does preserve QEMU/BIOS/GRUB submodules, but not the core integration.
- The public [`AlexAltea/orbital-qemu`](https://github.com/AlexAltea/orbital-qemu) archive contains a 6,594-entry QEMU source tree and PS4 machine/device code, but neither `externals/core.cmake` nor `externals/core.h`. AlexAltea’s listed public related projects are Orbital, QEMU, BIOS, GRUB, HAXM, and slides; no public core library appears there.

The upstream Git history is definitive for what Orbital committed. The public-fork web screen has the coverage limit stated above, so an unindexed personal archive or inaccessible branch cannot be ruled out absolutely.

## MISSING COMPONENT

The name `core` hides two different things:

1. `src/orbital/core.h` is a 20-line public guard/shim. It contains no emulator implementation. It includes `../externals/core.h` if available; otherwise it emits the explicit unreleased-library error.
2. `externals/core.h` and `externals/core.cmake` are the untracked third-party dependency. Their contents are unavailable, so their exact source-level definitions and CMake commands cannot be quoted. The surrounding source and fatal text establish that this is more than a CMake variable file: it supplies the runtime abstractions Orbital consumes and the CMake bridge that includes/links QEMU.

The visible call sites imply that the missing header/library must supply at least:

- Machine ownership/lifecycle: `Machine`, `MachineConfig`, reset/resume, CPU enumeration, VM ownership, and `createVirtualMachine(..., HypervisorBackend_Core)`.
- x86 virtualization/debug: `X86CPUDevice`, 8-vCPU execution, register/flag access, disassembly state, breakpoints, and host hypervisor integration.
- Device and address-space framework: `Device`, `MemorySpace`, `AliasSpace`, callbacks for memory/MMIO/PIO, memory mapping, PCI BARs, and shared device RAM.
- Interrupt plumbing: `IOAPICDevice`, interrupt objects, and the virtual interrupt controller used by Liverpool/Aeolia device models.
- Host channels and runtime support: `CharHost` for Aeolia UART, threading/tasks/events, common integer/address types, endian and bit helpers, assertions, and stream interfaces (`Stream`, `FileStream`, `BufferStream`) used by the BLS/CF/ELF/PUP/SELF parsers.
- QEMU build/embedding integration: compile/link configuration and the adapter between the C++ machine/device abstractions and the PS4-capable QEMU backend. The error itself says a replacement should forward to and include/link QEMU.

Forty-one current source/header files directly include `<orbital/core.h>` across the PS4 machine, Aeolia/Liverpool hardware, software parsers, and debugger/UI. The hardware/device models and file-format parsers exist in the current source tree; their shared runtime substrate does not. The public QEMU fork also contains parallel PS4 machine code, so a replacement must choose a coherent route rather than assume the two trees are interchangeable.

This is a QEMU-backed C++ platform layer/build integration, not the entire QEMU fork and not merely a small CMake fix. A boot-oriented replacement would likely be in the low-thousands-of-lines range plus build-system work. A rough planning estimate is 2–4 specialist engineer-months for one host/backend and a narrow boot/debug path; Windows/Linux parity and the existing CPU/memory/debug APIs can push this higher. This estimate has high uncertainty because the missing API contract and original implementation are unavailable.

## RECOVERY OPTIONS

### A — Recover an existing complete source

**Available for M0, with a scope boundary.** Use the pre-transition `8f51aea...` historical Orbital root and its three pinned public submodules. It has the full old QEMU-based build/run path and 5.00 config without the private core dependency. It is compatible with its own pinned source, build script, and launch script. It is not drop-in compatible with current `master`; do not copy old QEMU assumptions into the later C++ sources.

The core integration itself has not been found as a public source artifact. So A recovers the historical baseline architecture, not the missing modern library.

### B — Reimplement the missing core integration

This is the path only if the project must retain the post-2020 C++ architecture. It would require a QEMU adapter plus the machine/device/memory/interrupt/CPU/stream/host abstractions above, build and linker setup, and the host hypervisor interface. It is a multi-month systems task, not a two-file compatibility patch. The pinned old QEMU stack makes that possible in principle, but version/API drift and Windows hypervisor support need an early technical spike before committing to full implementation.

### C — Abandon Orbital as the foundation

Not recommended yet. The M0 target has a complete older Orbital history snapshot and public pinned dependencies. Abandon only if that old QEMU/HAXM stack cannot be made to build/run on the target Windows machine, or if future work requires capabilities absent from both the old runtime and the current public device model.

## RECOMMENDATION

For M0, recover commit `8f51aea60ee15a15dcf3f1fe09d93912f4539259` in an isolated checkout and initialize exactly its QEMU/BIOS/GRUB submodule pins. That is the shortest supported route to test the historical 5.00 QEMU-based boot stack without implementing the missing core. Keep the present `master` checkout as the newer research/source reference; do not blend the two architectures.

## DO NOT CODE YET

No replacement, emulator architecture change, firmware boot, or core stub was made. The next action, if approved, is to prepare the isolated historical checkout and validate its public submodule pins/build prerequisites before a build attempt.
