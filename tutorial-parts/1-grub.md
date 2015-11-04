# Making a bootloader with GRUB and QEMU

I found it fairly frustrating to find my way around the [OSDEV wiki](http://wiki.osdev.org/Main_Page). So, I decided to take the things I've learned and turn them into a git-based tutorial. This is the first bit, getting some basic tooling installed, and booting a machine. This uses GRUB legacy, which is not the most recent build, nor does it support EFI - BIOS only.

This all assumes you are running on OS X. If you are using Linux, I imagine you'll not have a hard time adapting this to your system.

# Tooling

We'll need two bits of software installed to proceed. I got them installed using homebrew.

    brew install qemu
    brew install xorriso

# Making a basic GRUB floppy bootloader

This is interesting just to test out QEMU and GRUB. This can be handy for using the GRUB cli to check out machine details. It's also nice just to verify that you have a working QEMU setup. I had a really tough time building GRUB from source, and I struggled to find binaries. They actually are available via [ftp](tp://alpha.gnu.org/gnu/grub/), but I've included them here, so you can follow along without needed to leave the terminal.

Here's how you build a basic bootable floppy. Note that we need to make sure to set the block size (bs) to 512 bytes. For stage one, we're telling DD to copy only 1 block worth of data. In this case, stage1 is exactly 512 bytes. I believe this is a requirement of the BIOS floppy boot system. stage2 is positioned immediately after (seek'ing 1 block in).

    mkdir build

    dd if=bootloader/grub-0.97-binaries/stage1 of=build/grub-floppy.img bs=512 count=1
    dd if=bootloader/grub-0.97-binaries/stage2 of=build/grub-floppy.img bs=512 seek=1

    qemu-system-x86_64 -fda build/grub-floppy.img

For reasons I don't yet fully understand, QEMU complains about having to auto-detect the raw floppy format. I didn't bother looking into this too deeply, but I would love an explanation if you happen to know. I was able to silence this warning with the following:

    qemu-system-x86_64 -drive file=build/grub-floppy.img,index=0,if=floppy,format=raw

I've automated these steps using rake. To build the floppy image quickly, do this:

    rake grub:floppy

# Quick aside about QEMU's monitor

QEMU has a monitor interface that gives you a ton of tools for control and introspection of the running machine. I like to run QEMU with "-curses", to keep everything in the terminal. With that option, you can use ESC + 2 to access the monitor. You need to do this, at a minimum, quit the process. This monitor, however, has some funky behavior. It is expecting to find the TERM environment variable set to "xterm-color", but OS X's Terminal has a default of "xterm-256color". This causes the monitor to output black text. If you have a black terminal background, as I do, this is suboptimal. One possible solution is to always set TERM to be "xterm-color". Another interesting option is to run QEMU with a monitor server, using "-monitor telnet:127.0.0.1:1234,server,nowait". Or you could just run it with the QUI, that's fine too.

# Making a bootable ISO image

Ok, back to business. Now, we're going to try to make a bootable ISO. This is really useful, because it makes it possible to deliver multiple independent files to the system. It all starts by creating a root directory, where we'll lay down the bits that ultimately become the ISO9660 file system.

    mkdir -p build/isofiles/boot/grub

Next, copy in the two GRUB bootloader stages we need. I found it fairly confusing that this is called a "1.5 " stage. It turns out this is just really bad naming, and stage1 is not required here.

    cp bootloader/grub-0.97-binaries/iso9660_stage1_5 build/isofiles/boot/grub/stage1
    cp bootloader/grub-0.97-binaries/stage2 build/isofiles/boot/grub/stage2

Next, we have to create a bootable ISO. This is a fairly esoteric thing, and was the most complex part of this process by far. We need an ISO9660 filesystem. We need the interestingly-named "Rock Ridge" extensions to support grub's lowercase filenames. And, then we need equally interestinly-named El Torito extension to support bootable CD-ROMs. xorriso can create the image we need, but it is one tough tool to use.

First try: make xorriso emulate a more user-friendly iso-creation tool, like mkisofs. I was able to find a bunch of instructions on how to use mkisofs to create a bootable GRUB image.

    xorriso -as mkisofs -R -b boot/grub/stage1 -no-emul-boot -boot-load-size 4 -boot-info-table -o build/kernel.iso build/isofiles

Second try: use native commands, specifying all of the options required for a successful GRUB boot. This was really annoying to get right, partially because of the weirdness of xorriso's command syntax, and partially because of the weirdness of bootloading in general.

    xorriso -outdev build/kernel.iso -blank as_needed -map build/isofiles / -boot_image any bin_path=/boot/grub/stage1 -boot_image any emul_type=no_emulation -boot_image any boot_info_table=on -boot_image any partition_table=on -boot_image any load_size=2048 -boot_image any cat_path=/boot/boot.cat -boot_image any platform_id=00 -boot_image any id_string=grubiso -boot_image any sel_crit=00

Third try: allow xorriso to do some of the heavy-lifting, by telling it we are trying to make a GRUB boot image. I guess this is common enough that they've built this into the tool itself. Handy.

    xorriso -outdev build/kernel.iso -blank as_needed -map build/isofiles / -boot_image grub bin_path=/boot/grub/stage1

This one I like best, because it's fairly succinct, but also uses the native xorriso commands. Now, let's give this a whirl.

    qemu-system-x86_64 -boot d -cdrom build/kernel.iso

You can build the ISO with rake as well. Check it:

    rake grub:basic_iso

# Congrats!

It's not much, but there you go. GRUB running in QEMU. I found this quite difficult to get going myself. If you try it and run into problems, please open up an issue so I can have a look.

In the future, I'd love to expand this tutorial to cover EFI as well as GRUB2.
