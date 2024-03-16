.fill_spaces:
    cmp cx, 0
    je .add_ext

    mov byte [file_buffer+bx], ' '

    dec cx
    inc bx

    jmp .fill_spaces