#!/bin/bash
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

qemu-system-x86_64  \
  -machine accel=kvm,type=q35 \
  -cpu host \
  -m 8G \
  -nographic \
  -device virtio-net-pci,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -drive if=virtio,format=qcow2,file=${BASEDIR}/delta/ubuntu-18.04.img.delta \
  -drive if=virtio,format=raw,file=seed.img
