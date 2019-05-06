bits 16                         ; Work in real mode with 16 bits
org 0x7C00                      ; Link everything from where the
                                ; BIOS puts the boot in memory.
global main
main:
    jmp 0000:start
    iBootDrive: db 0

%include "bios.asm"

start:
    ; DS = ES = CS
    mov ax, cs
    mov ds, ax
    mov es, ax
    ; Save the boot drive number
    mov [iBootDrive], dl
    ; Setup a stack
    cli                         ; Lock ints
    xor	ax, ax
	mov	ss, ax
    mov sp, 0x7C00
    sti                         ; Release ints

    ; From this point onwards well be using
    ; BIOS int since they are available for
    ; 16bits Real mode.

    ; Print init message
    lea si, [MSG_INIT]
    call Print

    ; Resets the disk, forcing recalibration 
    ; of the read/write head.
    mov dl, [iBootDrive]
    call ResetDisk
    or ah, ah                   ; Is 0 = OK?
    jz ErrReset

ErrReset:
    lea si, [MSG_ERESET]
    call Print
    call Reboot

MSG_INIT:   db "Simple Bootloader startup v1", 13, 10
            db "[-] Booting... ", 0
MSG_ERESET: db "FAIL", 13, 10, 0


times (510 - ($ - $$)) db 0x00  ; Fill blank spaces with 0x00 up
                                ; to the magic number zone.
    dw 0xAA55                   ; Magic Number for the BIOS