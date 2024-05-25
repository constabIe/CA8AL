bits 32

extern scanf, printf

section .text

%macro ALIGN_STACK 1.nolist
    sub     esp, %1
    and     esp, 0xfffffff0
    add     esp, %1
%endmacro

%macro UNALIGN_STACK 1.nolist
    add     esp, %1
%endmacro

global main
main:
	ALIGN_STACK 8
	push	n
	push	format
	call	scanf
	UNALIGN_STACK 8

	ALIGN_STACK 8
	push	eax
	push	format
	call	printf
	UNALIGN_STACK 8

	xor 	eax, eax
	ret

section .bss
	n	resd	1

section .data
	format 	db `%d`, 0
