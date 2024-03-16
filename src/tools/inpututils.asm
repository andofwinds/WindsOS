backspace:
    cmp bx, 0
    je input_proc
    mov ah, 0x0e
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x8
    int 0x10
    dec bx
    mov byte [input_buffer+bx], 0
    jmp input_proc

to_upper_case:  ; IN:
                ;   AL - CHAR
                ; OUT:
                ;   AL - CHAR IN UPPER CASE
    push ax
    mov ah, 0x61
    cmp al, ah
    jae .gate2

    pop ax
    ret

.gate2:
    mov ah, 0x7b
    cmp al, ah
    jb .set_val

    pop ax
    ret

.set_val
    pop ax
    sub ax, 32
    ret


puts:   ; IN:
        ;   DS:SI - INPUT
        ;   DL - Color

    ; save registers we will modify
    push si
    push ax
    push bx
    push dx

.loop:
    lodsb               ; loads next character in al
    or al, al           ; verify if next character is null?
    jz .done

    mov bl, 0xFF
    mov ah, 0x0E        ; call bios interrupt
    mov bh, 0           ; set page number to 0
    int 0x10

    jmp .loop

.done:
    pop dx
    pop bx
    pop ax
    pop si    
    ret

puts_color:     ; IN:
                ;   DS:SI - INPUT
                ;   DL - Color

    ; save registers we will modify
    push si
    push ax
    push bx
    push dx

.loop:
    lodsb               ; loads next character in al
    or al, al           ; verify if next character is null?
    jz .done

    mov bl, dl
    mov ah, 0x0E        ; call bios interrupt
    mov bh, 0           ; set page number to 0
    int 0x10

    jmp .loop

.done:
    pop dx
    pop bx
    pop ax
    pop si    
    ret


command_to_fatname: ; IN:
                    ;   SI - Command (NNNNNNNN/nnnnnnnn)
                    ; OUT:
                    ;   [CURRENT_FILE] - Filename (NNNNNNNNEEE)


    push ax
    push bx
    push cx
    push dx

    xor cx, cx
    xor bx, bx

    jmp .clear_cycle

.clear_cycle:
    cmp bx, 11
    je .after_clear

    mov byte [file_buffer+bx], ' '

    inc bx
    jmp .clear_cycle

.after_clear:


    mov bx, 0
    mov dx, 0

.loop:
    lodsb
    or al, al
    jz .done

    ;push ax
        call to_upper_case
        mov byte [file_buffer+bx], al
    ;pop ax

    ;push bx
    ;    add bx, 3
    ;    mov byte [file_buffer+bx], 0
    ;pop bx

    inc bx
    jmp .loop


.done:
    ;mov byte [file_buffer+bx], 0

    mov cx, 8
    sub cx, bx

.fill_spaces:
    cmp cx, 0
    je .add_ext

    mov byte [file_buffer+bx], ' '

    dec cx
    inc bx

    jmp .fill_spaces

.add_ext:   ; I'm too lazy to add another cycle :)
    ;mov dx, 'B'
    mov byte [file_buffer+bx], 'B'
    inc bx
    ;mov dx, 'I'
    mov byte [file_buffer+bx], 'I'
    inc bx
    ;mov dx, 'N'
    mov byte [file_buffer+bx], 'N'
    inc bx
    ;mov dx, 0
    mov byte [file_buffer+bx], 0


.return:

    pop dx
    pop cx
    pop bx
    pop ax

    ret