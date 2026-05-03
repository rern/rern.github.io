#!/bin/bash

sudo pacman -Sy arm-linux-gnueabihf-gcc bc bison flex libelf pahole cpio perl tar xz

set -euo pipefail

# ===== USER CONFIG =====

KERNEL_REPO="https://github.com/raspberrypi/linux.git"
KERNEL_BRANCH="rpi-6.6.y"   # Pi Zero-safe modern branch
WORKDIR="${PWD}/rpi-zero-build"
SRCDIR="${WORKDIR}/src"
BUILDDIR="${WORKDIR}/build"
OUTDIR="${WORKDIR}/out"
JOBS="$(nproc)"

# Cross toolchain

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

# Reproducibility knobs

export KBUILD_BUILD_USER="manjaro"
export KBUILD_BUILD_HOST="repro"
export KBUILD_BUILD_TIMESTAMP="1970-01-01"
export KBUILD_BUILD_VERSION="1"

# Avoid newer GCC breaking older kernel warnings

export KCFLAGS="-Wno-error"

# ===== PRECHECK =====

command -v ${CROSS_COMPILE}gcc >/dev/null || {
echo "[!] Missing cross-compiler: ${CROSS_COMPILE}gcc"
echo "    Install with: sudo pacman -S arm-linux-gnueabihf-gcc"
exit 1
}

# ===== SETUP =====

mkdir -p "$SRCDIR" "$BUILDDIR" "$OUTDIR"

if [ ! -d "${SRCDIR}/linux" ]; then
	git clone --depth=1 --branch "$KERNEL_BRANCH" "$KERNEL_REPO" "${SRCDIR}/linux"
fi

cd "${SRCDIR}/linux"

# Clean tree for reproducibility

make mrproper

# ===== CONFIG =====

if [ ! -f "${WORKDIR}/.config" ]; then
read -p "
On Pi Zero:
- zcat /proc/config.gz > /tmp/.config
- copy /tmp/.config to $WORKDIR

Then press enter to continue.
"
fi

echo "[*] Using external .config"
cp "${WORKDIR}/.config" .config
make olddefconfig

# ===== BUILD =====

make -j"${JOBS}" O="${BUILDDIR}" zImage modules dtbs

# ===== OUTPUT =====

mkdir -p "${OUTDIR}/boot"

cp "${BUILDDIR}/arch/arm/boot/zImage" 
"${OUTDIR}/boot/kernel.img"

cp "${BUILDDIR}/arch/arm/boot/dts/bcm2835-rpi-zero.dtb" 
"${OUTDIR}/boot/"

make O="${BUILDDIR}" modules_install 
INSTALL_MOD_PATH="${OUTDIR}/rootfs"

# ===== DONE =====

echo "[+] Build complete"
echo "    Kernel : ${OUTDIR}/boot/kernel.img"
echo "    DTB    : ${OUTDIR}/boot/bcm2835-rpi-zero.dtb"
echo "    Modules: ${OUTDIR}/rootfs/lib/modules"
