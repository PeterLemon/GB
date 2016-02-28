//===========
// GB Header
//===========
// ENTRY POINT ($0100..$0103) 
seek($0100)
nop
jp Start // Jump To Entry Point

// NINTENDO LOGO ($0104..$0133)
db $CE, $ED, $66, $66, $CC, $0D, $00, $0B, $03, $73, $00, $83, $00, $0C, $00, $0D
db $00, $08, $11, $1F, $88, $89, $00, $0E, $DC, $CC, $6E, $E6, $DD, $DD, $D9, $99
db $BB, $BB, $67, $63, $6E, $0E, $EC, $CC, $DD, $DC, $99, $9F, $BB, $B9, $33, $3E

// PROGRAM TITLE (11 Byte ASCII String, Use Spaces For Unused Bytes) ($0134..$013E)
db "PLOT PIXEL "
// "12345678901"

// MANUFACTURER CODE (4 Byte Upper-Case ASCII String) ($013F..$0142)
db "KROM"
// "1234"

// CGB FLAG ($0143)
db $00
// $00 = Game Does Not Support CGB Functions & Works On Old Gameboys
// $80 = Game Supports CGB Functions & Works On Old Gameboys
// $C0 = Game Works On CGB Only

// NEW LICENSEE CODE (2 Byte ASCII String) ($0144..$0145)
db "LC"
// "12"

// SGB FLAG ($0146)
db $00
// $00 = No SGB Functions (Normal Gameboy / CGB Only Game)
// $03 = Game Supports SGB Functions

// CARTRIDGE TYPE ($0147)
db $00
// $00 = ROM ONLY               $13 = MBC3+RAM+BATTERY
// $01 = MBC1                   $15 = MBC4
// $02 = MBC1+RAM               $16 = MBC4+RAM
// $03 = MBC1+RAM+BATTERY       $17 = MBC4+RAM+BATTERY
// $05 = MBC2                   $19 = MBC5
// $06 = MBC2+BATTERY           $1A = MBC5+RAM
// $08 = ROM+RAM                $1B = MBC5+RAM+BATTERY
// $09 = ROM+RAM+BATTERY        $1C = MBC5+RUMBLE
// $0B = MMM01                  $1D = MBC5+RUMBLE+RAM
// $0C = MMM01+RAM              $1E = MBC5+RUMBLE+RAM+BATTERY
// $0D = MMM01+RAM+BATTERY      $FC = POCKET CAMERA
// $0F = MBC3+TIMER+BATTERY     $FD = BANDAI TAMA5
// $10 = MBC3+TIMER+RAM+BATTERY $FE = HuC3
// $11 = MBC3                   $FF = HuC1+RAM+BATTERY
// $12 = MBC3+RAM

// ROM SIZE ($0148)
db $00
// $00 =  32KB (No ROM Banking) $52 = 1.1MB ( 72 Banks)
// $01 =  64KB (  4 Banks)      $53 = 1.2MB ( 80 Banks)
// $02 = 128KB (  8 Banks)      $54 = 1.5MB ( 96 Banks)
// $03 = 256KB ( 16 Banks)
// $04 = 512KB ( 32 Banks)
// $05 =   1MB ( 64 Banks) - Only  63 Banks Used By MBC1
// $06 =   2MB (128 Banks) - Only 125 Banks Used By MBC1
// $07 =   4MB (256 Banks)

// RAM SIZE ($0149)
db $00
// $00 = None,  $03 =  32 KB ( 4 * 8KB Banks)
// $01 = 2 KB,  $04 = 128 KB (16 * 8KB Banks)
// $02 = 8 KB,  $05 =  64 KB ( 8 * 8KB Banks)

// DESTINATION CODE ($014A)
db $00
// $00 = Japanese, $01 = Non-Japanese

// OLD LICENSEE CODE (Specifies Company/Publisher Code In Range $00..$FF) ($014B)
db $00
// $33 = New License Code ($0144..$0145) Is Used (Required For Super GameBoy)

// MASK ROM VERSION NUMBER ($014C) 
db $00
// $00 = 1.00, $01 = 1.01

// HEADER CHECKSUM (8-Bit Checksum Across Cartridge Header Bytes $0134..$014C) ($014D)
db $00
// x=0                  ; Checksum Calculation
// FOR i=$0134 TO $014C ; GAME WON'T WORK IF Incorrect
//   x -= MEM[i]-1      ; Lo 8-Bits Of Result Must Be The Value In This Entry
//   NEXT

// GLOBAL CHECKSUM (16-Bit Checksum (Upper Byte First) Across Whole Cartridge ROM) ($014E..$014F) 
db "CS"
// Produced By Adding All Bytes Of Cartridge ROM (Except For These 2 Checksum Bytes)
// GAME WILL WORK IF Incorrect (The Gameboy Does Not Verify This Checksum)