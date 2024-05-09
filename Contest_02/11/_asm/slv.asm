bits 32

%include "io.inc"

MAX_LIMIT 	equ	1000000000
MIN_LIMIT 	equ	2

section .text
global main
main:
	; get and verify input
	GET_DEC 4, eax
	mov [a], eax

	cmp eax, MIN_LIMIT
	js RangeExceptionCondition

	cmp eax, MAX_LIMIT
	jns RangeExceptionCondition

	GET_DEC 4, ebx
	mov [b], ebx

	cmp ebx, MIN_LIMIT
	js RangeExceptionCondition

	cmp ebx, MAX_LIMIT
	jns RangeExceptionCondition

	; a = max(a, b) 
	cmp eax, ebx
	js if_b_more_than_a

	mov eax, [a] ; divisible
	mov ebx, [b] ; divinded
	mov ecx, [b] ; r_prev
				 ; edx = r_curr

	jmp gcd_cycle

if_b_more_than_a:
	xchg eax, ebx
	mov [a], eax
	mov [b], ebx

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
	PRINT_DEC 4, ecx
	NEWLINE

	xor eax, eax
	ret

RangeExceptionCondition:
	PRINT_STRING RangeExceptionMessage
	NEWLINE

	xor eax, eax
	int 0x0A

section .bss
	a:	resd	1
	b:	resd	1

section .rodata
	RangeExceptionMessage	db	`Input data is out of range`, 0

