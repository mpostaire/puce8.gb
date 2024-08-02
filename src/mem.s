SECTION "Mem", ROM0

; Copy bytes from src to dest (after this, hl == hl + de)
; hl: dest addr
; bc: src addr
; de: size
Memcpy::
    ld a, [bc]
    ld [hli], a
    inc bc
    dec de
    ld a, d
    or a, e
    jr nz, Memcpy ; while de != 0
    ret

; Sets bytes of dest (after this, hl == hl + de)
; hl: dest addr
; b: value
; de: size
Memset::
    ld a, b
    ld [hli], a
    dec de
    ld a, d
    or a, e
    jr nz, Memset ; while de != 0
    ret
