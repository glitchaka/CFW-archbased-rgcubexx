# RG CubeXX boot layer

This directory owns the hardware-critical boot layer. It is deliberately separate from the Arch Linux ARM userspace.

## Target chain

```text
microSD
  -> H700 boot ROM
  -> U-Boot
  -> Linux Image
  -> sun50i-h700-anbernic-rgcubexx.dtb
  -> Arch Linux ARM rootfs
```

## Rules

1. Do not replace the project kernel, U-Boot or RG CubeXX DTB with generic Arch packages during normal system upgrades.
2. Keep the device-specific layer reproducible and versioned.
3. Prefer an upstream/mainline-capable H700 stack where it provides the required RG CubeXX hardware support.
4. Track borrowed patches/configuration with source and license information.
5. Keep stock/development SD cards separate while the boot path is experimental.

## Known device-tree name

The RG CubeXX device tree used by current H700 Linux distributions is:

```text
sun50i-h700-anbernic-rgcubexx.dtb
```

The exact kernel/U-Boot source and configuration for this project are not pinned yet. They must be selected and documented before the first image build.
