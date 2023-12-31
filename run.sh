#!/bin/bash
BASEDIR=$(cd "${BASH_SOURCE[0]%/*}" && pwd)

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "USAGE: ./run.sh [version]"
  exit 1
fi
DISTRO="$1"
VERSION="$2"

CONFIG_DIR="${BASEDIR}/config"
DIST_DIR="${BASEDIR}/dist"
DELTA_DIR="${BASEDIR}/delta"
ORIG_DIR="${BASEDIR}/orig"

DIST_IMAGE="${DIST_DIR}/${DISTRO}-${VERSION}.img.dist"
DELTA_IMAGE="${DELTA_DIR}/${DISTRO}-${VERSION}.img.delta"
ORIG_IMAGE="${ORIG_DIR}/${DISTRO}-${VERSION}.img.orig"
SEED_IMAGE="${CONFIG_DIR}/seed.img"

qemu-system-x86_64  \
  -machine accel=kvm,type=q35 \
  -cpu host \
  -m 8G \
  -nographic \
  -device virtio-net-pci,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -drive if=virtio,format=qcow2,file=${DELTA_IMAGE} \
  -drive if=virtio,format=raw,file=${SEED_IMAGE}
