INCLUDE "inc/hardware.inc"

SECTION "Emu RAM", WRAMX

wEmuRam: ds 4096


SECTION "Emu vars", WRAMX

wEmuRegs: ds 16
wEmuI: dw


SECTION "Emu", ROM0

EmuReset::
    ; load font into emu ram
    ld hl, wEmuRam + $0050
    ld bc, Chip8Font
    ld de, Chip8Font.end - Chip8Font
    call Memcpy

    ; load chip 8 rom into emu ram
    ld hl, wEmuRam + $0200
    ld bc, TestChip8Logo
    ld de, TestChip8Logo.end - TestChip8Logo
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
    ld a, $F0 ; a still contains MSB of just read instruction (which is in c)
    and b
    swap a
    ld d, 0
    ld e, a
    ld hl, OpcodeJT
    add hl, de
    add hl, de

    ; load function pointer of opcode into hl
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld h, d
    ld l, e

    ; jump to function of opcode
    jp hl

    call WaitVBLANK
    call UpdateKeys

    jr EmuLoop

OpcodeJT:
    dw Op0
    dw Op1
    dw Op2
    dw Op3
    dw Op4
    dw Op5
    dw Op6
    dw Op7
    dw Op8
    dw Op9
    dw OpA
    dw OpB
    dw OpC
    dw OpD
    dw OpE
    dw OpF

; instr opcode is in register bc

Op0:
    ld a, c
    cp $E0
    jr nz, .callSubroutineReturn
    call ClearScreen
    jp CPULoop
.callSubroutineReturn:
    cp $EE
    call z, SubroutineReturn
    jp CPULoop

; Jump
Op1:
    ; nnn in bc
    ld a, b
    and $0F
    ld b, a

    ; chip8 pc = nnn
    pop hl
    ld hl, wEmuRam
    add hl, de
    push hl

    jp CPULoop

Op2:
    ld b, b ; TODO
    jp CPULoop

Op3:
    ld b, b ; TODO
    jp CPULoop

Op4:
    ld b, b ; TODO
    jp CPULoop

Op5:
    ld b, b ; TODO
    jp CPULoop

; Load normal register with immediate value
Op6:
    ; x in de
    ld a, b
    and $0F
    ld d, 0
    ld e, a

    ; nn is already in c

    ; wEmuRegs[x] = nn
    ld hl, wEmuRegs
    add hl, de
    ld [hl], c

    jp CPULoop

Op7:
    ld b, b ; TODO
    jp CPULoop

Op8:
    ld b, b ; TODO
    jp CPULoop

Op9:
    ld b, b ; TODO
    jp CPULoop

; Load index register with immediate value
OpA:
    ; nnn in de
    ld a, b
    and $0F
    ld d, a
    ld e, c

    ; I = nnn
    ld hl, wEmuI
    ld a, d
    ld [hli], a
    ld [hl], e

    jp CPULoop

OpB:
    ld b, b ; TODO
    jp CPULoop

OpC:
    ld b, b ; TODO
    jp CPULoop

; Draw sprite to screen
OpD:
    ld b, b ; TODO
    jp CPULoop

OpE:
    ld b, b ; TODO
    jp CPULoop

OpF:
    ld b, b ; TODO
    jp CPULoop

; Clear the screen
ClearScreen:
    ; TODO call memset 0 on vram addresses where tilemap corresponds to chip8 screen
    ret

SubroutineReturn:
    ld hl, sp+1
    ret
