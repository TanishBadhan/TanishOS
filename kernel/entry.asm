[BITS 32]

global _start
extern kernel_main

_start:
    call kernel_main

.hang:
    cli
    hlt
    jmp .hang


section .note.GNU-stack noalloc noexec nowrite progbits