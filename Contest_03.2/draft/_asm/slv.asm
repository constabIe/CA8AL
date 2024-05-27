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

; ================================

global main
main:
	FUNCTION_PROLOGUE 0

	ALIGN_STACK 4
	push	arr
	call	arr_in
	UNALIGN_STACK 4

	ALIGN_STACK 4
	push	arr
	call	arr_out
	UNALIGN_STACK 4

	FUNCTION_EPILOGUE 0

	xor		eax, eax
	ret

; ================================

%define	arr_base 	dword [ebp + 8]
%define	iterator	dword [ebp - 4]

global	arr_in
arr_in:
	FUNCTION_PROLOGUE 4

	push	ebx

	mov		ebx, arr_base
	mov		iterator, 10

	.L:
		cmp		iterator, 0
		jle		arr_in.exit_func

		ALIGN_STACK 8
		push	ebx
		push	i_format
		call	scanf
		UNALIGN_STACK 8

		add		ebx, 4
		dec		iterator

		jmp		arr_in.L

.exit_func:
	pop		ebx

	FUNCTION_EPILOGUE 4

	ret

%undef	arr_base
%undef	iterator

%define	arr_base 	dword [ebp + 8]
%define	iterator	dword [ebp - 4]

global	arr_out
arr_out:
	FUNCTION_PROLOGUE 4

	push	ebx

	mov		ebx, arr_base
	mov		iterator, 10

	.L:
		cmp		iterator, 0
		jle		arr_out.exit_func

		ALIGN_STACK 8
		push	dword [ebx]
		push	o_format
		call	printf
		UNALIGN_STACK 8

		add		ebx, 4
		dec		iterator

		jmp		arr_out.L

.exit_func:
	pop		ebx

	FUNCTION_EPILOGUE 4

	ret

%undef	arr_base
%undef	iterator

section .data
	i_format	db		"%d", 0
	o_format	db		"%d ", 0

section .bss
	arr 		resd	10
