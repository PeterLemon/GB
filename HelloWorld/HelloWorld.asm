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
ld bc,BGTILES  // BC = BGTILES 16-Bit Address
ld hl,CHAR_RAM // HL = CHAR RAM 16-Bit Address ($8000)
ld d,$7E // D = Char Count (# Of Chars To Copy)
LoopChars:
  ld e,16 // E = Char Size
  CopyChar:
    ld a,(bc) // A = Tile Byte
    inc bc    // BGTILES++
    ld (hl+),a // CHAR RAM = A, CHAR RAM++
    dec e          // Char Size--
    jr nz,CopyChar // IF (Char Size != 0) Copy Char
    dec d           // Char Count--
    jr nz,LoopChars // IF (Char Count != 0) Loop Chars

// Clear BG Map Data VRAM To Space " " Character ($20)
ld hl,BG1_RAM // HL = BG1 RAM 16-Bit Map Address ($9800)
ld a,$20 // A = Space " " Character ($20)
ld b,4   // B = Copy Count (# Of Times To Copy)
LoopMap:
  ld c,0 // C = Copy Size (256 Bytes)
  CopyMap:
    ld (hl+),a // BG1 RAM = A, BG1 RAM++
    dec c         // Copy Size--
    jr nz,CopyMap // IF (Copy Size != 0) Copy Map
    dec b         // Copy Count--
    jr nz,LoopMap // IF (Copy Count != 0) Loop Map

// Print Text Characters To BG Map VRAM
ld bc,HELLOWORLD  // BC = Text 16-Bit Address
ld hl,BG1_RAM+$84 // HL = BG1 RAM 16-Bit Map Address ($9800 + $84)
ld d,13 // D = Text Count (# Of Text Chars To Copy)
CopyText:
  ld a,(bc)  // A = Text ASCII Byte
  inc bc     // Text++
  ld (hl+),a // BG1 RAM = A, BG1 RAM++
  dec d          // Text Count--
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