# BS4

### PlayStation 4 System Software Research on Windows

<p align="center">
  <img src="assets/bs4-play-no-limits.gif" alt="BS4 PlayStation-style blue bumper" width="960">
</p>

> **BS4** is an experimental project investigating whether genuine PlayStation 4 system software can be booted on Windows through the historical **Orbital** emulator stack.

The objective is **real Orbis system software** running in an emulated PS4 environment — not a recreated Home screen, not a frontend, and not simply PS4 game compatibility.

---

## Current status

**Phase:** Historical Orbital revival / M0 preparation  
**Platform:** Windows + MSYS2  
**Target:** PS4 system software 5.00  
**Boot status:** **Not yet booted**

| Component | Status |
|---|---|
| Historical Orbital baseline | ✅ Pinned |
| Historical QEMU | ✅ Clean-built |
| PS4 QEMU machine/devices | ✅ Verified |
| `qemu-img` / `create-ps4` | ✅ Built |
| Official PS4 5.00 PUP | ✅ Present locally |
| BIOS (`ubios.bin`) | 🔄 Build blocked |
| GRUB (`boot.img`) | 🔄 Build blocked |
| Orbital runtime inputs | 🔄 Being prepared/inventoried |
| M0 guest boot | ⏳ Not attempted |
| Orbis kernel | ⏳ Not verified |
| mini-syscore | ⏳ Not verified |
| Safe Mode | ⏳ Not verified |
| PS4 Shell / Dynamic Menu | ⏳ Future goal |

### M0

The first reproducible milestone is:

**Orbis 5.00 kernel → mini-syscore → Safe Mode**

Safe Mode is only a **diagnostic checkpoint**. The long-term objective is the genuine PS4 system software stack and ultimately the real Dynamic Menu / Home environment.

---

## What has been achieved

The project is based on the historical Orbital revision:

`8f51aea60ee15a15dcf3f1fe09d93912f4539259`

The historical QEMU component has been clean-built on Windows and produces the PS4-enabled QEMU executable. The resulting binary reports the historical QEMU 2.11.91 version and exposes Orbital's `ps4` machine and PS4-specific devices.

The custom Orbital `qemu-img` tool is also built and provides the historical `create-ps4` disk-image command.

The supplied **official PS4 5.00 system-update PUP** has been verified locally and is preserved outside Git. Orbital's historical documentation identifies matching 5.00 partition images such as `eap.img`, `system.img`, and `system_ex.img` as PUP-derived inputs, while other runtime material is separate.

The build process, failures, experiments, source revisions, firmware requirements, and recovery information are all recorded in this repository.

---

## Architecture

At a high level, the historical boot path being reconstructed is:

```text
Windows
   │
   ▼
Orbital / QEMU
   │
   ├── PS4 CPU / memory model
   ├── Liverpool GPU model
   ├── Aeolia / PS4 devices
   ├── storage
   └── other PS4-specific hardware
   │
   ▼
BIOS + GRUB
   │
   ▼
Orbis 5.00 kernel
   │
   ▼
early system services / mini-syscore
   │
   ▼
Safe Mode
   │
   ▼
PS4 system software
   │
   ▼
Shell / Dynamic Menu
```

The exact historical file layout and source consumers are documented in:

- [`research/ORBITAL_500_RUNTIME_LAYOUT.md`](research/ORBITAL_500_RUNTIME_LAYOUT.md)
- [`research/ORBITAL_BASELINE.md`](research/ORBITAL_BASELINE.md)
- [`research/ORBITAL_WINDOWS_BUILD.md`](research/ORBITAL_WINDOWS_BUILD.md)

---

## Why Orbital?

Modern PS4 emulators are primarily focused on running PS4 games. BS4 has a different experimental target: **booting the PS4 operating environment itself**.

Historical Orbital is therefore being used as the primary route because its architecture was built around a lower-level emulated PS4 machine capable of loading historical PS4 system software.

This is an experimental engineering choice, not a claim that Orbital is the most modern or best-maintained PS4 emulator.

---

## Firmware and runtime material

The project currently targets **PS4 system software 5.00**, because the selected Orbital baseline is tied to that environment.

The user-supplied official Sony 5.00 system-update PUP is kept locally under:

`firmware/official/`

