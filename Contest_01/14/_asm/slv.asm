bits 32

extern io_get_dec, io_get_udec, io_get_hex 
extern io_get_char, io_get_string

extern io_print_dec, io_print_udec, io_print_hex 
extern io_print_char, o_print_string, io_newline


section .text
global main
main:
	; input
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

	mov [s], ebx

	; beetroot quantity
	mov ebx, [k]
	imul ebx

	mov [beet_q], eax

	; boxes quantity
	mov ebx, [d]
	idiv ebx

	mov [box_q], eax

	cmp edx, ebx
	js valid_remainder
	
	mov eax, [box_q]
	mov [result], eax

	mov eax, [x]
	cmp [valid_hour_end], eax
	js invalid_hour

	; output
	mov eax, [result]
	call io_print_dec

	xor eax, eax
	ret

valid_remainder:
	inc dword [box_q]

invalid_hour:
	mov eax, [box_q]
	idiv 3

	sub [result], eax


section .bss
	n:					resd	1
	m:					resd	1
	k:					resd	1
	d:					resd	1
	x:					resd	1
	y:					resd	1
			
	s:					resd	1
	beet_q:				resd	1
	box_q:				resd	1
	result:				resd	1

section .rodata
	valid_hour_start:	dd		0
	valid_hour_end:		dd		5
