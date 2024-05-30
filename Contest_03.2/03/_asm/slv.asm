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

	; _debug_
	ALIGN_STACK 12
	push	len_str_1
	push	base_str_1
	push	debug_o_format
	call	printf
	UNALIGN_STACK 12
	; _debug_

	ALIGN_STACK 0
	call	get_str
	UNALIGN_STACK 0

	mov		base_str_2, eax

	ALIGN_STACK 4
	push	base_str_2
	call	strlen
	UNALIGN_STACK 2

	mov		len_str_2, eax

	; _debug_
	ALIGN_STACK 12
	push	len_str_2
	push	base_str_2
	push	debug_o_format
	call	printf
	UNALIGN_STACK 12
	; _debug_

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

	FUNCTION_EPILOGUE 20

	ret

%undef	struct_data
%undef	str_base_2
%undef	str_base_1

; ------------------------endmain-------------------------

; -----------------------functions-----------------------

%define	string		dword [ebp - 4]
%define	string_len	dword [ebp - 8]

global get_str
get_str:
	FUNCTION_PROLOGUE 8

	push	ebx
	push	edi
	push	esi

	ALIGN_STACK 4
	push	1
	call	malloc
	UNALIGN_STACK 4

	mov		string, eax

	mov		ebx, string
	mov		string_len, 1
	mov		edi, [newline]

	.L:
		ALIGN_STACK 8
		push	ebx
		push  	char_i_format
		call 	scanf
		UNALIGN_STACK 8

		; ;_debug_
		; ALIGN_STACK 4			;
		; push	debug_message	;
		; call	printf			;
		; UNALIGN_STACK 4			;
		; ;_debug_

		cmp		[ebx], edi
		je		.exit_func

		ALIGN_STACK 8
		push	dword [ebx]
		push	debug_char_o_format
		call	printf
		UNALIGN_STACK 8

		inc		string_len

		ALIGN_STACK 8
		push	string_len
		push	string
		call	realloc
		UNALIGN_STACK 8

		mov		string, eax

		mov		ebx, eax
		add		ebx, string_len

		jmp 	.L

.exit_func:
	ALIGN_STACK 8
	push	dword [ebx]
	push	debug_int_o_format
	call	printf
	UNALIGN_STACK 8	

	mov		dword [ebx], 0

	mov		eax, string

	pop		esi
	pop		edi
	pop		ebx

	FUNCTION_EPILOGUE 8

	ret

%undef	string_len
%undef	string

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

	; ;_debug_
	; ALIGN_STACK 4			;
	; push	debug_message	;
	; call	printf			;
	; UNALIGN_STACK 4			;
	; ;_debug_

	; res_struct_data 
	ALIGN_STACK 4
	push	12
	call	malloc
	UNALIGN_STACK 4

	mov		res_struct_data, eax
	mov		ebx, eax

	; ;_debug_
	; ALIGN_STACK 4			;
	; push	debug_message	;
	; call	printf			;
	; UNALIGN_STACK 4			;
	; ;_debug_

	mov		dword [ebx], 0
	mov		dword [ebx + 4], -1
	mov		dword [ebx + 12], -1

	; ;_debug_
	; ALIGN_STACK 4			;
	; push	debug_message	;
	; call	printf			;
	; UNALIGN_STACK 4			;
	; ;_debug_

	; cmp_string
	mov		edi, len_substring
	add		edi, 1

	;_debug_
	ALIGN_STACK 8				;
	push	edi					;
	push	debug_int_o_format 	;
	call	printf				;
	UNALIGN_STACK 8				;
	;_debug_	

	ALIGN_STACK 4
	push	edi
	call	malloc
	UNALIGN_STACK 4

	; ; _debug_
	; ALIGN_STACK 4			;
	; push	debug_message	;
	; call	printf			;
	; UNALIGN_STACK 4			;
	; ; _debug_

	mov		cmp_string, eax

	mov 	ebx, cmp_string
	mov		dword [ebx + edi], 0

	; _debug_
	ALIGN_STACK 4			;
	push	debug_message	;
	call	printf			;
	UNALIGN_STACK 4			;
	; _debug_

	ALIGN_STACK 8
	push	string
	push	cmp_string
	call	strcpy
	UNALIGN_STACK 8		

	; ; _debug_
	; ALIGN_STACK 4			;
	; push	debug_message	;
	; call	printf			;
	; UNALIGN_STACK 4			;
	; ; _debug_

	; loop
	mov		edi, len_string
	sub		edi, len_substring
	add		edi, 1

	mov		boundary_iterator_val, edi
	mov		edi, 0
	mov		ebx, cmp_string

	.L:
		cmp		edi, boundary_iterator_val
		jae		.exit_func 

		ALIGN_STACK 12
		push	len_substring
		push	ebx
		push	substring
		call	strncmp
		UNALIGN_STACK 12

		cmp		eax, 0
		je		.substr_true

		add		ebx, BYTE_SIZE
		inc		edi

		jmp		.L

	.substr_true:
		mov		ebx, res_struct_data

		mov		dword [ebx], 1
		mov		dword [ebx + 4], edi

		mov		esi, edi
		add		esi, len_substring
		sub		esi, 1

		mov		dword [ebx + 8], esi

		jmp		.exit_func

.exit_func:
	ALIGN_STACK 4
	push	cmp_string
	call	free
	UNALIGN_STACK 4

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
	BYTE_SIZE			equ		1
	newline				dd 		0x0000000A		
	
	char_i_format		db		`%c`, 0

	str_o_format		db 		`%s\n`, 0
	
	int_o_format		db		`%d `, 0


section .data
	debug_message			db		`_debug_\n`, 0
	debug_o_format 			db		`_%s_%d_\n`, 0
	debug_int_o_format		db 		`_%d_\n`, 0
	debug_char_o_format		db		`_%c_`, 0


; ALIGN_STACK 4			;
; push	debug_message	;
; call	printf			;
; UNALIGN_STACK 4			;
