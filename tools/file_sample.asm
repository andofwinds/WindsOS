; A standart sample for files

org 0x0
bits 16

%define ENDL 0x0D, 0x0A


jmp short start
nop 
%include "src/tools/bpb.asm"
%include "src/kernel/index.asm"


start:


    jmp mainloop


mainloop:
    jmp halt

halt:
    cli
    hlt



%include "src/tools/inpututils.asm"
%include "src/tools/fatutils.asm"

msg_hello: db 'Hello world from [FILENAME]!', ENDL, 0
msg_loading:            db ENDL, 'Loading selected file....', ENDL, 0
msg_read_failed:        db 'Read from disk failed!', ENDL, 0
msg_kernel_not_found:   db 'file not found!', ENDL, 0

kernel_cluster:         dw 0
KERNEL_LOAD_SEGMENT     equ 0x2000
KERNEL_LOAD_OFFSET      equ 0

current_file:           times 11 db 0
file_buffer:            times 11 db 0
buffer: