SHELL := /bin/bash

.PHONY: help rootfs hardware overlay image all clean

help:
	@printf '%s\n' \
	  'Arch Cube RG CubeXX build targets:' \
	  '  make rootfs    - prepare Arch Linux ARM AArch64 rootfs' \
	  '  make hardware  - prepare patched H700 kernel/U-Boot artifacts' \
	  '  make overlay   - apply Arch Cube configuration to rootfs' \
	  '  make image     - assemble flashable microSD image' \
	  '  make all       - rootfs + hardware + overlay + image' \
	  '  make clean     - remove generated build directory'

rootfs:
	sudo bash ./scripts/bootstrap-rootfs.sh

hardware:
	bash ./scripts/build-hardware.sh

overlay:
	sudo bash ./scripts/apply-rootfs-overlay.sh

image:
	sudo bash ./scripts/build-image.sh

all: rootfs hardware overlay image

clean:
	rm -rf build
