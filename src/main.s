INCLUDE "inc/hardware.inc"

SECTION "Chip8 ROMs", ROMX

ROMs:
    INCBIN "inc/roms/1-chip8-logo.ch8"

SECTION "Tiles", ROMX

Tiles:
    dw `11111111, `11111111, `11111111, `11111111, `11111111, `11111111, `11111111, `11111111 ; black
    dw `11110000, `11110000, `11110000, `11110000, `00000000, `00000000, `00000000, `00000000 ; black upper left
    dw `00001111, `00001111, `00001111, `00001111, `00000000, `00000000, `00000000, `00000000 ; black upper right
    dw `00000000, `00000000, `00000000, `00000000, `11110000, `11110000, `11110000, `11110000 ; black lower left
    dw `00000000, `00000000, `00000000, `00000000, `00001111, `00001111, `00001111, `00001111 ; black lower right
    dw `11111111, `11111111, `11111111, `11111111, `00000000, `00000000, `00000000, `00000000 ; black up
    dw `00000000, `00000000, `00000000, `00000000, `11111111, `11111111, `11111111, `11111111 ; black down
    dw `11110000, `11110000, `11110000, `11110000, `11110000, `11110000, `11110000, `11110000 ; black left
    dw `00001111, `00001111, `00001111, `00001111, `00001111, `00001111, `00001111, `00001111 ; black right

    dw `00000000, `00000000, `00000000, `00000000, `00000000, `00000000, `00000000, `00000000 ; white
    dw `00001111, `00001111, `00001111, `00001111, `11111111, `11111111, `11111111, `11111111 ; white upper left
    dw `11110000, `11110000, `11110000, `11110000, `11111111, `11111111, `11111111, `11111111 ; white upper right
    dw `11111111, `11111111, `11111111, `11111111, `00001111, `00001111, `00001111, `00001111 ; white lower left
    dw `11111111, `11111111, `11111111, `11111111, `11110000, `11110000, `11110000, `11110000 ; white lower right

    dw `11111111, `11111111, `10000011, `10111101, `10111101, `10000011, `10111111, `10111111 ; p
    dw `11111111, `11111111, `10111101, `10111101, `10111101, `10111101, `10111101, `11000011 ; u
    dw `11111111, `11111111, `11000001, `10111111, `10111111, `10111111, `10111111, `11000001 ; c
    dw `11111111, `11111111, `11000011, `10111101, `10111101, `10000011, `10111111, `11000001 ; e
    dw `11000011, `10111101, `10111101, `11000011, `10111101, `10111101, `10111101, `11000011 ; 8
TilesEnd:

SECTION "TileMap", ROMX

TileMap:
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 14, 15, 16, 17, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 13, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 11, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
TileMapEnd:

SECTION "Header", ROM0[$100]

    di
    jp EntryPoint
    ds $150 - @, 0 ; Make room for the header

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
