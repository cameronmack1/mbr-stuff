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
    mov bl, 0x0F
    xor di, di
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
    xor al, al
    test dx, 3
    cmove ax, bx
    
    ; save the value to the cell
    stosb
    loop init_screen

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
    mov cx, 64000 ; there are 64000 pixels, we want to loop 64000 times
    xor di, di ; reset di to 0
first_pass:
    ; check if current cell is alive
    test byte [es:di], 1
    jz .end
    mov ax, 0x1010
    ; increment the upper nibble of the current cell's neighbors
    add byte [es:di - 1], al
    add byte [es:di + 1], al
    add word [es:di - 321], ax
    add byte [es:di - 319], al
    add word [es:di + 319], ax
    add byte [es:di + 321], al
    .end:
        inc di
        loop first_pass 
    mov cx, 64000 ; there are 64000 pixels, we want to loop 64000 times
    xor di, di ; reset di to 0
second_pass:
    ; check if cell should be alive or dead
    mov al, [es:di]
    mov ah, al

    and al, 0x01
    shr ah, 4
    or al, ah

    cmp al, 3
    sete al
    mul bl
    stosb
    loop second_pass
    jmp main_loop
; magic number to tell computer this is bootable
times 510 - ($ - $$) db 0
dw 0xAA55