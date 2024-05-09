bits 32

%include "io.inc"

section .text
global main
main:
	GET_UDEC 4, eax 

	mov ebx, 8
	xor ecx, ecx

	jmp loopp

loopp:
	inc ecx

	xor edx, edx
	div ebx

	cmp eax, ebx
	jns if 		
	js else

if: 
	push edx
	jmp loopp

else:
	push edx

	cmp eax, 0
	jnz else_if
	
	inc ecx

	jmp output_loop

else_if:
	push eax

output_loop:
	pop eax

	PRINT_UDEC 4, eax

	loop output_loop

	jmp exit_program

exit_program:
	NEWLINE

	xor eax, eax
	ret

