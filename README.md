# BS4

BS4 is a local research project investigating whether genuine Sony PlayStation 4 system software can be booted on Windows. The project uses the historical Orbital PS4 emulator as its primary experimental route. The goal is real Orbis system software, not a visual recreation.

## Current status

The pinned historical QEMU component builds as a Windows executable and exposes Orbital's PS4 machine/devices. The full historical launch chain is not ready: the pinned BIOS and GRUB images have not been built successfully on this Windows/MSYS2 host, and the decrypted/runtime inputs required by Orbital are not staged. The user-provided official 5.00 system-update PUP is present locally, outside Git. No PS4 kernel, mini-syscore, Safe Mode, Shell, or Home boot has been verified in BS4.

The first technical milestone remains **M0: historical Orbital 5.00 kernel → mini-syscore → Safe Mode**. Safe Mode is a diagnostic milestone, not the project goal.

## Architecture

BS4 pins Orbital root revision `8f51aea60ee15a15dcf3f1fe09d93912f4539259`, including its historical QEMU, BIOS, and GRUB component revisions. QEMU models PS4-specific hardware and provides the `ps4` machine. BIOS/GRUB load the decrypted Orbis kernel. The guest then consumes HDD, SFLASH, GPU ROM, and SAMU fake-decryption data. Exact runtime layout and source consumers are in [`research/ORBITAL_500_RUNTIME_LAYOUT.md`](research/ORBITAL_500_RUNTIME_LAYOUT.md).

The source tree and build tools live locally under `orbital-500/` and `tools/`; generated logs are under `logs/orbital-m0/`. Those build inputs are intentionally kept out of the BS4 documentation repository for now; exact revisions and recovery commands are recorded under `docs/`.

## Firmware and proprietary files

The official 5.00 system-update PUP is preserved locally in `firmware/official/` and a byte-identical user-provided original is at the workspace root. It is encrypted and does not directly satisfy Orbital's runtime file paths. Some matching partition images can be prepared from it through Orbital's documented console decryption and host unpacking workflow. The matching decrypted kernel, console SFLASH/VBIOS dumps, and SAMU blob output remain separate requirements. Sony firmware, keys, dumps, and decrypted runtime files must never be committed to GitHub.

## What BS4 is not

BS4 is not a new emulator implementation, a PS4 Home UI mock-up, or a claim that Orbital already boots a PS4. It does not implement SceSysCore, SceShellCore, SceShellUI, NPXS20001, Mono, PUI/Psm, or Home rendering before the M0 baseline is reproduced.

## Resume

Start with [`docs/STATUS.md`](docs/STATUS.md), then follow [`docs/SESSION_HANDOFF.md`](docs/SESSION_HANDOFF.md). The records distinguish locally verified results from historical Orbital claims, inferences, and unknowns.

## Documentation map

See [`docs/RECOVERY.md`](docs/RECOVERY.md) for a clean continuation procedure and [`docs/`](docs/) for architecture, build/runtime history, firmware requirements, decisions, errors, roadmap, and research.
