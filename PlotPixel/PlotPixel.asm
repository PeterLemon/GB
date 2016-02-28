// GB Plot Pixel demo by krom (Peter Lemon):
// 1. Loads BG Palette Data To BG Palette Register
// 2. Loads BG Tile Data To VRAM
// 3. Setup 16x15 Tile Screen & Border Map
// 4. Uses Table to Plot Pixel To 16x15 Tile Screen
// 5. Joypad Direction Input Changes Pixel X/Y Value
arch gb.cpu
output "PlotPixel.gb", create

macro seek(variable offset) {
  origin offset
  base offset
}

// BANK 0 (32KB)
seek($0000); fill $8000 // Fill Bank 0 With Zero Bytes
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
ld bc,BGTiles  // BC = BG Tiles 16-Bit Address
ld hl,CHAR_RAM+$F00 // HL = CHAR RAM 16-Bit Address ($8000 + $F00)
ld d,1 // D = Tile Count (# Of Tiles To Copy)
LoopTile:
  ld e,16 // E = Tile Size
  CopyTile:
    ld a,(bc) // A = Tile Byte
    inc bc    // BGTILES++
    ld (hl+),a // CHAR RAM = A, CHAR RAM++
    dec e          // Tile Size--
    jr nz,CopyTile // IF (Tile Size != 0) Copy Tile
    dec d          // Tile Count--
    jr nz,LoopTile // IF (Tile Count != 0) Loop Tile


ld a,$F0 // A = Border Tile Number

// Fill BG Map VRAM Border Top Tiles
ld b,20 // B = Tile Count (# Of Tiles To Copy)
ld hl,BG1_RAM // HL = BG1 RAM 16-Bit Map Address ($9800)
BorderTop:
  ld (hl+),a // BG1 RAM = A, BG1 RAM++
  dec b           // Tile Count--
  jr nz,BorderTop // IF (Tile Count != 0) Border Top

// Fill BG Map VRAM Border Bottom Tiles
ld hl,BG1_RAM+$200 // HL = BG1 RAM 16-Bit Map Address ($9800 + $200)
ld c,2 // C = Border Row Count
ld de,12 // DE = End Of Row Map Increment
BorderBottomRow:
  ld b,20 // B = Tile Count (# Of Tiles To Copy)
  BorderBottom:
    ld (hl+),a // BG1 RAM = A, BG1 RAM++
    dec b              // Tile Count--
    jr nz,BorderBottom // IF (Tile Count != 0) Border Bottom
  add hl,de // BG1 RAM += 12
  dec c                 // Border Row Count--
  jr nz,BorderBottomRow // IF (Border Row Count != 0) Border Bottom Row

// Fill BG Map VRAM Border Left Tiles
ld hl,BG1_RAM+$20 // HL = BG1 RAM 16-Bit Map Address ($9800 + $20)
ld b,15 // B = Border Row Count
ld de,30 // DE = End Of Row Map Increment
BorderLeftRow:
  ld (hl+),a // BG1 RAM = A, BG1 RAM++
  ld (hl+),a // BG1 RAM = A, BG1 RAM++
  add hl,de  // BG1 RAM += 30
  dec b               // Border Row Count--
  jr nz,BorderLeftRow // IF (Border Row Count != 0) Border Left Row

// Fill BG Map VRAM Border Right Tiles
ld hl,BG1_RAM+$32 // HL = BG1 RAM 16-Bit Map Address ($9800 + $32)
ld b,15 // B = Border Row Count
ld de,30 // DE = End Of Row Map Increment
BorderRightRow:
  ld (hl+),a // BG1 RAM = A, BG1 RAM++
  ld (hl+),a // BG1 RAM = A, BG1 RAM++
  add hl,de  // BG1 RAM += 30
  dec b                // Border Row Count--
  jr nz,BorderRightRow // IF (Border Row Count != 0) Border Right Row


// Fill BG Map VRAM With 16x15 Tiles
ld a,0 // A = Reset Tile Number
ld hl,BG1_RAM+$22 // HL = BG1 RAM 16-Bit Map Address ($9800 + $22)
ld c,15  // C = Tile Row Count (# Of Tile Rows To Copy)
ld de,16 // DE = End Of Row Map Increment
CopyRow:
  ld b,16 // B = Tile Count (# Of Tiles To Copy)
  CopyMap:
    ld (hl+),a // BG1 RAM = A, BG1 RAM++
    inc a // Tile Number++
    dec b // Tile Count--
    jr nz,CopyMap // IF (Tile Count != 0) Copy Map
  add hl,de // BG1 RAM += 16
  dec c         // Tile Row Count--
  jr nz,CopyRow // IF (Tile Row Count != 0) Copy Row

// Clear BG Tile Data In VRAM
ld a,0 // A = Clear Tile Byte
ld hl,CHAR_RAM // HL = CHAR RAM 16-Bit Address ($8000)
ld d,$F0 // D = Clear Count (# Of Tiles To Clear)
LoopClear:
  ld e,16 // E = Clear Size
  ClearTile:
    ld (hl+),a // CHAR RAM = A, CHAR RAM++
    dec e           // Tile Size--
    jr nz,ClearTile // IF (Clear Size != 0) Clear Tile
    dec d           // Tile Count--
    jr nz,LoopClear // IF (Clear Count != 0) Loop Clear

