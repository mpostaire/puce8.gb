INCLUDE "inc/hardware.inc"

SECTION "Utils", ROM0

; Halts until VBLANK, if already in VBLANK this returns immediately.
; This expects that VBLANK int does not changes the hl register
WaitVBLANK::
    ld a, [rLY]
    cp SCRN_Y
    jr nc, .return

    ld hl, rIE
    set IEB_VBLANK, [hl]

    halt

    ; ld hl, rIE not needed because VBLANK int does nothing
    set IEB_VBLANK, [hl]
.return:
    ret

; Halts until VBLANK, then busy wait until LY == 0
WaitLY0::
    call WaitVBLANK

.loop:
    ld a, [rLY]
    cp 0
    jr nz, .loop
    ret

; Wait for VBLANK then disable LCD
DisableLCD::
    call WaitVBLANK
    ld a, LCDCF_OFF
    ld [rLCDC], a
    ret

; Loads tiles into VRAM
LoadTiles::
    ld hl, _VRAM
    ld bc, Tiles
    ld de, Tiles.end - Tiles
    call Memcpy
    ret

; Loads tilemap into VRAM
LoadTileMap::
    ld hl, _SCRN0
    ld bc, TileMap
    ld de, TileMap.end - TileMap
    call Memcpy
    ret

; ; hl = l * b
; ; TODO optimize by adding largest number and iterating on smallest
; Multiply::
;     ld a, h
;     or l
;     jr z, .return0

;     xor a
;     cp b
;     jr z, .return0

;     ld d, l
;     ld l, 0

; .loop:
;     ld a, l
;     add d
;     ld l, a
;     ld a, 0 ; xor a impossible as it resets C flag
;     adc a
;     ld h, a

;     dec b
;     jr nz, .loop

; .return:
;     ret
; .return0:
;     xor a
;     ld h, a
;     ld l, a
;     ret

; fast multiply hl by a power of 2 (16 bit shift left)
; hl <<= b
MultiplyPower2::
    sla l
    ld a, 0
    adc a
    sla h
    bit 0, a
    jr z, .returnCondition
    set 0, h

.returnCondition:
    dec b
    jr nz, MultiplyPower2
    ret

; ; multiply hl by 2 (16 bit shift left)
; ShiftLeft16::
;     sla l
;     ld a, 0
;     adc a
;     sla h
;     bit 0, a
;     jr z, .return
;     set 0, h
; .return:
;     ret
