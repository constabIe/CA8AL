bits 32

extern io_get_dec, io_get_udec, io_get_hex 
extern io_get_char, io_get_string

extern io_print_dec, io_print_udec, io_print_hex 
extern io_print_char, io_print_string, io_newline

MAX_LIMIT equ	1000000000
MIN_LIMIT equ	2

section .text
global main
main:
	; get and verify input
	call io_get_dec
	mov [a], eax

	cmp eax, MIN_LIMIT
	js RangeExceptionCondition

	cmp eax, MAX_LIMIT
	jns RangeExceptionCondition

	call io_get_dec
	mov [b], eax

	cmp eax, MIN_LIMIT
	js RangeExceptionCondition

	cmp eax, MAX_LIMIT
	jns RangeExceptionCondition

	mov eax, [a] ; divisible
	mov ebx, [b] ; divinded
	mov ecx, [b] ; r_prev

	jmp gcd_cycle

	; Euclidean algorithm
gcd_cycle:
	cdq
	idiv ebx

	test edx, edx
	jz if_remainder_eq_to_zero

	mov eax, ebx 
	mov ebx, edx 
	mov ecx, edx 

	jmp gcd_cycle

if_remainder_eq_to_zero:
	jmp exit_program

exit_program:
	mov eax, ecx
	call io_print_dec
	call io_newline

	xor eax, eax
	ret

RangeExceptionCondition:
	mov eax, RangeExceptionMessage
	call io_print_string
	call io_newline

	xor eax, eax
	int 0x0A

section .bss
	a:	resd	1
	b:	resd	1

section .rodata
	RangeExceptionMessage	db	`Inputed data is out of range`, 0