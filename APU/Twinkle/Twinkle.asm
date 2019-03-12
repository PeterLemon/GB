// GB Twinkle Song Demo by krom (Peter Lemon):
arch gb.cpu
output "Twinkle.gb", create

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
ld a,%00000000   // Frequency Sweep: Time = 0 (Bit 4..6), Direction = Increase (Bit 3), Shift = Disable (Bit 0..2)
ldh (NR10_REG),a // Store Channel 1: Frequency Sweep ($FF10) = A
ld a,%11000000   // Wave Duty / Sound Length: Wave Duty = 75% (Bit 6..7), Sound Length = 0 (Bit 0..5)
ldh (NR11_REG),a // Store Channel 1: Wave Duty / Sound Length ($FF11) = A
ld a,%11110011   // Volume Envelope: Initial Value = 15 (Bit 4..7), Direction = Decrease (Bit 3), Sweep = 3 (Bit 0..2)
ldh (NR12_REG),a // Store Channel 1: Volume Envelope ($FF12) = A

ld a,%00000001 // Enable V-Blank Interrupt
ldh (IE_REG),a // Interrupt Enable Flag Register ($FFFF) = A
ei // Enable Interrupts
halt // Power Down CPU Until An Interrupt Occurs

ld de,$0000 // DE = 0
LoopSong:
  ld bc,SONGCHAN1  // BC = SONGCHAN1 16-Bit Address

  APUCHAN1: // APU Channel 1
    ld a,(bc)        // A = Channel 1: Period Table Offset
    cp SUST          // Compare A To SUST Character ($FE)
    jr z,APUCHAN1End // IF (A == SUST) Channel 1: APUCHAN1 End

    // Channel 1: Key OFF
    ld hl,NR52_REG   // HL = NR52: Sound On/Off (Channel #1..4 On/Off 0..3, All Channels On/Off 7) ($FF26)
    res 0,(hl)       // APU Channel 1 Disable
    cp REST          // Compare A To REST Character ($FF)
    jr z,APUCHAN1End // IF (A == REST) Channel 1: APUCHAN1 End

    // ELSE Channel 1: Key ON
    ld e,a            // E = A
    ld hl,PeriodTable // HL = PeriodTable 16-Bit Address
    add hl,de         // HL += DE
    ld a,(hl+)        // A = Channel 1: Frequency Lo, Increment Period Table Offset
    ldh (NR13_REG),a  // Store Channel 1: Frequency Lo ($FF13) = A

    ld a,(hl)         // A = Channel 1: Frequency Hi (Bits 0..3)
    set 7,a           // Set Restart Flag (Bit 7), Reset Length Flag (Bit 6)
    ldh (NR14_REG),a  // Store Channel 1: Restart / Length Flag, Frequency Hi ($FF14) = A

    ld hl,NR52_REG // HL = NR52: Sound On/Off (Channel #1..4 On/Off 0..3, All Channels On/Off 7) ($FF26)
    set 0,(hl)     // APU Channel 1 Enable
  APUCHAN1End:

  // 250 MS Delay (15 VSYNCS)
  ld a,15
  Wait:
    halt // Power Down CPU Until An Interrupt Occurs
    dec a
    jr nz,Wait
    
  inc bc // BC++ (Increment Song Offset)

  ld a,SongEnd>>8 // IF (Song Offset != Song End) GOTO APU Channel 1
  cp b
  jp nz,APUCHAN1
  ld a,SongEnd
  cp c
  jp nz,APUCHAN1

  jp LoopSong // GOTO Loop Song

VBlankInterrupt:
  reti // Return From Interrupt

PeriodTable: // Period Table Used For APU Note Freqencies
  PeriodTable() // Timing, 6 Octaves: C3..B8 (72 Words)

SongStart:
  SONGCHAN1: // APU Channel 1 Song Data At 250ms (15 VSYNCS)
    db C5, REST, C5, REST, G5, REST, G5, REST, A5, REST, A5, REST, G5, SUST, SUST, REST // 1. Twinkle Twinkle Little Star...
    db F5, REST, F5, REST, E5, REST, E5, REST, D5, REST, D5, REST, C5, SUST, SUST, REST // 2.   How I Wonder What You Are...
    db G5, REST, G5, REST, F5, REST, F5, REST, E5, REST, E5, REST, D5, SUST, SUST, REST // 3.  Up Above The World So High...
    db G5, REST, G5, REST, F5, REST, F5, REST, E5, REST, E5, REST, D5, SUST, SUST, REST // 4.   Like A Diamond In The Sky...
    db C5, REST, C5, REST, G5, REST, G5, REST, A5, REST, A5, REST, G5, SUST, SUST, REST // 5. Twinkle Twinkle Little Star...
    db F5, REST, F5, REST, E5, REST, E5, REST, D5, REST, D5, REST, C5, SUST, SUST, REST // 6.   How I Wonder What You Are...
SongEnd: