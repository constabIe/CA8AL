bits 32

%include "io.inc"

section .text
global main
main:
	; input
	GET_DEC 4, eax
	mov [a], eax

	GET_DEC 4, ebx
	mov [b], ebx

	; a = max(a, b) 
	cmp eax, ebx
	js if_1
	jns continue_main

if_1: ; (b > a)
	xchg eax, ebx
	mov [a], eax
	mov [b], ebx

	jmp continue_main

continue_main:
	mov eax, [a] ; divisible
	mov ebx, [b] ; divinded
	mov ecx, [b] ; r_prev
				 ; edx = r_curr

	jmp gcd_cycle

	; Euclidean algorithm
gcd_cycle:
	xor edx, edx
	div ebx

	test edx, edx
	jz if_2

	mov eax, ebx 
	mov ebx, edx 
	mov ecx, edx 

	jmp gcd_cycle

if_2: ; (remainder == 0)
	jmp exit_program

exit_program:
	PRINT_UDEC 4, ecx
	NEWLINE

	xor eax, eax
	ret

section .bss
	a:	resd	1
	b:	resd	1

