section .data
    prefix        db "User just chugged ", 0
    nums          db 8, 6, 4, 2            ; % left in glass each round
    suffix_tmpl   db " 00% remains. ", 0
    newline       db 10
    message       db "Intern appears; glass magically full again.", 0
    quitMessage   db "Intern gave up. User dehydrated.", 0

section .bss
    counter       resb 1                   ; how many rounds of thirst we tolerate

section .text
    global _start

_start:
    ; Begin with full patience (4 rounds)
    mov byte [counter], 4

round_loop:
    xor esi, esi                           ; reset drink index

print_loop:
    ; Write prefix: "User just chugged "
    mov eax, 4
    mov ebx, 1
    mov ecx, prefix
    mov edx, 20
    int 0x80

    ; Get percentage value (nums[esi]) * 10
    mov al, [nums + esi]
    xor ah, ah
    imul ax, ax, 10                        ; multiply by 10 to get percentage

    mov dl, 10
    div dl                                 ; AX / 10 → AL = tens, AH = ones

    ; Insert digits into suffix string
    add al, '0'
    mov [suffix_tmpl + 1], al              ; tens place
    add ah, '0'
    mov [suffix_tmpl + 2], ah              ; ones place

    ; Write suffix: " 00% remains."
    mov eax, 4
    mov ebx, 1
    mov ecx, suffix_tmpl
    mov edx, 16
    int 0x80

    inc esi
    cmp esi, 4
    jl print_loop

    ; Determine which dramatic message to display
    mov eax, 4
    mov ebx, 1
    cmp byte [counter], 1
    jne .not_last

    mov ecx, quitMessage
    mov edx, 32
    jmp .print_message

.not_last:
    mov ecx, message
    mov edx, 40

.print_message:
    int 0x80

    ; Add a newline after message, unless it's the final message
    cmp byte [counter], 1
    je .skip_newline

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

.skip_newline:
    ; Decrease patience level
    dec byte [counter]
    cmp byte [counter], 0
    jg round_loop

    ; Exit peacefully
    mov eax, 1
    xor ebx, ebx
    int 0x80

