bits 32

extern	malloc, free
extern	scanf, printf

section .text

; -----------define_macro-----------

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

; ----------implement_main----------

global main
main:
	FUNCTION_PROLOGUE 0

	ALIGN_STACK 8
	push	n
	push	i_format
	call	scanf
	UNALIGN_STACK 8

	ALIGN_STACK 4
	push	dword [n]
	call	allocate_matrix
	UNALIGN_STACK 4

	mov		[matrix_ptr], eax

	ALIGN_STACK 4	;
	push	debug	;
	call 	printf	;
	UNALIGN_STACK 4	;

	ALIGN_STACK 8
	push	dword [n]
	push	dword [matrix_ptr]
	call	scanf_matrix
	UNALIGN_STACK 8



	ALIGN_STACK 8
	push	dword [n]
	push	dword [matrix_ptr]
	call	printf_matrix
	UNALIGN_STACK 8	

	ALIGN_STACK 4
	push	dword [matrix_ptr]
	call	deallocate_matrix
	UNALIGN_STACK 4	

	FUNCTION_EPILOGUE 0

	ret

; --------functions_implementation--------

%define matrix_order 	dword [ebp + 8]

global allocate_matrix
allocate_matrix:
	FUNCTION_PROLOGUE 0

	push	ebx

	mov		eax, matrix_order
	mul		matrix_order

	mov		ebx, DWORD_SIZE
	mul		ebx

	ALIGN_STACK	4
	push	eax
	call 	malloc
	UNALIGN_STACK 4

	pop		ebx

	FUNCTION_EPILOGUE 0

	ret

%undef	matrix_order

; ---------------------------------------

%define	matrix_base		dword [ebp + 8]

global deallocate_matrix
deallocate_matrix:
	FUNCTION_PROLOGUE 0

	ALIGN_STACK	4
	push	matrix_base
	call 	free
	UNALIGN_STACK 4

	FUNCTION_EPILOGUE 0

	ret	

%undef	matrix_base

; ---------------------------------------

%define	matrix_order	dword [ebp + 12]
%define	matrix_base 	dword [ebp +  8]
%define	iterator		dword [ebp -  4]

global scanf_matrix
scanf_matrix:
	FUNCTION_PROLOGUE 4

	push	ebx

	mov		eax, matrix_order
	mul		matrix_order
	mul		matrix_order

	mov		iterator, eax
	mov		ebx, matrix_base

	.get_input_loop:
		cmp		iterator, 0
		jle		scanf_matrix.exit_function

		ALIGN_STACK 8
		push	ebx
		push	i_format
		call 	scanf
		UNALIGN_STACK 8

		dec		iterator
		add		ebx, 4

		jmp		.get_input_loop

.exit_function:
	pop		ebx

	FUNCTION_EPILOGUE 4

	ret		

%undef	matrix_order
%undef	matrix_base
%undef	iterator

; ---------------------------------------

%define	matrix_order	dword [ebp + 12]
%define	matrix_base 	dword [ebp +  8]
%define	iterator		dword [ebp -  4]

global printf_matrix
printf_matrix:
	FUNCTION_PROLOGUE 4

	push	ebx

	mov		eax, matrix_order
	mul		matrix_order
	mul		matrix_order

	mov		iterator, eax
	mov		ebx, matrix_base

	.output_loop:
		cmp		iterator, 0
		jle		printf_matrix.exit_function

		ALIGN_STACK 8
		push	dword [ebx]
		push	o_format
		call 	scanf
		UNALIGN_STACK 8

		dec		iterator
		add		ebx, 4

		jmp		.output_loop

.exit_function:
	pop		ebx

	FUNCTION_EPILOGUE 4

	ret		

%undef	matrix_order
%undef	matrix_base
%undef	iterator

section	.data
	DWORD_SIZE	equ		4
	i_format	db		"%d", 0
	o_format	db		"%d "
	debug		db 		"_debug_", 0

section .bss
	n 			resd	1
	matrix_ptr 	resd	1


