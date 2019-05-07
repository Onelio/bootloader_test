;;; BPB (BIOS Parameter Block) FAT32
;
; Some parameters may be initialized
; at runtime.
     OEM_ID                db 		"OneOS1.1"     ; OS ID String (No particular use)
     BytesPerSector        dw 		0x0200         ; Bytes per Sector (512 Little-Endian)
     SectorsPerCluster     db 		0x08           ; Sectors per Cluster (1 up to 128)
     ReservedSectors       dw 		0x0020         ; Reserved Sectors + Boot one (20h in FAT32)
     TotalFATs             db 		0x02           ; FAT(File Allocation Table) copies (2 or +)
     MaxRootEntries        dw 		0x0000         ; Entries in Root Dir (FAT32 not used -> 0h)
     NumberOfSectors       dw 		0x0000         ; Total num of sectors if below 65535(32 MB)
     MediaDescriptor       db 		0xF8           ; Media Descriptor (Type F8 -> Any)
     SectorsPerFAT         dw 		0x0000         ; Sectors per FAT (0 in FAT32, used other)
     SectorsPerTrack       dw 		0x003D         ; Sectors per Track
     SectorsPerHead        dw 		0x0002         ; Sectors per Head
     HiddenSectors         dd 		0x00000000     ; Number of Hidden Sectors from beginning
     TotalSectors     	  dd 		0x00FE3B1F     ; Total num of sectors if over 65535 (32 MB)
     BigSectorsPerFAT      dd 		0x00000778     ; Sectors per FAT (used instead in FAT32)
     Flags                 dw 		0x0000         ; Not relevant, used to freeze FAT copies
     FSVersion             dw 		0x0000         ; Indicates the version of the File System
     RootDirectoryStart    dd 		0x00000002     ; Number of first Cluster for Root Directory
     FSInfoSector          dw 		0x0001         ; Sector number for File System Info Sector
     BackupBootSector      dw 		0x0006         ; Sector number for backup copy of Boot one

TIMES 12 DB 0 ; jump to next offset

     DriveNumber           db 		0x00           ; Indicates the Physical Drive Number
     ReservedByte          db   	     0x00           ; Reserved
     Signature             db 		0x29           ; Extended Boot Signature
     VolumeID              dd 		0xFFFFFFFF     ; Act as the serial number of the drive
     VolumeLabel           db 		"OneOS  BOOT"  ; Label name of the drive
     SystemID              db 		"FAT32   "     ; Indicates FAT File System type

; len(FAT) in sectors = TotalFats * BigSectorsPerFat
; Pos of the beginning of Data sectors = len(FAT) + Reserved Sectors
; With that we can actually find the Data Area which appears like

; Boot Sector(512 bytes) || Reserved Sectors || FAT || __DATA AREA__