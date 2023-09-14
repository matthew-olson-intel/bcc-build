# Ubuntu VMs

This is a collection of Ubuntu VMs which are intended to be used with
their cloud-init and cloud-localds scripts.

The file `user-data.yaml` and `metadata.yaml` are files that are consumed
by these scripts by passing an image containing them to `qemu`. You can create
this image by doing:
```
cloud-localds seed.img user-data.yaml metadata.yaml
```

Next, download an `.img` file of the Ubuntu distribution that you'd like to use.
Let's call that `disk.img.dist`. Then, we can simply follow the Ubuntu tutorial:

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
