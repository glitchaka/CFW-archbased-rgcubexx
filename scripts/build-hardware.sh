#!/usr/bin/env bash
set -euo pipefail
# Build the H700 hardware layer using the pinned ROCKNIX enablement tree, then
# rebuild the patched kernel without ROCKNIX's embedded initramfs. The resulting
# kernel boots directly into the Arch Cube root filesystem.

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/common.sh"

mkdir_build_dirs
require_cmd git
require_cmd find
require_cmd make
require_cmd rsync
require_cmd aarch64-linux-gnu-gcc

ROCKNIX_BUILD_IMAGE="${ROCKNIX_BUILD_IMAGE:-ghcr.io/rocknix/rocknix-build:latest}"

if [[ ! -d "${ROCKNIX_DIR}/.git" ]]; then
  log "cloning ROCKNIX hardware enablement source"
  git clone --filter=blob:none "${ROCKNIX_REPO}" "${ROCKNIX_DIR}"
fi

log "checking out pinned ROCKNIX commit ${ROCKNIX_COMMIT}"
git -C "${ROCKNIX_DIR}" fetch --depth=1 origin "${ROCKNIX_COMMIT}"
git -C "${ROCKNIX_DIR}" checkout --detach "${ROCKNIX_COMMIT}"

export PROJECT="${ROCKNIX_PROJECT}"
export DEVICE="${ROCKNIX_DEVICE}"
export ARCH="${ROCKNIX_ARCH}"
export AUTOREMOVE=no
export DISABLE_COLORS=yes

rocknix_build() {
  local target="$1"

  if [[ "${ARCHCUBE_ROCKNIX_DOCKER:-0}" == "1" ]]; then
    require_cmd docker
    log "building ROCKNIX target ${target} in ${ROCKNIX_BUILD_IMAGE}"
    (
      cd "${ROCKNIX_DIR}"
      ./scripts/get_env > .archcube-build.env
      docker run --init --rm \
        --user "$(id -u):$(id -g)" \
        --env-file .archcube-build.env \
        -v "${ROCKNIX_DIR}:${ROCKNIX_DIR}" \
        -w "${ROCKNIX_DIR}" \
        "${ROCKNIX_BUILD_IMAGE}" \
        bash -lc "./scripts/build ${target}"
    )
  else
    log "building ROCKNIX target ${target} on host"
    (
      cd "${ROCKNIX_DIR}"
      ./scripts/build "${target}"
    )
  fi
}

log "preparing/building the patched H700 Linux tree through ROCKNIX"
rocknix_build linux

KERNEL_BUILD="$(find "${ROCKNIX_DIR}" -type f -path '*/linux-*/arch/arm64/boot/Image' -printf '%h\n' 2>/dev/null | sed 's#/arch/arm64/boot$##' | head -n1)"
[[ -n "${KERNEL_BUILD}" && -d "${KERNEL_BUILD}" ]] || die "could not locate the prepared ROCKNIX Linux build tree"

log "rebuilding patched kernel without the ROCKNIX embedded initramfs"
"${KERNEL_BUILD}/scripts/config" --set-str CONFIG_INITRAMFS_SOURCE ""
make -C "${KERNEL_BUILD}" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- clean
make -C "${KERNEL_BUILD}" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olddefconfig
make -C "${KERNEL_BUILD}" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j"$(nproc)" Image dtbs modules

rm -rf "${HARDWARE_DIR}/modules-root"
mkdir -p "${HARDWARE_DIR}/modules-root"
make -C "${KERNEL_BUILD}" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- \
  INSTALL_MOD_PATH="${HARDWARE_DIR}/modules-root" modules_install

install -Dm0644 "${KERNEL_BUILD}/arch/arm64/boot/Image" "${HARDWARE_DIR}/Image"
DTB_SOURCE="${KERNEL_BUILD}/arch/arm64/boot/dts/allwinner/${DTB_NAME}"
[[ -f "${DTB_SOURCE}" ]] || die "RG CubeXX DTB was not produced: ${DTB_SOURCE}"
install -Dm0644 "${DTB_SOURCE}" "${HARDWARE_DIR}/${DTB_NAME}"

log "building ROCKNIX H700 U-Boot dependencies/artifacts"
rocknix_build u-boot

UBOOT_SOURCE="$(find "${ROCKNIX_DIR}" -type f \( \
  -name "H700_${UBOOT_SUBDEVICE}_u-boot-sunxi-with-spl.bin" -o \
  -path "*/u-boot-${UBOOT_SUBDEVICE}*/u-boot-sunxi-with-spl.bin" \
  \) | head -n1)"
[[ -n "${UBOOT_SOURCE}" && -f "${UBOOT_SOURCE}" ]] || die "could not locate H700 ${UBOOT_SUBDEVICE} U-Boot binary"
install -Dm0644 "${UBOOT_SOURCE}" "${HARDWARE_DIR}/u-boot-sunxi-with-spl.bin"

printf '%s\n' "${ROCKNIX_COMMIT}" > "${HARDWARE_DIR}/rocknix-commit"
printf '%s\n' "${DTB_NAME}" > "${HARDWARE_DIR}/dtb-name"

log "hardware layer prepared in ${HARDWARE_DIR}"
