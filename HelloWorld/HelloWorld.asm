// GB "Hello, World!" Text Printing demo by krom (Peter Lemon):
// 1. Loads BG Palette Data To BG Palette Register
// 2. Loads BG Tile Data To VRAM
// 3. Clears BG Map VRAM To A Space " " Character
// 4. Prints Text Characters To BG Map VRAM
arch gb.cpu
output "HelloWorld.gb", create

macro seek(variable offset) {
  origin offset
  base offset
}

// BANK 0..1 (32KB)
seek($0000); fill $8000 // Fill Bank 0..1 With Zero Bytes
include "LIB\GB_HEADER.ASM" // Include Header
include "LIB\GB.INC" // Include GB Definitions

seek($0150); Start:
  di // Disable Interrupts

// Turn Off LCD
xor a // A = 0
ldh (LCDC_REG),a // LCD Control Register ($FF40) = A

// Load BG Palette
ld a,%00001100 // A = BG Palette (White/Black)
ldh (BGP_REG),a // BG Palette Data Register ($FF47) = A

// Copy BG Tile Data To VRAM
ld bc,CHAR_RAM // BC = CHAR RAM 16-Bit Address ($8000)
ld de,BGTILES  // DE = BGTILES 16-Bit Address
ld l,$7E // L = Char Count (# Of Chars To Copy)
LoopChars:
  ld h,16  // H = Char Size
  CopyChar:
    ld a,(de) // A = Tile Byte
    inc de    // BGTILES++
    ld (bc),a // CHAR RAM = A
    inc bc    // CHAR RAM++
    dec h // Char Size--
    jr nz,CopyChar // IF (Char Size != 0) Copy Char
    dec l // Char Count--
    jr nz,LoopChars // IF (Char Count != 0) Loop Chars

// Clear BG Map Data VRAM To Space " " Character ($20)
ld bc,BG1_RAM // BC = BG1 RAM 16-Bit Map Address ($9800)
ld a,$20 // A = Space " " Character ($20)
ld d,$04 // D = Copy Count (# Of Times To Copy)
LoopMap:
  ld e,00  // e = Copy Size (256 Bytes)
  CopyMap:
    ld (bc),a // BG1 RAM = A
    inc bc    // BG1 RAM++
    dec e // Copy Size--
    jr nz,CopyMap // IF (Copy Size != 0) Copy Map
    dec d // Copy Count--
    jr nz,LoopMap // IF (Copy Count != 0) Loop Map

// Print Text Characters To BG Map VRAM
ld bc,BG1_RAM+$84 // BC = BG1 RAM 16-Bit Map Address ($9800 + $84)
ld de,HELLOWORLD  // DE = Text 16-Bit Address
ld l,13 // L = Text Count (# Of Text Chars To Copy)
CopyText:
  ld a,(de) // A = Text ASCII Byte
  inc de    // Text++
  ld (bc),a // BG1 RAM = A
  inc bc    // BG1 RAM++
  dec l // Text Count--
  jr nz,CopyText // IF (Text Count != 0) Copy Text

// Turn On LCD & BG, BG Tile Data Select = $8000
ld a,%10010001 // A = BG On Bit 0, BG Tile Data Select = $8000 Bit 4, LCD On Bit 7
ldh (LCDC_REG),a // LCD Control Register ($FF40) = A

Loop:
  jr Loop

HELLOWORLD:
  db "Hello, World!" // Hello World Text

BGTILES:
  include "Font8x8.asm" // Include BG 2BPP 8x8 Tile Font Character Data (2032 Bytes)
BGTILESEnd: