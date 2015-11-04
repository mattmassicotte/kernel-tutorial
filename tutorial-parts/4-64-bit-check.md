# Checking for 64 bit Support

In my experience, getting a 32-bit kernel going is doable. There are a fair number of good tutorials you can find online, explaining what you need to do and why. However, getting up and running with a 64-bit kernel (called long mode) is much more difficult.

This next bit is going to be all about determining if our CPU even *supports* 64-bit, also known as long mode.

# Tooling

Same ol', same ol'.

    brew install qemu
    brew install xorriso
    brew install nasm
    brew install https://raw.githubusercontent.com/Gallopsled/pwntools-binutils/master/osx/binutils-i386.rb

# The CPUID Instruction

Modern x86 processors support an instruction called CPUID. This instruction gives software a way to check for the presence of various hardware features. We're going to use it to check for long mode support. Wikipedia has an amazingly detailed [entry](https://en.wikipedia.org/wiki/CPUID) on the instruction, including examples in both C and assembly on how to use it.

First, we're going to make sure the processor even supports CPUID. This is basically unnecessary, as it's been around for a very long time. Practically speaking, every x86 processor you find will have it. But, it just feels wrong not to check. The function we'll use is the [cpuid_supported.asm](32-bit-kernel/i386/cpuid_supported.asm) file. This check uses the behavior of the EFLAGS register to determine if CPUID is supported. The details here are not particularly important, but you can read up on the implementation used over at [OSDev](http://wiki.osdev.org/CPUID) if you want to know. What is important is this bit of assembly is implemented with the C calling convention. Its signature, along with a bunch of defines useful for using CPUID can be found in [cpuid.h](32-bit-kernel/i368/cpuid.h).

# Using CPUID

Once we know that we are allowed to call CPUID, we have to do two checks. First, we need to verify that the CPUID query we want to make is allowed. Again, this is a historical problem, as more and more queries were added to CPUID, not all processors support all queries. Assuming it does support our query, we can then, finally, check for long mode. Again, I've implemented CPUID in assembly, with the standard C calling convention in [cpuid.asm](32-bit-kernel/i386/cpuid.asm).

# Building our Code

Let's build the two assembly files.

    mkdir build
    nasm -felf32 32-bit-kernel/i386/cpuid_supported.asm -o build/cpuid_supported.o
    nasm -felf32 32-bit-kernel/i386/cpuid.asm -o build/cpuid.o

The next step is to build a [tweaked version](32-bit-kernel/cpuid_kernel.c) of our kernel, that will print out the results of our CPUID checks.

    clang -target i386-linux-gnu -ffreestanding -Wall -Wextra -c 32-bit-kernel/cpuid_kernel.c -o build/kernel.o

Finally, we can build the other pieces, taken from previous tutorial steps.

    nasm -felf32 32-bit-kernel/multiboot_entry.asm -o build/multiboot_entry.o
    nasm -felf32 32-bit-kernel/multiboot_header.asm -o build/multiboot_header.o

And, now let's link it all together.

    i386-unknown-linux-gnu-ld -T 32-bit-kernel/kernel.ld -o build/kernel.bin build/multiboot_header.o build/multiboot_entry.o build/kernel.o build/cpuid.o build/cpuid_supported.o

# Running

We aren't going to bother with building an bootable ISO for this part, though it wouldn't be all that hard. We'll just run our kernel binary directly, to check out the results of our changes.

    qemu-system-i386 -kernel build/kernel.bin

Hrm, unsupported? As you might have guessed, given the qemu command we've been running, the emulated processor does not support 64 bit. However, this is easy to fix, we just need to use a different command.

    qemu-system-x86_64 -kernel build/kernel.bin

Ah ha! 64-bit support, confirmed by our CGA output!
