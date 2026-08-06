; =====================================
; TanishOS Stage 2 Bootloader
; Loads Kernel
; Real Mode -> Protected Mode
; =====================================

[BITS 16]
[ORG 0x8000]


stage2_start:

    cli

    xor ax,ax

    mov ds,ax
    mov es,ax
    mov ss,ax

    mov sp,0x9000


    ; Save BIOS boot drive
    mov [BOOT_DRIVE],dl

    sti



; ------------------------------------
; Print 2
; ------------------------------------

    mov ah,0x0E
    mov al,'2'
    int 0x10



; ------------------------------------
; Enable A20
; ------------------------------------

    call enable_a20


    mov ah,0x0E
    mov al,'A'
    int 0x10



; ------------------------------------
; Load Kernel
;
; Kernel location:
; Sector 3
;
; Destination:
; 1000:0000
; Physical 0x10000
; ------------------------------------


load_kernel:


    ; Reset floppy

    mov ah,0x00
    mov dl,[BOOT_DRIVE]
    int 0x13



    ; Destination address 1000:0000

    mov ax,0x1000
    mov es,ax

    xor bx,bx



    ; BIOS read sector 3

    mov ah,0x02
    mov al,1

    mov ch,0
    mov cl,3
    mov dh,0

    mov dl,[BOOT_DRIVE]


    int 0x13


    jc disk_error



; Kernel loaded successfully

    mov ah,0x0E
    mov al,'K'
    int 0x10




; ------------------------------------
; Load GDT
; ------------------------------------


    xor ax,ax
    mov ds,ax


    lgdt [gdt_descriptor]


    mov ah,0x0E
    mov al,'G'
    int 0x10




; ------------------------------------
; Enter Protected Mode
; ------------------------------------


    cli


    mov eax,cr0

    or eax,1

    mov cr0,eax



; Far jump
; CS = 0x08


    db 0x66
    db 0xEA

    dd protected_mode

    dw 0x08




; =====================================
; Enable A20
; =====================================


enable_a20:

    in al,0x92

    or al,00000010b

    out 0x92,al

    ret





; =====================================
; Disk Error
; =====================================


disk_error:


    mov ah,0x0E
    mov al,'E'
    int 0x10


error_hang:

    cli
    hlt
    jmp error_hang





; =====================================
; Boot drive variable
; =====================================

BOOT_DRIVE:

    db 0





; =====================================
; Global Descriptor Table
; =====================================

%include "boot/gdt.asm"





; =====================================
; Protected Mode
; =====================================


[BITS 32]


protected_mode:


    mov ax,0x10


    mov ds,ax
    mov es,ax
    mov fs,ax
    mov gs,ax
    mov ss,ax



    mov esp,0x90000


; ------------------------------------
; Jump to kernel
; ------------------------------------

call 0x10000



; ------------------------------------
; Stop
; ------------------------------------


pm_hang:

    cli
    hlt
    jmp pm_hang