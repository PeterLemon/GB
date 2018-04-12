// GB APU Channel 2 Demo by krom (Peter Lemon):
arch gb.cpu
output "APUChannel2.gb", create

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

// Setup Channel 2
ld a,%11000000   // Wave Duty / Sound Length: Wave Duty = 75% (Bit 6..7), Sound Length = 0 (Bit 0..5)
ldh (NR21_REG),a // Store Channel 2: Wave Duty / Sound Length ($FF16) = A
ld a,%11110000   // Volume Envelope: Initial Value = 15 (Bit 4..7), Direction = Decrease (Bit 3), Sweep = 0 (Bit 0..2)
ldh (NR22_REG),a // Store Channel 2: Volume Envelope ($FF17) = A
ld a,%00010000   // Channel 2: Frequency Lo
ldh (NR23_REG),a // Store Channel 2: Frequency Lo ($FF18) = A
ld a,%10000100   // Channel 2: Set Restart Flag (Bit 7), Reset Length Flag (Bit 6), Frequency Hi (Bits 0..3)
ldh (NR24_REG),a // Store Channel 2: Restart / Length Flag, Frequency Hi ($FF19) = A

ld a,%00000001 // Enable V-Blank Interrupt
ldh (IE_REG),a // Interrupt Enable Flag Register ($FFFF) = A
ei // Enable Interrupts

Refresh:
  halt // Power Down CPU Until An Interrupt Occurs
  jr Refresh

VBlankInterrupt:
  reti // Return From Interrupt