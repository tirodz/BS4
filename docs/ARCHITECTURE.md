# Architecture

## Current experimental stack

BS4 uses historical Orbital at root revision `8f51aea60ee15a15dcf3f1fe09d93912f4539259`. Its QEMU submodule models PS4-specific CPU/chipset and devices, including Aeolia/SAMU and Liverpool GPU. The pinned BIOS and GRUB provide the boot chain. GRUB's Orbital configuration reads `sflash/orbisys-500`, selects firmware-specific environment files (the 5.00 configuration is `resources/boot/grub/env-500.cfg`), then boots the guest kernel. QEMU attaches generated HDD and recovery USB storage and uses Orbital display plus serial/monitor output.

The runner is relative-path dependent. The historical `bin/run.sh` changes to `bin/`, selects `ubios.bin` and `boot.img`, attaches `hdd.qcow2` and `usb/usb-pup-500rec.qcow2`, uses eight vCPUs and the Orbital display. The BS4 launcher stages generated open-source boot artifacts in the runtime directory and captures diagnostics under `logs/orbital-m0/`.

## Firmware boundary

The official encrypted PUP is an input to preparation, not a direct QEMU runtime image. Matching system partition images can be extracted after the historical console-assisted PUP decryption route. Other QEMU inputs are separate console dumps or Orbital Dumper outputs. Public source does not provide a full static list of Safe Mode userland files.

## Scope boundary

M0 establishes the historic kernel → mini-syscore → Safe Mode path. Work on SceSysCore, SceShellCore, VSH compositor, SceShellUI, NPXS20001, Mono, PUI/Psm, VideoOut/CRTC page flips, and Home must wait until M0 works repeatably. Post-M0 research and the current candidate first experiment are in `research/POST_M0_SHELL_PLAN.md`.

## Architecture unknowns

- The public Orbital checkout references a missing `externals/core` integration, so the separate `orbital/` current-source tree is incomplete at that layer.
- The exact Safe Mode executable/blob set is not statically documented by the pinned runner.
- The complete internal layout expected in `usb-pup-500rec.qcow2` is not described in the pinned source.
- The Windows BIOS/GRUB image production path is still unresolved.
