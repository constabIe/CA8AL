bits 32

extern io_get_dec, io_get_udec, io_get_hex 
extern io_get_char, io_get_string

extern io_print_dec, io_print_udec, io_print_hex 
extern io_print_char, io_print_string, io_newline

UINT32_LEN	equ	32
UINT32_MAX	equ	0xFFFFFFFF

section	.text
global main
	; get and check input
	call io_get_udec
	mov [n], eax

	call io_get_dec
	mov [k], eax

	cmp eax, 31
	jns RangeException

	; [template] and itterator preparing
	mov ecx, UINT32_MAX
	sub ecx, [k]

	mov eax, [template]
	shl dword [template], cl

	; cycle to find [max_value] 
find_max_loop:
	mov eax, [template]
	and eax, [n]

	shr eax, cl

	cmp [max_value], eax
	js if
	jns continue_loop

if:							; val > max_val
	mov [max_value], eax
	jmp continue_loop

continue_loop:
	shr dword [template], 1

	dec ecx
	jns find_max_loop
	js exit_program

exit_program:
	call io_print_udec

	xor eax, eax
	ret

RangeException:
	mov eax, [RangeExceptionMessage]
	call io_print_string

	xor eax, eax
	int 0x0A 

section .bss
	n:	resd	1
	k:	resd	1

section .data
	template	dd 	UINT32_MAX
	max_value	dd 	0

section .rodata
	RangeExceptionMessage	db `Invalid input`, 0


