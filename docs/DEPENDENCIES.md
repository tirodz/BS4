# Dependencies and source revisions

## Historical Orbital components

| Component | Revision | Local path |
|---|---|---|
| Orbital | `8f51aea60ee15a15dcf3f1fe09d93912f4539259` | `orbital-500/` |
| QEMU | `8f4e40e628b40d0a78d41438afa59eb7ccc326ce` | `orbital-500/orbital-qemu/` |
| BIOS | `bb0e19a5c026ad5ca833afe16e2deed025d4419d` | `orbital-500/orbital-bios/` |
| GRUB | `bc159e3fbd976ba30897db6307a618d9d8de6911` | `orbital-500/orbital-grub/` |
| keycodemapdb | `6b3d716e2b6472eb7189d3220552280ef3d832ce` | QEMU submodule |
| glslang | `7.11.3214`, `c11e3156af2297f89a23c8db3f5e2323733ee556` | `tools/glslang-*` |

## Windows build environment

The build uses local MSYS2 under `tools/msys64/msys64`, MINGW64 GCC, Python, Autoconf/Automake, libtool, gettext, pkgconf, NASM, SDL2, Vulkan headers/loader, GLib, Pixman, libzip, libusb, DTC, libgcrypt, CMake and Ninja. GNU Binutils 2.46 source/build are under `tools/binutils-*`; the archive SHA-256 was verified against the GNU release announcement: `a389850c2d3919f2cc96fb8b5e7711eacfc819259aaffb11615c9fb9756eaeae`.

Exact MSYS2 package versions and commands are maintained in `research/ORBITAL_WINDOWS_BUILD.md`. Dependencies/toolchains are local-only and are not required to download from this repository.

## Runtime acceleration

QEMU lists TCG/HAX/KVM/Xen. The documented Windows build uses TCG. KVM is Linux-only; HAX needs a compatible HAXM driver and enabled CPU virtualization. WHPX is not enabled by this historical configure. None of these are required merely to build QEMU.
