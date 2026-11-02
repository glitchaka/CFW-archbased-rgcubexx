#!/usr/bin/env bash
set -euo pipefail

ROOTFS_URL="${ROOTFS_URL:-http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz}"
WORKDIR="${WORKDIR:-$(pwd)/build}"
ROOTFS_DIR="${ROOTFS_DIR:-${WORKDIR}/rootfs}"
CACHE_DIR="${CACHE_DIR:-${WORKDIR}/cache}"
TARBALL="${CACHE_DIR}/ArchLinuxARM-aarch64-latest.tar.gz"

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Missing required command: $1" >&2
        exit 1
    }
}

if [[ ${EUID} -ne 0 ]]; then
    echo "This script must run as root because the Arch Linux ARM rootfs must be extracted preserving ownership, ACLs and extended attributes." >&2
    exit 1
fi

require_cmd curl
require_cmd bsdtar
require_cmd install

mkdir -p "${CACHE_DIR}"
rm -rf "${ROOTFS_DIR}"
mkdir -p "${ROOTFS_DIR}"

if [[ ! -f "${TARBALL}" ]]; then
    echo "Downloading Arch Linux ARM AArch64 rootfs..."
    curl -fL "${ROOTFS_URL}" -o "${TARBALL}"
else
    echo "Using cached rootfs: ${TARBALL}"
fi

echo "Extracting rootfs..."
bsdtar -xpf "${TARBALL}" -C "${ROOTFS_DIR}"

install -d -m 0755 "${ROOTFS_DIR}/etc/archcube"
printf '%s\n' 'rgcubexx' > "${ROOTFS_DIR}/etc/archcube/device"
printf '%s\n' '0.1-dev' > "${ROOTFS_DIR}/etc/archcube/version"

echo "Arch Linux ARM rootfs prepared at: ${ROOTFS_DIR}"
echo "Boot/kernel/device-tree integration is intentionally handled separately."
