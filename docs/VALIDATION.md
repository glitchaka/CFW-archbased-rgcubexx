# Arch Cube 0.1-dev — first device validation

This is the release gate between `0.1-dev` and `0.1`.

## Safety

- Keep the original Anbernic microSD untouched.
- Use a separate development card.
- Do not write the image to an internal PC disk; verify the target device before flashing.
- The current image does not modify internal storage on the RG CubeXX.

## Build-host validation

Before flashing:

```bash
make all
```

Expected artifact:

```text
build/images/archcube-rgcubexx-0.1-dev.img
```

Check the image partition table and labels:

```bash
fdisk -l build/images/archcube-rgcubexx-0.1-dev.img
```

Expected labels after loop mounting:

```text
ACBOOT
ARCHCUBE
```

## First boot setup

For the first test, connect:

1. development microSD in TF1
2. USB-C Ethernet adapter with working DHCP/Internet
3. charger/power as appropriate

The bootstrap is intentionally autonomous. The expected sequence is:

```text
H700 Boot ROM
 -> SPL/U-Boot
 -> Linux Image + CubeXX DTB
 -> Arch Linux ARM / systemd
 -> wired DHCP
 -> archcube-firstboot.service
 -> pacman package installation
 -> NetworkManager / BlueZ / PipeWire / labwc / RetroArch
 -> tty1 graphical Arch Cube session
```

The first provisioning pass can remain on the text console while packages are downloaded. It marks itself complete only after the required package set is installed.

## Boot failure checkpoints

### No visible boot

Primary suspects:

- SPL/U-Boot compatibility
- wrong DDR target
- boot partition discovery
- panel initialization

Use serial logs if available before changing multiple variables at once.

### Kernel starts but rootfs is not mounted

Check for:

```text
root=LABEL=ARCHCUBE
```

and confirm that the ext4 partition is labeled `ARCHCUBE`.

### systemd starts but provisioning does not finish

From a console inspect:

```bash
systemctl status archcube-firstboot.service
journalctl -u archcube-firstboot.service -b
ip addr
resolvectl status
```

The service is designed to retry after network/package failures and does not create `/var/lib/archcube/firstboot.done` until provisioning completes.

## Hardware validation checklist

After reaching the Arch Cube session:

- [ ] native 720x720 panel orientation and refresh are correct
- [ ] DRM/KMS active
- [ ] Panfrost renderer active
- [ ] D-pad/buttons detected
- [ ] both analog sticks detected and axes correct
- [ ] internal audio works
- [ ] volume path works
- [ ] Wi-Fi sees 2.4/5 GHz networks
- [ ] Bluetooth scans/pairs
- [ ] battery capacity is reported
- [ ] USB host detects a keyboard/storage/Ethernet adapter
- [ ] TF2 is detected
- [ ] clean poweroff works
- [ ] suspend/resume does not corrupt display/input/audio

Useful commands:

```bash
uname -a
cat /proc/device-tree/model
ls /dev/dri
cat /sys/kernel/debug/dri/0/name 2>/dev/null || true
lsmod
ip link
bluetoothctl list
aplay -l
lsblk
cat /sys/class/power_supply/*/capacity 2>/dev/null
```

## Arch validation

From `foot`:

```bash
sudo pacman -Syu
sudo pacman -S htop
```

0.1 requires normal package installation to work without rebuilding the firmware.

## RetroArch validation

- [ ] RetroArch launches from the Arch Cube menu
- [ ] renderer works without software/fallback corruption
- [ ] built-in controls are visible
- [ ] audio works
- [ ] at least one libretro core loads a ROM from `/home/alarm/ROMs`
- [ ] exiting RetroArch returns to the launcher

## Release decision

Only after the required boot, package-management, display/input/audio and RetroArch checks pass should `ARCHCUBE_VERSION` be changed from `0.1-dev` to `0.1` and a release image/tag be produced.
