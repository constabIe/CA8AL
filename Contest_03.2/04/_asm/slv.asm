bits 32

extern	fopen, fclose
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

	ALIGN_STACK 8
	push	mode_read
	push	stream
	call	fopen
	UNALIGN_STACK 8

	mov	[input], eax

	ALIGN_STACK 12
	push	cell
	push	IO_format
	push	input
	call	fscanf
	UNALIGN_STACK 12

	ALIGN_STACK 4
	push	stream
	call	fclose
	UNALIGN_STACK 4

	ALIGN_STACK 8
	push	dword [cell]
	push	IO_format
	call	printf
	UNALIGN_STACK 8

	FUNCTION_EPILOGUE 0

	xor		eax, eax
	ret

section .data
	mode_read	db		`r`, 0
	stream		db		`/home/aiavkhadiev/Downloads/Assembly/CA8AL/Contest_03.2/04/data.txt`, 0
	input		dd 		-1

	cell		dd 		-1
	IO_format	db 		`%d`, 0


