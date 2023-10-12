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

# Create a seed.img file, which includes:
#   1. Any files that you've placed in the `data` directory.
#   2. cloud-init configuration
${CONFIG_DIR}/create_user_data.sh

# All resetting needs to do is delete and recreate the delta image
rm ${DELTA_IMAGE}
qemu-img create -f qcow2 -F qcow2 -b ${ORIG_IMAGE} ${DELTA_IMAGE}
