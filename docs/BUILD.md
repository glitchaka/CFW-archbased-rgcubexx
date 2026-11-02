# Building Arch Cube 0.1

## Build host

The build scripts target a Linux host. Ubuntu/Debian package names are shown as a reference; equivalents are fine.

Required host tools include:

```text
git curl libarchive-tools rsync make gcc-aarch64-linux-gnu
bc bison flex libssl-dev libelf-dev dwarves
util-linux dosfstools e2fsprogs
```

ROCKNIX may require additional build dependencies while preparing its patched H700 kernel tree. Its own dependency checker remains authoritative for that stage.

## Build

From the repository root:

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

The final image is written under:

```text
build/images/archcube-rgcubexx-0.1-dev.img
```

The default image is a sparse 8 GiB image with:

```text
16 MiB reserved area
  - H700 SPL/U-Boot at offset 8 KiB

partition 1: 512 MiB FAT32, label ACBOOT
  - Image
  - dtb.img
  - extlinux/extlinux.conf

partition 2: ext4, label ARCHCUBE
  - Arch Linux ARM AArch64 rootfs
  - H700 kernel modules
  - Arch Cube overlay
```

## First boot

The first boot is deliberately split into two stages so the image does not need to execute AArch64 package-manager scriptlets on the build host.

1. Arch Linux ARM boots directly to systemd.
2. `systemd-networkd` provides DHCP on a wired interface. A USB-C Ethernet adapter is the bootstrap path.
3. `archcube-firstboot.service` initializes the Arch Linux ARM keyring and installs the first package set through pacman.
4. NetworkManager replaces bootstrap networking.
5. labwc, PipeWire, Bluetooth and RetroArch are installed.
6. tty1 is restarted and enters the graphical Arch Cube session.

If the network is unavailable, first-boot provisioning fails without marking itself complete and systemd retries it. The system remains usable from the local console.

## First UI

The 0.1 UI is intentionally minimal. labwc starts `archcube-launcher`, a fuzzel-based menu with:

- RetroArch
- terminal
- NetworkManager TUI
- bluetoothctl
- reboot / power off

This is scaffolding, not the final Arch Cube interface.

## ROMs

The initial ROM path is:

```text
/home/alarm/ROMs
```

A future release can add TF2 discovery and per-system library management without changing the base boot architecture.

## Flashing

Write the generated `.img` to a development microSD with a raw image writer. Keep the original Anbernic card untouched while 0.1 is experimental.

## Current validation policy

The repository is implementation-first: changes are committed before compilation, flashing and device validation. A build completing successfully does not by itself prove panel, audio, suspend or input behavior on physical RG CubeXX hardware; those require device validation.
