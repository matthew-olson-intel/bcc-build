# Ubuntu VMs

This is a collection of Ubuntu VMs which are intended to be used with
their cloud-init and cloud-localds scripts.

## Dependencies

Arch Linux:
```
pacman -S cloud-init qemu-base
```

Ubuntu:
```
apt-get install cloud-init qemu-utils qemu-system-x86
```

In general, you just need the cloud-init scripts and Qemu.

## How to Use

All top-level scripts take a distro (currently "ubuntu" or "centos") and a version
(e.g. "18.04" or "7" or "8-stream") as arguments. Check `setup.sh` to see the URLs that
it's downloading the images from. Submit a PR if you want to add more distros
or URLs.

1. `setup.sh` will download an image from either the Ubuntu or CentOS images repositories  and create
   all necessary images.
2. `run.sh` will run the given image.
3. `reset.sh` will "reset" an image; that is, the image will return to its pristine state
   and all files will be lost.

If you place files in `data/`, those files will be processed by `config/create_user_data.sh`.
This script compresses and encodes each file and appends it to your `cloud-init` configuration,
as a workaround to easily copy files into these VMs. These files will be placed in
`/home/ubuntu`, but will be owned by root.

## Examples

```
./setup.sh ubuntu 18.04
./run.sh ubuntu 18.04
```

If you want to erase all changes you've made to the Ubuntu 18.04 VM, do
```
./reset.sh ubuntu 18.04
```

You can replace "ubuntu" with "centos," and the scripts should support
any of the versions available on either

https://cloud-images.ubuntu.com/releases/

or

https://cloud.centos.org/centos/

## Details

The file `user-data.yaml` and `metadata.yaml` are files that are consumed
by these scripts by passing an image containing them to `qemu`. You can create
this image by doing:
```
cloud-localds seed.img user-data.yaml metadata.yaml
```

Next, download an `.img` file of the distro's distribution that you'd like to use.
Let's call that `disk.img.dist`. Then, we can simply follow a typical qemu workflow:

Convert the compressed qcow file downloaded to a uncompressed qcow2:
```
qemu-img convert -O qcow2 disk.img.dist disk.img.orig
```

Resize the image to 52G from original image of 2G:
```
qemu-img resize disk.img.orig +50G
```

Create a delta disk to keep our .orig file pristine:
```
qemu-img create -f qcow2 -F qcow2 -b disk.img.orig disk.img.delta
```
 
Finally, run your `qemu` command.
