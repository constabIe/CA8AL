bits 32

%include "io.inc"

%macro ALIGN_STACK 1.nolist
	sub		esp, %1
	and		esp, 0xfffffff0
	add		esp, %1
%endmacro

%macro UNALIGN_STACK 1.nolist
	add		esp, %1
%endmacro

%macro FUNCTION_PROLOGUE 1.nolist
	enter	%1, 0
	and 	esp, 0xfffffff0
%endmacro

%macro FUNCTION_EPILOGUE 1.nolist
	add		esp, %1
	leave
%endmacro	

global main
main:
	FUNCTION_PROLOGUE 0



	FUNCTION_EPILOGUE 0

	ret

%define	pos		dword [ebp - 4]

global reverse_half
reverse_half:
	push	ebp
	mov		ebp, esp

	GET_DEC	4, eax

	bt		ebx, 0
	jc		

	cmp		eax, 0
	jne 	.recursion

	.recursion:


	mov		esp, ebp
	pop		ebp

	ret



