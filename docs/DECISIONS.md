# Decision log

## DEC-0001 — Use historical Orbital for the first baseline

Date: 2026-10-06. Decision: pin root commit `8f51aea60ee15a15dcf3f1fe09d93912f4539259` for M0. Alternatives: modern/incomplete Orbital tree or starting a new emulator. Rationale: the target is the historical kernel → mini-syscore → Safe Mode path and preserving the demonstrated baseline makes results comparable. Consequence: revive its exact old QEMU/BIOS/GRUB and accept compatibility work rather than silently swapping components.

## DEC-0002 — Use firmware 5.00 as primary target

Date: 2026-10-06. Decision: target the documented 5.00 setup, with 4.55 only as fallback. Rationale: historical configuration and user-provided 5.00 PUP. Consequence: all runtime files and provenance must match 5.00 or be explicitly version-invariant recovery files.

## DEC-0003 — Keep proprietary material outside source control

Date: 2026-10-06. Decision: PUP, decrypted Sony files, keys, console dumps and runtime images stay local and are ignored by Git. Rationale: preserve Sony proprietary material and console-specific data outside the public source repository. Consequence: manifests and docs describe paths/provenance, never embed the files.

## DEC-0004 — shadPS4 remains a comparison/Plan B, not primary

Date: 2026-10-06 (project context). Decision: do not change the primary route before testing historical Orbital. Rationale: M0 is explicitly a reproducible historical baseline. Consequence: do not conflate a game-focused emulator with this boot-chain milestone.

## DEC-0005 — Build QEMU independently while BIOS/GRUB are unresolved

Date: 2026-10-07. Decision: continue building the working historical QEMU target and diagnose BIOS/GRUB toolchain failures separately. Rationale: QEMU builds and can be made ready without proprietary runtime inputs. Consequence: QEMU build pass does not count as M0 or complete Orbital launch readiness.
