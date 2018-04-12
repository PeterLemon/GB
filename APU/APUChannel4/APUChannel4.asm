// GB APU Channel 4 Demo by krom (Peter Lemon):
arch gb.cpu
output "APUChannel4.gb", create

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

// Setup Channel 4
ld a,0           // Sound Length: Sound Length = 0 (Bit 0..5)
ldh (NR41_REG),a // Store Channel 4: Sound Length ($FF20) = A
ld a,%11110000   // Volume Envelope: Initial Value = 15 (Bit 4..7), Direction = Decrease (Bit 3), Sweep = 0 (Bit 0..2)
ldh (NR42_REG),a // Store Channel 2: Volume Envelope ($FF21) = A
ld a,%01100001   // Channel 4: Noise Rate = 6 (Bit 4..7), Counter Step/Width = 15-Bit (Bit 3), Divider = 1 (Bit 0..2)
ldh (NR43_REG),a // Store Channel 4: Shift Clock Frequency, Counter Step/Width, Dividing Ratio ($FF22) = A
ld a,%10000000   // Channel 4: Set Restart Flag (Bit 7), Reset Length Flag (Bit 6)
ldh (NR44_REG),a // Store Channel 4: Restart / Length Flag ($FF23) = A

ld a,%00000001 // Enable V-Blank Interrupt
ldh (IE_REG),a // Interrupt Enable Flag Register ($FFFF) = A
ei // Enable Interrupts

Refresh:
  halt // Power Down CPU Until An Interrupt Occurs
  jr Refresh

VBlankInterrupt:
  reti // Return From Interrupt