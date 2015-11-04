# Booting an ISO kernel

Part one of this tutorial describes how to install GRUB on an disk image. Part two puts together a basic multiboot kernel. In this tutorial, we're going to put the two things together.

# Tooling

We'll need all the tools from the previous two tutorials, but nothing new. Just in case, here are the brew commands I've used to set this up:

    brew install qemu
    brew install xorriso
    brew install nasm
    brew install https://raw.githubusercontent.com/Gallopsled/pwntools-binutils/master/osx/binutils-i386.rb

# Get GRUB going again

First thing we'll do is get a bootable ISO with just GRUB installed. From there, we'll have a good base for iterating.

    mkdir -p build/isofiles/boot/grub
    cp bootloader/grub-0.97-binaries/iso9660_stage1_5 build/isofiles/boot/grub/stage1
    cp bootloader/grub-0.97-binaries/stage2 build/isofiles/boot/grub/stage2

    xorriso -outdev build/kernel.iso -blank as_needed -map build/isofiles / -boot_image grub bin_path=/boot/grub/stage1

    (rake grub:basic_iso)

# Verify with QEMU

Fire up this ISO with QEMU, just to be sure things are working.

    qemu-system-i386 -boot d -cdrom build/kernel.iso

This should kick you into the GRUB command line interface.

# Build our Kernel

Using the same code and steps from the kernel tutorial, we're going to build a multiboot-aware ELF binary.

    nasm -felf32 32-bit-kernel/multiboot_header.asm -o build/multiboot_header.o
    nasm -felf32 32-bit-kernel/multiboot_entry.asm -o build/multiboot_entry.o
    clang -target i386-linux-gnu -ffreestanding -Wall -Wextra -c 32-bit-kernel/kernel.c -o build/basic_kernel.o
    i386-unknown-linux-gnu-ld -T 32-bit-kernel/kernel.ld -o build/kernel.bin build/multiboot_header.o build/multiboot_entry.o build/basic_kernel.o

    (rake kernel:basic:build)

And, again, let's quickly boot that up, just to verify.

    qemu-system-i386 -kernel build/kernel.bin

# Adding to our ISO9660 file system

Now, let's put it all together. First, we want to move our kernel.bin file into the directory that serves at the root for the ISO9660 file system.

    cp build/kernel.bin build/isofiles/boot/kernel.bin

Next, we need to tell GRUB what do after it has initialized the system. We do this with a GRUB-specific [menu.lst](bootloader/menu.lst) file. The file is very simple, and you may even have run into them before while setting up a Linux installation. We just need to put it in a place GRUB can find it.

    cp bootloader/menu.lst build/isofiles/boot/grub/

While we're at it, we're also going to use the modules facility in multiboot. This makes it possible to pass in arbitrary data files, and have their contents read and mapped into memory. Super handy, as otherwise, our kernel would need a driver for the CD-ROM (or boot media) and would need to be able to read ISO9660 file systems.

    cp bootloader/data_file build/isofiles/boot/

# Build our ISO

This step is now easy. We just rebuild the ISO using xorriso, just like we have in the past.

    xorriso -outdev build/kernel.iso -blank as_needed -map build/isofiles / -boot_image grub bin_path=/boot/grub/stage1

    (rake kernel:basic:build)
    (rake kernel:iso)

When we load this with QEMU, we should now expect to see our kernel output onscreen, instead of GRUBs interface.

    qemu-system-i386 -boot d -cdrom build/kernel.iso

# Expanding our kernel

Let's add just a little to our kernel, so we can see some of the multiboot info on screen. We'll be compiling a slightly different version. We then need to link, copy, and rebuild our ISO image.

    clang -target i386-linux-gnu -ffreestanding -Wall -Wextra -c 32-bit-kernel/more_multiboot_kernel.c -o build/more_multiboot_kernel.o
    i386-unknown-linux-gnu-ld -T 32-bit-kernel/kernel.ld -o build/kernel.bin build/multiboot_header.o build/multiboot_entry.o build/more_multiboot_kernel.o
    cp build/kernel.bin build/isofiles/boot/kernel.bin
    xorriso -outdev build/kernel.iso -blank as_needed -map build/isofiles / -boot_image grub bin_path=/boot/grub/stage1

    (rake kernel:more_multiboot:build)
    (rake kernel:iso)

Now, we can run it and see what's different.

    qemu-system-i386 -boot d -cdrom build/kernel.iso

There are two new interesting elements displayed. First, we see "cmdline". This is data passed from the menu.lst file's 'kernel' entry directly to the kernel as a null-terminated string. Next, we see "hello" as a module. This is actually the contents of the "data_file" file we copied in earlier. Because modules are just raw bytes, "data_file" was modified to include a null-terminator so it can be printed like a string. The modules are defined in the menu.lst file as well.

# Booting directly with QEMU

Interesting, you can actually achieve all this will QEMU's multiboot implementation as well. Check this out:

    qemu-system-i386 -kernel build/kernel.bin -initrd "bootloader/data_file" -append "hello world"

# All Done

You've produced a valid CD-ROM ISO image, which automatically boots up your kernel. Pretty impressive!

    