// GB LZ77 Decode Demo by krom (Peter Lemon):
arch gb.cpu
output "LZ77Decode.gb", create

macro seek(variable offset) {
  origin offset
  base offset
}

// BANK 0 (32KB)
seek($0000); fill $8000 // Fill Bank 0 With Zero Bytes
include "LIB/GB_HEADER.ASM" // Include Header
include "LIB/GB.INC" // Include GB Definitions

seek($0150); Start:
  di // Disable Interrupts

// Decode LZ77/LZSS Data
ld hl,BGTiles+4 // HL = LZ Source Offset (Skip LZ Header)
ld de,IRAM0 // DE = Destination Address
LZLoop:
  ld a,(hl+) // A = Flag Data For Next 8 Blocks (0 = Uncompressed Byte, 1 = Compressed Bytes)
  ld b,a // B = A
  ld c,%10000000 // C = Flag Data Block Type Shifter
  LZBlockLoop:
    ld a,(BGTiles+2) // A = Data Length Hi Byte
    add a,IRAM0>>8 // A = Destination End Offset Hi Byte
    cp d // Compare Destination End Offset Hi Byte With Destination Address Hi Byte
    jr nz,LZContinue
    ld a,(BGTiles+1) // A = Destination End Offset Lo Byte
    cp e // Compare Destination End Offset Lo Byte With Destination Address Lo Byte
    jr z,LZEnd // IF (Destination Address == Destination End Offset) LZ End
  LZContinue:
    xor a // A = 0
    cp c // IF (Flag Data Block Type Shifter == 0) LZ Loop
    jr z,LZLoop
    ld a,b // A = Flag Data For Next 8 Blocks (0 = Uncompressed Byte, 1 = Compressed Bytes)
    and c // Test Block Type
    jr nz,LZDecode // IF (Block Type != 0) LZ Decode Bytes
    srl c // Shift C To Next Flag Data Block Type
    ld a,(hl+) // ELSE Copy Uncompressed Byte
    ld (de),a // Store Uncompressed Byte To Destination Address
    inc de // Destination Address++
    jr LZBlockLoop
    LZDecode:
      srl c // Shift C To Next Flag Data Block Type
      push bc // Push BC To Stack
      ld a,(hl+) // A = Number Of Bytes To Copy & Disp MSB's
      ld b,a // B = A
      ld a,(hl+) // A = Disp LSB's
      push hl // Push HL To Stack
      cpl // Complement A
      ld l,a // L = A
      ld a,b // A = B
      and $0F // A &= $0F
      cpl // Complement A
      ld h,a // H = A (HL = -Disp - 1)
      add hl,de // HL = Destination - Disp - 1
      srl b
      srl b
      srl b
      srl b // B = Number Of Bytes To Copy (Minus 3)
      inc b
      inc b
      inc b // B = Number Of Bytes To Copy
      LZCopy:
        ld a,(hl+) // A = Byte To Copy
        ld (de),a // Store Uncompressed Byte To Destination Address
        inc de // Destination Address++
        dec b // Number Of Bytes To Copy--
        jr nz,LZCopy // IF (Number Of Bytes To Copy != 0) LZ Copy Bytes
        pop hl // Pop HL Off Stack
        pop bc // Pop BC Off Stack
        jr LZBlockLoop
LZEnd:

ei // Enable Interrupts

Loop:
  halt // Power Down CPU Until An Interrupt Occurs
  jr Loop // GOTO Loop

VBlankInterrupt:
  reti // Return From Interrupt

insert BGTiles, "BG.lz" // Include LZ Compressed BG 2BPP 8x8 Tile Font Character Data (720 Bytes)