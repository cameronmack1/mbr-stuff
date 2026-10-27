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

; 0000 0000 air 0x00
; 0100 0011 sand 0x43
; 0010 0001 water 0x21
; 0000 1111 wall 0x0F
; air is always 0
; test bit 1 to check if its sand
; test bit 6 to see if its water
; test bit 0 to see if its solid
init_screen:
    mov cx, 3200
    mov al, 0x21
    rep stosb
    mov cx, 20
    mov di, 63800
    mov al, 0x0F
    rep stosb
main_loop:
    xor ah, ah
    int 0x1A

    ; compare dx to previous frame
    cmp si, dx

    ; jump back to loop if equal
    je main_loop
    mov si, dx

    mov di, 64000
    mov cx, di
    .screen_loop:
        mov al, [es:di]
        bt ax, 6
        jc .sand
        bt ax, 5
        jnc .next_loop
    .sand:
        ; test all the positions under the current pixel
        ; down
        mov bx, di
        add bx, 320
        bt [es:bx], 0
        jnc .repl
        ; down left
        dec bx
        bt [es:bx], 0
        jnc .repl
        ; down right
        add bx, 2
        bt [es:bx], 0
        jnc .repl
        ; test if its sand or water, if its sand, skip
        bt ax, 5
        jnc .next_loop
        ; test positions beside pixel
        ; left
        sub bx, 322
        bt [es:bx], 0
        jnc .repl
        ; right
        add bx, 2
        bt [es:bx], 0
        jc .next_loop

    ; move the pixel to es:bx and remove the old pixel
    .repl:
        mov [es:bx], al
        mov [es:di], 0
        .next_loop:
            dec di
            loop .screen_loop
            jmp main_loop

; magic number to tell computer this is bootable
times 510 - ($ - $$) db 0
dw 0xAA55