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

    
    ; get system time since midnight as initial random in dx
    mov ah, 0x00
    int 0x1A

    ; initialize
    mov cx, 64000
    mov bx, 0x000F
init_screen:
    ; 16 bit xorshift algorithm
    mov ax, dx
    shl ax, 7
    xor dx, ax
    mov al, dh
    shr al, 1
    xor dl, al
    xor dh, dl

    ; set that cell to 1 if the low to bits of dx are both 0, aka 25% of the board is alive
    xor ax, ax
    test dx, 3
    cmove ax, bx
    
    stosb
    loop init_screen

hang:
    jmp hang
; magic number to tell computer this is bootable
times 510 - ($ - $$) db 0
dw 0xAA55