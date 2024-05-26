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
	push	ebp
	mov		ebp, esp

	ALIGN_STACK 8
	push	n
	push	format_int32_t
	call	scanf
	UNALIGN_STACK 8	

	ALIGN_STACK 8
	push	dword [n]
	push	format_int32_t
	call	printf
	UNALIGN_STACK 8

	ALIGN_STACK 4
	push	message
	call	printf
	UNALIGN_STACK 4	

	mov		esp, ebp
	pop 	ebp

	xor 	eax, eax
	ret

section .data
	format_int32_t	db		"%d", 0
	format_string 	db		"%s", 0
	message			db		`\n`, 0
	n				dd		0
