bits 32

extern malloc, realloc, free
extern printf, scanf 
extern strcpy, strncmp, strlen

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

%define	base_str_1		dword [ebp - 4]
%define	len_str_1		dword [ebp - 8]
%define	base_str_2		dword [ebp - 12]
%define	len_str_2		dword [ebp - 16]
%define	struct_data		dword [ebp - 12]
; %define	issubstr		dword [ebp - 8]
; %define	start			dword [ebp - 12]				
; %define	end				dword [ebp - 16]	


global main
main:
	FUNCTION_PROLOGUE 20

	ALIGN_STACK 0
	call	get_str
	UNALIGN_STACK 0

	mov		base_str_1, eax

	ALIGN_STACK 4
	push	base_str_1
	call	strlen
	UNALIGN_STACK 2

	mov		len_str_1, eax

	ALIGN_STACK 0
	call	get_str
	UNALIGN_STACK 0

	mov		base_str_2, eax

	ALIGN_STACK 4
	push	base_str_2
	call	strlen
	UNALIGN_STACK 2

	mov		len_str_2, eax

	; substr
	ALIGN_STACK 16
	push	len_str_2
	push	base_str_2
	push	len_str_1
	push 	base_str_1
	call	issubstr
	UNALIGN_STACK 16

	mov		struct_data, eax

	; out
	ALIGN_STACK 8
	push	base_str_1
	push	str_o_format
	call	printf
	UNALIGN_STACK 8

	ALIGN_STACK 4			;
	push	debug_message	;
	call	printf			;
	UNALIGN_STACK 4			;

	ALIGN_STACK 8
	push	base_str_2
	push	str_o_format
	call	printf
	UNALIGN_STACK 8

	mov		ebx, struct_data

	ALIGN_STACK 8
	push	dword [ebx] 
	push	int_o_format
	call	printf
	UNALIGN_STACK 8


	ALIGN_STACK 8
	push	dword [ebx + 4] 
	push	int_o_format
	call	printf
	UNALIGN_STACK 8


	ALIGN_STACK 8
	push	dword [ebx + 8] 
	push	int_o_format
	call	printf
	UNALIGN_STACK 8

	; ALIGN_STACK 4			;
	; push	debug_message	;
	; call	printf			;
	; UNALIGN_STACK 4			;	

	; ALIGN_STACK 4			;
	; push	debug_message	;
	; call	printf			;
	; UNALIGN_STACK 4			;

	; free
	ALIGN_STACK 4
	push	base_str_1
	call	free
	UNALIGN_STACK 4

	ALIGN_STACK 4
	push	base_str_2
	call	free
	UNALIGN_STACK 4

	ALIGN_STACK 4
	push	struct_data
	call	free
	UNALIGN_STACK 4

	; ALIGN_STACK 4			;
	; push	debug_message	;
	; call	printf			;
	; UNALIGN_STACK 4			;

	FUNCTION_EPILOGUE 20

	ret

; %undef	end 
; %undef	start 
; %undef	issubstr
%undef	struct_data
%undef	str_base_2
%undef	str_base_1

; ------------------------endmain-------------------------

; -----------------------functions-----------------------

%define	str_base	dword [ebp - 4]
%define	str_size	dword [ebp - 8]

global get_str
get_str:
	FUNCTION_PROLOGUE 8

	push	ebx
	push	edi
	push	esi

	ALIGN_STACK 4
	push	BYTE_SIZE
	call	malloc
	UNALIGN_STACK 4

	mov		str_base, eax

	mov		ebx, eax
	mov		str_size, 1

	.L:	
		ALIGN_STACK 8
		push	ebx
		push	str_i_format
		call	scanf
		UNALIGN_STACK 8

		mov		edi, [newline]
		cmp		[ebx], edi
		je		get_str.exit_func

		add		ebx, BYTE_SIZE
		add		str_size, BYTE_SIZE

		ALIGN_STACK 8
		push	str_size
		push	str_base
		call	realloc
		UNALIGN_STACK 8

		jmp		get_str.L

.exit_func:
	mov		dword [ebx], 0

	mov		eax, str_base

	pop		esi
	pop		edi
	pop		ebx

	FUNCTION_EPILOGUE 8

	ret

%undef	str_size
%undef	str_base

; -------------------------------------------------------

%define	len_substring			dword [ebp + 20]
%define substring				dword [ebp + 16]
%define	len_string				dword [ebp + 12]
%define	string					dword [ebp +  8]

%define	cmp_string				dword [ebp -  4]
%define	boundary_iterator_val	dword [ebp -  8]
%define	res_struct_data			dword [ebp - 12]

global issubstr
issubstr:
	FUNCTION_PROLOGUE 12

	push	ebx
	push	edi	; iterator
	push	esi

	; res_struct_data 
	ALIGN_STACK 4
	push	12
	call	malloc
	UNALIGN_STACK 4

	mov		res_struct_data, eax
	mov		ebx, eax

	mov		dword [ebx], 0
	mov		dword [ebx + 4], -1
	mov		dword [ebx + 12], -1

	ALIGN_STACK 4			;
	push	debug_message	;
	call	printf			;
	UNALIGN_STACK 4			;

	; cmp_string
	mov		edi, len_substring
	add		edi, 1

	ALIGN_STACK 8
	push	edi
	push	cmp_string
	call	malloc
	UNALIGN_STACK 8

	mov 	ebx, cmp_string
	mov		dword [ebx + 1], 0

	ALIGN_STACK 4			;
	push	debug_message	;
	call	printf			;
	UNALIGN_STACK 4			;

	ALIGN_STACK 8
	push	string
	push	cmp_string
	call	strcpy
	UNALIGN_STACK 8		

	ALIGN_STACK 4			;
	push	debug_message	;
	call	printf			;
	UNALIGN_STACK 4			;

	; loop
	mov		edi, len_string
	sub		edi, len_substring
	add		edi, 1

	mov		boundary_iterator_val, edi
	mov		edi, 0
	mov		ebx, cmp_string

	.L:
		cmp		edi, boundary_iterator_val
		jae		issubstr.exit_func 

		ALIGN_STACK 12
		push	len_substring
		push	ebx
		push	substring
		call	strncmp
		UNALIGN_STACK 12

		cmp		eax, 0
		je		issubstr.substr_true

		add		ebx, BYTE_SIZE
		inc		edi

		jmp		issubstr.L

	.substr_true:
		mov		ebx, res_struct_data

		mov		dword [ebx], 1
		mov		dword [ebx + 4], edi

		mov		esi, edi
		add		esi, len_substring
		sub		esi, 1

		mov		dword [ebx + 8], esi

		jmp		issubstr.exit_func

.exit_func:
	mov		eax, res_struct_data

	pop		esi
	pop		edi
	pop		ebx

	FUNCTION_EPILOGUE 12

	ret

%undef	res_struct_data
%undef	boundary_iterator_val
%undef	cmp_string

%undef	string
%undef	len_string
%undef	substring
%undef	len_substring	

; ---------------------endfunctions----------------------
section .data
	BYTE_SIZE	equ		1
	newline		dd 		0x0000000A		

	str_i_format	db		`%c`, 0
	str_o_format	db 		`%s\n`, 0

	int_o_format	db		`%d `, 0


section .data
	debug_message		db		`_debug_`, 0
	debug_o_format 		db		`_%d_`, 0


; ALIGN_STACK 4			;
; push	debug_message	;
; call	printf			;
; UNALIGN_STACK 4			;
