# Orbital 5.00 runtime material requirements

Pinned historical source: Orbital root commit `8f51aea60ee15a15dcf3f1fe09d93912f4539259`.

The expected runtime tree is `firmware/orbital-5.00/`. Keep Sony material outside the Git source trees. Source references and what is known about each file are recorded in [the exact runtime layout](../research/ORBITAL_500_RUNTIME_LAYOUT.md).

## Official Sony distribution

| Item | Role | Status |
|---|---|---|
| `firmware/official/PS4UPDATE-5.00-system.PUP` | Encrypted/signed 5.00 system update package, 374,669,312 bytes. It is preserved as a source package but is not opened directly by QEMU. | Present as a copy of the user-provided root `PS4UPDATE.PUP`; SHA256 `089168A7CC702FD45B65E8C8271FDFA0386BD1969509A06DC2FE94B03B978501`. Size matches the published 5.00 system PUP record. This does not establish cryptographic authenticity. No new package was downloaded. |

Orbital's historical `bin/hdd/README.md` points to open-source `ps4-pup_decrypt` to decrypt a legitimately held PUP on the console and `ps4-pup_unpack` to unpack it on a computer. That same README explicitly identifies `eap.img`, `system.img`, and `system_ex.img` as extractable from a matching normal or recovery PUP; the supplied 5.00 system PUP can support those outputs after the documented decrypt/unpack process. `preinst.img` and `recovery.img` are specified as coming from a recovery PUP. The provided system PUP does not replace the separate decrypted-kernel, SFLASH/VBIOS console dumps, SAMU Dumper blobs, or userland files. The source does not document a full recipe for creating `usb-pup-500rec.qcow2`.

## User-supplied matching 5.00 material

Stage these exact paths under `firmware/orbital-5.00/`:

| Path | Version | Expected state/format | Orbital consumer |
|---|---|---|---|
| `sflash/orbisys-500` | 5.00 | Decrypted x86-64 ELF kernel, no extension required. | GRUB config selects it; Aeolia PCI device reads it. |
| `sflash.bin` | 5.00 console dump | Writable raw SFLASH input. Source opens `r+`; historical Windows manual says to decrypt SFLASH. No internal structural test is known. | Aeolia PCI device. |
| `vbios.bin` | 5.00 | User-provided/decrypted VBIOS ROM. | Liverpool GPU PCI ROM. |
| `hdd/eap.img` | Matching 5.00 PUP | Extracted partition image. | Listed in historical HDD README; no direct consumer found in pinned image-builder/PS4 device source. Still required by the documented five-image staging set. |
| `hdd/preinst.img` | Any recovery PUP, per README | Extracted partition image. | Listed in README; no direct consumer found in pinned image-builder/PS4 device source. |
| `hdd/recovery.img` | Any recovery PUP, per README | Extracted partition image. | Listed in README; no direct consumer found in pinned image-builder/PS4 device source. |
| `hdd/system.img` | Matching 5.00 PUP | Extracted system partition image. | Custom HDD image builder copies it into the generated PS4 system partition. |
| `hdd/system_ex.img` | Matching 5.00 PUP | Extracted system_ex partition image. | Custom HDD image builder copies it into the generated system_ex partition. |
| `usb/usb-pup-500rec.qcow2` | 5.00 recovery | QCOW2 recovery disk. Internal layout and complete creation recipe are not documented in the pinned repository. | Read-only USB mass-storage device from `bin/run.sh`. |
| `crypto/blobs.zip` | Inputs matching target 5.00 runtime | ZIP root entries named `<uppercase 32-character MD5>.bin`, containing corresponding decrypted blob bytes. Required entry set depends on guest execution. | SAMU fake-decrypt code hashes each encrypted blob input and looks up the matching ZIP entry. |
| `firmware-manifest.json` | User provenance declaration | JSON with `firmwareVersion: "5.00"` and an `artifacts` map, per `research/ORBITAL_500_RUNTIME_LAYOUT.md`. | BS4 preflight only; it is a declaration, not proof of authenticity. |

Orbital Dumper is the historical tool for dumping/decrypting console userland ELF/SELF/SPRX and SAMU blobs. The source does not provide a complete static list of the userland executables needed to reach Safe Mode, nor does `run.sh` take separate executable paths. The guest loads them from its mounted system material; actual file requests must be learned from boot logs. Preflight cannot certify userland coverage in advance.

## Open-source host tools and generated build files

| Tool or file | Role |
|---|---|
| Historical `orbital-qemu`, `orbital-bios`, `orbital-grub` submodules | Exact emulator, BIOS and GRUB source pinned by the selected root commit. |
| MSYS2 packages documented by `docs/manual-windows.md` | Windows build environment: Python, Git, base-devel, OpenSSL development package, MinGW toolchain, GTK3/Vulkan/SDL2/glslang/libzip/libusb/GLib. The build attempt also needs a compatible crypto backend because current MSYS2 Nettle 4 removed the `nettle/sha.h` header expected by this QEMU revision. |
| `bin/ubios.bin` | Generated from the open-source BIOS submodule. Not proprietary Sony firmware. |
| `bin/boot.img` | Generated from the open-source GRUB submodule plus Orbital GRUB config. |
| `bin/qemu-system-ps4.exe` | Historical QEMU executable. |
| `bin/qemu-img.exe` | Historical custom image builder used to generate the `hdd.qcow2` runtime system disk. |
| `firmware/orbital-5.00/hdd.qcow2` | Generated locally by `qemu-img create-ps4 --data hdd -f qcow2 hdd.qcow2 200G`; launcher must not overwrite an existing image. |

No proprietary Sony firmware, keys, or decrypted binaries are stored in the source repository or downloaded by this preparation work. Current workspace inventory found the user-provided official 5.00 system-update PUP, but no decrypted kernel, extracted system partition images, SFLASH data, VBIOS, recovery USB image, or crypto archive.
