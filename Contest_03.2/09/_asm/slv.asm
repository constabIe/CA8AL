bits 32

extern malloc, free
extern scanf, printf

section .text

global main

%macro ALIGN_STACK 1.nolist
    sub     esp, %1
    and     esp, 0xfffffff0
    add     esp, %1
%endmacro

%macro UNALIGN_STACK 1.nolist
    add     esp, %1
%endmacro

main:
	push 	ebp
	mov 	ebp, esp

	sub		esp, 4

	push	ebx

	ALIGN_STACK 8	
	push 	format
	push 	n
	call	scanf
	UNALIGN_STACK 8

	ALIGN_STACK 4	
	push	dword [n]
	call	allocate_matrix
	UNALIGN_STACK 4

	mov		[matrix], eax

	ALIGN_STACK 8
	push 	dword [n]
	push 	[matrix]
	call	scanf_matrix
	UNALIGN_STACK 8

	ALIGN_STACK 8
	push 	dword [n]
	push 	[matrix]
	call	printf_matrix
	UNALIGN_STACK 8

	ALIGN_STACK 4
	push	[matrix]
	call	deallocate_matrix
	UNALIGN_STACK 4

	add		esp, 4

	mov		esp, ebp
	pop		ebp

	xor		eax, eax
	ret

%define dimension	dword [ebp +  8]

global allocate_matrix
allocate_matrix:
	push	ebp
	mov 	ebp, esp

	push	ebx

	mov 	eax, dimension
	mul		dimension
	mov		ebx, DWORD_SIZE
	mul		ebx

	ALIGN_STACK 4
	push 	eax
	call	malloc
	UNALIGN_STACK 4

	pop  	ebx

	mov		esp, ebp
	pop		ebp

	ret

%undef dimension

%define matrix_ptr	dword [ebp +  8]

global deallocate_matrix
deallocate_matrix:
	push	ebp
	mov 	ebp, esp

	ALIGN_STACK 4
	push 	matrix_ptr
	call	free
	UNALIGN_STACK 4

	mov		esp, ebp
	pop		ebp

	ret

%undef matrix_ptr

%define dimension 		dword [ebp + 12]
%define matrix_ptr		dword [ebp +  8]

global scanf_matrix
scanf_matrix:
	push	ebp
	mov 	ebp, esp

	sub 	esp, 4

	push	eax
	push	ebx
	push	ecx

	mov		eax, dimension
	mul		dimension

	mov		ecx, eax
	mov		ebx, matrix_ptr

	.loop_scanf:
		cmp  	ecx, 0
		jle		scanf_matrix.exit_func

		ALIGN_STACK 8
		push 	format
		push 	ebx
		call	scanf
		UNALIGN_STACK 8

		add		ebx, DWORD_SIZE

		jmp 	.loop_scanf

.exit_func:
	pop 	ecx
	pop 	ebx
	pop 	eax

	add		esp, 4

	mov		esp, ebp
	pop		ebp

	ret

%undef dimension
%undef matrix_ptr

%define dimension 		dword [ebp + 12]
%define matrix_ptr 		dword [ebp +  8]

global printf_matrix
printf_matrix:
	push	ebp
	mov 	ebp, esp

	sub 	esp, 4

	push	eax
	push	ebx
	push	ecx

	mov		eax, dimension
	mul		dimension

	mov		ecx, eax
	xor		ebx, ebx

	.loop_scanf:
		cmp  	ecx, 0
		jle		printf_matrix.exit_func

		mov		eax, matrix_ptr
		add 	eax, ebx

		ALIGN_STACK 8
		push 	format
		push 	dword [eax]
		call	printf
		UNALIGN_STACK 8

		add		ebx, DWORD_SIZE

		jmp 	.loop_scanf

.exit_func:
	pop 	ecx
	pop 	ebx
	pop 	eax

	add		esp, 4

	mov		esp, ebp
	pop		ebp

	ret

%undef dimension
%undef matrix_ptr

section .data
	DWORD_SIZE 	equ		4
	format		db 		`%d`, 0

section .bss
	n 		resd 	1
	matrix	resd	1



