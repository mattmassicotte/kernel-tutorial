; bool cpuid(uint32_t level, uint32_t sublevel, uint32_t result[4])

section .text
global cpuid
  cpuid:
    push ebx
    push edi

    ; load our query into eax and ecx, and zero out the result registers
    mov eax, [esp+12]
    mov ecx, [esp+16]
    mov edi, [esp+20]
    xor ebx, ebx
    xor edx, edx

    cpuid

    ; results are now in eax, ebx, ecx, edx
    ; we need to copy then into the out parameter
    mov [edi], eax
    mov [edi+4], ebx
    mov [edi+8], ecx
    mov [edi+12], edx

    mov eax, 1

  epilogue:
    pop edi
    pop ebx
    ret
