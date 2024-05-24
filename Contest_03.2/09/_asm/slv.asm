bits 32

extern malloc, free
extern scanf, printf

section .text

global main
main:
	push 	ebp
	mov 	ebp, esp

	sub		esp, 8
	and		esp, 0xfffffff0
	add		esp, 8	

	push 	format
	push 	n
	call	scanf

	add		esp, 8

	sub		esp, 4
	and		esp, 0xfffffff0
	add		esp, 4	

	push	dword [n]
	call	allocate_matrix

	add		esp, 4

	mov		[matrix], eax

	sub		esp, 8
	and		esp, 0xfffffff0
	add		esp, 8	

	push 	dword [n]
	push 	matrix
	call	scanf_matrix

	add		esp, 8

	sub		esp, 8
	and		esp, 0xfffffff0
	add		esp, 8	

	push 	dword [n]
	push 	matrix
	call	printf_matrix

	sub		esp, 4
	and		esp, 0xfffffff0
	add		esp, 4	

	push	matrix
	call	deallocate_matrix

	add		esp, 4	

	add		esp, 8

	mov		esp, ebp
	pop		ebp

	xor		eax, eax
	ret


%define dimension	dword [ebp +  8]

global allocate_matrix
allocate_matrix:
	push	ebp
	mov 	ebp, esp

	mov 	eax, dimension
	mul		dimension
	mul		DWORD_SIZE

	sub		esp, 4
	and		esp, 0xfffffff0
	add		esp, 4

	push 	eax
	call	malloc

	add 	esp, 4

	mov		esp, ebp
	pop		ebp

	ret

%undef dimension

%define matrix_pointer	dword [ebp +  8]

global deallocate_matrix
deallocate_matrix:
	push	ebp
	mov 	ebp, esp

	sub		esp, 4
	and		esp, 0xfffffff0
	add		esp, 4

	push 	matrix_pointer
	call	malloc

	add 	esp, 4

	mov		esp, ebp
	pop		ebp

	ret

%undef matrix_pointer

%define dimension 			dword [ebp + 12]
%define matrix_pointer 		dword [ebp +  8]

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

		sub		esp, 8
		and		esp, 0xfffffff0
		add		esp, 8

		lea		eax, [matrix + ebx]

		push 	format
		push 	eax
		call	scanf

		add		esp, 8

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

%define dimension 		dword [ebp + 12]
%define matrix_pointer 	dword [ebp +  8]

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

		sub		esp, 8
		and		esp, 0xfffffff0
		add		esp, 8

		mov		eax, [matrix + ebx]

		push 	format
		push 	eax
		call	printf

		add		esp, 8

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

section .bss
	n 			resd	1
	matrix  	resd	1
