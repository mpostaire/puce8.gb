INCLUDE "inc/hardware.inc"

DEF TILEMAP_STRIDE EQU 32
DEF EMU_TILEMAP_OFFSET_Y EQU 5
DEF EMU_TILEMAP_OFFSET_X EQU 2
DEF EMU_TILEMAP_START EQU TILEMAP_STRIDE * EMU_TILEMAP_OFFSET_Y + EMU_TILEMAP_OFFSET_X
DEF EMU_TILEMAP_HEIGHT EQU 8
DEF EMU_TILEMAP_WIDTH EQU 16

DEF EMU_INSTRS_PER_FRAME EQU 11

DEF EMU_REGS_SIZE EQU 16
DEF EMU_RAM_SIZE EQU 4096
DEF VRAM_SIZE EQU $800
DEF EMU_VRAM_STRIDE EQU 32 ; TODO


SECTION "Emu vars", WRAM0

wEmuRegs:
.V: ds EMU_REGS_SIZE
.I: dw

wDrawCmds: ds (EMU_INSTRS_PER_FRAME * 8) + 1
.end:
.head: dw

wTmpDraw:
.x: db
.y: db

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

    ld a, low(wDrawCmds)
    ld l, a
    ld a, high(wDrawCmds)
    ld h, a

    ld [wTmpSP], sp
    ld sp, hl

; [clear, draw1, draw1, draw1, draw2, draw2, draw2]
; [.end, .end+2, .end+4, .end+6, .end+8, .end+10, .end+12]

; TODO draw cmds:
; if clear screen --> 1 byte == 1
; if draw sprite --> 3 words where 1st is n (byte 0 == 0, byte 1 == n), 2nd is tilemap addr, 3rd is vram addr
.start:
    pop bc

    ; if c.1 set : end of draw cmds fifo --> stop drawing
    bit 1, c
    jr nz, .end

    ; if c.1 reset and c.0 set : clear screen
    bit 0, c
    jr nz, .clearScreen

    ; TODO n is in b

    ; if c.1 reset and c.0 set : draw sprite
.applyTilemap:
    pop de ; tilemap addr is in de
    pop bc

        push hl

    ld h, d
    ld l, e
    ld a, c

    ; ld l, e
    ; REPT 4
    ;     sra l
    ; ENDR

    ; ld b, l
    ; ld a, l
    ; ld hl, _SCRN0 + EMU_TILEMAP_START
    ; add l
    ; ld l, a

    ; ld a, b
    ; add 128
    ld [hl], a

        pop hl

.renderSprite: ; TODO

    pop de ; vram start addr is in de

        push hl

    ld h, d
    ld l, e
    ld a, $FF

    ; actually draw pixels
    REPT 5
        ld [hli], a
        inc l
        inc l
    ENDR
    ld [hli], a

        pop hl

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
    ld a, [wTmpSP]
    ld l, a
    ld a, [wTmpSP + 1]
    ld h, a
    ld sp, hl

EmuLoop:
    ld a, low(wDrawCmds)
    ld [wDrawCmds.head], a
    ld a, high(wDrawCmds)
    ld [wDrawCmds.head + 1], a

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
    ; sla a ; x *= 2 (emu screen size is 2x chip8 screen size)
    ld [wTmpDraw.x], a

    ; y
    ld a, c
    and $F0
    swap a
    ld e, a
    ld hl, wEmuRegs.V
    add hl, de
    ld a, [hl]
    and 31 ; modulo 32
    ld [wTmpDraw.y], a

    ld a, [wDrawCmds.head]
    ld l, a
    ld a, [wDrawCmds.head + 1]
    ld h, a

    ; add cmd id and sprite size (n) into draw cmds fifo
    xor a ; a == 0 --> draw sprite command
    ld [hli], a
    ; n
    ld a, c
    and $0F
    ld [hli], a

    ; move draw cmds fifo head
    ld a, l
    ld [wDrawCmds.head], a
    ld a, h
    ld [wDrawCmds.head + 1], a

    ; compute tilemap addr
    ld h, 0
    ld a, [wTmpDraw.y]
    REPT 3 ; TODO divide by 8 because each tile contains 8 pixels --> in the future we may want to keep remainder somewhere to draw sprites in non 8-multiple coords
        sra a
    ENDR
    ld l, a
    ld b, 5 ; stride in amount of bit shifts to multiply by 32 (1 << 5 == 32)

    ; y * stride
    call Mul2

    ; ld d, 0 ; d is already 0 here
    ld a, [wTmpDraw.x]
    REPT 3 ; TODO divide by 8 because each tile contains 8 pixels --> in the future we may want to keep remainder somewhere to draw sprites in non 8-multiple coords
        sra a
    ENDR
    ld e, a
    add hl, de ; + x

    ld hl, _SCRN0 + EMU_TILEMAP_START
    add hl, de
    ld b, h
    ld c, l

    ld a, [wDrawCmds.head]
    ld l, a
    ld a, [wDrawCmds.head + 1]
    ld h, a

    ; add tilemap addr to draw cmds fifo
    ld a, c
    ld [hli], a
    ld a, b
    ld [hli], a

    ; move draw cmds fifo head
    ld a, l
    ld [wDrawCmds.head], a
    ld a, h
    ld [wDrawCmds.head + 1], a

    ; compute vram start addr
    ld h, 0
    ld a, [wTmpDraw.y]
    ld l, a
    ld b, 8 ; stride in amount of bit shifts (1 << 8 == 256) --> 1 << 5 == 32 we do * 32 because we divide by 8, then multiply by 256

    ; y * stride
    call Mul2

    ld d, 0
    ld a, [wTmpDraw.x]
    ld e, a
    add hl, de ; + x

    ; TODO multiply side effects in d (and a) --> may break everything below

    ; compute tile id (128 + (y * stride) + x)
    ld b, h
    ld a, l
    add 128
    ld c, a

    ld de, _VRAM8800
    add hl, de ; + x
    ld d, h
    ld e, l

    ld a, [wDrawCmds.head]
    ld l, a
    ld a, [wDrawCmds.head + 1]
    ld h, a

    ; add tile id to draw cmds fifo
    ld a, c
    ld [hli], a
    ld a, b
    ld [hli], a

    ; add vram addr to draw cmds fifo
    ld a, e
    ld [hli], a
    ld a, d
    ld [hli], a

    ; move draw cmds fifo head
    ld a, l
    ld [wDrawCmds.head], a
    ld a, h
    ld [wDrawCmds.head + 1], a

    ; add end bytes
    ld a, %11
    ld [hli], a
    ld [hl], a

    jp EmuStep

OpE:
    ld b, b
    jp EmuStep

OpF:
    ld b, b
    jp EmuStep

; Clear the screen
OpClearScreen:
    ld a, [wDrawCmds.head]
    ld l, a
    ld a, [wDrawCmds.head + 1]
    ld h, a

    ld a, %01 ; a == 1 --> clear screen cmd
    ld [hli], a
    ld [hli], a

    ld a, l
    ld [wDrawCmds.head], a
    ld a, h
    ld [wDrawCmds.head + 1], a

    ; add end bytes
    ld a, %11
    ld [hli], a
    ld [hl], a

    jp EmuStep

OpSubroutineReturn:
    ld b, b
    jp EmuStep
