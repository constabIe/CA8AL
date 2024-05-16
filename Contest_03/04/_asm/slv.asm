bits 32

%include "io.inc"

section .text
global reverse_half
reverse_half:
	push 	ebp
	mov 	ebp, esp

	push 	eax
	push 	ecx

	xor 	ecx, ecx
	.while:
		GET_DEC 4, eax

		bt 		ecx, 31
		jc 		.out_odd
		jnc 	.in_even
		jmp 	.exit_while

		.out_odd: 	
			PRINT_DEC 	4, eax
			PRINT_CHAR 	` `

			jmp 	.while

		.in_even:
			inc 	ecx
			push 	eax

			jmp 	.while

	.exit_while:
		jmp .out_even_loop

	.out_even_loop:
		cmp 	ecx, 0
		jz 		.exit_function 		

		pop  	eax

		PRINT_DEC 4, eax
		PRINT_CHAR ` `

		dec 	ecx
		jmp 	.out_even_loop

	.exit_function:
		pop  	ecx
		pop  	eax

		mov  	esp, ebp
		pop  	ebp

		ret

global main:
main:
	call 	reverse_half

	xor  	eax, eax
	ret



