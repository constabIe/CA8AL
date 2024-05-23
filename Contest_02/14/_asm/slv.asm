bits 32

%include "io.inc"

section .text

%macro ALIGN_STACK 1.nolist
    sub     esp, %1
    and     esp, 0xfffffff0
    add     esp, %1
%endmacro

%macro UNALIGN_STACK 1.nolist
    add     esp, %1
%endmacro

global main
main:
	push 	ebp
	mov 	ebp, esp

	GET_DEC	4, eax
	mov 	[n], eax

	GET_DEC	4, eax
	mov 	[k], eax

<<<<<<< HEAD
	push	dword [n]
	push	dword [k]
	call	combination
=======
	ALIGN_STACK 8	
	push  	dword [k]
	push  	dword [n]	
	call 	combination
	UNALIGN_STACK 8
>>>>>>> parent of 14b9c2c (02-14: Двоичные нули. Sample #14)

	PRINT_DEC 4, eax
	NEWLINE
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
	; cmp  	k, 1
	; jl 		RangeExceptionLabel

	; mov  	eax, n
	; cmp  	k, eax
	; ja 		RangeExceptionLabel

	ALIGN_STACK 4
	push	n
	call	factorial
	UNALIGN_STACK 4

	PRINT_CHAR `w`
	NEWLINE

	mov		n_factorial, eax

	ALIGN_STACK 4
	push 	k
	call 	factorial
	UNALIGN_STACK 4

	mov 	k_factorial, eax

	mov		eax, n
	sub		eax, k

<<<<<<< HEAD
=======
	ALIGN_STACK 4	
>>>>>>> parent of 14b9c2c (02-14: Двоичные нули. Sample #14)
	push	eax
	call 	factorial
	UNALIGN_STACK 4

	mov	    n_sub_k_factorial, eax

	mov 	eax, k_factorial
	imul 	n_sub_k_factorial

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

