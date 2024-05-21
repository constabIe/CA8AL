bits 32

%include "io.inc"

section .text

%define	k 	dword [ebp + 12]
%define val dword [ebp +  8]

global 	not_just_zeros
not_just_zeros:
	push  	ebp
	mov  	ebp, esp

	push  	ebx
	push  	ecx	

	mov 	eax, 0
	mov 	ecx, 31
	.find_one_loop:
		cmp 	ecx, 0
		jb 		not_just_zeros.exit_function

		bt 		val, ecx
		jc 		not_just_zeros.bit_one

		dec 	ecx
		jmp 	not_just_zeros.find_one_loop

		.bit_one:
			mov 	ebx, ecx
			jmp  	not_just_zeros.count_zeros_loop_prepares

	.count_zeros_loop_prepares:
		xor 	eax, eax

	.count_zeros_loop:
		cmp  	ebx, 0
		jb 		not_just_zeros.exit_function

		bt 		val, ebx
		jnc 	not_just_zeros.continue_count_zeros_loop

		.zero_flag_true:
			inc  	eax
			jmp 	not_just_zeros.continue_count_zeros_loop

	.continue_count_zeros_loop:
		dec  	ebx

		jmp  	not_just_zeros.count_zeros_loop

	cmp		eax, k
	je 		not_just_zeros.exit_function
	
	mov  	eax, 0

.exit_function:
	pop 	ecx
	pop 	ebx

	mov 	esp, ebp
	pop 	ebp

	ret

%undef k 
%undef val

global main
main:
	push	ebp
	mov 	ebp, esp

	push	ebx
	push	esi

	push	eax	
	push	ecx
	push	edx

	GET_DEC	4, edx
	mov 	[n], edx

	xor  	ecx, ecx
	xor  	ebx, ebx
	input_loop:
		cmp 	ecx, edx
		jae 	continue_main

		GET_DEC 4, dword [vals_arr + ebx]

		add 	ebx, DWORD_BYTE_SIZE
		inc 	ecx

		jmp 	input_loop

continue_main:
	xor  	ecx, ecx
	xor  	ebx, ebx
	xor  	esi, esi
	verifying_loop:
		cmp 	ecx, edx
		jae 	output

		push 	dword [vals_arr + ebx]
		push 	dword [k]
		call 	not_just_zeros

		add		esi, eax

		add 	ebx, INT_BYTE_SIZE
		inc 	ecx

		jmp 	verifying_loop

output:
	PRINT_DEC 4, esi
	NEWLINE

exit_main:
	pop		edx
	pop		ecx
	pop 	eax

	pop		esi
	pop		ebx

	mov		esp, ebp
	pop 	ebp

	xor		eax, eax
	ret

section .data
	MAX_INPUT_QUANTITY	equ 1000
	DWORD_BYTE_SIZE		equ	4

section .bss 
	n 			resd 	1
	k 			resd	1
	vals_arr	resd 	MAX_INPUT_QUANTITY	
