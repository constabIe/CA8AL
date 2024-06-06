bits 32

extern fopen, fclose
extern fscanf, fprintf, printf
extern malloc, free

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

section .text

%define input			dword [ebp -  4]
%define	output			dword [ebp -  8]
%define	n  				dword [ebp - 12]
%define	m  				dword [ebp - 16]
%define	arr_parameters	dword [ebp - 20]

global main
main:
	FUNCTION_PROLOGUE 20

	push	ebx
	push	edi
	push	esi

	push	ecx

	ALIGN_STACK 8
	push	read_mode
	push	path_input
	call	fopen
	UNALIGN_STACK 8

	mov		input, eax

	ALIGN_STACK 8
	push	write_mode
	push	path_output
	call	fopen
	UNALIGN_STACK 8	

	mov		output, eax

	lea		ebx, [ebp - 12]

	ALIGN_STACK 12
	push	ebx
	push	i_format_int
	push	input
	call 	fscanf
	UNALIGN_STACK 12

	lea		ebx, [ebp - 16]

	ALIGN_STACK 12
	push	ebx
	push	i_format_int
	push	input
	call 	fscanf
	UNALIGN_STACK 12

	ALIGN_STACK 8
	push	m
	push	input
	call	get_parameters
	UNALIGN_STACK 8

	mov		arr_parameters, eax

	mov		ebx, arr_parameters

	mov		eax, 2
	imul	m
	mov		ecx, eax

	.L:	
		cmp		ecx, 0
		jle		.exit_func

		ALIGN_STACK 8
		push	dword [ebx]
		push	o_format_int
		call	printf
		UNALIGN_STACK 8

		add		ebx, DWORD_SIZE
		dec		ecx

		jmp		.L

.exit_func:
	ALIGN_STACK 4
	push	arr_parameters
	call	free
	UNALIGN_STACK 4

	ALIGN_STACK 4
	push	output
	call	fclose
	UNALIGN_STACK 4

	ALIGN_STACK 4
	push	input
	call	fclose
	UNALIGN_STACK 4

	pop		ecx

	pop		esi
	pop		edi
	pop		ebx

	FUNCTION_EPILOGUE 20

	xor		eax, eax
	ret

%undef	input
%undef	output
%undef	n
%undef	m
%undef	arr_pairs

%define	m				dword [ebp + 12]
%define	stream			dword [ebp +  8]
%define	arr_parameters	dword [ebp -  4]

global get_parameters
get_parameters:
	FUNCTION_PROLOGUE 4

	push	ebx
	push	edi
	push	esi

	mov		eax, 2
	imul	m

	mov		edi, eax

	mov		ebx, DWORD_SIZE
	imul	ebx

	ALIGN_STACK 4
	push	eax
	call	malloc
	UNALIGN_STACK 4	

	mov		arr_parameters, eax

	mov 	ebx, eax

	.L:
		cmp 	edi, 0
		jle		.exit_func

		ALIGN_STACK 12
		push	ebx
		push	i_format_int
		push	stream
		call 	fscanf
		UNALIGN_STACK 12

		dec		edi
		add		ebx, DWORD_SIZE

		jmp		.L

.exit_func:
	mov		eax, arr_parameters

	pop		esi
	pop		edi
	pop		ebx	

	FUNCTION_EPILOGUE 4

	ret

%undef	m
%undef	stream
%undef	arr_parameters

%define	size 	dword [ebp + 16]
%define	src 	dword [ebp + 12]
%define	dst		dword [ebp -  4]

global arrcpy
arrcpy:
	FUNCTION_PROLOGUE 4

	push	ebx
	push	edi
	push	esi

	push	edx

	mov		eax, DWORD_SIZE
	imul 	size

	ALIGN_STACK 4
	push	eax
	call	malloc
	UNALIGN_STACK 4

	mov		dst, eax

	mov		ebx, dst
	mov		esi, src
	xor		edi, edi

	.L:	
		cmp		edi, size
		jae		.exit_func

		mov		edx, dword [esi]
		mov		dword [ebx], edx

		add		ebx, DWORD_SIZE
		add		esi, DWORD_SIZE
		inc		edi

		jmp		.L

.exit_func:
	mov		eax, dst

	pop		edx

	pop		esi
	pop		edi
	pop		ebx

	FUNCTION_EPILOGUE 4

	ret

