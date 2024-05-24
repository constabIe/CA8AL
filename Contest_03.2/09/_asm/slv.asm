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

%define matrix	dword [ebp + 12]
%define n		dword [ebp +  8]

main:
	push 	ebp
	mov 	ebp, esp

	sub		esp, 8

	ALIGN_STACK 8	
	push 	format
	push 	n
	call	scanf
	UNALIGN_STACK 8

	ALIGN_STACK 4	
	push	dword [n]
	call	allocate_matrix
	UNALIGN_STACK 4

	mov		matrix, eax

	ALIGN_STACK 8
	push 	dword [n]
	push 	matrix
	call	scanf_matrix
	UNALIGN_STACK 8

	ALIGN_STACK 8
	push 	dword [n]
	push 	matrix
	call	printf_matrix
	UNALIGN_STACK 8

	ALIGN_STACK 4
	push	matrix
	call	deallocate_matrix
	UNALIGN_STACK 4

	add		esp, 8

	mov		esp, ebp
	pop		ebp

	xor		eax, eax
	ret

%undef matrix
%undef n

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

%define matrix	dword [ebp +  8]

global deallocate_matrix
deallocate_matrix:
	push	ebp
	mov 	ebp, esp

	ALIGN_STACK 4
	push 	matrix
	call	free
	UNALIGN_STACK 4

	mov		esp, ebp
	pop		ebp

	ret

%undef matrix

%define dimension 	dword [ebp + 12]
%define matrix		dword [ebp +  8]

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
	xor		ebx, ebx

	.loop_scanf:
		cmp  	ecx, 0
		jle		scanf_matrix.exit_func

		lea		eax, [matrix + ebx]

		ALIGN_STACK 8
		push 	format
		push 	eax
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
%undef matrix

%define dimension 	dword [ebp + 12]
%define matrix 		dword [ebp +  8]

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

		mov		eax, [matrix + ebx]

		ALIGN_STACK 8
		push 	format
		push 	eax
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
%undef matrix

section .data
	DWORD_SIZE 	equ		4
	format		db 		`%d`, 0
