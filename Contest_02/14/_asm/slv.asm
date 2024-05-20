bits 32

%include "io.inc"

section .text
RangeExceptionLabel:
	PRINT_STRING RangeExceptionMessage
	NEWLINE

	int 0x0A

global main
main:
	GET_DEC	4, eax
	mov 	[n], eax

	GET_DEC	4, eax
	mov 	[k], eax

	push  	dword [n]
	push  	dword [k]	
	call 	combination

	PRINT_DEC 4, eax

	xor 	eax, eax
	ret

%define	k 	dword [ebp + 12]
%define	n 	dword [ebp + 8]

global combination
combination:
	push 	ebp
	mov 	ebp, esp

	push 	ebx ; n!
	push 	ecx ; k!
	push 	edx ; (n - k)!
	push  	esi	; interim calculations

	; verify arguments
	cmp  	k, 1
	jb 		RangeExceptionLabel

	mov  	eax, n
	cmp  	k, eax
	ja 		RangeExceptionLabel

	push 	n
	call  	factorial
	mov 	ebx, eax

	push 	k
	call  	factorial
	mov 	ecx, eax

	mov 	esi, n
	sub 	esi, k

	push 	esi
	call 	factorial
	mov 	edx, eax

	mov 	eax, ecx
	mul 	edx

	mov  	ecx, eax

	mov  	eax, ebx
	cdq 	
	div 	ecx

	pop 	esi
	pop 	edx
	pop 	ecx
	pop  	ebx

	mov  	esp, ebp
	pop 	ebp

	ret 

%undef	k
%undef	n

%define	val 	dword [ebp + 8]

global factorial
factorial:
	push 	ebp
	mov 	ebp, esp

	push  	ecx

	cmp  	val, 0
	jb 		RangeExceptionLabel
	je  	.if_zero

	mov 	ecx, 1
	mov 	eax, 1

	.cycle:
		cmp  	ecx, val
		ja 		.exit_cycle

		mul 	ecx

		inc 	ecx

		jmp 	.cycle

	.exit_cycle:
		jmp 	.exit_function

.if_zero:
	mov  eax, 1

	jmp .exit_function

.exit_function:
	pop  	ecx

	mov  	esp, ebp
	pop 	ebp

	ret

%undef	val 

section .bss
	n: 	resd 	1
	k: 	resd 	1

section .rodata
	RangeExceptionMessage	db `Input data is out of range`, 0

