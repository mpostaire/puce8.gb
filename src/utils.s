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
    cp a, 0
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

;; Multiplies hl with de
Multiply::
    ld a, d
    or a, e
    jr z, .return

    add hl, hl
    dec de
    jr Multiply

.return:
    ret
