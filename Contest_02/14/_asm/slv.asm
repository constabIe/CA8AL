bits 32

%include "io.inc"

section .text

global factorial

%define		val 	dword [ebp + 8]

factorial:
	push 	ebp
	mov 	ebp, esp

	push  	ecx

	cmp  	val, 0
	jb 		factorial.RangeExceptionLabel
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

.RangeExceptionLabel:
	PRINT_STRING RangeExceptionMessage
	NEWLINE

	int 0x0A

global main
main:
	GET_DEC	4, eax
	mov 	[n], eax

	push  	eax
	call 	factorial

	PRINT_DEC 4, eax

	xor 	eax, eax
	ret

section .bss
	n: 	resd 	1

section .rodata
	RangeExceptionMessage	db `Input data is out of range`, 0


