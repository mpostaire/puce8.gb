INCLUDE "inc/hardware.inc"

SECTION "Emu RAM", WRAMX

wEmuRam: ds 4096


SECTION "Emu", ROM0

EmuReset::
    ; load font into emu ram
    ld hl, wEmuRam + $0050
    ld bc, Chip8Font
    ld de, Chip8FontEnd - Chip8Font
    call Memcpy

    ; load chip 8 rom into emu ram
    ld hl, wEmuRam + $0200
    ld bc, TestChip8Logo
    ld de, TestChip8LogoEnd - TestChip8Logo
    call Memcpy

    ; set chip8 pc in hl register
    ld hl, wEmuRam + $0200
    push hl

EmuLoop:
    ; ld a, cycles_to_wait

CPULoop:
    ; fetch
    pop hl ; restore chip8 pc into hl

    ld a, [hli]
    ld b, a
    ld a, [hli]
    ld c, a

    push hl ; save chip8 pc

    ; decode
    ld a, $F0
    and b
    swap a
    ld b, 0
    ld c, a
    ld hl, OpcodeJT
    add hl, bc

    ; load function pointer of opcode into hl
    ld a, [hli]
    ld c, a
    ld a, [hli]
    ld b, a
    ld h, b
    ld l, c

    ; jump to function of opcode
    jp hl

    call WaitVBLANK
    call UpdateKeys

    jr EmuLoop

OpcodeJT:
    dw .zero
    dw .one
    dw .two
    dw .three
    dw .four
    dw .five
    dw .six
    dw .seven
    dw .eight
    dw .nine
    dw .a
    dw .b
    dw .c
    dw .d
    dw .e
    dw .f

.zero:
    ld b, b
    jp CPULoop

.one:
    ld b, b
    jp CPULoop

.two:
    ld b, b
    jp CPULoop

.three:
    ld b, b
    jp CPULoop

.four:
    ld b, b
    jp CPULoop

.five:
    ld b, b
    jp CPULoop

.six:
    ld b, b
    jp CPULoop

.seven:
    ld b, b
    jp CPULoop

.eight:
    ld b, b
    jp CPULoop

.nine:
    ld b, b
    jp CPULoop

.a:
    ld b, b
    jp CPULoop

.b:
    ld b, b
    jp CPULoop

.c:
    ld b, b
    jp CPULoop

.d:
    ld b, b
    jp CPULoop

.e:
    ld b, b
    jp CPULoop

.f:
    ld b, b
    jp CPULoop
