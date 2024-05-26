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
	enter 0, 0

	ALIGN_STACK 4
	push	message
	call	printf
	UNALIGN_STACK 4

	leave

	xor 	eax, eax
	ret

section .data
	format 		db		"%s", 0
	message		db		`qwerty`, 0
	n			dd		0
