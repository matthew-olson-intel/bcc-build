#!/bin/bash
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DELTA_IMAGE="${BASEDIR}/delta/ubuntu-18.04.img.delta"
ORIG_IMAGE="${BASEDIR}/orig/ubuntu-18.04.img.orig"

rm ${DELTA_IMAGE}
qemu-img create -f qcow2 -F qcow2 -b ${ORIG_IMAGE} ${DELTA_IMAGE}
