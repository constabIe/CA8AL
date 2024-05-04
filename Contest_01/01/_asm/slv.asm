bits 32

extern io_get_dec, io_get_udec, io_get_hex 
extern io_get_char, io_get_string

extern io_print_dec, io_print_udec, io_print_hex 
extern io_print_char, o_print_string, io_newline

; S_x = t * (vx + ax_half * t)
; S_y = t * (vy + ay_half * t)

section .text
global main
main:
	; get input
	call io_get_dec
	mov dword [v], eax

	call io_get_dec
	mov dword [v + 1], eax

	call io_get_dec
	mov dword [a_half], eax

	call io_get_dec
	mov dword [a_half + 1], eax

	call io_get_dec
	mov dword [t], eax

	; interim calculations
	mov eax, [a_half]
	mov ecx, [t]
	mul ecx

	add eax, [v]

	mul ecx

	mov [S], eax

	mov eax, [a_half + 1]
	mov ecx, [t]
	mul ecx

	add eax, [v + 1]

	mul ecx

	mov [S + 1], eax

	; result output
	mov eax, [S]
	call io_print_dec

	mov eax, space
	call io_print_char

	mov eax, [S + 1]
	call io_print_dec

	xor eax, eax
	ret 0


section .bss
	; R \in \mathbb{R} ^ 2
	v:			resd 2
	a_half:		resd 2
	t:			resd 1
	S:			resd 2


section .rodata
	space: 		db ` `


