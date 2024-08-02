INCLUDE "inc/hardware.inc"

DEF TILEMAP_WIDTH EQU 32
DEF EMU_TILEMAP_OFFSET_Y EQU 5
DEF EMU_TILEMAP_OFFSET_X EQU 2
DEF EMU_TILEMAP_START EQU TILEMAP_WIDTH * EMU_TILEMAP_OFFSET_Y + EMU_TILEMAP_OFFSET_X
DEF EMU_TILEMAP_HEIGHT EQU 8
DEF EMU_TILEMAP_WIDTH EQU 16
DEF EMU_TILEMAP_STRIDE EQU 32

DEF EMU_RAM_SIZE EQU 4096
DEF EMU_REGS_SIZE EQU 16

SECTION "Emu RAM", WRAMX

wEmuRam: ds EMU_RAM_SIZE


SECTION "Emu vars", WRAM0

wEmuRegs: ds EMU_REGS_SIZE
wEmuI: dw


SECTION "Emu", ROM0

EmuReset::
    ; init emu ram
    ld hl, wEmuRam
    ld b, 0
    ld de, EMU_RAM_SIZE
    call Memset

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

    ; TODO prevent chip8 pc (hl) to go before and after WRAMX
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
    ld hl, OpJT
    add hl, de
    add hl, de

    ; load function pointer of opcode into hl
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld h, d
    ld l, e

    ; execute (jump to function of opcode)
    jp hl

    call WaitVBLANK
    call UpdateKeys

    jr EmuLoop

OpJT:
    dw OpClearScreenOrOpSubroutineReturn
    dw OpJump
    dw Op2
    dw Op3
    dw Op4
    dw Op5
    dw Op6
    dw Op7
    dw Op8
    dw Op9
    dw OpLoadIndexRegImmediate
    dw OpB
    dw OpC
    dw OpDrawSprite
    dw OpE
    dw OpF

; instr opcode is in register bc

OpClearScreenOrOpSubroutineReturn:
    ld a, c
    cp $E0
    jr nz, .callOpSubroutineReturn
    call OpClearScreen
    jp CPULoop
.callOpSubroutineReturn:
    cp $EE
    call z, OpSubroutineReturn
    jp CPULoop

; Jump
OpJump:
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
OpLoadIndexRegImmediate:
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
OpDrawSprite:
    ld b, b ; TODO
    jp CPULoop

OpE:
    ld b, b ; TODO
    jp CPULoop

OpF:
    ld b, b ; TODO
    jp CPULoop

; Clear the screen
OpClearScreen:
    ld c, EMU_TILEMAP_HEIGHT

    ld hl, _SCRN0 + EMU_TILEMAP_START
.loop
    ld b, 0 ; 0 is full black tile
    ld de, EMU_TILEMAP_WIDTH
    call Memset

    ld de, EMU_TILEMAP_STRIDE - EMU_TILEMAP_WIDTH
    add hl, de

    dec c
    cp c
    jr nz, .loop

    ret

OpSubroutineReturn:
    ld hl, sp+1
    ret
