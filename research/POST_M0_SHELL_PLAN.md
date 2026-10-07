# Post-M0 route toward the real PS4 Dynamic Menu

Date: 2026-10-07
Baseline target: Orbital `8f51aea60ee15a15dcf3f1fe09d93912f4539259`, 5.00.

## First code change after M0

**Add persistent, acceleration-independent guest process and executable-load tracing to the pinned QEMU layer.** Capture process creation/exit, executable path and ELF/SELF load result, child-process launch requests, and the guest's loader/syscall failures to timestamped files. Run the exact Safe Mode baseline with tracing first and preserve that log as the comparison point; then boot the next normal-start configuration and record what the kernel actually asks for.

This is the first engineering change because the current process list UI is not a sufficient trace: Orbital's `ui/orbital-procs-list.cpp` only displays process snapshots that are passed in, and the inspected producer is `target/i386/hax-all.c:665`. That is in the HAX accelerator path. A TCG run cannot be assumed to populate it. The build also needs actual 5.00 startup evidence to tell which missing syscall, loader feature, service, or device blocks normal startup. Do not begin by writing SceSysCore, SceShellCore, NPXS20001, Mono, PUI, or a replacement shell.

## Sequence after the first trace change

1. Preserve the reproducible Safe Mode boot and use the trace to inventory what executes and which calls fail.
2. Try the existing historical non-Safe-Mode configuration (`kern.init_safe_mode=0` is an available, commented setting in `resources/boot/grub/env-common.cfg`) as a configuration-only experiment. Confirm from guest logs which startup mode the kernel enters; the setting alone is not proof of normal boot.
3. Trace the launch sequence and identify the first failed or absent dependency in the real 5.00 startup. Implement only that measured kernel/QEMU compatibility gap, then rerun the same image and compare logs.
4. Continue until SceSysCore can start the system services and SceShellCore in normal mode. Validate actual process names/paths from the user's image and guest trace; do not infer them from other firmware versions.
5. After shell startup is stable, add the graphics path required by the genuine shell: GNM command submission and resource mapping, VSH compositor surfaces, VideoOut/CRTC buffer registration, flip submission and vblank handling. The first visual success should be the shell's real framebuffer/flip, not a re-created dashboard.
6. Investigate the 5.00 shell application's actual loader/runtime requirements, then resolve SceShellUI/NPXS20001, `app.exe.sprx`, Mono and Psm dependencies from the local 5.00 image and traces. These are later runtime layers and should not be implemented from guesses.

## Source-backed execution path and limitations

- The pinned 5.00 GRUB configuration loads the real kernel selected as `(sflash)/orbisys-500`. Orbital's roadmap historically describes `/mini-syscore.elf`, `/SceAvControl.elf`, `/safemode.elf`, and later `/system/sys/SceSysCore.elf`; that roadmap is historical project progress, not verification on this Windows build.
- The PS4 boot-process reverse-engineering notes on PSDevWiki describe SceSysCore starting system services including `orbis_audiod.elf` and `GnmCompositor.elf`, and subsequently starting SceShellCore. Treat these as investigation leads and verify the actual launch chain from the user's 5.00 image and our logs.
- The 5.00 NPXS20001 reverse-engineering page reports its managed shell application under `/system_ex/app/NPXS20001/psm/Application/app.exe.sprx`. OSM-Made's PS4-Mono repository analyzes the associated application entry and managed UI loop. These are reverse-engineering sources, not Sony SDK specifications; confirm every path and ABI against the supplied 5.00 material.
- The open-source shadPS4 implementation has a useful VideoOut reference for `sceVideoOutRegisterBuffers`, `sceVideoOutSubmitFlip`, and `sceVideoOutWaitVblank`, plus a GNM driver layer. It emulates game-facing APIs and does not provide PS4 system software, SceSysCore, or a drop-in shell implementation.
- Orbital already contains GPU/CRTC and display-device emulation. Before changing those components, determine whether the missing step is in guest API coverage, DMA/resource mapping, synchronization, or Orbital's host presentation path.

## Evidence links

- Pinned Orbital source: https://github.com/AlexAltea/orbital/tree/8f51aea60ee15a15dcf3f1fe09d93912f4539259
- Archived Orbital roadmap snapshot: https://github.com/AlexAltea/orbital/wiki/Roadmap/db0ddc4bb7d89ee1fcb51b9df592821b1cb204a5
- PS4 boot-process reverse-engineering notes: https://www.psdevwiki.com/ps4/Bootprocess
- NPXS20001 reverse-engineering notes: https://www.psdevwiki.com/ps4/NPXS20001
- PS4-Mono analysis: https://github.com/OSM-Made/PS4-Mono
- shadPS4 VideoOut implementation reference: https://github.com/shadps4-emu/shadPS4/blob/main/src/core/libraries/videoout/video_out.cpp
- shadPS4 GNM implementation reference: https://github.com/shadps4-emu/shadPS4/tree/main/src/core/libraries/gnmdriver

No third-party SceSysCore, SceShellCore, NPXS20001, Mono/PUI, or Home implementation is proposed as a substitute for genuine Sony components. No firmware was downloaded, and no post-M0 implementation was started.
