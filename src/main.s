INCLUDE "inc/hardware.inc"

SECTION "Header", ROM0[$100]

    di
    jp EntryPoint
    ds $150 - @, 0 ; Make room for the header


SECTION "Input Variables", WRAM0

wCurKeys::
    db
wNewKeys::
    db


SECTION "EntryPoint", ROM0

EntryPoint:
    ; Disable audio
    ld a, 0
    ld [rNR52], a

    call DisableLCD

    call LoadTiles
    call LoadTileMap

    ; Enable LCD
    ld a, LCDCF_ON | LCDCF_BG8000 | LCDCF_BGON
    ld [rLCDC], a

.emu_init:
    ld a, 0
    ld [wCurKeys], a
    ld [wNewKeys], a

.emu_loop:
    jr .emu_loop

.done:
    jr @ ; traps execution here

; Wait for VBLANK
WaitVBLANK:
    ld a, [rLY]
    cp SCRN_Y
    jp c, WaitVBLANK ; jp if a < SCRN_Y (144)
    ret

; Wait for VBLANK then disable LCD
DisableLCD:
    call WaitVBLANK
    ld a, LCDCF_OFF
    ld [rLCDC], a
    ret

; Loads tiles into VRAM
LoadTiles:
    ld hl, _VRAM
    ld bc, Tiles
    ld de, TilesEnd - Tiles
    jr Memcpy

; Loads tilemap into VRAM
LoadTileMap:
    ld hl, _SCRN0
    ld bc, TileMap
    ld de, TileMapEnd - TileMap
    jr Memcpy

; Copy bytes from src to dest
; hl: dest addr
; bc: src addr
; de: size
Memcpy:
    ld a, [bc]
    ld [hli], a
    inc bc
    dec de
    ld a, d
    or a, e
    jr nz, Memcpy ; while de != 0
    ret
