# Milestone 0.1 — Functional Arch base

## Definition of done

Milestone 0.1 is complete when the RG CubeXX can boot from a development microSD into an Arch Linux ARM AArch64 userspace and the machine can be used without rebuilding the firmware for every application change.

The key requirement is package-driven extensibility: once networking works, software should be installable through `pacman` or project packages.

## Phase 1 — Boot chain

- [ ] Establish reproducible microSD partition layout
- [ ] Establish U-Boot source/configuration for H700
- [ ] Boot Linux kernel on RG CubeXX
- [ ] Load `sun50i-h700-anbernic-rgcubexx.dtb`
- [ ] Mount Arch root filesystem
- [ ] Reach systemd userspace
- [ ] Obtain serial or persistent boot logs for failures

## Phase 2 — Essential hardware

- [ ] Internal 720x720 display
- [ ] DRM/KMS
- [ ] Mali/Panfrost acceleration where supported by the selected kernel stack
- [ ] Built-in controls
- [ ] Analog sticks
- [ ] Audio output
- [ ] Battery reporting
- [ ] Clean shutdown
- [ ] Suspend/resume foundation
- [ ] TF2 / secondary microSD
- [ ] USB host/OTG

## Phase 3 — Connectivity

- [ ] Wi-Fi
- [ ] Bluetooth
- [ ] Network time synchronization
- [ ] SSH for development
- [ ] Stable DNS resolution

## Phase 4 — Arch package layer

- [ ] Initialize Arch Linux ARM keyring
- [ ] `pacman -Syu` works
- [ ] Hardware-critical kernel/boot packages are protected from accidental generic replacement
- [ ] Create project package namespace
- [ ] Create first project metapackage

## Phase 5 — Graphical session

- [ ] Wayland session
- [ ] labwc
- [ ] terminal emulator
- [ ] gamepad navigation mapping foundation
- [ ] minimal Arch Cube launcher/session
- [ ] correct 720x720 scaling

## Phase 6 — First applications

- [ ] RetroArch package/install path
- [ ] initial libretro cores
- [ ] ROM storage path definition
- [ ] launch and exit cleanly back to the session
- [ ] additional standalone emulators only after the base system is stable

## Explicitly out of scope for 0.1

- network cable tester
- custom external hardware
- advanced context switching
- media-station automation
- full software store UI
- OTA system
- elaborate gaming frontend
- custom theming beyond what is required for usability

## Technical principle

Arch Linux ARM is the userspace base. The RG CubeXX-specific bootloader, kernel, device tree and low-level hardware configuration remain under project control. A normal userspace update must not be able to replace those pieces with unsuitable generic packages.
