# Firmware inventory

Inventory scan date: 2026-10-07. Runtime requirements were refined against the pinned source on 2026-10-07.
Workspace scanned recursively: `C:\Users\Syf\Desktop\BS4`.

## Result

The workspace contains `PS4UPDATE.PUP` at the BS4 root. Its size is exactly 374,669,312 bytes and its first four bytes are `SLB2`. The published PS4 system-software catalog maps that exact size to the 5.00 system PUP (`5.008.000`, build date 2017-09-26); its recovery PUP is a separate 954,624,512-byte package. I recorded SHA-256 `089168A7CC702FD45B65E8C8271FDFA0386BD1969509A06DC2FE94B03B978501` and copied it without changing the original to `firmware/official/PS4UPDATE-5.00-system.PUP`. The package remains encrypted/signed; this size match is version identification, not cryptographic authentication.

The PUP is not the decrypted runtime tree Orbital opens. No decrypted kernel, extracted system partition images, SFLASH dump, VBIOS, recovery USB qcow2 image, or SAMU blob archive was found in the recursive workspace scan. No firmware package was downloaded during this work. The pinned HDD README explicitly permits `eap.img`, `system.img`, and `system_ex.img` to be extracted from a matching normal PUP after console-side decryption and host unpacking; the existing system PUP can support those files. `preinst.img` and `recovery.img` require recovery-PUP material. Other console dump/Dumper requirements are separate. See the derivation matrix in `ORBITAL_500_RUNTIME_LAYOUT.md`.

The exact historical checkout is now staged separately at `orbital-500/`, detached at commit `8f51aea60ee15a15dcf3f1fe09d93912f4539259`. Its QEMU, BIOS, and GRUB submodules are pinned by that commit. Build products and research remain outside this source tree's Git history.

## Exact source paths required by the 5.00 runner

Relative to the runtime working directory `firmware/orbital-5.00/`:

- `sflash/orbisys-500` — decrypted 5.00 x86-64 kernel ELF. Read by `orbital-qemu/hw/ps4/aeolia_pcie.c:680`, selected by `resources/boot/grub/boot.cfg:1`.
- `sflash.bin` — writable raw SFLASH input opened as `r+` at `aeolia_pcie.c:690`.
- `vbios.bin` — 5.00 VBIOS ROM selected by `orbital-qemu/hw/ps4/liverpool_gc.c:725`.
- `hdd/eap.img`, `hdd/preinst.img`, `hdd/recovery.img`, `hdd/system.img`, `hdd/system_ex.img` — the five PUP-extracted files named in `bin/hdd/README.md`. The custom HDD image builder demonstrably copies only `system.img` and `system_ex.img`; source references for the other three are not known.
- `usb/usb-pup-500rec.qcow2` — exact read-only recovery USB image from `bin/run.sh:11`.
- `crypto/blobs.zip` — exact SAMU archive consumed by `lvp_samu.c:532-544`; root entries are `<uppercase 32-character MD5>.bin` and runtime coverage depends on guest inputs.
- `firmware-manifest.json` — BS4's user-maintained declaration of each artifact's firmware provenance. This is not a Sony authenticity check.

The runner generates `hdd.qcow2` from `hdd/system.img` and `hdd/system_ex.img` using the historical custom `qemu-img create-ps4` command. The launcher also stages the open-source build outputs `ubios.bin` and `boot.img`. Details, version requirements, and unknowns are in `ORBITAL_500_RUNTIME_LAYOUT.md` and `../firmware/ORBITAL_FIRMWARE_REQUIREMENTS.md`.

## Compatibility assessment

- Firmware package present: PS4 5.00 system PUP (encrypted/signed; not directly bootable by Orbital).
- Required Orbital runtime inputs satisfied: none.
- Firmware boot: not attempted.
- Decrypted userland coverage: unknown until files from the user's own 5.00 material are staged and actual guest output names requested files.
- Current blocker: open-source BIOS/GRUB build outputs and decrypted/runtime inputs are missing. The three matching system partition images can be prepared from the supplied PUP using Orbital's documented console decryption and host unpacking route; the PUP itself is present.

No placeholder files were created. The original root PUP was preserved. A byte-for-byte copy was placed in the official firmware folder. No Sony material was downloaded or overwritten.

Version/size reference: https://www.psdevwiki.com/ps4/System_Software (the catalog lists 5.008.000 / 5.00 system PUP at 374,669,312 bytes, recovery PUP at 954,624,512 bytes).
