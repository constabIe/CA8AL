bits 32

extern 	fopen, fclose
extern	fscanf, printf

section .text

; -------------------------macro-------------------------

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

; -----------------------endmacro-------------------------

; -------------------------main--------------------------

global main
main:
	FUNCTION_PROLOGUE 0

	push	ebx
	push	edi

	ALIGN_STACK 8
	push	mode
	push	src_path
	call	fopen
	UNALIGN_STACK 8

	ALIGN_STACK 4			;
	push	debug_message	;
	call	printf			;
	UNALIGN_STACK 4			;

	mov		[stream], eax

	xor 	ebx, ebx
	L:	
		ALIGN_STACK 12
		push	cell
		push	format
		push	dword [stream]
		call	fscanf
		UNALIGN_STACK 12

		cmp		eax, EOF
		je		exit_main

		add		ebx, eax

		jmp		L

exit_main:
	ALIGN_STACK 8
	push	ebx
	push	format
	call	printf
	UNALIGN_STACK 8

	ALIGN_STACK 4
	push	dword [stream]
	call	fclose
	UNALIGN_STACK 4

	FUNCTION_EPILOGUE 0

	pop		edi
	pop		ebx

	xor  	eax, eax
	ret
; ------------------------endmain------------------------

section .data
	mode		db	"r", 0
	src_path 	db	"~/Downloads/Assembly/CA8AL/Contest_03.2/04/data.in", 0

	cell		dd  0 
	format		db	"%d", 0
	stream		dd  0

	EOF			equ 	-1

; DEBUG
section .data
	debug_message 	db	"_debug_", 0
