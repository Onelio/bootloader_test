; PROCEDURE Print
; Print Text to screen using BIOS int 0x10 in Real Mode
; (lea si, [MSG])
Print:
    .PRINTLOOP:
    lodsb
    or al, al
    jz .END

    mov ah, 0x0E                        ; Teletype output subfunction
    mov bx, 9                           ; Dummy in this mode
    int 0x10                            ; Video Services Interruption
    jmp .PRINTLOOP
    .END:
    ret

; PROCEDURE ClusterLBA
; Convert(ax) FAT cluster into LBA addressing scheme
; FileStartSector = ((X − 2) * SectorsPerCluster(0x08))
ClusterLBA:
    sub ax, 0x0002                      ; Zero base cluster number
    xor cx, cx
    mov cl, BYTE [SectorsPerCluster]    ; Convert byte to word
    mul cx
    add ax, WORD [iDataSector]          ; Base data sector
    ret

; PROCEDURE LBACHS
; Convert(ax) LBA addressing scheme to CHS addressing scheme
; absolute sector = (logical sector / sectors per track) + 1
; absolute head   = (logical sector / sectors per track) MOD number of heads
; absolute track  = logical sector / (sectors per track * number of heads)
LBACHS:
    xor dx, dx                          ; Prepare dx:ax for operation
    div WORD [SectorsPerTrack]          ; Calculate div
    inc dl                              ; Adjust for sector 0
    mov BYTE [iAbsoluteSector], dl
    xor dx, dx                          ; Prepare dx:ax for operation
    div WORD [SectorsPerHead]           ; Calculate div
    mov BYTE [iAbsoluteHead], dl
    mov BYTE [iAbsoluteTrack], al
    ret

; PROCEDURE ReadSectors
; Reads cx sectors from disk starting at ax into
; memory location es:bx
ReadSectors:
    .SECTORMAIN:
    mov di, 0x0005                      ; Five retries for error

    .SECTORLOOP:                        ; TODO: Remove unnecessary push and pops
    push ax
    push bx
    push cx
    call LBACHS
    mov ah, 0x02                        ; BIOS Read Sectors From Drive
    mov al, 0x01                        ; Number to read (1)
    mov ch, BYTE [iAbsoluteTrack]
    mov cl, BYTE [iAbsoluteSector]
    mov dh, BYTE [iAbsoluteHead]
    mov dl, BYTE [DriveNumber]
    int 0x13                            ; Disk Services interruption
    jnc .SECTORSUCCESS
    call ResetDisk                      ; In case of failure retry
    dec di                              ; Decrement error counter
    pop cx
    pop bx
    pop ax
    jnz .SECTORLOOP                     ; Attempt to read again (not zero)
    call ErrReset                       ; Every read attempt failed, reboot

    .SECTORSUCCESS:
    pop cx
    pop bx
    pop ax
    add bx, WORD [BytesPerSector]       ; Queue next buffer
    inc ax                              ; Queue next sector
    loop .SECTORMAIN                    ; Decrement cx and repeat if not 0
    ret

ResetDisk:
    xor  ax, ax                         ; Reset Disk Drives
    int 0x13                            ; Disk Services interruption
    ret

Reboot:
    lea si, [MSG_REBOOT]
    call Print
    xor  ax, ax                         ; Expect key press
    int 0x16                            ; Keyboard Services interruption
    int 0x19                            ; Reboot Services interruption
    ;jmp 0FFFFh:0                        ; Reboot