%undef	size
%undef	src
%undef	dst	

%define n			dword [ebp + 8]
%define	res_seq		dword [ebp - 4]

global sequence_generator
sequence_generator:
	FUNCTION_PROLOGUE 4

	push	ebx
	push	edi

	mov		eax, DWORD_SIZE
	imul	n

	ALIGN_STACK 4
	push	eax
	call	malloc
	UNALIGN_STACK 4

	mov		res_seq, eax

	mov		ebx, res_seq
	mov		edi, 1

	.L:
		cmp		edi, n
		ja		.exit_func

		mov		[ebx], edi

		add		ebx, DWORD_SIZE
		inc		edi

		jmp 	.L

.exit_func:
	mov		eax, res_seq

	pop		edi
	pop		ebx

	FUNCTION_EPILOGUE 4

	ret

%undef	n
%undef	res_seq

%define	upper_bound			dword [ebp + 20]
%define	lower_bound			dword [ebp + 16]
%define	size				dword [ebp + 12]
%define mutable_seq 		dword [ebp +  8]
%define auxiliary_seq		dword [ebp -  4]
%define	ind_lower_bound		dword [ebp -  8]
%define	ind_upper_bound		dword [ebp - 12]
	
global transform_sequence
transform_sequence:
	FUNCTION_PROLOGUE 12

	push	ebx
	push	edi
	push	esi

	push	edx

	mov		ebx, mutable_seq
	mov		edi, 1

	.L_1:
		cmp		edi, size
		ja		.continue_func_1

		mov		esi, [ebx]

		cmp		esi, lower_bound
		cmove	edx, edi
		mov		ind_lower_bound, edx

		cmp		esi, upper_bound
		cmove	edx, edi
		mov	ind_upper_bound, edx

		add		ebx, DWORD_SIZE
		inc		edi

		jmp		.L_1

.continue_func_1:
	mov		eax, DWORD_SIZE
	imul	size

	ALIGN_STACK 4
	push	eax
	call	malloc
	UNALIGN_STACK 4

	mov		auxiliary_seq, eax

	mov		ebx, auxiliary_seq

	mov		eax, DWORD_SIZE
	imul	ind_lower_bound
	add		eax, DWORD_SIZE

	mov		edi, mutable_seq
	add		edi, eax

	mov		esi, ind_lower_bound

	.L_2:
		cmp		esi, ind_upper_bound
		ja		.continue_func_2

		mov		edx, [edi]
		mov		[ebx], edx

		add		ebx, DWORD_SIZE
		add		edi, DWORD_SIZE

		inc		esi

		jmp		.L_2

.continue_func_2:
	mov		edi, mutable_seq
	xor		edx, edx

	.L_3:
		cmp		edx, ind_lower_bound
		jae		.continue_func_3

		mov		esi, [edi]
		mov		[ebx], esi

		add		ebx, DWORD_SIZE			
		add		edi, DWORD_SIZE
		inc		edx

		jmp		.L_3

.continue_func_3:
	mov		eax, DWORD_SIZE
	imul	ind_upper_bound
	add		eax, DWORD_SIZE

	mov		edi, mutable_seq
	add		edi, eax

	mov		edx, ind_upper_bound

	.L_4:
		cmp		edx, size
		jae		.continue_func_4

		mov		esi, [edi]
		mov		[ebx], esi

		add		ebx, DWORD_SIZE
		add		esi, DWORD_SIZE
		inc		edx

		jmp		.L_4

.continue_func_4:
	ALIGN_STACK 4
	push	mutable_seq
	call	free
	UNALIGN_STACK 4

	mov		ebx, auxiliary_seq
	mov		mutable_seq, ebx

	pop		edx

	pop		esi
	pop		edi
	pop		ebx

	FUNCTION_EPILOGUE 12

	ret

%undef	ind_upper_bound
%undef	ind_lower_bound
%undef	auxiliary_seq
%undef	mutable_seq
%undef	lower_bound
%undef	upper_bound

section .data
	DWORD_SIZE		equ		4

	read_mode		db 		`r`, 0
	write_mode		db 		`w`, 0
	path_input		db 		`../input.txt`, 0
	path_output		db 		`../output.txt`, 0	

	i_format_int	db 		`%d`, 0
	o_format_int	db 		`%d `, 0	
