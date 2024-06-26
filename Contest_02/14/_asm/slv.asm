bits 32

%include "io.inc"

section .text

global main
main:
	push 	ebp
	mov 	ebp, esp

	GET_DEC	4, eax
	mov 	[n], eax

	GET_DEC	4, eax
	mov 	[k], eax

	ALIGN_STACKK	8
	push	dword []
	push	dword [k]
	call	combination
	UNALIGN_STACKK

	PRINT_DEC 4, eax
	; mov 	eax, dword [n]
	; mov 	ecx, 31

	; loop_find_n:
	; 	cmp		ecx, 0
	; 	jl		loop_exit_find_n

	; 	bt		eax, ecx
	; 	jc 		loop_zeros

	; 	dec  	ecx
	; 	jmp  	loop_find_n

	; 	significant_zeros:
	; 		dec 	ecx
	; 		mov 	ebx, ecx

	mov 	esp, ebp 
	pop 	ebp

	xor 	eax, eax
	ret

%define	k 					dword [ebp + 12]
%define	n 					dword [ebp +  8]

%define n_factorial 		dword [ebp -  4]
%define k_factorial 		dword [ebp -  8]
%define n_sub_k_factorial 	dword [ebp - 12]

global combination
combination:
	push 	ebp
	mov 	ebp, esp

	sub 	esp, 12

	push 	ebx

	; verify arguments
	cmp  	k, 1
	jl 		RangeExceptionLabel

	mov  	eax, n
	cmp  	k, eax
	ja 		RangeExceptionLabel

	ALIGN_STACKK 4
	push	n
	call	factorial
	UNALIGN_STACKK

	mov		n_factorial, eax

	ALIGN_STACKK 4
	push 	k
	call 	factorial
	UNALIGN_STACKK

	mov 	k_factorial, eax

	mov		eax, n
	sub		eax, k

	ALIGN_STACKK 4	
	push	eax
	call 	factorial
	UNALIGN_STACKK

	mov	    n_sub_k_factorial, eax

	ALIGN_STACKK 4
	mov 	eax, k_factorial
	imul 	n_sub_k_factorial
	UNALIGN_STACKK

	mov		ebx, eax

	mov 	eax, n_factorial
	cdq		
	idiv	ebx

	pop  	ebx

	add		esp, 12

	mov  	esp, ebp
	pop 	ebp

	ret 

%undef	k
%undef	n

%define	val	dword [ebp + 8]

global factorial
factorial:
	push 	ebp
	mov 	ebp, esp

	push  	ecx

	cmp  	val, 0
	jb 		RangeExceptionLabel
	je  	factorial.if_zero

	mov 	ecx, 1
	mov 	eax, 1

	.cycle:
		cmp  	ecx, val
		ja 		factorial.exit_cycle

		mul 	ecx

		inc 	ecx
		jmp 	factorial.cycle

	.exit_cycle:
		jmp 	factorial.exit_function

.if_zero:
	mov  eax, 1

	jmp factorial.exit_function

.exit_function:
	pop  	ecx

	mov  	esp, ebp
	pop 	ebp

	ret

%undef	val 

RangeExceptionLabel:
	PRINT_STRING RangeExceptionMessage
	NEWLINE

	int 0x0A

section .bss
	n: 	resd 	1
	k: 	resd 	1

section .rodata
	RangeExceptionMessage	db `Input data is out of range`, 0

