# RG CubeXX boot layer

The hardware-critical boot layer is kept outside Arch package management. A normal `pacman -Syu` must never replace the H700 bootloader, kernel or RG CubeXX device tree.

## Boot chain

```text
H700 Boot ROM
  -> SPL / U-Boot at 8 KiB on the microSD
  -> extlinux.conf
  -> Linux Image
  -> sun50i-h700-anbernic-rgcubexx.dtb
  -> root=LABEL=ARCHCUBE
  -> Arch Linux ARM / systemd
```

## 0.1 source policy

For the first usable release, Arch Cube uses the current mainline-oriented H700 enablement maintained by ROCKNIX as a build-time hardware reference. The source is pinned in `config/build.env` rather than following their moving branch.

The hardware build performs two distinct operations:

1. ROCKNIX prepares its H700-patched kernel/U-Boot trees and dependencies.
2. Arch Cube rebuilds that patched kernel with `CONFIG_INITRAMFS_SOURCE=""`, so the resulting kernel boots the Arch Linux ARM filesystem directly instead of the ROCKNIX userspace.

Current target details:

- H700 Cortex-A53 / AArch64
- LPDDR4 / DDR4 U-Boot target
- U-Boot binary: `u-boot-sunxi-with-spl.bin`
- raw U-Boot offset: 8 KiB
- DTB: `sun50i-h700-anbernic-rgcubexx.dtb`
- GPU path: DRM/KMS + Panfrost
- boot configuration: U-Boot distro boot / extlinux

## Upgrade rule

`linux`, U-Boot and the DTB are Arch Cube hardware artifacts. They are deliberately not installed from generic Arch kernel packages. Userspace remains independently upgradeable through pacman.

## Licensing

ROCKNIX, Linux, U-Boot and related patches retain their upstream licenses. This repository does not relicense third-party sources; `scripts/build-hardware.sh` fetches the pinned upstream trees at build time.
