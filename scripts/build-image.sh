#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

require_root
for cmd in truncate sfdisk losetup mkfs.vfat mkfs.ext4 mount umount rsync dd sync; do
  require_cmd "${cmd}"
done

[[ -d "${ROOTFS_DIR}" ]] || die "rootfs missing; run make rootfs and make overlay"
[[ -f "${HARDWARE_DIR}/Image" ]] || die "kernel Image missing; run make hardware"
[[ -f "${HARDWARE_DIR}/${DTB_NAME}" ]] || die "RG CubeXX DTB missing; run make hardware"
[[ -f "${HARDWARE_DIR}/u-boot-sunxi-with-spl.bin" ]] || die "U-Boot missing; run make hardware"
[[ -d "${HARDWARE_DIR}/modules-root/usr/lib/modules" ]] || die "kernel modules missing; run make hardware"

mkdir_build_dirs
IMAGE="${IMAGE_DIR}/archcube-rgcubexx-${ARCHCUBE_VERSION}.img"
MOUNT_ROOT="${BUILD_DIR}/mnt-root"
MOUNT_BOOT="${BUILD_DIR}/mnt-boot"
LOOPDEV=""

cleanup() {
  set +e
  mountpoint -q "${MOUNT_BOOT}" && umount "${MOUNT_BOOT}"
  mountpoint -q "${MOUNT_ROOT}" && umount "${MOUNT_ROOT}"
  [[ -n "${LOOPDEV}" ]] && losetup -d "${LOOPDEV}"
}
trap cleanup EXIT

log "creating sparse ${IMAGE_SIZE_MIB} MiB image"
rm -f "${IMAGE}"
truncate -s "${IMAGE_SIZE_MIB}M" "${IMAGE}"

START_SECTORS=$((16 * 2048))
BOOT_SECTORS=$((BOOT_SIZE_MIB * 2048))
ROOT_START=$((START_SECTORS + BOOT_SECTORS))

sfdisk "${IMAGE}" <<EOF
label: dos
unit: sectors

start=${START_SECTORS}, size=${BOOT_SECTORS}, type=c, bootable
start=${ROOT_START}, type=83
EOF

# Allwinner H700 SPL/U-Boot is stored at 8 KiB, before the first partition.
dd if="${HARDWARE_DIR}/u-boot-sunxi-with-spl.bin" of="${IMAGE}" \
  bs=1K seek=8 conv=fsync,notrunc status=progress

LOOPDEV="$(losetup --find --show --partscan "${IMAGE}")"
BOOT_PART="${LOOPDEV}p1"
ROOT_PART="${LOOPDEV}p2"

mkfs.vfat -F 32 -n "${BOOT_LABEL}" "${BOOT_PART}"
mkfs.ext4 -F -L "${ROOT_LABEL}" "${ROOT_PART}"

mkdir -p "${MOUNT_BOOT}" "${MOUNT_ROOT}"
mount "${ROOT_PART}" "${MOUNT_ROOT}"
mount "${BOOT_PART}" "${MOUNT_BOOT}"

log "copying Arch Linux ARM root filesystem"
rsync -aHAX --numeric-ids --exclude='/boot/*' "${ROOTFS_DIR}/" "${MOUNT_ROOT}/"

log "installing kernel modules"
mkdir -p "${MOUNT_ROOT}/usr/lib/modules"
rsync -aH "${HARDWARE_DIR}/modules-root/usr/lib/modules/" "${MOUNT_ROOT}/usr/lib/modules/"

log "creating H700 boot partition"
install -Dm0644 "${HARDWARE_DIR}/Image" "${MOUNT_BOOT}/Image"
install -Dm0644 "${HARDWARE_DIR}/${DTB_NAME}" "${MOUNT_BOOT}/dtb.img"
install -d "${MOUNT_BOOT}/extlinux"
cat > "${MOUNT_BOOT}/extlinux/extlinux.conf" <<EOF
DEFAULT archcube
TIMEOUT 10
MENU TITLE Arch Cube

LABEL archcube
  LINUX /Image
  FDT /dtb.img
  APPEND root=LABEL=${ROOT_LABEL} rw rootwait rootfstype=ext4 console=ttyS0,115200 console=tty0 loglevel=4 systemd.show_status=1
EOF

sync
log "flashable image created: ${IMAGE}"
