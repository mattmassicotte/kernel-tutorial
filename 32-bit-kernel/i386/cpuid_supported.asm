; adapted from: http://wiki.osdev.org/CPUID

section .text
global cpuid_supported
  cpuid_supported:
    pushfd                      ; Save EFLAGS to stack twice
    pushfd
    xor dword [esp], 0x00200000 ; Invert the ID bit in stored EFLAGS
    popfd                       ; Load stored EFLAGS (with ID bit inverted)
    pushfd                      ; Store EFLAGS again
    pop eax                     ; eax = modified EFLAGS
    xor eax, [esp]              ; eax = whichever bits were changed
    popfd                       ; Restore original EFLAGS
    and eax, 0x00200000
    cmp eax, 0x00200000         ; check if the bit it set
    jne _unsupported
    mov eax, 1                  ; set eax to 1 and return
    ret

    _unsupported:
    xor eax, eax                ; set eax to 0 and return
    ret
