bits 32

extern io_get_dec, io_get_udec, io_get_hex 
extern io_get_char, io_get_string

extern io_print_dec, io_print_udec, io_print_hex 
extern io_print_char, o_print_string, io_newline


section .text
global main
main:
	call io_get_dec
	mov [n], eax

	call io_get_dec
	mov [m], eax

	call io_get_dec
	mov [k], eax

	call io_get_dec
	mov [d], eax

	call io_get_dec
	mov [x], eax

	call io_get_dec
	mov [y], eax

	; field square 
	mov eax, [n]
	mov ebx, [m]
	imul ebx

	mov [s], eax

	; beetroot quantity
	mov ebx, [k]
	imul ebx

	mov [beet_q], eax

	; boxes quantity
	mov eax, [d]
	mov ebx, [beet_q]
	; cdq 				; maybe using uint32_t would be the better way 
	idiv ebx

	; box_q++ if remainder != 0
	sub edx, [d]

	test edx, edx
	js valid_remainder:

	mov [result], ebx ; result = beet_q

	mov eax, [hour_end]
	sub eax, [x]

	test eax, eax
	; jns valid_hour
	js invalid_hour	

	mov eax, [result]
	call io_print_dec

	xor eax, eax
	ret

valid_remainder:
	inc [beet_q]

; valid_hour:
; 	mov eax, [box_q]
; 	mov [result], eax

invalid_hour:
	mov eax, [beet_q]
	mov ebx, 0x0003
	cdq
	idiv ebx

	sub [result], eax




section .bss
	n:			resd 	1
	m:			resd 	1 
	k:			resd 	1
	d:			resd 	1
	x:			resd 	1
	y:			resd 	1

	s:			resd 	1
	beet_q:		resd 	1
	box_q:		resd 	1
	result:		resd	1


section .rodata
	; appropriate time
	hour_start 	dd		0
	minute_start dd 		0
	hour_end	dd		5
	minute_end	dd 		59

