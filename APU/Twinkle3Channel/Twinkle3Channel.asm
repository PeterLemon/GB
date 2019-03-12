// GB Twinkle 3 Channel Song Demo by krom (Peter Lemon):
arch gb.cpu
output "Twinkle3Channel.gb", create

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

// Setup Channel 2
ld a,%11000000   // Wave Duty / Sound Length: Wave Duty = 75% (Bit 6..7), Sound Length = 0 (Bit 0..5)
ldh (NR21_REG),a // Store Channel 2: Wave Duty / Sound Length ($FF16) = A
ld a,%11110011   // Volume Envelope: Initial Value = 15 (Bit 4..7), Direction = Decrease (Bit 3), Sweep = 3 (Bit 0..2)
ldh (NR22_REG),a // Store Channel 2: Volume Envelope ($FF17) = A

// Setup Channel 3
ld a,%10000000   // On/Off: Channel 3 On (Bit 7)
ldh (NR30_REG),a // Store Channel 3: On/Off ($FF1A) = A
ld a,128         // Sound Length: Sound Length = 128 (Bit 0..7)
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

  ld hl,SongEnd-SongStart
  add hl,bc
  ld b,h
  ld c,l

  APUCHAN2: // APU Channel 2
    ld a,(bc)        // A = Channel 2: Period Table Offset
    cp SUST          // Compare A To SUST Character ($FE)
    jr z,APUCHAN2End // IF (A == SUST) Channel 2: APUCHAN2 End

    // Channel 2: Key OFF
    ld hl,NR52_REG   // HL = NR52: Sound On/Off (Channel #1..4 On/Off 0..3, All Channels On/Off 7) ($FF26)
    res 1,(hl)       // APU Channel 2 Disable
    cp REST          // Compare A To REST Character ($FF)
    jr z,APUCHAN2End // IF (A == REST) Channel 2: APUCHAN2 End

    // ELSE Channel 2: Key ON
    ld e,a            // E = A
    ld hl,PeriodTable // HL = PeriodTable 16-Bit Address
    add hl,de         // HL += DE
    ld a,(hl+)        // A = Channel 2: Frequency Lo, Increment Period Table Offset
    ldh (NR23_REG),a  // Store Channel 2: Frequency Lo ($FF18) = A

    ld a,(hl)         // A = Channel 2: Frequency Hi (Bits 0..3)
    set 7,a           // Set Restart Flag (Bit 7), Reset Length Flag (Bit 6)
    ldh (NR24_REG),a  // Store Channel 2: Restart / Length Flag, Frequency Hi ($FF19) = A

    ld hl,NR52_REG // HL = NR52: Sound On/Off (Channel #1..4 On/Off 0..3, All Channels On/Off 7) ($FF26)
    set 1,(hl)     // APU Channel 2 Enable
  APUCHAN2End:

  ld hl,SongEnd-SongStart
  add hl,bc
  ld b,h
  ld c,l

  APUCHAN3: // APU Channel 3
    ld a,(bc)        // A = Channel 3: Period Table Offset
    cp SUST          // Compare A To SUST Character ($FE)
    jr z,APUCHAN3End // IF (A == SUST) Channel 3: APUCHAN3 End

    // Channel 3: Key OFF
    ld hl,NR52_REG   // HL = NR52: Sound On/Off (Channel #1..4 On/Off 0..3, All Channels On/Off 7) ($FF26)
    res 2,(hl)       // APU Channel 3 Disable
    cp REST          // Compare A To REST Character ($FF)
    jr z,APUCHAN3End // IF (A == REST) Channel 3: APUCHAN3 End

    // ELSE Channel 3: Key ON
    ld e,a            // E = A
    ld hl,PeriodTable // HL = PeriodTable 16-Bit Address
    add hl,de         // HL += DE
    ld a,(hl+)        // A = Channel 3: Frequency Lo, Increment Period Table Offset
    ldh (NR33_REG),a  // Store Channel 3: Frequency Lo ($FF1D) = A

    ld a,(hl)         // A = Channel 3: Frequency Hi (Bits 0..3)
    set 6,a // Set Length Flag (Bit 6)
    set 7,a // Set Restart Flag (Bit 7)
    ldh (NR34_REG),a  // Store Channel 3: Restart / Length Flag, Frequency Hi ($FF1E) = A

    ld a,128 // Sound Length: Length = 128 (Bit 0..7)
    ldh (NR31_REG),a // Store Channel 3: Sound Length ($FF1B) = A

    ld hl,NR52_REG // HL = NR52: Sound On/Off (Channel #1..4 On/Off 0..3, All Channels On/Off 7) ($FF26)
    set 2,(hl)     // APU Channel 3 Enable
  APUCHAN3End:

  ld hl,-((SongEnd-SongStart) * 2)
  add hl,bc
  ld b,h
  ld c,l

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

  SONGCHAN2: // APU Channel 2 Song Data At 250ms (15 VSYNCS)
    db C3, REST, C3, REST, G3, REST, G3, REST, A3, REST, A3, REST, G3, SUST, SUST, REST // 1.
    db F3, REST, F3, REST, E3, REST, E3, REST, D3, REST, D3, REST, C3, SUST, SUST, REST // 2.
    db G3, REST, G3, REST, F3, REST, F3, REST, E3, REST, E3, REST, D3, SUST, SUST, REST // 3.
    db G3, REST, G3, REST, F3, REST, F3, REST, E3, REST, E3, REST, D3, SUST, SUST, REST // 4.
    db C3, REST, C3, REST, G3, REST, G3, REST, A3, REST, A3, REST, G3, SUST, SUST, REST // 5.
    db F3, REST, F3, REST, E3, REST, E3, REST, D3, REST, D3, REST, C3, SUST, SUST, REST // 6.

  SONGCHAN3: // APU Channel 3 Song Data At 250ms (15 VSYNCS)
    db C7, REST, C7, REST, G7, REST, G7, REST, A7, REST, A7, REST, G7, SUST, SUST, REST // 1.
    db F7, REST, F7, REST, E7, REST, E7, REST, D7, REST, D7, REST, C7, SUST, SUST, REST // 2.
    db G7, REST, G7, REST, F7, REST, F7, REST, E7, REST, E7, REST, D7, SUST, SUST, REST // 3.
    db G7, REST, G7, REST, F7, REST, F7, REST, E7, REST, E7, REST, D7, SUST, SUST, REST // 4.
    db C7, REST, C7, REST, G7, REST, G7, REST, A7, REST, A7, REST, G7, SUST, SUST, REST // 5.
    db F7, REST, F7, REST, E7, REST, E7, REST, D7, REST, D7, REST, C7, SUST, SUST, REST // 6.