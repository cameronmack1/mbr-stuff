bits 16
org 0x7C00

start:
    ; switch to vga mode 13h
    mov ax, 0x0013
    int 0x10

    ; move 0xa000 to es
    ; vram can now be accessed with es:di
    mov ax, 0xa000
    mov es, ax

main_loop:
    ; save tick count to dx
    mov ah, 0x00
    int 0x1A

    ; compare dx to previous frame
    cmp si, dx

    ; jump back to loop if equal
    je main_loop

    ; else, save tick to si and draw next frame
    mov si, dx
    mov cx, 320 ; loop once for each column
    xor di, di ; reset di to 0

; input: al 0 to 63
; output: the signed value in al
; destroys bx, ah
get_sin:
    ; al: 0000 0000
    ; to 0011 1111
    ; low 4 bits are pos within quadrant
    ; high 2 bits are which quadrant
    test al, 16 ; test if we are mirrored
    jz .no_reverse ; skip reversing if we are
    xor al, 15 ; invert the bits of the index (reverse it)
    .no_reverse:
        movzx bx, al ; move al to bl, clear bx
        and bl, 15 ; get the index from bl, not al, because bl needs to be cleared of the 2 high bits for indexing
        test al, 32 ; are we negative?
        mov al, [sin + bx] ; get the sin value from the index in bx
        jz .done ; skip if we are
        neg al ; negative
    .done:
        ret

; sine table
; each value is 5.625 degrees from the last, clockwise from 0 degrees
sin:
    db 0, 12, 25, 37, 49, 60, 71, 81
    db 90, 98, 106, 112, 117, 122, 125, 127
map:
    db 0xFF
    db 0x81
    db 0x81
    db 0x81
    db 0x81
    db 0x81
    db 0x81
    db 0xFF


; magic number to tell computer this is bootable
times 510 - ($ - $$) db 0
dw 0xAA55