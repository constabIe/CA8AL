bits 32

%include "io.inc"

global div3
%define	value 			dword [ebp + 8]
%define iterations_q	15

div3:
	push 	ebp
	mov 	ebp, esp

	push  	ebx		; itterator 
	push 	edx		; bit position
	push 	esi		; check sub

	xor ebx, ebx
	xor edx, edx
	inc edx

.loop_half_even:
	cmp 	ebx, iterations_q	
	jae 	.exit_loop_half_even

	bt 		value, edx

	jc 		.bit_1_even
	jmp 	.continue_loop_half_even
	
	.bit_1_even:
		add esi, 1
		jmp .continue_loop_half_even

.continue_loop_half_even:
	inc 	ebx
	add 	edx, 2

	jmp 	.loop_half_even

.exit_loop_half_even:
	xor ebx, ebx
	xor edx, edx

.loop_half_odd:
	cmp 	ebx, iterations_q
	jae 	.exit_loop_half_odd

	bt 		value, edx

	jc 		.bit_1_odd
	jmp 	.continue_loop_half_odd
	
	.bit_1_odd:
		sub 	esi, 1
		jmp 	.continue_loop_half_odd

.continue_loop_half_odd:
	inc 	ebx
	add 	ebx, 2

	jmp 	.loop_half_odd

.exit_loop_half_odd:
	xor 	ebx, ebx
	xor 	edx, edx

.flag_setting:
	cmp 	esi, 15
	jz 		.flag_true

	cmp 	esi, 12
	jz 		.flag_true

	cmp 	esi, 9
	jz 		.flag_true

	cmp 	esi, 6
	jz 		.flag_true	

	cmp 	esi, 3
	jz 		.flag_true	

	cmp 	esi, 0
	jz 		.flag_true		

	jmp 	.flag_false


.flag_false:
	mov 	eax, 0
	jmp 	.exit_func

.flag_true:
	mov 	eax, 1
	jmp 	.exit_func

.exit_func:
	pop  	esi	; itterator 
	pop 	edx	; bit position
	pop 	ebx	; check sub

	mov 	esp, ebp
	pop 	ebp

	ret

global RangeExceptionCondition
RangeExceptionCondition:
	PRINT_STRING RangeExceptionMessage
	NEWLINE

	xor 	eax, eax
	int 	0x0A

section .text
global main
main:
	GET_DEC 4, eax

	cmp 	eax, MAX_VALUE
	ja 		RangeExceptionCondition

	cmp 	eax, MIN_VALUE
	jb 		RangeExceptionCondition

	mov 	[n], eax

	mov 	ecx, eax

cycle:	
	cmp 	ecx, [n]
	jae 	exit_cycle

	GET_UDEC 4, eax

	mov 	value, eax
	call 	div3

	cmp 	eax, 1
	jz 		div3_true
	jnz 	div3_false

	div3_true:
		PRINT_STRING 	YES
		NEWLINE

		jmp continue_cycle

	div3_false:
		PRINT_STRING 	NO
		NEWLINE

		jmp continue_cycle

continue_cycle:
	dec ecx

	jmp cycle

exit_cycle:
	jmp exit_program

exit_program:
	xor eax, eax
	ret

section .bss
	n: 						resd 	1

section .data
	MAX_VALUE				equ		100000
	MIN_VALUE				equ		1

section .rodata
	RangeExceptionMessage	db 		`Input data is out of range`, 0

	YES						db		`YES`, 0
	NO						db		`NO`, 0