#!/bin/bash
BASEDIR=$(cd "${BASH_SOURCE[0]%/*}" && pwd)

# User-editable options
IMAGE_SIZE="50G" # How much space you want on top of the ~2GB that Ubuntu provides

if [ -z "$1" ]; then
  echo "USAGE: ./setup.sh [version]"
  exit 1
fi
UBUNTU_VERSION="$1"

CONFIG_DIR="${BASEDIR}/config"
DIST_DIR="${BASEDIR}/dist"
DELTA_DIR="${BASEDIR}/delta"
ORIG_DIR="${BASEDIR}/orig"

DIST_IMAGE="${DIST_DIR}/ubuntu-${UBUNTU_VERSION}.img.dist"
DELTA_IMAGE="${DELTA_DIR}/ubuntu-${UBUNTU_VERSION}.img.delta"
ORIG_IMAGE="${ORIG_DIR}/ubuntu-${UBUNTU_VERSION}.img.orig"

# Create the directories if they don't already exist
mkdir -p ${DIST_DIR}
if [ ! -d ${DIST_DIR} ] || [ ! -w ${DIST_DIR} ]; then
  echo "Failed to create ${DIST_DIR}! Aborting."
  exit 1
fi
mkdir -p ${DELTA_DIR}
if [ ! -d ${DELTA_DIR} ] || [ ! -w ${DELTA_DIR} ]; then
  echo "Failed to create ${DELTA_DIR}! Aborting."
  exit 1
fi
mkdir -p ${ORIG_DIR}
if [ ! -d ${ORIG_DIR} ] || [ ! -w ${ORIG_DIR} ]; then
  echo "Failed to create ${ORIG_DIR}! Aborting."
  exit 1
fi

# Create a seed.img file, which includes:
#   1. Any files that you've placed in the `data` directory.
#   2. cloud-init configuration
${CONFIG_DIR}/create_user_data.sh

# Download the Ubuntu image in question
curl \
  https://cloud-images.ubuntu.com/releases/${UBUNTU_VERSION}/release/ubuntu-${UBUNTU_VERSION}-server-cloudimg-amd64.img \
  -o ${DIST_IMAGE}
  
# Convert the dist image into an uncompressed version (so that we can resize it)
qemu-img convert -O qcow2 ${DIST_IMAGE} ${ORIG_IMAGE}

# Resize. Add 50GB of space to the image.
qemu-img resize ${ORIG_IMAGE} +50G

# Create the delta image, so that our original (resized) image is pristine.
rm -f ${DELTA_IMAGE}
qemu-img create -f qcow2 -F qcow2 -b ${ORIG_IMAGE} ${DELTA_IMAGE}
