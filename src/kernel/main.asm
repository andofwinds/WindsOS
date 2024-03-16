; NOTE:
; * EXEC-CODES (in AX):
;   * 0xE1 - Execute success

org 0x0
bits 16


%define ENDL 0x0D, 0x0A


;
; FAT12 header
; 
jmp short start
nop

%include "src/tools/bpb.asm"



start:
    pop ax

    cmp ax, 0xE1    ; Success
    je .exec_success

    jmp .default

.exec_success:

    jmp mainloop

.default:
    mov si, msg_hello
    call puts

    jmp shell



; ========================================SHELL============================================
%include "src/tools/inpututils.asm"

shell:
    mov si, msg_watershell_started
    call puts
    jmp mainloop

mainloop:
    mov si, current_dir
    call puts
    mov si, prompt
    call puts

    call get_input

get_input:
    xor bx, bx
    jmp input_proc

input_proc:
    xor ah, ah
    int 0x16

    cmp al, 0x0d    ; Enter
    je check_input

    cmp al, 0x8     ; Backspace
    je backspace

    cmp al, 0x3     ; Ctrl+C
    je enter_secure

    mov ah, 0x0e    ; Anything else
    ;call to_upper_case
    int 0x10
    
    mov [input_buffer+bx], al
    inc bx

    cmp bx, 64
    je check_input

    jmp input_proc

enter_secure:
    mov si, securemode
    mov [current_file], si
    call load_file

    ret

check_input:
    inc bx
    mov byte [input_buffer+bx], 0

    cmp bx, 10
    jb .exec_fat

    mov si, NEWLINE
    call puts

    jmp mainloop

.exec_fat:

    mov si, input_buffer
    call command_to_fatname
    push si

.clear_input_buffer:
    cmp bx, 0
    je .continue

    dec bx
    mov byte [input_buffer+bx], ' '
    jmp .clear_input_buffer

.continue:

    pop si
    mov si, file_buffer
    mov [current_file], si
    call load_file

    ret 

; ========================================FAT TOOLS========================================
%include "src/tools/fatutils.asm"



%include "src/kernel/index.asm"
msg_hello:              db ENDL, ENDL, 'Welcome to Forsaken WindsOS!', ENDL, 0
msg_watershell_started: db 'WaterShell v1.3', ENDL, '<==========>', ENDL, ENDL, ENDL, 0
msg_read_failed:        db 'Read from disk failed!', ENDL, 0
msg_kernel_not_found:   db 'file not found!', ENDL, 0

NEWLINE:                db ENDL, 0

input_buffer:           times 64 db 0

current_dir:            db "~", 0
prompt:                 db ">> ", 0

kernel_cluster:         dw 0
KERNEL_LOAD_SEGMENT     equ 0x3000
KERNEL_LOAD_OFFSET      equ 0

current_file:           times 11 db 0
file_buffer:            times 11 db 0
buffer: