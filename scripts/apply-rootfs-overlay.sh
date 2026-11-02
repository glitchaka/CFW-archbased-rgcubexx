#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

require_root
require_cmd rsync
[[ -d "${ROOTFS_DIR}" ]] || die "rootfs not found; run make rootfs first"

log "applying Arch Cube rootfs overlay"
rsync -aHAX "${REPO_ROOT}/rootfs-overlay/" "${ROOTFS_DIR}/"

chmod 0755 \
  "${ROOTFS_DIR}/usr/local/sbin/archcube-firstboot" \
  "${ROOTFS_DIR}/usr/local/bin/archcube-launcher" \
  "${ROOTFS_DIR}/usr/local/bin/archcube-session" \
  "${ROOTFS_DIR}/usr/share/archcube/labwc/autostart"

install -d "${ROOTFS_DIR}/etc/systemd/system/multi-user.target.wants"
ln -sfn /usr/lib/systemd/system/systemd-networkd.service \
  "${ROOTFS_DIR}/etc/systemd/system/multi-user.target.wants/systemd-networkd.service"
ln -sfn /usr/lib/systemd/system/systemd-resolved.service \
  "${ROOTFS_DIR}/etc/systemd/system/multi-user.target.wants/systemd-resolved.service"
ln -sfn /etc/systemd/system/archcube-firstboot.service \
  "${ROOTFS_DIR}/etc/systemd/system/multi-user.target.wants/archcube-firstboot.service"

rm -f "${ROOTFS_DIR}/etc/resolv.conf"
ln -s /run/systemd/resolve/stub-resolv.conf "${ROOTFS_DIR}/etc/resolv.conf"

install -d "${ROOTFS_DIR}/etc/archcube"
printf '%s\n' "${DEVICE}" > "${ROOTFS_DIR}/etc/archcube/device"
printf '%s\n' "${ARCHCUBE_VERSION}" > "${ROOTFS_DIR}/etc/archcube/version"

if [[ -d "${HARDWARE_DIR}/modules-root/usr/lib/modules" ]]; then
  log "installing H700 kernel modules into rootfs"
  install -d "${ROOTFS_DIR}/usr/lib/modules"
  rsync -aH "${HARDWARE_DIR}/modules-root/usr/lib/modules/" "${ROOTFS_DIR}/usr/lib/modules/"
else
  log "kernel modules are not present yet; run make hardware before the final image"
fi

log "rootfs overlay complete"
