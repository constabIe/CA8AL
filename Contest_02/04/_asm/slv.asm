bits 32

%include "io.inc"

section .text
global main
main:
	; get input
	GET_UDEC 4, eax

	; I am going to divide [n] to 8 until quotient -- result of division -- more than 8. I.e. the standard steps for converting 
	; from the 10 to 8 number system 

	mov ebx, 8
	xor ecx, ecx
	xor edx, edx

	jmp loopp

loopp:
	inc ecx

	cdq
	div ebx

	cmp edx, ebx
	jns if 		
	jns else

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