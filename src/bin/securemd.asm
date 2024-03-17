org 0x0
bits 16

%define ENDL 0x0D, 0x0A


jmp short start
nop 
%include "src/tools/bpb.asm"
%include "src/kernel/index.asm"

start:
    ; print hello world message
    mov si, msg_hello
    call puts

    xor ah, ah
    int 0x16
    jmp mainloop

mainloop:
    mov si, test_txt
    mov [current_file], si
    call read_file

    call puts

.halt:
    cli
    hlt



%include "src/tools/inpututils.asm"
; inpututils just needs this
    input_proc:
        jmp start
    input_buffer: times 64 db 0

%include "src/tools/fatutils.asm"

msg_hello: db 'You are in WindsOS secure mode.', ENDL, 0
NEWLINE:                db ENDL, 0
msg_read_failed:        db 'Read from disk failed!', ENDL, 0
msg_kernel_not_found:   db 'file not found!', ENDL, 0

kernel_cluster:         dw 0
KERNEL_LOAD_SEGMENT     equ 0x2000
KERNEL_LOAD_OFFSET      equ 0

current_file:           times 11 db 0
file_buffer:            times 11 db 0
buffer: