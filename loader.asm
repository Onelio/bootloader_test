bits 16                         ; Work in real mode with 16 bits
org 0x7C00                      ; Link everything from where the
                                ; BIOS puts the boot in memory.
global main
main:
    jmp 0000:START

%include "bootsector.asm"
%include "bios.asm"

START:
    ; DS = ES = CS
    mov ax, cs
    mov ds, ax
    mov es, ax
    ; Setup a stack
    cli                         ; Lock-in BIOS interruptions
    xor	ax, ax
	mov	ss, ax
    mov sp, 0x7C00
    sti                         ; Release BIOS interruptions

    ; From this point onwards we'll request
    ; BIOS int since they are available for
    ; 16bits Real mode.

    ; Print init message
    lea si, [MSG_INIT]
    call Print

    ; Store Sectors per cluster in cx
    mov cx, WORD [SectorsPerCluster]

    ; Compute location of Data Area offset
    ; and store it in memory
    mov al, BYTE [TotalFATs]
    mul WORD [BigSectorsPerFAT] ; Get calc Sectors per FAT to ax
    add ax, WORD [ReservedSectors]
    mov WORD [iDataSector], ax  ; Store result offset in memory




    ; Print boot message
    lea si, [MSG_BOOT]
    call Print

    ; Read first data Cluster into memory
    mov ax, WORD [RootDirectoryStart]
    call ClusterLBA
    ; Copy first data Cluster above boot
    mov bx, 0x0200              ; 0x0200 (512d)
    call ReadSectors

    lea si, [MSG_OK]
    call Print




    ; Print kernel finding message
    lea si, [MSG_FINDBOOT]
    call Print

    ; Point Index register to 1st File Entry
    mov di, 0x0200 + 0x20       ; (512d + 32d)

    ; Point to the offset where the file 
    ; location information contains.
    mov dx, WORD [di + 0x001A]  ; 0x001A (26d)
    mov WORD [iCluster], dx                  

	; Set up the segments where the kernel 
    ; needs to be loaded.
	mov ax, 0100h               
    ; Set ES:BX = 0100:0000
    mov es, ax          
    mov bx, 0           
	   
	; Read the cluster which contains the kernel
    mov cx, 0x0008	
    mov ax, WORD[iCluster]
    call ClusterLBA
    call ReadSectors

    lea si, [MSG_OK]
    call Print

    ; Jump to the location where kernel was load
	push WORD 0x0100
    push WORD 0x0000
    retf

	; An error happened if this part is executed
ErrReset:
    lea si, [MSG_ERROR]
    call Print
    call Reboot

MSG_INIT        db "Simple Bootloader startup v1", 13, 10, 0
MSG_BOOT        db "[-] Booting... ", 0
MSG_FINDBOOT    db "[-] Finding bootable kernel... ", 0
MSG_OK          db "OK", 13, 10, 0
MSG_ERROR       db "FAIL", 13, 10, 0
MSG_REBOOT      db 13, 10, "Press any key to reboot", 0

iAbsoluteSector db 0x00
iAbsoluteHead   db 0x00
iAbsoluteTrack  db 0x00

iCluster        dw 0x0000
iDataSector     dw 0x0000

times (510 - ($ - $$)) db 0x00  ; Fill blank spaces with 0x00 up
                                ; to the magic number zone.
    dw 0xAA55                   ; Magic Number for the BIOS