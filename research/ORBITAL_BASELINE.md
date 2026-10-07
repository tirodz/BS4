# Orbital baseline research (M0 feasibility)

Date: 2026-10-06
Workspace: `C:\Users\Syf\Desktop\BS4`
Upstream: <https://github.com/AlexAltea/orbital>
Checkout: `orbital/`, branch `master`, clean working tree, full Git history cloned; no submodule manifest is present.
Exact checked-out commit: `cc408367da6a6ebbf5ac1ac559fefeadc73b2831` (2024-03-04, “Update README.md”).

## Finding first

This upstream checkout is intentionally incomplete as a buildable emulator. `CMakeLists.txt` stops with a fatal error when `externals/core.cmake` is absent, and `src/orbital/core.h` emits an error when `externals/core.h` is absent. Both files are absent. The source itself says the unreleased third-party core is required and the open-sourced parts are documentation for developers. That missing core is described as the QEMU forwarding/integration layer. This prevents building Orbital as supplied and is not a Windows-only defect. A stub or rewrite would amount to recreating the missing architecture, outside M0's scope. Git history inspection found no committed `externals/core.h` or `externals/core.cmake`; `src/orbital/core.h` is only a disclaimer shim (commit 25b9def, 2021). Correction from the follow-up investigation: a complete older QEMU-based source/build stack is present at historical root commit `8f51aea60ee15a15dcf3f1fe09d93912f4539259` (2020-01-14), with public QEMU/BIOS/GRUB pins and direct build/run scripts. This is a candidate historical M0 path, but it has not yet been built or booted on this host. See [`ORBITAL_CORE_INVESTIGATION.md`](ORBITAL_CORE_INVESTIGATION.md).

A direct build command was attempted and could not start because CMake is not installed/on PATH. Installing the many CMake dependencies would not fix the missing core; therefore no third-party build dependencies were installed and no speculative compatibility edits were made. Details are in [`../logs/build-attempt.txt`](../logs/build-attempt.txt).

## Repository and architecture

- Build system: CMake, minimum 3.12, C++20. The Windows manual describes Visual Studio 2019+ and CMake 3.12+ and recommends vcpkg. The listed CMake packages are SDL2, imgui, fmt, RapidJSON, Vulkan, ZLIB; CMake also probes Botan and Capstone libraries. The checked-out tree contains no `vcpkg.json`, `externals/`, `build.sh`, or `run.sh`.
- Emulator core: the public code calls the absent `Machine`, VM, CPU, and memory-space interfaces through `core.h`. `PS4Machine` calls `createVirtualMachine(..., HypervisorBackend_Core)`. That interface is exactly the boundary which prevents CPU virtualization and QEMU integration from being built from this tree alone.
- BIOS/GRUB/QEMU: `README.md` historically says all three components must be built. The checkout contains GRUB environment/config files under `resources/boot/grub/` but not BIOS/GRUB build sources, a QEMU source tree, or launch scripts. The missing `core.cmake` is the explicit QEMU integration blocker. No independent build recipes for the full chain are present.
- Windows hypervisor: the current upstream Windows manual requires only a CPU with Intel VT-x or AMD-V enabled after building; it does not give a current accelerator setup. The historical 2018-era Windows manual visible on a GitHub mirror describes MSYS2, an Orbital HAXM fork, and optional Windows SDK header/library copying for WHPX. `env-common.cfg` comments document an old TSC synchronization workaround motivated by behavior under HAXM. These historical references do not demonstrate a working modern HAXM/KVM/Hyper-V path. No KVM setup for native Windows is documented in this checkout. Hardware/firmware virtualization readiness on this machine could not be inspected because system inventory calls were denied by the environment.
- Firmware target: README says PS4 firmware 4.55 and 5.00 kernels were tested historically. The GRUB config includes `env-455.cfg` and `env-500.cfg`; `boot.cfg` selects `(sflash)/orbisys-500`, loads the 5.00 environment, loads common settings, then boots. 5.00 is the preferred documented target; 4.55 is an included alternate. The archived project roadmap specifically describes its progress entries as tests on the 5.00 kernel.
- Firmware material: the historical Windows installation instructions require decrypted CPU kernel, VBIOS/UBIOS, SFLASH, PUP, and decrypted/dumped userland executables. The current Windows manual is less specific and leaves console-owned system material as TBD, referring to a file placed in `bin/crypto`. The checkout has no proprietary firmware. `C:\Users\Syf\Desktop\BS4\firmware` does not exist, so there is no supplied user material to use. Nothing proprietary was downloaded or added.
- Boot path and Safe Mode: `PS4Machine` exposes `boot()`, `recover()`, and `recover(PUP)` APIs; the latter parses a recovery PUP and kernel container but includes a TODO for exposing the PUP as USB storage. `env-500.cfg` applies optional kernel debug settings and a timer workaround. Common config sets the QEMU vendor string and `kern.hz=1000` to bypass a documented TSC synchronization problem in the guest. The default `boot.cfg` is a recovery/5.00 configuration. The public archived roadmap reports the 5.00 emulator surviving `/mini-syscore.elf` and `/safemode.elf`; it also lists items as incomplete and says the page is archived. This is historical evidence of milestones, not execution evidence from this Windows host or proof that a complete graphical Safe Mode was reproduced in this run.
- GPU/display: host UI uses SDL2 + Vulkan + Dear ImGui (`src/orbital/ui.cpp`, Vulkan host manager). Liverpool GC/GFX source models a command processor and connects to this Vulkan manager. The archived roadmap lists the Vulkan GFX backend and GCN-to-SPIR-V translator as needing more work. The current Vulkan UI backend is not by itself proof that the guest PS4 GPU can render Safe Mode.
- SAM/SAMU: the public tree includes a SAM MMIO device and basic mailbox/SMC paths. `sam.cpp` leaves mailbox operations unimplemented and has the larger SAMU command path under `#if 0`; its comments explicitly mark functionality TODO. The archived roadmap estimates SAMU command processing as only partially complete (30%).
- Storage/system image: `tools/generate-hdd.py` exists and `bin/machines/` is an ignored runtime-data directory; the sources describe a virtual HDD and recovery PUP flow. The recovery path still has a USB mass-storage TODO. No user firmware or HDD image is present. Public docs do not provide a complete tested system-image recipe sufficient to reproduce a disk-backed 5.00 Safe Mode environment without the omitted emulator core and user-supplied extracted files.

