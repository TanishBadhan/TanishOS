; TanishOS Bootloader
; First program written for TanishOS

BITS 16
ORG 0x7C00

start:
    call clear_screen
    call move_cursor

    mov si, message
    call print_string

keyboard_loop:
    call read_key
    cmp al, 8
    je handle_backspace
    cmp al, 13
    je handle_enter
    call store_char
    call print_char
    jmp keyboard_loop

print_char:
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x0A
    mov cx, 1
    int 0x10
    ret

clear_screen:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    ret

move_cursor:
    mov ah, 0x02
    mov bh, 0
    mov dh, 10
    mov dl, 30
    int 0x10
    ret

read_key:
    mov ah, 0x00
    int 0x16
    ret

handle_backspace:
    cmp word [buffer_index], 0
    je keyboard_loop

    dec word [buffer_index]

    mov al, 8
    call print_char

    mov al, ' '
    call print_char

    mov al, 8
    call print_char

    jmp keyboard_loop

handle_enter:
    mov al, 13
    call print_char
    mov al, 10
    call print_char

    mov si, cmd_help
    call compare_string
    cmp al, 1
    je do_help

    mov si, cmd_clear
    call compare_string
    cmp al, 1
    je do_clear

    call print_buffer
    jmp handle_enter_end

do_help:
    mov si, help_text
    call print_string
    jmp handle_enter_end

do_clear:
    call clear_screen
    call move_cursor
    jmp handle_enter_end

handle_enter_end:
    mov al, 13
    call print_char
    mov al, 10
    call print_char
    mov word [buffer_index], 0
    jmp keyboard_loop

print_buffer:
    push si
    push dx

    mov al, '>'
    call print_char
    mov al, ' '
    call print_char

    mov si, 0
    mov dx, [buffer_index]
    cmp dx, 0
    je pb_done

pb_loop:
    mov al, [input_buffer + si]
    call print_char
    inc si
    dec dx
    jnz pb_loop

pb_done:
    pop dx
    pop si
    ret

store_char:
    push si
    mov si, buffer_index
    mov si, [si]
    mov [input_buffer + si], al
    inc word [buffer_index]
    pop si
    ret

compare_string:
    push si
    push di
    push cx
    mov di, 0

cs_loop:
    mov al, [si]
    cmp al, 0
    je cs_check_end
    cmp di, [buffer_index]
    jae cs_fail
    mov cl, [input_buffer + di]
    cmp al, cl
    jne cs_fail
    inc si
    inc di
    jmp cs_loop

cs_check_end:
    cmp di, [buffer_index]
    jne cs_fail
    mov al, 1
    jmp cs_done

cs_fail:
    mov al, 0

cs_done:
    pop cx
    pop di
    pop si
    ret

print_string:
    mov al, [si]
    cmp al, 0
    je done

    call print_char

    inc si
    jmp print_string

done:
    ret

message:    db "Hello", 13, 10, "Welcome to TanishOS", 0

cmd_help:   db "help", 0
cmd_clear:  db "clear", 0
help_text:  db "Commands: help, clear", 13, 10, 0

input_buffer: times 64 db 0
buffer_index: dw 0

times 510-($-$$) db 0
dw 0xAA55