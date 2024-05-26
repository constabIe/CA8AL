bits 32

extern	malloc, free
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

; ==================================
global main
main:
	enter 0, 0

	ALIGN_STACK 8
	push	n
	push	i_format
	call 	scanf
	UNALIGN_STACK 8	

	ALIGN_STACK 4
	push	dword [n]
	call	allocate_matrix
	UNALIGN_STACK 4	

	mov	[matrix_base], eax

	ALIGN_STACK 8
	push	dword [n]
	push	dword [matrix_base]
	call	scanf_matrix
	UNALIGN_STACK 8	

	ALIGN_STACK 8
	push	dword [n]
	push	dword [matrix_base]
	call	printf_matrix
	UNALIGN_STACK 8	

	ALIGN_STACK 4
	push	dword [matrix_base]
	call	deallocate_matrix
	UNALIGN_STACK 4	

	leave

	xor		eax, eax
	ret

; ==================================

%define	matrix_order 	dword [ebp + 8]

global allocate_matrix
allocate_matrix:
	enter 	0, 0

	push	ebx
	push	ecx

	mov		eax, matrix_order
	imul	matrix_order

	mov		ebx, DWORD_SIZE	
	imul	ebx

	ALIGN_STACK 4
	push	eax
	call	malloc
	UNALIGN_STACK 4

	pop		ecx
	pop		ebx

	leave

	ret

%undef	matrix_order

%define	matrix_ptr 	dword [ebp + 8]

global deallocate_matrix
deallocate_matrix:
	enter 	0, 0

	ALIGN_STACK 4
	push	matrix_ptr
	call	free
	UNALIGN_STACK 4

	leave

	ret

%undef	matrix_ptr

%define	matrix_order	dword [ebp + 12]
%define	matrix_ptr		dword [ebp +  8]

global scanf_matrix
scanf_matrix:
	enter 0, 0

	push	eax
	push	ebx
	push	ecx

	mov		eax, matrix_order
	imul	matrix_order

	mov		ecx, eax
	mov		ebx, matrix_ptr

	ALIGN_STACK 8
	push	ecx
	push 	o_format
	call	printf
	UNALIGN_STACK 8

	.input_loop:
		ALIGN_STACK 4
		push	w
		call	printf
		UNALIGN_STACK 4

		cmp		ecx, 0
		jle		scanf_matrix.exit_function

		ALIGN_STACK 8
		push	ebx
		push	i_format 
		call	scanf
		UNALIGN_STACK 8

		dec		ecx
		add		ebx, 4

		jmp  	.input_loop

.exit_function:
	pop		ecx
	pop		ebx
	pop		eax

	leave

	ret

%undef	matrix_order
%undef	matrix_ptr

%define	matrix_order	dword [ebp + 12]
%define	matrix_ptr		dword [ebp +  8]

global printf_matrix
printf_matrix:
	enter 0, 0

	push	eax
	push	ebx
	push	ecx

	mov		eax, matrix_order
	imul	matrix_order

	mov		ecx, eax
	mov		ebx, matrix_ptr

	.output_loop:
		cmp		ecx, -1
		jle		printf_matrix.exit_function

		ALIGN_STACK 8
		push	dword [ebx]
		push	o_format
		call	scanf
		UNALIGN_STACK 8

		dec		ecx
		add		ebx, 4

		jmp  	.output_loop

.exit_function:
	pop		ecx
	pop		ebx
	pop		eax

	leave

	ret

%undef	matrix_order
%undef	matrix_ptr

section .data
	DWORD_SIZE	equ 	4

	i_format	db		`%d`, 0
	o_format	db		`_%d_`, 0
	newline		db		`\n`, 0
	w			db		`w`, 0

section .bss
	n			resd	1
	matrix_base	resd	1	