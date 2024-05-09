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

if: 			; quotient < 8
	push edx
	jmp loopp

else:
	push eax
	jmp output_loop

output_loop:
	pop eax
	PRINT_UDEC 4, eax

	loop output_loop