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

	push	ebx

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

	ALIGN_STACK 8
	push	dword [n]
	push	dword [matrix_ptr]
	call	scanf_matrix
	UNALIGN_STACK 8

	; ALIGN_STACK 8
	; push	dword [n]
	; push	dword [matrix_ptr]
	; call	printf_matrix
	; UNALIGN_STACK 8	

	ALIGN_STACK 16
	push	dword [n]
	push	dword [matrix_ptr]
	push	2
	push	2
	call	get_cell_base
	UNALIGN_STACK 16

	ALIGN_STACK 8
	push	dword [eax]
	push	debug_o_format
	call	printf
	UNALIGN_STACK 8

	; xor  	ebx, ebx

	; ALIGN_STACK 12
	; push	ebx
	; push	dword [n]
	; push	matrix_ptr
	; call	trace
	; UNALIGN_STACK 12

	; ALIGN_STACK 8
	; push	eax
	; push	debug_o_format
	; call	printf
	; UNALIGN_STACK 8

	ALIGN_STACK 4
	push	dword [matrix_ptr]
	call	deallocate_matrix
	UNALIGN_STACK 4	

	pop		ebx

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

	mov		iterator, eax
	mov		ebx, matrix_base

	.output_loop:
		cmp		iterator, 0
		jle		printf_matrix.exit_function

		ALIGN_STACK 8
		push	dword [ebx]
		push	o_format
		call 	printf
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

; ---------------------------------------

%define	overflow_counter	dword [ebp + 16]
%define	matrix_order		dword [ebp + 12]
%define matrix_base			dword [ebp +  8]

global trace
trace:
	FUNCTION_PROLOGUE 0

	push	ebx
	push	edi
	push	esi

	mov		esi, 0
	mov		ebx, matrix_base
	xor		edi, edi
	mov		overflow_counter, 0

	.trace_loop:
		cmp		esi, matrix_order
		jle		trace.exit_function

		add		edi, [ebx]
		jo		.overflow_true
		jmp		.continue_trace_loop

		.overflow_true:
			inc		overflow_counter
			jmp		.continue_trace_loop

	.continue_trace_loop:		
		inc		esi

		ALIGN_STACK 16
		push	matrix_order
		push	matrix_base
		push	esi
		push	esi
		call	get_cell_base
		UNALIGN_STACK 16

		mov		ebx, eax

		jmp		.trace_loop

.exit_function:
	mov		eax, edi

	pop		esi	
	pop		edi
	pop		ebx

	FUNCTION_EPILOGUE 0

	ret

%undef	matrix_order
%undef 	matrix_base
%undef	iterator

; ---------------------------------------

%define	matrix_order	dword [ebp + 20]
%define	matrix_base		dword [ebp + 16]
%define	j				dword [ebp + 12]
%define	i				dword [ebp +  8]

global get_cell_base
; matrix[y][x] = matrix + 4 * (MATRIX_SIZE * y + x)
get_cell_base:
	FUNCTION_PROLOGUE 0

	push	ebx

	mov		eax, matrix_order
	mul		i

	add		eax, j

	mov		ebx, DWORD_SIZE
	mul		ebx

	add		eax, matrix_order

	pop		ebx

	FUNCTION_EPILOGUE 0

	ret

%undef	matrix_order
%undef	matrix_base
%undef	j
%undef	i

section	.data
	DWORD_SIZE	equ		4
	i_format	db		"%d", 0
	o_format	db		"%d ",0


	debug			db 		"_debug_", 0
	debug_o_format	db		"_%d_",0

section .bss
	n 			resd	1
	matrix_ptr 	resd	1


