bits 16
section .text
org 0x0

global main
main:
    lea si, [MSG_OK]
    call Print
    call Reboot

MSG_OK          db "OK", 13, 10, 0
MSG_REBOOT      db 13, 10, "Press any key to reboot", 0

Print:
    .PRINTLOOP:
    lodsb
    or al, al
    jz .END

    mov ax, 0x0E                        ; Teletype output subfunction
    mov bx, 9                           ; Dummy in this mode
    int 0x10                            ; Video Services Interruption
    jmp .PRINTLOOP
    .END:
    ret

Reboot:
    lea si, [MSG_REBOOT]
    call Print
    xor  ax, ax                         ; Expect key press
    int 0x16                            ; Keyboard Services interruption
    int 0x19                            ; Reboot Services interruption
    ;jmp 0FFFFh:0                        ; Reboot