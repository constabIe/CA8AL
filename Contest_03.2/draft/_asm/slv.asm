bits 32

extern	scanf, printf

section .text

%macro FUNCTION_PROLOGUE 1.nolist
    enter   %1, 0
    and     esp, 0xfffffff0
%endmacro

%macro FUNCTION_EPILOGUE 0.nolist
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

; ==============================
global main
main:	
	FUNCTION_PROLOGUE 0

	ALIGN_STACK 4
	push	arr
	call	scanf_arr
	UNALIGN_STACK 4

	ALIGN_STACK 4
	push	arr
	call	printf_arr
	UNALIGN_STACK 4	

	ALIGN_STACK 4
	push	newline
	call	printf
	UNALIGN_STACK 4

	FUNCTION_EPILOGUE

	xor		eax, eax
	ret
; ==============================

%define arr_base 	dword [ebp + 8]

global scanf_arr
scanf_arr:
	FUNCTION_PROLOGUE 4

	push	eax
	push	ebx
	push	ecx	

	mov		ecx, 0
	mov		ebx, arr_base

	.L:
		cmp		ecx, 10
		jae		scanf_arr.exit_func

		push	ebx
		push	ecx

		ALIGN_STACK 8
		push	ebx	
		push	i_format	
		call	scanf
		UNALIGN_STACK 8

		pop		ecx	
		pop		ebx

		inc		ecx
		add		ebx, 4

		jmp		scanf_arr.L

.exit_func:
	pop		ecx
	pop		ebx
	pop		eax

	FUNCTION_EPILOGUE

	ret

%undef arr_base

%define arr_base dword [ebp + 8]

global printf_arr
printf_arr:
	FUNCTION_PROLOGUE 0

	push	eax
	push	ebx
	push	ecx	

	mov		ecx, 0
	mov		ebx, arr_base

	.L:
		cmp		ecx, 10
		jae		printf_arr.exit_func

		push	ebx
		push	ecx

		ALIGN_STACK 8
		push	dword [ebx]	
		push	o_format	
		call	printf
		UNALIGN_STACK 8

		pop		ecx
		pop		ebx
		
		inc		ecx
		add		ebx, 4

		jmp		printf_arr.L

.exit_func:
	pop		ecx
	pop		ebx
	pop		eax

	FUNCTION_EPILOGUE

	ret

%undef arr_base

section .bss
	arr		resd	10

section .data
	i_format	db	"%d", 0
	o_format	db	"%d ", 0
	newline		db	"\n", 0
	w  			db	"w", 0