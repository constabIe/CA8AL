bits 32

extern	fopen, fclose, feof
extern	fscanf, fprintf, printf

%macro FUNCTION_PROLOGUE 1.nolist
	enter	%1, 0
	and 	esp, 0xfffffff0
%endmacro

%macro FUNCTION_EPILOGUE 1.nolist
	add		esp, %1
	leave
%endmacro

%macro ALIGN_STACK 1.nolist
	sub		esp, %1
	and		esp, 0xfffffff0
	add		esp, %1
%endmacro

%macro UNALIGN_STACK 1.nolist
	add		esp, %1
%endmacro

global main
main:
	FUNCTION_PROLOGUE 0

	push	ebx

	ALIGN_STACK 8
	push	mode_read
	push	stream
	call	fopen
	UNALIGN_STACK 8

	mov		[input], eax

	xor		ebx, ebx

	.L:
		ALIGN_STACK 12
		push	cell
		push	io_format
		push	dword [input]
		call	fscanf
		UNALIGN_STACK 12

		cmp 	eax, 1
		jne		.exit_func

		add		ebx, eax

		jmp 	.L

.exit_func:
	ALIGN_STACK 8
	push	ebx
	push	io_format
	call	printf
	UNALIGN_STACK 8

	ALIGN_STACK 4
	push	dword [input]
	call	fclose
	UNALIGN_STACK 4

	pop		ebx

	FUNCTION_EPILOGUE 0

	xor		eax, eax
	ret

section .data
	mode_read			db		`r`, 0
	stream				db		`data.in`, 0
	input				dd 		-1
		
	cell				dd 		-1
	io_format			db 		`%d`, 0

; section .data ; debug
; 	debug_message		db		`_debug_\n`, 0


	; ;_debug_
	; ALIGN_STACK 4
	; push	debug_message
	; call	printf
	; UNALIGN_STACK 4
	; ;_debug_
