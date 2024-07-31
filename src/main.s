INCLUDE "inc/hardware.inc"

SECTION "Header", ROM0[$100]

    di
    jp EntryPoint
    ds $150 - @, 0 ; Make room for the header


SECTION "Variables", WRAM0

wCurKeys:: db
wNewKeys:: db


SECTION "Chip8 RAM", WRAMX

wEmuRam:: ds 4096


SECTION "EntryPoint", ROM0

EntryPoint:
    ; disable audio
    xor a
    ld [rNR52], a

    call DisableLCD

    call LoadTiles
    call LoadTileMap

    ; init input variables
    xor a
    ld [wCurKeys], a
    ld [wNewKeys], a

    ; enable LCD
    ld a, LCDCF_ON | LCDCF_BG8000 | LCDCF_BGON
    ld [rLCDC], a

EmuReset:
    ; ; TODO load font into wram
    ; ld hl, wEmuRam + $0050
    ; ld bc, Font
    ; ld de, FontEnd - Font
    ; call Memcpy

    ld hl, wEmuRam + $0200
    ld bc, TestChip8Logo
    ld de, TestChip8LogoEnd - TestChip8Logo
    call Memcpy

    ; set chip8 pc in hl register
    ld hl, wEmuRam + $0200

.emuLoop:
    ; ld a, cycles_to_wait

.cpuLoop:
    ; fetch
    ld a, [hli]
    ld c, a
    ld a, [hli]
    ld b, a

    ; TODO decode
    ; TODO execute

    jr .cpuLoop
    ; jr nz, .cpuLoop

    call WaitVBLANK
    call UpdateKeys

    jr .emuLoop

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
    call Memcpy
    ret

; Loads tilemap into VRAM
LoadTileMap:
    ld hl, _SCRN0
    ld bc, TileMap
    ld de, TileMapEnd - TileMap
    call Memcpy
    ret

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

; Sets bytes of dest
; hl: dest addr
; b: value
; de: size
Memset:
    ld a, b
    ld [hli], a
    dec de
    ld a, d
    or a, e
    jr nz, Memset ; while de != 0
    ret
