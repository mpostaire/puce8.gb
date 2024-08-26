INCLUDE "inc/hardware.inc"

DEF TILEMAP_WIDTH EQU 32
DEF EMU_TILEMAP_OFFSET_Y EQU 5
DEF EMU_TILEMAP_OFFSET_X EQU 2
DEF EMU_TILEMAP_START EQU TILEMAP_WIDTH * EMU_TILEMAP_OFFSET_Y + EMU_TILEMAP_OFFSET_X
DEF EMU_TILEMAP_HEIGHT EQU 8
DEF EMU_TILEMAP_WIDTH EQU 16
DEF EMU_TILEMAP_STRIDE EQU 32

DEF EMU_INSTRS_PER_FRAME EQU 11

DEF EMU_REGS_SIZE EQU 16
DEF EMU_RAM_SIZE EQU 4096
DEF VRAM_SIZE EQU $800
DEF EMU_VRAM_STRIDE EQU 32 ; TODO


SECTION "Emu vars", WRAM0

wEmuRegs:
.V: ds EMU_REGS_SIZE
.I: dw

wDrawCmds: ds EMU_INSTRS_PER_FRAME * 2
.end:
.tail: dw

wTmpSP: dw

SECTION "Emu RAM", WRAMX

wEmuRam: ds EMU_RAM_SIZE


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

    call WaitLY0

    jp EmuLoop

GetInputAndRenderFrame:
    call WaitVBLANK
    call UpdateKeys

    ; apply draw cmds queue

    ld [wTmpSP], sp
    ld hl, wDrawCmds.end

.start:
    REPT 4
        dec l
    ENDR

    ld a, [wDrawCmds.tail]
    ld b, a
    ld a, l
    cp b

    jr c, .end ; while [wDrawCmds.tail] >= l

    ld sp, hl

    pop bc
    
    xor a
    cp b
    jr nz, .clearScreen

.renderSprite: ; TODO
    pop de

    ; n in c
    ; vram start addr in de

    ld b, b

    jr .start

.clearScreen:
    push hl

    ld hl, _SCRN0 + EMU_TILEMAP_START

    ld de, 16 ; offset between 2 screen lines (in tiles)
    ld b, 8 ; height of screen (in tiles)
    ld a, 15 ; black

.loop:
    REPT 16
        ld [hli], a
    ENDR

    add hl, de

    dec b
    jr nz, .loop

    pop hl
    jr .start

.end
    ld [wDrawCmds.end], sp
    ld a, [wTmpSP]
    ld l, a
    ld a, [wTmpSP + 1]
    ld h, a
    ld sp, hl

EmuLoop:
    ld a, low(wDrawCmds.end)
    ld [wDrawCmds.tail], a
    ld a, high(wDrawCmds.end)
    ld [wDrawCmds.tail + 1], a

    ld d, EMU_INSTRS_PER_FRAME
    push de ; save loop counter in stack
    ; TODO maybe storing loop counter in stack is not a good idea, the stack should be reserved for calls and chip8 pc

EmuStep:
    pop de ; restore loop counter into d
    dec d
    jp z, GetInputAndRenderFrame

    ; fetch
    pop hl ; restore chip8 pc into hl

    ; TODO prevent chip8 pc (hl) to go before and after WRAMX
    ld a, [hli]
    ld b, a
    ld a, [hli]
    ld c, a

    push hl ; save chip8 pc in stack
    push de ; save loop counter in stack

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

OpJT:
    dw OpClearScreenOrOpSubroutineReturn
    dw OpJump
    dw Op2
    dw Op3
    dw Op4
    dw Op5
    dw LoadVRegImmediate
    dw Op7
    dw Op8
    dw Op9
    dw OpLoadIndexRegImmediate
    dw OpB
    dw OpC
    dw OpDrawSprite
    dw OpE
    dw OpF

OpInvalid:
    jp EmuStep
; instr opcode is in register bc

OpClearScreenOrOpSubroutineReturn:
    ld a, c
    cp $E0
    jp z, OpClearScreen
    cp $EE
    jp z, OpSubroutineReturn
    jp OpInvalid

; Jump
OpJump:
    ; nnn in bc
    ld a, b
    and $0F
    ld b, a

    pop de ; pop emu loop counter
    
    ; chip8 pc = nnn
    pop hl
    ld hl, wEmuRam
    add hl, bc
    push hl

    push de ; push back emu loop counter

    jp EmuStep

Op2:
    ld b, b
    jp EmuStep

Op3:
    ld b, b
    jp EmuStep

Op4:
    ld b, b
    jp EmuStep

Op5:
    ld b, b
    jp EmuStep

; Load normal register with immediate value
LoadVRegImmediate:
    ; x in de
    ld a, b
    and $0F
    ld d, 0
    ld e, a

    ; nn is already in c

    ; wEmuRegs.V[x] = nn
    ld hl, wEmuRegs.V
    add hl, de
    ld [hl], c

    jp EmuStep

Op7:
    ld b, b
    jp EmuStep

Op8:
    ld b, b
    jp EmuStep

Op9:
    ld b, b
    jp EmuStep

; Load index register with immediate value
OpLoadIndexRegImmediate:
    ; nnn in de
    ld a, b
    and $0F
    ld d, a
    ld e, c

    ; I = nnn
    ld hl, wEmuRegs.I
    ld a, d
    ld [hli], a
    ld [hl], e

    jp EmuStep

OpB:
    ld b, b
    jp EmuStep

OpC:
    ld b, b
    jp EmuStep

; Draw sprite to screen
OpDrawSprite:
    ld d, 0

    ; x
    ld a, b
    and $0F
    ld e, a
    ld hl, wEmuRegs.V
    add hl, de
    ld a, [hl]
    and 63 ; modulo 64
    ld b, a

    ; y
    ld a, c
    and $F0
    swap a
    ld e, a
    ld hl, wEmuRegs.V
    add hl, de
    ld a, [hl]
    and 31 ; modulo 32

    ; start vram addr in de
    ld d, 0
    ld e, a
    ld a, b
    ld h, 0
    ld l, a
    call Multiply
    ld de, _VRAM8800
    add hl, de

    ld d, h
    ld e, l

    ; n in c
    ld a, c
    and $0F
    ld c, a

    ; push draw command into queue
    ld [wTmpSP], sp
    ld a, [wDrawCmds.tail]
    ld l, a
    ld a, [wDrawCmds.tail + 1]
    ld h, a
    ld sp, hl

    push de
    ld b, 0 ; b == 0 --> draw sprite cmd
    push bc

    ld [wDrawCmds.tail], sp
    ld a, [wTmpSP]
    ld l, a
    ld a, [wTmpSP + 1]
    ld h, a
    ld sp, hl

    jp EmuStep

OpE:
    ld b, b
    jp EmuStep

OpF:
    ld b, b
    jp EmuStep

; Clear the screen
OpClearScreen:
    ; push draw command into queue
    ld [wTmpSP], sp
    ld a, [wDrawCmds.tail]
    ld l, a
    ld a, [wDrawCmds.tail + 1]
    ld h, a
    ld sp, hl

    push de
    ld b, 1 ; b == 1 --> clear screen cmd
    push bc

    ld [wDrawCmds.tail], sp
    ld a, [wTmpSP]
    ld l, a
    ld a, [wTmpSP + 1]
    ld h, a
    ld sp, hl

    jp EmuStep

OpSubroutineReturn:
    ld b, b
    jp EmuStep
