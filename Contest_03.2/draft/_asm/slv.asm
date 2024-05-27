bits 32

extern	scanf, printf

section .text

%macro FUNCTION_PROLOGUE 1.nolist
	enter	%1, 0
	and 	esp, 0xfffffff0
%endmacro

%macro FUNCTION_EPILOGUE 1.nolist
	add		esp, %1
	leave
%endmacro

%macro ALIGN_STACK 1.nolist
	sub		esp, %1
	and 	esp, 0xfffffff0
	add		esp, %1
%endmacro

%macro UNALIGN_STACK 1.nolist
	add		esp, %1
%endmacro

%define	arr_base 	dword [ebp + 8]
%define	iterator	dword [ebp - 4]

global	arr_out
arr_out:
	FUNCTION_PROLOGUE 4

	push	ebx

	mov		ebx, arr_base
	mov		iterator, 0

	.L:
		cmp		iterator, 10
		jae		arr_out.exit_func

		ALIGN_STACK 8
		push	dword [ebx]
		push	o_format
		call	printf
		UNALIGN_STACK 8

		add		ebx, 4
		add		iterator, 1

		jmp		arr_out.L

.exit_func:
	pop		ebx

	FUNCTION_EPILOGUE 4

	ret

section .data
	arr 		dd		0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	o_format	db		"%d ", 0