It is **not committed to GitHub**.

The PUP is a legitimate official package, but the historical Orbital runner expects additional prepared runtime inputs. These include, depending on the exact boot path:

- matching HDD partition images
- decrypted Orbis kernel
- SFLASH data
- VBIOS
- recovery USB image
- SAMU fake-decryption blob archive
- additional decrypted userland material

The repository documents which inputs are known to be PUP-derived, which are separate console-derived inputs, and which remain uncertain.

See:

- [`docs/FIRMWARE.md`](docs/FIRMWARE.md)
- [`docs/FIRMWARE_REQUIREMENTS.md`](docs/FIRMWARE_REQUIREMENTS.md)
- [`research/ORBITAL_500_RUNTIME_LAYOUT.md`](research/ORBITAL_500_RUNTIME_LAYOUT.md)

### Proprietary material policy

Sony firmware, console dumps, decrypted proprietary binaries, keys, secrets, and other restricted material remain **local-only** and must not be committed to this repository.

GitHub contains documentation, source-compatible tooling, research, patches, logs, and reproducibility notes — not proprietary Sony payloads.

---

## Current engineering blockers

### BIOS

The historical BIOS requires an **i386 ELF** build environment. The Windows MinGW toolchain produces PE/COFF output, and Clang also rejects legacy GCC-specific x86 inline-assembly constraints used by the pinned BIOS source.

The Kconfig stage has already been repaired for the Windows checkout's CRLF/LF issue. GNU ELF binutils are available locally, and the next route is an **i686-ELF GCC** toolchain.

### GRUB

Historical GRUB also requires an ELF-oriented build path. The native MinGW linker produces PE/COFF, causing GRUB's linker probe to fail.

These are **open-source build-toolchain issues**, separate from the PS4 firmware/runtime requirements.

No guest boot has been attempted yet.

---

## Repository structure

```text
.
├── assets/                 # README/project artwork
├── docs/                   # Long-term project memory and recovery docs
├── firmware/               # Firmware requirements/tools; Sony payloads stay local
├── logs/                   # Build and preflight evidence
├── patches/                # Narrow Windows compatibility patches
├── research/               # Historical/source-level investigation
└── scripts/                # Local build/preflight/launcher helpers
```

The large historical Orbital checkout, build toolchains, generated binaries, and proprietary/user-supplied files remain outside the public documentation tree where appropriate.

---

## Documentation and continuity

This repository is intended to be the project's **long-term source of truth**.

Start here when continuing work:

1. [`docs/STATUS.md`](docs/STATUS.md) — exact current state
2. [`docs/SESSION_HANDOFF.md`](docs/SESSION_HANDOFF.md) — continue from the latest checkpoint
3. [`docs/RECOVERY.md`](docs/RECOVERY.md) — rebuild/recovery procedure
4. [`docs/BUILD_LOG.md`](docs/BUILD_LOG.md) — chronological build history
5. [`docs/RUNTIME_LOG.md`](docs/RUNTIME_LOG.md) — runtime/boot attempts
6. [`docs/ERRORS.md`](docs/ERRORS.md) — known failures and diagnoses
7. [`docs/DECISIONS.md`](docs/DECISIONS.md) — architectural decisions
8. [`docs/FIRMWARE_REQUIREMENTS.md`](docs/FIRMWARE_REQUIREMENTS.md) — exact runtime inputs
9. [`docs/PROJECT_RULES.md`](docs/PROJECT_RULES.md) — engineering standards

Every meaningful build failure, discovery, experiment, and milestone should be recorded so the project can continue even if the original development session disappears.

---

## What BS4 is not

BS4 is **not**:

- a PS4 Home UI mock-up
- a frontend pretending to be the PS4 OS
- a claim that historical Orbital already boots the PS4
- a new general-purpose PS4 emulator
- a replacement for modern game-focused projects

The project will only claim a PS4-system milestone when it has been **actually reproduced and documented with evidence**.

---

## Long-term goal

```text
Windows
  ↓
Historical Orbital
  ↓
PS4 5.00 system software
  ↓
Orbis kernel
  ↓
system services
  ↓
Shell / Dynamic Menu
  ↓
genuine PS4 Home environment
```

Getting M0 to work is the next major milestone.

**No Home-screen success is claimed yet.**