// Turn On LCD & BG, BG Tile Data Select = $8000
ld a,%10010001 // A = BG On Bit 0, BG Tile Data Select = $8000 Bit 4, LCD On Bit 7
ldh (LCDC_REG),a // LCD Control Register ($FF40) = A


ld a,64 // A = Plot X
ld ($FF00 + $80),a // Load X To Memory Address $FF80

ld a,60 // A = Plot Y
ld ($FF00 + $81),a // Load Y To Memory Address $FF81

Refresh:
  // Wait V-Blank
  WaitVBlank:
    ld a,($FF00 + $44) // A = LCDC Y-Coord ($FF44)
    cp 144  // Compare Y-Coord To 144
    jr nz,WaitVBlank // IF (Y-Coord != 144) WaitVBlank


  // Plot Pixel
  ld a,($FF00 + $80) // A = X ($FF80)
  ld c,a // C = X

  and 7 // X &= 7
  sla a // X *= 4 (X * Plot Set Bit Instruction Size)
  sla a
  ld d,0
  ld e,a
  ld hl,PlotSet
  add hl,de // HL += (X & 7) * 4
  push hl // Push HL To Stack (Plot Set Bit Return Offset)

  ld a,($FF00 + $81) // A = Y ($FF81)
  ld b,a // B = Y
  sla c  // X *= 2 (BC = Offset)
  ld hl,PlotTable // HL = Plot Table 16-Bit Address
  add hl,bc // HL += Offset

  ld a,(hl+) // Load VRAM Table Offset
  ld b,a
  ld a,(hl)
  ld h,a
  ld l,b // HL = VRAM Table Offset

  ret // Plot Pixel
  PlotSet: // Plot Set Bit Instructions (4 Bytes Each)
    set 7,(hl) // Set Bit 7 In 8-Bit Value Of Address In Register HL (X & 7 = 0)
    jr PlotEnd
    set 6,(hl) // Set Bit 6 In 8-Bit Value Of Address In Register HL (X & 7 = 1)
    jr PlotEnd
    set 5,(hl) // Set Bit 5 In 8-Bit Value Of Address In Register HL (X & 7 = 2)
    jr PlotEnd
    set 4,(hl) // Set Bit 4 In 8-Bit Value Of Address In Register HL (X & 7 = 3)
    jr PlotEnd
    set 3,(hl) // Set Bit 3 In 8-Bit Value Of Address In Register HL (X & 7 = 4)
    jr PlotEnd
    set 2,(hl) // Set Bit 2 In 8-Bit Value Of Address In Register HL (X & 7 = 5)
    jr PlotEnd
    set 1,(hl) // Set Bit 1 In 8-Bit Value Of Address In Register HL (X & 7 = 6)
    jr PlotEnd
    set 0,(hl) // Set Bit 0 In 8-Bit Value Of Address In Register HL (X & 7 = 7)
  PlotEnd:


  // Test Joypad
  ld hl,IO_PORT_REG // HL = Hardware I/O Port Register ($FF00)
  res 4,(hl) // Reset Bit 4 (Select Direction Keys)
  set 5,(hl) // Set Bit 5 (De-Select Button Keys)
  ld b,(hl) // B = Joypad Direction Keys
  ld hl,$FF80 // HL = X/Y Mem
  JoyRight:
    bit 0,b // Test Right
    jr nz,JoyLeft
    inc (hl) // X++
    ld a,128 // Clamp X Positive
    cp (hl)  // Compare X To 128
    jr nz,JoyUp // IF (X != 128) Skip
    dec (hl)    // ELSE X--
    jr JoyUp
  JoyLeft:
    bit 1,b // Test Left
    jr nz,JoyUp
    dec (hl) // X--
    ld a,-1  // Clamp X Negative
    cp (hl)  // Compare X To -1
    jr nz,JoyUp // IF (X != -1) Skip
    inc (hl)    // ELSE X++
  JoyUp:
    inc l
    bit 2,b // Test Up
    jr nz,JoyDown
    dec (hl) // Y--
    ld a,-1  // Clamp Y Negative
    cp (hl)  // Compare Y To -1
    jr nz,JoyEnd // IF (Y != -1) Skip
    inc (hl)     // ELSE Y++
    jr JoyEnd
  JoyDown:
    bit 3,b // Test Down
    jr nz,JoyEnd
    inc (hl) // Y++
    ld a,120 // Clamp Y Positive
    cp (hl)  // Compare Y To 120
    jr nz,JoyEnd // IF (Y != 120) Skip
    dec (hl)     // ELSE Y--
  JoyEnd:

  jp Refresh

BGTiles:
  db %11111111 // Include BG 2BPP 8x8 BG Tile Data (16 Bytes)
  db %00000000
  db %11111111
  db %00000000
  db %11111111
  db %00000000
  db %11111111
  db %00000000
  db %11111111
  db %00000000
  db %11111111
  db %00000000
  db %11111111
  db %00000000
  db %11111111
  db %00000000

PlotTable: // Per Pixel VRAM Offset Table (16x15 Tiles = 128x120 Pixels)
  define row(0)
  define offset($8000)

  while {row} < 15 {
    define y(0)

    while {y} < 8 {
      define x(0)

      while {x} < 128 {
        dw {offset}
        evaluate x({x} + 1)
        if {x} % 8 == 0 {
          evaluate offset({offset} + $10)
        }
      }

      evaluate offset({offset} - $FE)
      evaluate y({y} + 1)
    }

    evaluate row({row} + 1)
    evaluate offset($8000 + ({row} << 8))
  }