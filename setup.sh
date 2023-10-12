#!/bin/bash
BASEDIR=$(cd "${BASH_SOURCE[0]%/*}" && pwd)

# User-editable options
IMAGE_SIZE="50G" # How much space you want on top of the ~2GB that Ubuntu provides

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "USAGE: ./setup.sh [distro] [version]"
  exit 1
fi
DISTRO="$1"
VERSION="$2"

CONFIG_DIR="${BASEDIR}/config"
DIST_DIR="${BASEDIR}/dist"
DELTA_DIR="${BASEDIR}/delta"
ORIG_DIR="${BASEDIR}/orig"

URL=""
if [ ${DISTRO} = "ubuntu" ]; then
  URL="https://cloud-images.ubuntu.com/releases/${VERSION}/release/ubuntu-${VERSION}-server-cloudimg-amd64.img"
elif [ ${DISTRO} = "centos" ]; then

  # First, get the base URL
  ARCH=""
  if [ ! ${VERSION} = 6 ] && [ ! ${VERSION} = 7 ]; then
    ARCH="x86_64/"
  fi
  BASE_URL="https://cloud.centos.org/centos/${VERSION}/${ARCH}images"
  
  # The filename depends on the version too
  NUMERIC_VERSION=$(echo ${VERSION} | sed s/-stream//)
  FILENAME=""
  if [[ ${VERSION} =~ stream$ ]]; then
    FILENAME="CentOS-Stream-GenericCloud-${NUMERIC_VERSION}-latest.x86_64.qcow2"
  else
    FILENAME="CentOS-${VERSION}-x86_64-GenericCloud.qcow2"
  fi
  URL="${BASE_URL}/${FILENAME}"
  
fi

DIST_IMAGE="${DIST_DIR}/${DISTRO}-${VERSION}.img.dist"
DELTA_IMAGE="${DELTA_DIR}/${DISTRO}-${VERSION}.img.delta"
ORIG_IMAGE="${ORIG_DIR}/${DISTRO}-${VERSION}.img.orig"

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

# Download the image in question
curl -L \
  ${URL} \
  -o ${DIST_IMAGE}
  
# Convert the dist image into an uncompressed version (so that we can resize it)
qemu-img convert -O qcow2 ${DIST_IMAGE} ${ORIG_IMAGE}

# Resize. Add 50GB of space to the image.
qemu-img resize ${ORIG_IMAGE} +50G

# Create the delta image, so that our original (resized) image is pristine.
rm -f ${DELTA_IMAGE}
qemu-img create -f qcow2 -F qcow2 -b ${ORIG_IMAGE} ${DELTA_IMAGE}
