; define some constants used to tell the bootloader what we want done
MULTIBOOT_ALIGN      equ 1 << 0 ; page align our kernel in memory
MULTIBOOT_MEMORY_MAP equ 1 << 1 ; provide us with a memory map

; setup a single value that represents all of these bit flags
MULTIBOOT_FLAGS      equ MULTIBOOT_ALIGN | MULTIBOOT_MEMORY_MAP

; define the multiboot magic value, which the bootloader will scan through our binary to find
MULTIBOOT_INPUT_MAGIC  equ 0x1BADB002

; define the checksum value
; MULTIBOOT_CHECKSUM + MULTIBOOT_FLAGS + MULTIBOOT_INPUT_MAGIC must equal 0
MULTIBOOT_CHECKSUM    equ -(MULTIBOOT_INPUT_MAGIC + MULTIBOOT_FLAGS)

; Define a section in the executable, and write out three 32-bit values
; (double-words, dd). Make sure to align these to a 4 byte boundary.
section .multiboot
align 4
  dd MULTIBOOT_INPUT_MAGIC
  dd MULTIBOOT_FLAGS
  dd MULTIBOOT_CHECKSUM
