#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

require_root
require_cmd curl
require_cmd bsdtar
mkdir_build_dirs

TARBALL="${CACHE_DIR}/ArchLinuxARM-aarch64-latest.tar.gz"

if [[ ! -f "${TARBALL}" ]]; then
  log "downloading Arch Linux ARM AArch64 rootfs"
  curl --fail --location --retry 3 "${ARCH_ROOTFS_URL}" -o "${TARBALL}"
else
  log "using cached Arch Linux ARM rootfs"
fi

log "extracting clean rootfs"
rm -rf "${ROOTFS_DIR}"
install -d -m0755 "${ROOTFS_DIR}"
bsdtar -xpf "${TARBALL}" -C "${ROOTFS_DIR}"

install -d -m0755 \
  "${ROOTFS_DIR}/boot" \
  "${ROOTFS_DIR}/etc/archcube" \
  "${ROOTFS_DIR}/var/lib/archcube"
printf '%s\n' "${DEVICE}" > "${ROOTFS_DIR}/etc/archcube/device"
printf '%s\n' "${ARCHCUBE_VERSION}" > "${ROOTFS_DIR}/etc/archcube/version"

log "Arch Linux ARM rootfs prepared at ${ROOTFS_DIR}"
