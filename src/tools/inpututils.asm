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
                ;   STRING IN UPPER CASE
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
    and al, 11011111b
    ret


puts:   ; IN:
        ;   DS:SI - INPUT

    ; save registers we will modify
    push si
    push ax
    push bx

.loop:
    lodsb               ; loads next character in al
    or al, al           ; verify if next character is null?
    jz .done

    mov ah, 0x0E        ; call bios interrupt
    mov bh, 0           ; set page number to 0
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si    
    ret