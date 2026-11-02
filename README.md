# CFW Arch-based for Anbernic RG CubeXX

Custom Linux firmware for the Anbernic RG CubeXX, built around an Arch Linux ARM AArch64 userspace.

## Project goal

The first objective is not to build a large retro-gaming distribution. The goal is to get a clean, maintainable Arch-based system booting on the RG CubeXX with working hardware, networking, package management and a lightweight graphical session. Emulators are the first application category, not the identity of the system.

## Target hardware

- Anbernic RG CubeXX
- Allwinner H700
- AArch64 userspace
- 720x720 internal display

## 0.1 milestone

The first usable milestone targets:

- Boot from microSD
- RG CubeXX kernel + device tree
- Arch Linux ARM AArch64 root filesystem
- systemd
- working display / DRM
- controls and joysticks
- audio
- Wi-Fi
- Bluetooth
- USB
- microSD storage
- battery / poweroff / suspend foundations
- pacman and Internet connectivity
- Wayland + labwc
- terminal
- minimal launcher/session
- installable emulators, starting with RetroArch

See [docs/MILESTONE-0.1.md](docs/MILESTONE-0.1.md).

## Architecture

```text
microSD
  |
  +-- U-Boot
  |
  +-- Linux kernel for H700
  |    +-- RG CubeXX device tree
  |
  +-- Arch Linux ARM AArch64
       +-- systemd
       +-- pacman
       +-- networking / Bluetooth / audio
       +-- Wayland
       +-- labwc
       +-- Arch Cube session
       +-- applications
            +-- emulators
```

Arch Linux ARM provides the userspace. Device-specific boot, kernel, DTB and hardware configuration are maintained separately so regular userspace updates do not replace the hardware-critical parts of the firmware.

## Repository layout

```text
boot/               bootloader, kernel and device-tree integration
configs/            system and session configuration
packages/           Arch packages maintained by this project
scripts/            image/rootfs/build helpers
docs/               project documentation
```

## Current status

Early bootstrap. The repository is being initialized and is not yet a flashable firmware image.

## Development rule

During the initial implementation phase, changes are committed to the repository before compilation, device flashing or validation.
