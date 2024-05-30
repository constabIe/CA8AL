bits 32

extern malloc, realloc, free
extern	printf, scanf 

section .text

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

; -------------------------main---------------------------

%define	str_base	dword [ebp - 4]

global main
main:
	FUNCTION_PROLOGUE 4

	ALIGN_STACK 0
	call	get_str
	UNALIGN_STACK 0

	mov		str_base, eax

	ALIGN_STACK 8
	push	str_base
	push	o_format
	call	printf
	UNALIGN_STACK 8

	ALIGN_STACK 4
	push	str_base
	call	free
	UNALIGN_STACK 4

	FUNCTION_EPILOGUE 4

	ret

; ------------------------endmain-------------------------

%define	str_base	dword [ebp - 4]

global get_str
get_str:
	FUNCTION_PROLOGUE 4

	push	ebx
	push	edi
	push	esi

	ALIGN_STACK 4
	push	BYTE_SIZE
	call	malloc
	UNALIGN_STACK 4

	mov		str_base, eax

	mov		ebx, eax

	.L:	
		ALIGN_STACK 8
		push	ebx
		push	i_format
		call	scanf
		UNALIGN_STACK 8

		mov		edi, [newline]
		cmp		[ebx], edi
		je		get_str.exit_func

		add		ebx, BYTE_SIZE

		ALIGN_STACK 8
		push	str_base
		push	ebx
		call	realloc
		UNALIGN_STACK 8

		jmp		get_str.L

.exit_func:
	mov		dword [ebx], 0

	mov		eax, str_base

	FUNCTION_EPILOGUE 4

	pop		esi
	pop		edi
	pop		ebx

	ret

%undef	str_base

section .data
	BYTE_SIZE	equ		4
	newline		dd 		0x0000000A		

	i_format	db		"%c", 0
	o_format	db 		"%s\n", 0