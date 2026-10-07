# Changelog

## 2026-10-07

- Recorded the BS4 project state and recovery instructions in the new GitHub source-of-truth documentation.
- Added a source-backed classification of runtime inputs that may be prepared from the user-provided 5.00 system PUP versus separate console/recovery inputs.
- Recorded that the historical QEMU executable builds on Windows, while the BIOS/GRUB artifacts and M0 runtime remain blocked.

## 2026-10-06

- Identified and checked out Orbital historical baseline commit `8f51aea60ee15a15dcf3f1fe09d93912f4539259` with its pinned component submodules.
- Investigated the missing `externals/core.h` / `externals/core.cmake` integration in the public checkout.
- Prepared local preflight/launcher scripts and runtime research. No real PS4 boot was verified.
