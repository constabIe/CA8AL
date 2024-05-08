bits 32

extern io_get_dec, io_get_udec, io_get_hex 
extern io_get_char, io_get_string

extern io_print_dec, io_print_udec, io_print_hex 
extern io_print_char, o_print_string, io_newline

UINT32_LEN	equ	32
UINT32_MAX	equ 0xFFFFFFFF

section .text
global main
main:
	; input	
	call io_get_udec
	mov [n], eax

	call io_get_udec
	mov [k], eax

	; prepare variables for the cycle
	mov ebx, UINT32_LEN 				; initial shift size
	sub ebx, [k]
	mov [initial_shift_size], ebx

	shl dword [template], ebx

	inc dword [initial_shift_size]
	mov ecx, [initial_shift_size]

find_max_cycle:
	mov eax, [template]
	and eax, [n]
	shr eax, ecx

	cmp eax, [max_val]
	jns if_1 							

	shr dword [template], 1

	loop find_max_cycle

	mov eax, [max_val]
	call io_print_udec

	xor eax, eax
	ret

if_1:						; val > max_val
	mov [max_val], eax


section .bss
	n:					resd 	1
	k:					resd	1
	initial_shift_size:	resd	1


section .data
	template:			dd		UINT32_MAX
	max_val:			dd 		0

