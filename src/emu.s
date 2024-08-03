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
DEF EMU_VRAM_SIZE EQU 2048


SECTION "Emu vars", WRAM0

wEmuVRegs: ds EMU_REGS_SIZE
wEmuIReg: dw


SECTION "Emu VRAM", WRAM0

wEmuVram: ds EMU_VRAM_SIZE


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
    jp EmuLoop

GetInputAndRenderFrame:
    call WaitVBLANK
    call UpdateKeys


;     ; copy emu vram into tilemap vram
;     ; ld hl, _SCRN0
;     ; ld bc, wEmuVram
;     ; ld de, EMU_VRAM_SIZE
;     ; call Memcpy
;     ld c, EMU_TILEMAP_HEIGHT

;     ld hl, _SCRN0 + EMU_TILEMAP_START
; .loop
;     ld bc, wEmuVram
;     ld de, EMU_TILEMAP_WIDTH
;     call Memcpy

;     ld de, EMU_TILEMAP_STRIDE - EMU_TILEMAP_WIDTH
;     add hl, de

;     dec c
;     cp c
;     jr nz, .loop

EmuLoop:
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
    ld b, b ; TODO
    jp EmuStep

Op3:
    ld b, b ; TODO
    jp EmuStep

Op4:
    ld b, b ; TODO
    jp EmuStep

Op5:
    ld b, b ; TODO
    jp EmuStep

; Load normal register with immediate value
LoadVRegImmediate:
    ; x in de
    ld a, b
    and $0F
    ld d, 0
    ld e, a

    ; nn is already in c

    ; wEmuVRegs[x] = nn
    ld hl, wEmuVRegs
    add hl, de
    ld [hl], c

    jp EmuStep

Op7:
    ld b, b ; TODO
    jp EmuStep

Op8:
    ld b, b ; TODO
    jp EmuStep

Op9:
    ld b, b ; TODO
    jp EmuStep

; Load index register with immediate value
OpLoadIndexRegImmediate:
    ; nnn in de
    ld a, b
    and $0F
    ld d, a
    ld e, c

    ; I = nnn
    ld hl, wEmuIReg
    ld a, d
    ld [hli], a
    ld [hl], e

    jp EmuStep

OpB:
    ld b, b ; TODO
    jp EmuStep

OpC:
    ld b, b ; TODO
    jp EmuStep

; Draw sprite to screen
OpDrawSprite:
    ld b, b ; TODO
    jp EmuStep

OpE:
    ld b, b ; TODO
    jp EmuStep

OpF:
    ld b, b ; TODO
    jp EmuStep

; Clear the screen
OpClearScreen:
    ld hl, wEmuVram
    ld b, 0 ; 0 is full black tile
    ld de, EMU_VRAM_SIZE
    call Memset
    jp EmuStep

OpSubroutineReturn:
    ld hl, sp+1
    jp EmuStep
