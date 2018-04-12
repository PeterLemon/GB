// GB APU Channel 3 Demo by krom (Peter Lemon):
arch gb.cpu
output "APUChannel3.gb", create

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

// Setup Channel 3
ld a,%10000000   // On/Off: Channel 3 On (Bit 7)
ldh (NR30_REG),a // Store Channel 3: On/Off ($FF1A) = A
ld a,%00000000   // Sound Length: Sound Length = 0 (Bit 0..7)
ldh (NR31_REG),a // Store Channel 3: Sound Length ($FF1B) = A
ld a,%00100000   // Output Level: 100% Volume (Bit 5..6)
ldh (NR32_REG),a // Store Channel 3: Output Level ($FF1C) = A

// Fill FF30..FF3F - Channel 3 Wave Pattern RAM (Square Wave: 50% Wave Duty)
ld a,$FF // A = Unsigned 4-Bit Sample A (Bit 4..7), Unsigned 4-Bit Sample B (Bit 0..3)
ldh (AUD3WAVERAM+0),a // Store Channel 3: Wave Pattern RAM ($FF30) = A
ldh (AUD3WAVERAM+1),a // Store Channel 3: Wave Pattern RAM ($FF31) = A
ldh (AUD3WAVERAM+2),a // Store Channel 3: Wave Pattern RAM ($FF32) = A
ldh (AUD3WAVERAM+3),a // Store Channel 3: Wave Pattern RAM ($FF33) = A
ldh (AUD3WAVERAM+4),a // Store Channel 3: Wave Pattern RAM ($FF34) = A
ldh (AUD3WAVERAM+5),a // Store Channel 3: Wave Pattern RAM ($FF35) = A
ldh (AUD3WAVERAM+6),a // Store Channel 3: Wave Pattern RAM ($FF36) = A
ldh (AUD3WAVERAM+7),a // Store Channel 3: Wave Pattern RAM ($FF37) = A
ld a,$00 // A = Unsigned 4-Bit Sample A (Bit 4..7), Unsigned 4-Bit Sample B (Bit 0..3)
ldh (AUD3WAVERAM+8),a // Store Channel 3: Wave Pattern RAM ($FF38) = A
ldh (AUD3WAVERAM+9),a // Store Channel 3: Wave Pattern RAM ($FF39) = A
ldh (AUD3WAVERAM+10),a // Store Channel 3: Wave Pattern RAM ($FF3A) = A
ldh (AUD3WAVERAM+11),a // Store Channel 3: Wave Pattern RAM ($FF3B) = A
ldh (AUD3WAVERAM+12),a // Store Channel 3: Wave Pattern RAM ($FF3C) = A
ldh (AUD3WAVERAM+13),a // Store Channel 3: Wave Pattern RAM ($FF3D) = A
ldh (AUD3WAVERAM+14),a // Store Channel 3: Wave Pattern RAM ($FF3E) = A
ldh (AUD3WAVERAM+15),a // Store Channel 3: Wave Pattern RAM ($FF3F) = A

ld a,%00010000   // Channel 3: Frequency Lo
ldh (NR33_REG),a // Store Channel 3: Frequency Lo ($FF1D) = A
ld a,%10000100   // Channel 3: Set Restart Flag (Bit 7), Reset Length Flag (Bit 6), Frequency Hi (Bits 0..3)
ldh (NR34_REG),a // Store Channel 3: Restart / Length Flag, Frequency Hi ($FF1E) = A

ld a,%00000001 // Enable V-Blank Interrupt
ldh (IE_REG),a // Interrupt Enable Flag Register ($FFFF) = A
ei // Enable Interrupts

Refresh:
  halt // Power Down CPU Until An Interrupt Occurs
  jr Refresh

VBlankInterrupt:
  reti // Return From Interrupt