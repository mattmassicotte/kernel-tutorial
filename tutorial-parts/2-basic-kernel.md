# Creating a Basic Kernel

The idea for this tutorial came from me having a fair amount of trouble following along with the [Bare Bones](http://wiki.osdev.org/Bare_Bones) example from the [OSDEV wiki](http://wiki.osdev.org/Main_Page). I did manage to get something working, but it took more effort than I would have liked. Even though I did struggle, this tutorial still borrows heavily from the work done over at OSDEV's wiki, and I doubt I would have figured this all out without it.

# Tooling

OS X is assumed throughout.

Grab qemu and the nasm assembler:

    brew install qemu
    brew install nasm
    brew install https://raw.githubusercontent.com/Gallopsled/pwntools-binutils/master/osx/binutils-i386.rb

# Quick Multiboot Primer

Booting a computer system and loading an OS is actually incredibly complicated. So, some fine folks decided to try to make a standard so the bootloader system could be truly separate the OS itself. The standard they developed is called [Multiboot](https://www.gnu.org/software/grub/manual/multiboot/multiboot.html). GRUB is a very popular multiboot-compliant bootloader.

Multiboot provides a standard way for the bootloader to find and load the kernel, as well as relay some critical machine details over. This tutorial is going to be about creating a multiboot-aware kernel and getting it running in QEMU.

I found it very challenging to experiment with a kernel and a bootloader at the same time. Luckily, QEMU has a really handy facility for booting multiboot-aware kernels directly, without the need for even creating a bootable drive image. This eliminates a ton of complexity up-front, and is a great way to get up and running faster.

# Becoming Multiboot-aware

Multiboot works by searching through a binary file for a magic number along with some data. When found, this data tells the loader that this is in fact a kernel, how to load it, and what info it wants. We're going to construct this [header](multiboot_header.asm) in assembly. This file contains some defines to improve readability, as well as a bunch of comments to help explain what's going on. It is not critical you understand everything in this file.

The second part of our multiboot support is the initial [entry point](multiboot_entry.asm) for our kernel, also in assembly. This file contains the code that the bootloader will actually call. It also contains a simple "hang" function, to halt the CPU if something goes wrong, or if our kernel entry point returns. Notably, this file also sets up a stack so we can begin executing C code. Remember, we're at a pretty low level here, so even that isn't done for us automatically.

# Building our assembly

    mkdir build

    nasm -felf32 32-bit-kernel/multiboot_header.asm -o build/multiboot_header.o
    nasm -felf32 32-bit-kernel/multiboot_entry.asm -o build/multiboot_entry.o

Or, via rake:

  rake multiboot:compile

With these pieces, we have enough to be multiboot-aware, and to setup an environment suitable for running C code.

# PoC Kernel in C

So far, every step we've done changes internal machine state in a completely silent way. The last piece we need is a [C program](kernel.c) that will provide a little feedback to prove that we're actually executing some code.

To do that, we're going to use the video card's memory-mapped text mode to print a few characters to the screen. The details here aren't super-important for now. But, if you want more info, you can check it out on the [OSDEV wiki](http://wiki.osdev.org/Text_UI).

We'll build this code using clang as a cross-compiler, which is easy:

    clang -target i386-linux-gnu -ffreestanding -Wall -Wextra -c 32-bit-kernel/kernel.c -o build/basic_kernel.o

The one bit that might look unfamiliar is the 'freestanding' flag. It tells the compiler that the programming isn't running in a typical libc-enabled environment. You can read a good explanation about it on [stack overflow](http://stackoverflow.com/questions/17692428/what-is-ffreestanding-option-in-gcc).

# A note about linking

Something I found quite foreign when working on this was the need for a [linker script](kernel.ld). Normally, linker behavior is defined via a default setup, and you never need to mess around with it. In this case, we need to exert more control over the final binary the linker produces. There are two things we need to do that the defaults don't make possible. First, we have to position that multiboot header close to the beginning. A multiboot loader will only scan so far into the binary before it will give up. Second, we need to ask the linker to position the executable at 1M.

Normally, the memory positions used by the linker are virtual addresses. In this case, the bootloader is going to be putting this executable in physical addresses because paging isn't enabled. This is problematic, because lots of hardware features are memory-mapped and we shouldn't (or can't) overwrite them. Starting at 1M is a safe place to load.

This linker script is mostly taken from the [Bare Bones](http://wiki.osdev.org/Bare_Bones) tutorial. But, be careful! There is a *ton* of stuff in ld's default script. Because this script has so much stripped out, lots of features (particularly for C++) will not work correctly.

*WARNING*: gnu-ld appears to not warn about syntax errors in linker scripts. It just happily does the wrong thing, of falls back to the default. Be extra careful.

# Actually doing the linking

    i386-unknown-linux-gnu-ld -T 32-bit-kernel/kernel.ld -o build/kernel.bin build/multiboot_header.o build/multiboot_entry.o build/basic_kernel.o

    (rake kernel:basic:build)

This produces a 32-bit ELF executable, and will be loadable by QEMU's multiboot implementation. You can verify you've built the right thing with the 'file' command

    file build/kernel.bin

You should see something about this being an ELF 32-bit executable.

# Booting it up

Running this with QEMU is a snap.

    qemu-system-i386 -kernel build/kernel.bin

It doesn't do much, but it does confirm that we're actually seeing our own code running on the machine.

# Well Done!

A real 32-bit kernel, running in supervisor mode! And, all without having to mess around with bootloaders. I'd like to, again, thanks those that contributed to OSDev.org for the help getting this going.
