#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
# shellcheck disable=SC1091
source "${REPO_ROOT}/config/build.env"

BUILD_DIR="${BUILD_DIR:-${REPO_ROOT}/build}"
CACHE_DIR="${CACHE_DIR:-${BUILD_DIR}/cache}"
ROOTFS_DIR="${ROOTFS_DIR:-${BUILD_DIR}/rootfs}"
HARDWARE_DIR="${HARDWARE_DIR:-${BUILD_DIR}/hardware}"
ROCKNIX_DIR="${ROCKNIX_DIR:-${BUILD_DIR}/rocknix}"
IMAGE_DIR="${IMAGE_DIR:-${BUILD_DIR}/images}"

log() { printf '[archcube] %s\n' "$*"; }
die() { printf '[archcube] ERROR: %s\n' "$*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

require_root() {
  [[ ${EUID} -eq 0 ]] || die "this step must be run as root"
}

mkdir_build_dirs() {
  mkdir -p "${BUILD_DIR}" "${CACHE_DIR}" "${HARDWARE_DIR}" "${IMAGE_DIR}"
}
