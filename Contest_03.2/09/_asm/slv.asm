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

section .data
	DWORD_SIZE	equ 	4

	i_format	db		`%d`, 0
	o_format	db		`%d `, 0
	newlinw		db		`\n`, 0

section .bss
	n			resd	1	