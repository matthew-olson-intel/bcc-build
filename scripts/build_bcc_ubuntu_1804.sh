#!/bin/bash
################################################################################
# Ubuntu 18.04 BCC Build Script
########################################
# This script successfully builds BCC on a fresh Ubuntu 18.04 system.
# Before running it, you'll need to install and boot into a newer kernel
# with BTF information, e.g.:
#   sudo apt-get install linux-image-5.4.0-137-generic
# And then reboot the system to boot into it (assuming GRUB is configured
# to boot the latest kernel, which it is by default).
################################################################################

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BCCDIR="${BASEDIR}/bcc"
BUILDDIR="${BCCDIR}/build"

# Install Clang 12, which is just new enough to compile the libbpf-tools
cd ${BASEDIR}
curl https://apt.llvm.org/llvm.sh -o ${BASEDIR}/llvm.sh
chmod +x llvm.sh
sudo ${BASEDIR}/llvm.sh 12 all

# Deps
sudo apt-get update
sudo apt-get -y install zip bison build-essential cmake flex git libedit-dev \
        python zlib1g-dev libelf-dev libfl-dev python3-setuptools liblzma-dev \
        arping netperf iperf python3-venv pkg-config gcc-multilib

# Create a Python environment and activate it
cd ${BASEDIR}
sudo rm -rf ${BASEDIR}/env
if [ ! -d ${BASEDIR}/env ]; then
  python3 -m venv ${BASEDIR}/env
fi
source ${BASEDIR}/env/bin/activate
which python
pip install wheel

# Clone
git clone https://github.com/iovisor/bcc.git ${BCCDIR}
cd ${BCCDIR}

rm -rf ${BUILDDIR}
mkdir ${BUILDDIR}
cd ${BUILDDIR}

# Make the project
cd ${BUILDDIR}
cmake -DPYTHON_CMD=python3 ..
cd ${BUILDDIR}/src/python
make
# sudo make install
cd bcc-python3
which python3
python3 setup.py install --prefix=${BASEDIR}/env

# Deactivate the Python environment
deactivate

# Make the libbpf tools
cd ${BASEDIR}/bcc/libbpf-tools
CLANG=clang-12 LLVM_STRIP=llvm-strip-12 make
