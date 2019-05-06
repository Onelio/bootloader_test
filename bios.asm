Print:
    lodsb
    or al, al
    jz Print_end

    mov ah, 0x0E
    mov bx, 9
    int 0x10
    jmp Print
Print_end:
    ret

ResetDisk:
    mov ah, 0
    int 0x13
    ret

Reboot:
    lea si, [MSG_REBOOT]
    call Print
    mov ah, 0
    int 0x16
    jmp 0FFFFh:0 
    
MSG_REBOOT: db 13, 10, "Press any key to reboot", 0
