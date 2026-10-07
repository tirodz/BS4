# Firmware record

## Present package

The user supplied the official PS4 5.00 system-update PUP. A copy is at local-only `firmware/official/PS4UPDATE-5.00-system.PUP`; original remains at `PS4UPDATE.PUP`. Copy length is 374,669,312 bytes and SHA-256 is `089168A7CC702FD45B65E8C8271FDFA0386BD1969509A06DC2FE94B03B978501`. The local preflight identified the matching published 5.00 system-PUP size and `SLB2` header. The PUP is encrypted/signed. These checks identify the expected package by user-provided provenance, size, and hash; they are not an independent Sony signature verification.

No PUP was downloaded in this work. Do not install it on a physical console as part of this project.

## What it can support

Orbital's pinned `bin/hdd/README.md` says `eap.img`, `system.img`, and `system_ex.img` may be extracted from a normal or recovery PUP matching the target version. Its historical workflow first runs open-source `ps4-pup_decrypt` on the console and then `ps4-pup_unpack` on a computer. Therefore the present 5.00 system PUP can support these matching 5.00 images after that workflow.

The same README says `preinst.img` and `recovery.img` come from a recovery PUP. The supplied package is the system/update PUP, so it does not establish those files. The USB image `usb-pup-500rec.qcow2` is required by `run.sh`; the pinned tree does not document its complete creation/internal-layout recipe.

The decrypted kernel path `sflash/orbisys-500`, writable `sflash.bin`, and GPU `vbios.bin` are separate files in the historical layout. Orbital docs describe them as decrypted/dumped console inputs and do not document derivation from the system PUP. `crypto/blobs.zip` and decrypted userland executables are Orbital Dumper outputs from console runtime material. Details and per-file statuses: `docs/FIRMWARE_REQUIREMENTS.md` and `research/ORBITAL_500_RUNTIME_LAYOUT.md`.

## Data handling

All Sony files, console dumps, decrypted binaries, proprietary keys, disk images and secrets remain outside Git. Git records only path requirements, version/provenance declarations without file payloads, and public-source research.