## Windows build attempt

Command attempted in the repository root:

```powershell
cmake -B build .
```

Observed result: PowerShell reported that `cmake` is not recognized. Separately, source inspection confirms that after obtaining CMake and its dependencies, configuration/build still cannot complete against this checkout because required `externals/core.cmake` and `externals/core.h` are absent. There is no justified compatibility fix for a deliberately omitted core integration.

No CMake, Visual Studio, vcpkg, HAXM, Vulkan SDK, or other build dependency was installed. This was an intentional stop after verifying the source-level blocker; installing build packages would not make this source tree buildable.

## M0 result status

| Gate | Result | Evidence |
|---|---|---|
| Clone with Git history | PASS | `orbital/` is a Git checkout at the commit above, tracking `origin/master`. |
| Build | FAIL | CMake unavailable here; upstream also deliberately omits required core/QEMU integration. |
| Real PS4 kernel boot | FAIL / not run | No buildable emulator and no user-supplied firmware files. |
| mini-syscore | FAIL / not run | No emulator run; historical upstream roadmap only. |
| Safe Mode | FAIL / not run | No emulator run; historical upstream roadmap only. |
| Reproducible invocation | NO | No first successful boot exists to repeat. |

`M0_BASELINE.md` is intentionally not created: it is reserved for a baseline that has actually booted and passed a clean second invocation.

## Sources consulted

Primary checkout files: `README.md`, `docs/manual-windows.md`, `docs/manual-linux.md`, `CMakeLists.txt`, `src/orbital/core.h`, `src/orbital/hardware/ps4.{h,cpp}`, `src/orbital/hardware/liverpool/sam/sam.cpp`, `src/orbital/hardware/liverpool/gca/gfx.cpp`, `resources/boot/grub/{boot.cfg,env-common.cfg,env-455.cfg,env-500.cfg}`.

Upstream public references:
- README and firmware status: <https://github.com/AlexAltea/orbital>
- Archived 5.00 roadmap, including mini-syscore, safemode, GPU, and SAMU status: <https://github.com/AlexAltea/orbital/wiki/Roadmap>
- Historical Windows manual describing MSYS2/HAXM/WHPX and decrypted files: <https://github.com/AtlasCoCo/PlayStation_4_Emulator_Orbital/blob/master/docs/manual-windows.md>


