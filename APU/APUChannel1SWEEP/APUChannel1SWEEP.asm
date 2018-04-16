// GB APU Channel 1 SWEEP Demo by krom (Peter Lemon):
arch gb.cpu
output "APUChannel1SWEEP.gb", create

macro seek(variable offset) {
  origin offset
  base offset
}

// BANK 0 (32KB)
seek($0000); fill $8000 // Fill Bank 0 With Zero Bytes
include "LIB/GB_HEADER.ASM" // Include Header
include "LIB/GB.INC" // Include GB Definitions
include "LIB/GB_APU.INC"    // Include APU Definitions & Macros

seek($0150); Start:
  di // Disable Interrupts

GB_APU_INIT() // Run GB APU Initialisation Routine

// Setup Channel 1
ld a,%01110111   // Frequency Sweep: Time = 0 (Bit 4..6), Direction = Increase (Bit 3), Shift = Disable (Bit 0..2)
ldh (NR10_REG),a // Store Channel 1: Frequency Sweep ($FF10) = A
ld a,%11000000   // Wave Duty / Sound Length: Wave Duty = 75% (Bit 6..7), Sound Length = 0 (Bit 0..5)
ldh (NR11_REG),a // Store Channel 1: Wave Duty / Sound Length ($FF11) = A
ld a,%11110000   // Volume Envelope: Initial Value = 15 (Bit 4..7), Direction = Decrease (Bit 3), Sweep = 0 (Bit 0..2)
ldh (NR12_REG),a // Store Channel 1: Volume Envelope ($FF12) = A
ld a,%00010000   // Channel 1: Frequency Lo
ldh (NR13_REG),a // Store Channel 1: Frequency Lo ($FF13) = A
ld a,%10000100   // Channel 1: Set Restart Flag (Bit 7), Reset Length Flag (Bit 6), Frequency Hi (Bits 0..3)
ldh (NR14_REG),a // Store Channel 1: Restart / Length Flag, Frequency Hi ($FF14) = A

ld a,%00000001 // Enable V-Blank Interrupt
ldh (IE_REG),a // Interrupt Enable Flag Register ($FFFF) = A
ei // Enable Interrupts

ld d,0 // D = 0 (VSYNC Count)
Refresh:
  halt // Power Down CPU Until An Interrupt Occurs

  inc d // VSYNC Count++

  ld a,d
  and $1F
  jr nz,NoChange
  ld d,a

  ld hl,NR10_REG // HL = Channel 1: Frequency Sweep ($FF10)
  ld a,(hl)
  xor %00001000 // Direction = Decrease/Increase (Bit 3) 
  ld (hl),a

NoChange:
  jr Refresh

VBlankInterrupt:
  reti // Return From Interrupt