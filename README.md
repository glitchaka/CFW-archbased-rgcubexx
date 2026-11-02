# Arch Cube — Arch-based CFW for Anbernic RG CubeXX

Custom Linux firmware for the Anbernic RG CubeXX, built around an Arch Linux ARM AArch64 userspace.

## Project goal

Arch Cube is not intended to be only another retro-gaming distribution. The base goal is a small, maintainable Arch system for the RG CubeXX with normal package management and a lightweight Wayland session. Emulators are the first application category; additional tools can be added later through pacman without rebuilding the firmware.

## Target hardware

- Anbernic RG CubeXX
- Allwinner H700 / Cortex-A53
- Mali G31 / Panfrost path
- 1 GB LPDDR4
- AArch64 userspace
- 720x720 internal display

## 0.1-dev architecture

```text
microSD
  |
  +-- H700 SPL / U-Boot (raw offset 8 KiB)
  |
  +-- FAT32 boot partition (ACBOOT)
  |    +-- Image
  |    +-- dtb.img
  |    +-- extlinux/extlinux.conf
  |
  +-- ext4 Arch partition (ARCHCUBE)
       +-- Arch Linux ARM AArch64
       +-- H700 kernel modules
       +-- systemd
       +-- pacman
       +-- NetworkManager / BlueZ / PipeWire
       +-- Wayland + labwc
       +-- foot + fuzzel launcher
       +-- RetroArch
```

Arch Linux ARM provides the userspace. The H700 bootloader, kernel, CubeXX DTB and low-level hardware configuration are kept outside generic Arch kernel packages, so ordinary userspace updates cannot silently replace the device-critical boot layer.

For 0.1-dev, the H700 enablement source is pinned to a known ROCKNIX commit. Their build system is used to prepare the current H700 kernel/U-Boot support, then Arch Cube rebuilds the patched kernel without the ROCKNIX embedded initramfs so it boots the Arch root filesystem directly.

## Build

On a supported Linux build host:

```bash
make rootfs
make hardware
make overlay
make image
```

or:

```bash
make all
```

The generated image is expected at:

```text
build/images/archcube-rgcubexx-0.1-dev.img
```

See [docs/BUILD.md](docs/BUILD.md) for dependencies, disk layout and the first-boot process.

## First boot

The image boots to Arch Linux ARM first. A USB-C Ethernet connection provides the initial network path. `archcube-firstboot.service` then uses pacman to install the graphical/audio/network package set and RetroArch, switches networking to NetworkManager and starts the labwc session on tty1.

The initial launcher exposes only:

- RetroArch
- terminal
- network configuration
- Bluetooth configuration
- reboot / power off

This launcher is scaffolding for 0.1, not the final Arch Cube interface.

## Repository layout

```text
boot/                 boot architecture documentation
config/               pinned build configuration
rootfs-overlay/       Arch Cube files copied into the Arch rootfs
scripts/              rootfs, hardware and image builders
docs/                 build and milestone documentation
Makefile              build entry points
```

## Current status

**0.1-dev implementation complete; physical validation pending.**

The repository now contains the complete first-pass path from Arch Linux ARM rootfs to H700 hardware build and flashable microSD image assembly. It has not yet earned a `0.1` release tag because the generated image still needs to be compiled and boot-tested on a physical RG CubeXX. Display, controls, audio, Wi-Fi/Bluetooth, suspend and RetroArch behavior remain device-validation gates.

See [docs/MILESTONE-0.1.md](docs/MILESTONE-0.1.md) for the exact implementation/test split.

## Development rule

During the initial implementation phase, changes are committed to the repository before compilation, device flashing or final validation.
