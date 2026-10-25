bits 16
org 0x7C00

start:
    ; switch to vga mode 13h
    mov ax, 0x0013
    int 0x10

    ; mov 0xa000 to es
    ; vram can now be accessed with es:di
    mov ax, 0xa000
    mov es, ax
    ; set bx to 0
    xor bx, bx

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

    jmp pattern_start

pattern_start:
    ; set di to 0
    xor di, di
    ; increment bx and save its value to cx for the loop
    inc bx
    mov dx, bx
    .outer_loop:
        ; clamp cx to 320 and below
        mov cx, dx
        cmp cx, 320
        jbe .pre_loop
        mov cx, 320
        .pre_loop:
        mov bp, cx
        .inner_loop:
            ; check if we are past the framebuffer before drawing
            cmp di, 64000
            jae main_loop
            ; increment 1 to bx pixels
            mov al, [es:di]
            inc al
            stosb
            loop .inner_loop
        ; reset di to the first column in the next row
        sub di, bp
        add di, 320
        ; subtract 1 from dx and check if its 0
        sub dx, 1
        cmp dx, 0
        ja .outer_loop
        
    jmp main_loop

; magic number to tell computer this is bootable
times 510 - ($ - $$) db 0
dw 0xAA55