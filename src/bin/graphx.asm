org 0x0
bits 16

%define ENDL 0x0D, 0x0A

%include "src/kernel/index.asm"


start:
    xor ah, ah
    mov al, 0x10
    int 0x10

    mov si, msg_hello
    call puts

    mov ah, 0x0c
    mov al, 0x7
    mov dx, 20
    mov cx, 20
    xor bh, bh

    call init_workspace

    mov cx, 320
    mov dx, 175
    int 0x10

    call draw_cursor

    jmp mainloop

init_workspace:

    jmp .yfill_loop

.yfill_loop:
    cmp dx, 340
    je .after_y
    inc dx
    int 0x10

    mov cx, 20
    int 0x10

    mov cx, 620
    int 0x10

    jmp .yfill_loop

.after_y:
    mov dx, 20
    mov cx, 20

.xfill_loop:
    cmp cx, 620
    je .after_x
    inc cx
    int 0x10

    mov dx, 20
    int 0x10
    mov dx, 340
    int 0x10

    jmp .xfill_loop


.after_x:
    ret


mainloop:
    xor ah, ah
    int 0x16

    cmp ah, 0x4b    ; Left arrow
    je .left_arrow

    cmp ah, 0x48    ; Up arrow
    je .up_arrow

    cmp ah, 0x4d    ; Right arrow
    je .right_arrow

    cmp ah, 0x50    ; Down arrow
    je .down_arrow

    jmp mainloop


.left_arrow:

    sub cx, 1
    jmp write

.right_arrow:

    add cx, 1
    jmp write

.up_arrow:

    sub dx, 1
    jmp write

.down_arrow:

    add dx, 1
    jmp write

write:
    mov ah, 0x0c
    mov al, 0xFF
    xor bh, bh
    int 0x10

    jmp mainloop


draw_cursor:
    mov ah, 0x0c
    mov al, 0xFF
    xor bh, bh
    xor si, si

    add dx, 3
    sub cx, 2

.draw_x:
    cmp si, 5
    je .after_x
    int 0x10

    add dx, 4
    int 0x10

    sub dx, 4

    inc cx
    inc si

    jmp .draw_x

.after_x:

    xor si, si
    sub cx, 5

    jmp .draw_y

.draw_y:
    cmp si, 5
    je .after_y
    int 0x10

    add cx, 4
    int 0x10

    sub cx, 4

    inc dx
    inc si

    jmp .draw_y

.after_y:
    sub dx, 3
    add cx, 2

    int 0x10

    ret

%include "src/tools/inpututils.asm"
    input_proc:
            jmp start
    input_buffer: times 64 db 0

msg_hello:              db 'Forsaken GraphX', ENDL, 0
NEWLINE:                db ENDL, 0
msg_read_failed:        db 'Read from disk failed!', ENDL, 0
msg_kernel_not_found:   db 'file not found!', ENDL, 0

msg_up:                 db 'up', ENDL, 0
msg_right:              db 'right', ENDL, 0
msg_left:               db 'left', ENDL, 0
msg_down:               db 'down', ENDL, 0

kernel_cluster:         dw 0
KERNEL_LOAD_SEGMENT     equ 0x2000
KERNEL_LOAD_OFFSET      equ 0

current_file:           times 11 db 0
file_buffer:            times 11 db 0
buffer: