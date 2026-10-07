# Orbital 5.00 runtime requirements

Runtime staging root (local-only): `firmware/orbital-5.00/`. Status reflects the workspace inventory on 2026-10-07. The official 5.00 system-update PUP is **present** separately under `firmware/official/`; that does not mean decrypted runtime inputs are present.

| Exact filename/path | Purpose/consumer | Exists? | From PUP / derivable? | Console-specific or unknown? | Verification status |
|---|---|---:|---|---|---|
| `sflash/orbisys-500` | Decrypted kernel ELF; GRUB config and Aeolia PCIe consume it. | No | Not established; PUP-to-this-file extraction is undocumented in pinned source. | Matching console kernel dump required by documented route. | Expected ELF64 x86-64; no payload to inspect. |
| `sflash.bin` | Writable SFLASH file opened `r+` by Aeolia. | No | No documented derivation. | User console SFLASH dump; historical manual says decrypted. | Opaque format, no source-level validation known. |
| `vbios.bin` | Liverpool GPU PCI ROM. | No | No documented derivation from PUP. | User console VBIOS dump on current evidence. | Opaque ROM, no payload to inspect. |
| `hdd/eap.img` | Documented HDD partition; no direct consumer found in pinned image-builder/device code. | No | Yes: README permits matching normal/recovery PUP; requires documented decrypt/unpack. | Not a separate dump after the PUP decrypt step. | No image present. |
| `hdd/system.img` | Copied into generated system GPT partition. | No | Yes: matching 5.00 normal/recovery PUP; decrypt/unpack. | Not a separate dump after PUP processing. | No image present. |
| `hdd/system_ex.img` | Copied into generated system_ex GPT partition. | No | Yes: matching 5.00 normal/recovery PUP; decrypt/unpack. | Not a separate dump after PUP processing. | No image present. |
| `hdd/preinst.img` | Historical documented HDD staging file; no direct consumer found in pinned image-builder/device code. | No | No: README specifies any recovery PUP, version-invariant. | Requires legitimate recovery-PUP material; source does not require console-specific provenance. | No image present. |
| `hdd/recovery.img` | Historical documented HDD staging file; no direct consumer found in pinned image-builder/device code. | No | No: README specifies any recovery PUP, version-invariant. | Requires legitimate recovery-PUP material; source does not require console-specific provenance. | No image present. |
| `usb/usb-pup-500rec.qcow2` | Read-only recovery USB attached by historical `bin/run.sh`. | No | No documented recipe from current system-update PUP. | Legitimate matching recovery source needed; console-specific status unknown. | Expected QCOW2 header/version can be preflighted; internal guest contents not validated. |
| `crypto/blobs.zip` | SAMU fake-decrypt archive keyed by MD5 names. | No | No; PUP is not Orbital Dumper output. | Console-derived decrypted blob set via Orbital Dumper. | Expected ZIP shape known; exact blob set depends on guest execution. |
| Decrypted userland ELF/SELF/SPRX files in `bin/` | Kernel/runtime loads userland; historical manual says Orbital Dumper produces decrypted files under `bin`. | No complete set found | Some originals may be in PUP filesystem, but complete Safe Mode set and transformation are undocumented; cannot call PUP sufficient. | Console/Dumper route documented; exact filenames UNKNOWN until source/runtime evidence. | No static checklist or guest load trace exists. |
| `hdd.qcow2` | Generated PS4 virtual HDD passed to QEMU. | No | Not a Sony artifact. Generate with Orbital `qemu-img create-ps4` from staged partition files. | No. | Requires successful image generation. |
| `firmware-manifest.json` | BS4 local preflight provenance metadata. | No | No; create locally when inputs are staged. | No. | Preflight currently treats absent manifest as unknown provenance. |
| `ubios.bin` | Orbital BIOS build output. | No | Open-source build product, not firmware. | No. | BIOS build not complete. |
| `boot.img` | Orbital GRUB build output. | No | Open-source build product, not firmware. | No. | GRUB build not complete. |

### Tools identified in pinned Orbital documentation

- `ps4-pup_decrypt` (source linked from Orbital HDD README): runs on a legitimately owned PS4 and decrypts the user's PUP into blob fragments.
- `ps4-pup_unpack` (source linked from Orbital HDD README): host-side unpacker for already-decrypted PUP fragments; it does not itself decrypt the encrypted PUP.
- Orbital Dumper (`orbital-500/tools/dumper/`): historical on-console extraction/decryption of userland and SAMU blob data. Its 5.00 code is pinned in the Orbital source.
- Orbital `qemu-img create-ps4`: creates `hdd.qcow2` from supported source images.

No Sony or third-party decrypted files were downloaded. The next user-material request should be limited to genuine console-specific data only after source-backed extraction from the existing PUP has been exhausted. The PUP itself is not missing.
