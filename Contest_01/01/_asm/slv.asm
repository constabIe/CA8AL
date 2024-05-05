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
	; input
	call io_get_dec
	mov [v_xy], eax

	call io_get_dec
	mov [v_xy + 1], eax

	call io_get_dec
	mov [a_xy_half], eax

	call io_get_dec
	mov [a_xy_half + 1], eax

	call io_get_dec
	mov [t], eax

	; calculations
	; S_x
	mov eax, [a_xy_half]
	mul [t]

	add eax, [v_xy]

	mul [t]

	mov [s_xy], eax

	; S_y
	mov eax, [a_xy_half + 1]
	mul [t]

	add eax, [v_xy + 1]

	mul [t]

	mov [s_xy + 1], eax

	; output
	mov eax, [s_xy]
	call io_print_dec

	mov eax, space
	call io_print_char

	mov eax, [s_xy + 1]
	call io_print_dec

	xor eax, eax
	ret
	
section .bss 
	v_xy:		resd 	2
	a_xy_half:	resd 	2
	t: 			resd 	1
	s_xy:		resd 	2

section .data
	space		db 		0x20

