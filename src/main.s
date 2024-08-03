INCLUDE "inc/hardware.inc"

SECTION "Header", ROM0[$100]

    jp EntryPoint
    ds $150 - @, 0 ; Make room for the header


SECTION "Variables", WRAM0

wCurKeys:: db
wNewKeys:: db


SECTION "VBLANK interrupt", ROM0[INT_HANDLER_VBLANK]

    reti


SECTION "EntryPoint", ROM0

EntryPoint:
    ; disable audio
    xor a
    ld [rNR52], a

    ei ; WaitVBLANK needs interrupts enabled

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

    jp EmuReset
