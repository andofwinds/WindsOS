org 0x0
bits 16

%define ENDL 0x0D, 0x0A


jmp short start
nop

%include "src/tools/bpb.asm"
%include "src/kernel/index.asm"

start:
    mov si, msg_hello
    call puts

.key_wait_loop:
    xor ah, ah
    int 0x16

    cmp al, 0x0d
    je mainloop

    cmp al, 0x3
    je cancel

    jmp .key_wait_loop

cancel:
    mov si, kernel
    mov [current_file], si
    mov ax, 0xE1
    push ax
    jmp load_file

mainloop:
    jmp 0FFFFh:0



%include "src/tools/fatutils.asm"
%include "src/tools/inpututils.asm"
    input_proc:
            jmp start
    input_buffer: times 64 db 0



msg_hello: db ENDL, 'Press [RETURN] to reboot this machine. [Ctrl+C] to cancel....', ENDL, 0
NEWLINE:                db ENDL, 0
msg_read_failed:        db 'Read from disk failed!', ENDL, 0
msg_kernel_not_found:   db 'file not found!', ENDL, 0
msg_exec_success:       db 'Program was executed successfully!', ENDL, 0

kernel_cluster:         dw 0
KERNEL_LOAD_SEGMENT     equ 0x2000
KERNEL_LOAD_OFFSET      equ 0

current_file:           times 11 db 0
file_buffer:            times 11 db 0
buffer:
buffer: