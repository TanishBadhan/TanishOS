; =====================================
; TanishOS Stage 1 Bootloader
; Loads Stage 2 from sector 2
; =====================================

[BITS 16]
[ORG 0x7C00]


start:

    ; -----------------------
    ; Setup segments
    ; -----------------------

    cli

    xor ax, ax

    mov ds, ax
    mov es, ax
    mov ss, ax

    mov sp, 0x7A00

    sti


    ; -----------------------
    ; Print "1"
    ; -----------------------

    mov ah, 0x0E
    mov al, '1'
    int 0x10



    ; -----------------------
    ; Save BIOS boot drive
    ; DL contains drive number
    ; -----------------------

    mov [BOOT_DRIVE], dl



    ; -----------------------
    ; Load Stage 2
    ;
    ; Sector 2
    ; Address 0000:8000
    ; -----------------------

    mov ah, 0x02        ; BIOS read sector

    mov al, 1           ; Number of sectors

    mov ch, 0           ; Cylinder 0

    mov cl, 2           ; Sector 2

    mov dh, 0           ; Head 0

    mov dl, byte [BOOT_DRIVE]


    mov bx, 0x8000      ; Load address


    int 0x13


    ; Check BIOS error

    jc disk_error



    ; -----------------------
    ; Print "S"
    ; Stage2 loaded
    ; -----------------------

    mov ah,0x0E
    mov al,'S'
    int 0x10



    ; -----------------------
    ; Jump to Stage 2
    ; -----------------------

    mov ah,0x0E
    mov al,'J'
    int 0x10


    jmp 0x0000:0x8000



; =====================================
; Disk error handler
; =====================================

disk_error:

    mov ah,0x0E
    mov al,'E'
    int 0x10


hang:

    cli
    hlt
    jmp hang



; =====================================
; Variables
; =====================================

BOOT_DRIVE:

    db 0



; =====================================
; Boot signature
; =====================================

times 510-($-$$) db 0

dw 0xAA55