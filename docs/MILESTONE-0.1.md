# Milestone 0.1 — Functional Arch base

## Status

The 0.1 implementation is now present in the repository. Hardware validation is deliberately separate: items marked **implemented** have a build/configuration path, while items marked **device test** cannot be called working until the generated image is booted on a physical RG CubeXX.

## Definition of done

0.1 is released only when a development microSD boots into Arch Linux ARM on the RG CubeXX, first-boot provisioning can install software through pacman, and RetroArch can launch and return to the labwc session.

## Phase 1 — Boot chain

- implemented — reproducible MBR microSD layout with 16 MiB bootloader reservation
- implemented — LPDDR4 H700 U-Boot source/configuration pinned through ROCKNIX enablement
- implemented — patched H700 kernel build with ROCKNIX initramfs removed
- implemented — `sun50i-h700-anbernic-rgcubexx.dtb`
- implemented — extlinux boots `root=LABEL=ARCHCUBE`
- implemented — serial and tty0 kernel consoles in boot arguments
- device test — SPL/U-Boot starts on RG CubeXX
- device test — kernel reaches systemd on physical hardware

## Phase 2 — Essential hardware

The selected H700 kernel/device-tree stack contains the support paths; all of these remain physical-device tests:

- device test — internal 720x720 display
- device test — DRM/KMS
- device test — Mali G31 / Panfrost acceleration
- device test — built-in controls
- device test — analog sticks
- device test — audio output
- device test — battery reporting
- device test — clean shutdown
- device test — suspend/resume
- device test — secondary microSD
- device test — USB host/OTG

## Phase 3 — Connectivity

- implemented — systemd-networkd wired DHCP bootstrap
- implemented — NetworkManager installation/takeover
- implemented — Bluetooth/BlueZ installation
- implemented — systemd-timesyncd enablement
- implemented — OpenSSH package installed but not enabled by default
- device test — RTL8821CS Wi-Fi
- device test — Bluetooth

## Phase 4 — Arch package layer

- implemented — Arch Linux ARM generic AArch64 rootfs
- implemented — first-boot Arch Linux ARM keyring initialization
- implemented — package-driven provisioning through pacman
- implemented — hardware kernel/U-Boot/DTB kept outside generic Arch kernel packages
- device test — full `pacman -Syu` on the CubeXX

A private Arch Cube package repository is intentionally deferred; 0.1 uses standard Arch Linux ARM packages plus files shipped in the image.

## Phase 5 — Graphical session

- implemented — Wayland/labwc package path
- implemented — foot terminal
- implemented — fuzzel-based minimal Arch Cube launcher
- implemented — tty1 autologin into the session after provisioning
- implemented — 720x720-first fullscreen window rule
- deferred — gamepad-as-desktop-navigation daemon
- device test — labwc/Panfrost session on the internal display

## Phase 6 — First applications

- implemented — RetroArch installation path
- implemented — optional initial libretro core installation
- implemented — `/home/alarm/ROMs`
- implemented — launcher entry for RetroArch
- device test — RetroArch graphics/audio/input
- device test — exit cleanly back to labwc

## Explicitly out of scope for 0.1

- network cable tester
- custom external hardware
- advanced context switching
- media-station automation
- full software store UI
- OTA system
- elaborate gaming frontend
- final joystick desktop navigation
- custom theming beyond basic usability

## Release gate

The repository may call the implementation complete, but the `0.1` release tag must wait for the first physical boot/validation pass. Until then the image version remains `0.1-dev`.
