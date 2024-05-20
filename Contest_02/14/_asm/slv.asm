bits 32

%inclue "io.inc"

section .text
global factorial

%define		n 	dword [ebp + 8]

factorial:
	push 	ebp
	mov 	ebp, esp

	push  	ecx

	cmp  	n, 0
	jb 		.RangeExceptionLabel
	je  	.if_zero

	mov 	ecx, 1
	mov 	eax, 1

	.cycle:
		cmp  	ecx, n
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
	pop  	ebx

	mov  	esp, ebp
	pop 	ebp

	ret

.RangeExceptionLabel:
	PRINT_STRING RangeExceptionMessage
	NEWLINE

	int 0x0A

global main
main:
	GET_DEC	4, eax ; n

	; GET_DEC	4, ebx	; k

	push  	eax
	call 	factorial

	PRINT_DEC 4, eax

	xor 	eax, eax
	ret

section .bss
	n: 	resd 	1
	; k: 	resd	1

section .rodata
	RangeExceptionMessage	db `Input data is out of range`, 0


