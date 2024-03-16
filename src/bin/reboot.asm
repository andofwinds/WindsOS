org 0x0
bits 16

%define ENDL 0x0D, 0x0A


start:
    mov si, msg_hello
    call puts


    xor ah, ah
    int 0x16
    jmp 0FFFFh:0



%include "src/tools/inpututils.asm"
    input_proc:
            jmp start
    input_buffer: times 64 db 0
    file_buffer:            times 11 db 0

msg_hello: db 'Press any key to reboot this machine....', ENDL, 0

buffer: