; defines for our stack, and for a return value from the multiboot
; bootloader
STACK_SIZE equ 16384
MULTIBOOT_OUTPUT_MAGIC equ 0x2BADB002

; define the "kernel_main" function, which this code is going to call
extern kernel_main

; this code needs to be in the .text section
section .text

; Define a simple function that will sleep the processor in a loop. This
; is just here for a fallback, in case we run into trouble
hang:
.hlt_loop:
  hlt           ; sleep processsor
  jmp .hlt_loop ; if we wake up for some reason, sleep again

; the multiboot bootloader will jump into our code at the "_start" symbol
global _start
  _start:

  ; a compliant bootloader will put this value into eax. Let's verify that.
  cmp eax, MULTIBOOT_OUTPUT_MAGIC
  jne hang

  ; at this point, we'll need a stack before we can call into C code. We do
  ; this by loading a pointer to some memory we've reserved. Remember, the
  ; stack grows from high memory to low.
  mov esp, stack + STACK_SIZE

  ; the bootloader will also give a pointer to the multiboot_info structure
  ; in ebx. There's lots of stuff in there we need, so we want to get that
  ; into kernel_main. Do this by following the cdecl calling convention and
  ; pushing our arguments onto the stack.
  push ebx
  call kernel_main

  ; we shouldn't get here, but if we do, hang
  call hang

; allocate a stack, to be positioned by the linker in the bss section
section .bss
stack:
  resb STACK_SIZE ; reserve STACK_SIZE bytes
