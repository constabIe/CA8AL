bits 32

extern io_get_dec, io_get_udec, io_get_hex 
extern io_get_char, io_get_string

extern io_print_dec, io_print_udec, io_print_hex 
extern io_print_char, io_print_string, io_newline

MAX_SIDE_LEN 	equ 	1000
MAX_QUANTITY 	equ 	1000
MAX_CAPACITY 	equ 	10000
MAX_HOUR 	 	equ 	23
MAX_MINUTE 	 	equ 	59
		
MIN_SIDE_LEN 	equ 	1
MIN_QUANTITY 	equ 	0
MIN_CAPACITY 	equ 	1
MIN_HOUR	 	equ 	0
MIN_MINUTE	 	equ 	0
	
VALID_HOUR_END 	equ 	5
MULTIPLICITY	equ 	3

section .text
global main
main:
	; input
	call io_get_dec

	cmp eax, MAX_SIDE_LEN
	jns RangeExceptionCondition

	cmp eax, MIN_SIDE_LEN
	js RangeExceptionCondition

	mov [n], eax

	call io_get_dec

	cmp eax, MAX_SIDE_LEN
	jns RangeExceptionCondition

	cmp eax, MIN_SIDE_LEN
	js RangeExceptionCondition

	mov [m], eax
	
	call io_get_dec

	cmp eax, MAX_QUANTITY
	jns RangeExceptionCondition

	cmp eax, MIN_QUANTITY
	js RangeExceptionCondition

	mov [k], eax
	
	call io_get_dec

	cmp eax, MAX_CAPACITY
	jns RangeExceptionCondition

	cmp eax, MIN_CAPACITY
	js RangeExceptionCondition

	mov [d], eax
	
	call io_get_dec

	cmp eax, MAX_HOUR
	jns RangeExceptionCondition

	cmp eax, MIN_HOUR
	js RangeExceptionCondition

	mov [x], eax
	
	call io_get_dec

	cmp eax, MAX_MINUTE
	jns RangeExceptionCondition

	cmp eax, MIN_MINUTE	
	js RangeExceptionCondition

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
	xor edx, edx
	idiv ebx

	mov [box_q], eax

	cmp edx, ebx
	js if_remainder
	jns continue_main

if_remainder: ; (remainder != 0)
	inc dword [box_q]

	jmp continue_main

continue_main:
	mov eax, [box_q]
	mov [result], eax

	mov eax, [x]

	cmp eax, VALID_HOUR_END
	jns if_hour
	js exit_program

if_hour: ; transpoortation time in appropriate
	mov eax, [box_q]
	mov ecx, MULTIPLICITY
	xor edx, edx
	idiv ecx

	sub [result], eax

	jmp exit_program

exit_program:
	mov eax, [result]
	call io_print_dec

	xor eax, eax
	ret

RangeExceptionCondition:
	mov eax, RangeExceptionMessage

	call io_print_string
	call io_newline

	xor eax, eax
	int 0x0A

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
	valid_hour_end:		dd		5
	RangeExceptionMessage	db `Input data is out of range`, 0

