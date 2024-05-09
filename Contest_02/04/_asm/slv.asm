bits 32

%include "io.inc"

section .text
global main
main:
	; get input
	GET_UDEC 4, eax
	; mov [n], eax

	; I am going to divide [n] to 8 until quotient -- result of division -- more than 8. I.e. the standard steps for converting 
	; from the 10 to 8 number system 

	mov ebx, 8
	mov ecx, 0

	jmp cycle
cycle:
	inc ecx

	cdq
	div ebx

	cmp edx, ebx
	jns if 		; quotient < 8
	jns else

if: 
	push edx
	jmp cycle

else:
	push eax
	jmp output_loop

output_loop:
	pop eax
	PRINT_UDEC 4, eax

	loop output_loop

; section .bss
; 	n:	resd	1

