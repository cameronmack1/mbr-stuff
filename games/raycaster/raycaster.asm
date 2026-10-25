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
angle_loop:
    ; cx represents the current column, looping from right side to left side
    ; angle can be calculated from the low 6 bits of the player angle + cx / 20 - 16
    ; this gives a 90 degree fov
    ; since cosx = sinx + 16 here, we can get the cos before subtracting the 16

    ; divide cx by 20, result is in ax
    xor dx, dx
    mov ax, cx
    mov bx, 20
    div bx
    add al, [player_angle] ; add angle
    mov ah, al ; save the angle to be used twice
    call get_sin ; al now contains the cos value

    xchg al, ah ; save the sin to ah, and get the angle back
    sub al, 16 ; add 16 (get sin instead of cos)
    call get_sin ; get sin, so now ah is cos and al is sin
    loop angle_loop

; input: al 0 to 63
; output: the signed value in al
; destroys bx
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
; player angle is from 0 to 63
player_angle:
    db 0
; the actual position is x or y / 32, but only saving it from 0-7 is less precise than this
player_x:
    db 127
player_y:
    db 127


; magic number to tell computer this is bootable
times 510 - ($ - $$) db 0
dw 0xAA55