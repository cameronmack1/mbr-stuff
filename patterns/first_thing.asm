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
    mov cx, bx
    .loop:
        mov ax, [es:di]
        inc ax
        stosb
        loop .loop
    jmp main_loop

; magic number to tell computer this is bootable
times 510 - ($ - $$) db 0
dw 0xAA55