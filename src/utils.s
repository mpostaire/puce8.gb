INCLUDE "inc/hardware.inc"

SECTION "Utils", ROM0

; Halts until VBLANK, if already in VBLANK this returns immediately.
; This expects that VBLANK int does not changes the hl register
WaitVBLANK::
    ld a, [rLY]
    cp SCRN_Y
    jr nc, .returnNow

    ld hl, rIE
    set IEB_VBLANK, [hl]

    halt

    ; ld hl, rIE not needed because VBLANK int does nothing
    set IEB_VBLANK, [hl]
    reti
.returnNow:
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
