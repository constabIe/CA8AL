bits 32

extern	scanf, printf

section .text

%macro ALIGN_STACK 1.nolist
	sub		esp, %1
	and		esp, 0xfffffff0
	add		esp, %1
%endmacro

%macro UNALIGN_STACK 1.nolist
	add		esp, %1
%endmacro

; ==============================
global main
main:	
	enter 	0, 0

	ALIGN_STACK 4
	push	arr
	call	scanf_arr
	UNALIGN_STACK 4

	ALIGN_STACK 4
	push	arr
	call	printf_arr
	UNALIGN_STACK 4	

	ALIGN_STACK 4
	push	newline
	call	printf
	UNALIGN_STACK 4

	leave

	xor		eax, eax
	ret
; ==============================

%define arr_ptr dword [ebp + 8]

global scanf_arr
scanf_arr:
	enter	0, 0

	push	eax
	push	ebx
	push	ecx	

	mov		ecx, 10
	mov		ebx, arr_ptr

	.L:
		cmp		ecx, 0
		jae		scanf_arr.exit_func

		ALIGN_STACK 8
		push	ebx	
		push	i_format	
		call	scanf
		UNALIGN_STACK 8

		dec		ecx
		add		ebx, 4

		jmp		scanf.L

.exit_func:
	pop		ecx
	pop		ebx
	pop		eax

	leave

	ret

%undef arr_ptr

%define arr_ptr dword [ebp + 8]

global printf_arr
printf_arr:
	enter	0, 0

	push	eax
	push	ebx
	push	ecx	

	mov		ecx, 10
	mov		ebx, arr_ptr

	.L:
		cmp		ecx, 0
		jae		printf_arr.exit_func

		ALIGN_STACK 8
		push	dword [ebx]	
		push	o_format	
		call	printf
		UNALIGN_STACK 8

		dec		ecx
		add		ebx, 4

		jmp		printf.L

.exit_func:
	pop		ecx
	pop		ebx
	pop		eax

	leave

	ret

%undef arr_ptr

section .bss
	arr		resd	10

section .data
	i_format	db	"%d", 0
	o_format	db	"%d ", 0
	newline		db	"\n", 0