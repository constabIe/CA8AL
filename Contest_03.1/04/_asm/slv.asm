bits 32

%include "io.inc"

section .text
global reverse_half
reverse_half:
	push 	ebp
	mov 	ebp, esp

	push 	eax		; input storage
	push 	ecx 	; common iterator
	push  	ebx 	; even iterator

	sub     esp, 12

	xor 	ecx, ecx
	xor  	ebx, ebx

	.while:
		GET_DEC 4, eax

		cmp  	eax, 0
		jz 		.exit_while

		bt 		ecx, 0
		jnc 	.out_odd
		jc 		.in_even

		.out_odd: 	
			PRINT_DEC 	4, eax
			PRINT_CHAR 	` `

			inc 	ecx

			jmp 	.while

		.in_even:
			inc 	ecx
			inc  	ebx

			push 	eax

			jmp 	.while

	.exit_while:
		jmp .out_even_loop

	.out_even_loop:
		cmp 	ebx, 0
		jz 		.exit_function 		

		pop  	eax

		PRINT_DEC 	4, eax
		PRINT_CHAR 	` `

		dec 	ebx
		jmp 	.out_even_loop

	.exit_function:
		NEWLINE

    	add     esp, 12

		pop  	ebx
		pop  	ecx
		pop  	eax

		mov  	esp, ebp
		pop  	ebp

		ret

global main:
main:
	push 	ebp
	mov 	ebp, esp

	push 	eax
	push 	ecx
	push  	ebx

	sub     esp, 12

	call 	reverse_half

    add     esp, 12

	pop  	ebx
	pop  	ecx
	pop 	eax

	mov  	esp, ebp
	pop  	ebp

	xor  	eax, eax
	ret



