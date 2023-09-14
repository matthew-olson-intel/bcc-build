# Ubuntu 18.04 Build Issues

This document serves to document issues that I encountered when attempting to build the BCC repo
on a fresh install of Ubuntu 18.04. Installing takes into account the commands listed in the relevant
section in `INSTALL.md`.

## Main Project

I did not encounter any issues building BCC itself without the Python bindings; that is, a regular
`cmake .. && make` did not cause any errors and installed correctly.

## Python Bindings

Upon configuring BCC with Python bindings (`cmake -DPYTHON_CMD=python3 ..`), I get the following lengthy error:

```
running install
Checking .pth file support in /lib/python3/dist-packages/
/usr/bin/python3 -E -c pass
TEST FAILED: /lib/python3/dist-packages/ does NOT support .pth files
error: bad install directory or PYTHONPATH

You are attempting to install a package to a directory that is not
on PYTHONPATH and which Python does not read ".pth" files from.  The
installation directory you specified (via --install-dir, --prefix, or
the distutils default setting) was:

    /lib/python3/dist-packages/

and your PYTHONPATH environment variable currently contains:

    ''

Here are some of your options for correcting the problem:

* You can choose a different installation directory, i.e., one that is
  on PYTHONPATH or supports .pth files

* You can add the installation directory to the PYTHONPATH environment
  variable.  (It must then also be on PYTHONPATH whenever you run
  Python and want to use the package(s) you are installing.)

* You can set up the installation directory to support ".pth" files by
  using one of the approaches described here:

  https://setuptools.readthedocs.io/en/latest/easy_install.html#custom-installation-locations


Please make the appropriate changes for your system and try again.
```

This can be fixed by simply installing the Ubuntu virtualenv package (`python3-venv`), creating a
virtual environment (`python -m venv env`), and installing a later version of the `wheel` Python package with
`pip install wheel`. The BCC Python bindings can then be installed into the virtual environment.

## Libbpf Tools

When going into the `libbpf-tools` directory, the first error that users will encounter is
```
/bin/sh: 1: clang: not found
```

The solution to this problem is to install Clang, but the default installation of Clang on Ubuntu 18.04 is
version 6.0, which isn't new enough to compile eBPF programs. They can do:
```
sudo apt-get install clang-10
```
Then, to compile `libbpf-tools`, they'll need to get it to use `clang-10` as the compiler:
```
CLANG=clang-10 LLVM_STRIP=llvm-strip-10 make
```

But there's a problem: core_fixes.bpf.h uses a `builtin` that is only supported in Clang 12, and Ubuntu 18.04
doesn't provide a package for Clang 12. This can be solved by downloading LLVM's install script
from their website:
```
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 12
```

But then the user runs into yet another problem, this time caused by some of the headers on the system:
```
/usr/include/linux/errno.h:1:10: fatal error: 'asm/errno.h' file not found
```

This header file is provided by the `gcc-multilib` package, so can be fixed by doing:
```
sudo apt-get install gcc-multilib
```

Now the `libbpf-tools` are finally built! The final problem to tackle is at runtime: Ubuntu 18.04 ships with
a 4.15 kernel by default, and no BTF information, so we'll need to install a newer kernel. This can be fixed by
installing:
```
sudo apt-get install linux-image-5.4.0-137-generic linux-headers-5.4.0-137-generic
```
and rebooting. This newer kernel version includes BTF type information, so shouldn't give the user any
additional problems.
