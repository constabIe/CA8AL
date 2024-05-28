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
	push	edi

	ALIGN_STACK 8
	push	matrix_input_quantity
	push	i_format
	call	scanf
	UNALIGN_STACK 8

	ALIGN_STACK 4
	push	0x00000001
	call	allocate_matrix
	UNALIGN_STACK 4

	mov		[matrix_ptr_max], eax

	mov		edi, 0

	L:
		cmp		edi, [matrix_input_quantity]
		jae		result_out

		ALIGN_STACK 8
		push	matrix_order_i
		push	i_format
		call	scanf
		UNALIGN_STACK 8	

		ALIGN_STACK 4
		push	dword [matrix_order_i]
		call	allocate_matrix
		UNALIGN_STACK 4

		mov		[matrix_ptr_i], eax

		ALIGN_STACK 8
		push	dword [matrix_order_i]
		push	dword [matrix_ptr_i]
		call 	scanf_matrix
		UNALIGN_STACK 8

		mov		dword [overflow_i], 0

		ALIGN_STACK 12
		push	overflow_i
		push	dword [matrix_order_i]
		push	dword [matrix_ptr_i]
		call	trace_overflow
		UNALIGN_STACK 12

		ALIGN_STACK 8
		push	eax
		push 	debug_o_format 
		call 	printf
		UNALIGN_STACK 8

		mov		dword [trace_i], eax

		mov		ebx, dword [overflow_i]

		cmp		ebx, dword [overflow_max]
		jae		if_overflow
		jmp		else

		if_overflow:
			mov		ebx, dword [trace_i]

			ALIGN_STACK 8
			push	ebx
			push 	debug_o_format 
			call 	printf
			UNALIGN_STACK 8			

			cmp		ebx, dword [trace_max]
			ja		if_trace
			jmp		else

			if_trace:	
				ALIGN_STACK 4
				push	dword [matrix_ptr_max]
				call	deallocate_matrix
				UNALIGN_STACK 4

				mov		ebx, dword [matrix_ptr_i]
				mov		dword [matrix_ptr_max], ebx

				mov		ebx, dword [matrix_order_i]
				mov		dword [matrix_order_max], ebx

				mov		ebx, dword [overflow_i]
				mov		dword [overflow_max], ebx

				mov		ebx, dword [trace_i]
				mov		dword [trace_max], ebx

				jmp		L_continue

		else:
			ALIGN_STACK 4
			push	dword [matrix_ptr_i]
			call	deallocate_matrix
			UNALIGN_STACK 4			
			jmp 	L_continue

	L_continue:	
		inc		edi

		jmp		L

result_out:
	ALIGN_STACK 8
	push	dword [matrix_order_max]
	push	dword [matrix_ptr_max]
	call	printf_matrix
	UNALIGN_STACK 8

exit_main:
	pop		edi
	pop		ebx

	FUNCTION_EPILOGUE 0

	xor		eax, eax
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

%define	overflow_counter_base	dword [ebp + 16]
%define	matrix_order			dword [ebp + 12]
%define matrix_base				dword [ebp +  8]

global trace_overflow
trace_overflow:
	FUNCTION_PROLOGUE 0

	push	ebx
	push	edi
	push	esi

	push	ecx
	push	edx

	mov		esi, 0
	mov		ebx, matrix_base
	mov		edi, 0
	mov		ecx, 0

	.trace_overflow_loop:
		cmp		esi, matrix_order
		jae		trace_overflow.exit_function

		add		edi, [ebx]
		jo		.overflow_true
		jmp		.continue_trace_overflow_loop

		.overflow_true:
			inc		ecx
			jmp		.continue_trace_overflow_loop

	.continue_trace_overflow_loop:		
		inc		esi

		ALIGN_STACK 16
		push	matrix_order
		push	matrix_base
		push	esi
		push	esi
		call	get_cell_base
		UNALIGN_STACK 16

		mov		ebx, eax

		jmp		.trace_overflow_loop

.exit_function:
	mov		eax, edi
	
	mov		edx, overflow_counter_base
	mov		dword [edx], ecx

	pop		edx
	pop		ecx

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
%define	row				dword [ebp + 12]
%define	line			dword [ebp +  8]

global get_cell_base
; matrix[y][x] = matrix + 4 * (MATRIX_SIZE * y + x)
get_cell_base:
	FUNCTION_PROLOGUE 0

	push	ebx

	mov		eax, matrix_order
	mul		line

	add		eax, row

	mov		ebx, DWORD_SIZE
	mul		ebx

	add		eax, matrix_base

	pop		ebx

	FUNCTION_EPILOGUE 0

	ret

%undef	matrix_order
%undef	matrix_base
%undef	row
%undef	line

section	.data
	DWORD_SIZE				equ		4
	
	i_format				db		"%d", 0
	o_format				db		"%d ", 0
	
	debug					db 		"_debug_", 0
	debug_o_format			db		"_%d_", 0

	matrix_input_quantity 	dd		0
	
	matrix_ptr_i			dd		0
	matrix_order_i 			dd		0
	trace_i					dd		-1
	overflow_i				dd		-1

	matrix_ptr_max			dd		0
	matrix_order_max 		dd		0
	trace_max				dd		-1
	overflow_max			dd		-1

; section .bss
; 	matrix_input_quantity 	resd	1

; 	matrix_order_i 			resd	1
; 	matrix_ptr_i			resd	1
; 	overflow_i				resd	1
; 	trace_i					resd	1
	
; 	matrix_ptr_max 			resd	1
; 	matrix_order_max		resd	1
; 	overflow_max			resd 	1
; 	trace_max				resd	1




