# Research index and evidence labels

This page summarizes the verified research present in `research/` and the pinned source. **VERIFIED** means checked in the local source/build; **HISTORICAL** means an upstream description or old demo; **INFERRED** means supported but not proven; **UNKNOWN** means evidence is missing.

## Orbital and the baseline

- **VERIFIED:** historical root revision is `8f51aea60ee15a15dcf3f1fe09d93912f4539259`; its pinned QEMU, BIOS and GRUB hashes are in `DEPENDENCIES.md`.
- **HISTORICAL:** project documents describe kernel → mini-syscore → Safe Mode and old firmware configurations including 4.55/5.00.
- **VERIFIED:** public current Orbital checkout lacks `externals/core.h` and `externals/core.cmake`; historical Git investigation did not find the integration in public reachable refs. Detailed evidence: `../research/ORBITAL_CORE_INVESTIGATION.md`.
- **UNKNOWN:** how to restore/replace this missing integration without substantial work; it is separate from the pinned `orbital-500` QEMU build.

## Firmware and boot chain

- **VERIFIED:** the user provided a 5.00 system PUP copy, encrypted, with recorded size/hash. No PUP was downloaded.
- **VERIFIED:** pinned HDD README says `eap.img`, `system.img`, `system_ex.img` derive from matching normal/recovery PUP after console decryption and host unpacking; it assigns `preinst.img` and `recovery.img` to any recovery PUP.
- **VERIFIED:** source copies only `system.img` and `system_ex.img` into generated custom HDD; it does not directly consume the three other README images in the checked source search.
- **VERIFIED:** `run.sh` attaches `usb/usb-pup-500rec.qcow2`; its internal layout creation process is not documented in the pinned source.
- **UNKNOWN:** static decrypted executable and blob set sufficient for Safe Mode.
- Full path and consumers: `../research/ORBITAL_500_RUNTIME_LAYOUT.md`; earlier project findings: `../research/ORBITAL_BASELINE.md`, `../research/FIRMWARE_INVENTORY.md`.

## QEMU, BIOS, GRUB

- **VERIFIED:** QEMU clean build succeeded locally and exposes PS4 machine/device types.
- **VERIFIED:** BIOS and GRUB images have not built; current failures are in `ERRORS.md`.
- **HISTORICAL:** pinned Orbital root build script skips BIOS and GRUB under MSYS, so its Windows build branch does not produce a full runner.
- **INFERRED:** locally built GNU ELF tools may resolve the GRUB target mismatch; full build remains to test.

## Later PS4 shell path

`../research/POST_M0_SHELL_PLAN.md` records candidate post-M0 work. No local kernel runtime traces exist, so claims about SceSysCore, SceShellCore, VSH compositor, SceShellUI, NPXS20001, Mono, PUI/Psm or VideoOut/CRTC sequencing remain research hypotheses, not BS4 observations.

## Other emulator projects

shadPS4, fpPS4, Kyty, Obliteration, Prosperity, GPCS4 and psOff are not the primary implementation route. This local documentation set does not yet contain source-verified comparative studies for all of them. Their detailed capability/architecture comparisons are **UNKNOWN here** and must be researched from their current source before influencing a strategy change. Do not copy unsourced claims into project status.
