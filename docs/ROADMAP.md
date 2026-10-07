# Roadmap

## M0 — historical Orbital Safe Mode baseline

1. Finish native Windows build of pinned QEMU, BIOS (`ubios.bin`) and GRUB (`boot.img`). QEMU alone currently builds.
2. Prepare matching system partition images from the user-provided 5.00 system PUP using Orbital's documented decryption/unpacking process.
3. Obtain remaining legitimate user-console artifacts and document each file's provenance.
4. Pass preflight, run the pinned 5.00 configuration, and capture serial/QEMU/display evidence.
5. Verify real Orbis kernel, mini-syscore, and Safe Mode separately; repeat from clean invocation.

## After M0

First investigate and instrument real process/ELF load and service-start traces from the guest. Compare observed startup against the actual 5.00 system-service/userland files before implementing shell behavior. Exact post-M0 work is only a research plan at this stage.

## Later target

Reach genuine PS4 Dynamic Menu using Sony system software, including required system services, shell, compositor, UI application and graphics presentation. This is a long-term objective and is not verified or currently implemented.

## Out of scope before M0

No new PS4 emulator, mock Home screen, SceSysCore, SceShellCore, NPXS20001, Mono, PUI/Psm, Shell UI or Home rendering work.
