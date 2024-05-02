bits 32

extern io_get_dec, io_get_udec, io_get_hex 
extern io_get_char, io_get_string

extern io_print_dec, io_print_udec, io_print_hex 
extern io_print_char, o_print_string, io_newline


section .text
global main
main:
	call io_get_udec
	mov byte [a], al

	call io_get_udec
	mov byte [b], al

	
	call io_get_udec
	mov byte [c], al

	
	call io_get_udec
	mov byte [d], al


	mov eax, 0

	or al, byte [d]
	shl eax, 8

	or al, byte [c]
	shl eax, 8

	or al, byte [b]
	shl eax, 8

	or al, byte [a]


	call io_print_udec
	

section .bss
a:		resb 1
b:		resb 1
c:		resb 1
d:		resb 1
