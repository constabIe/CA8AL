bits 32

extern malloc, calloc, realloc, free
extern printf, scanf 
extern strcpy, strncpy, strncmp, strlen

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

%define	string_1			dword [ebp -  4]
%define	len_str_1			dword [ebp -  8]
%define	string_2			dword [ebp - 12]
%define	len_str_2			dword [ebp - 16]
%define struct_issubstr		dword [ebp - 20]
%define	flag_swap			dword [ebp - 24]
%define	res_string			dword [ebp - 28]
%define	dummy_res_string	dword [ebp - 32]
%define	dummy_string_1		dword [ebp - 36]


global main
main:
	FUNCTION_PROLOGUE 36

	push	ebx
	push	edi

	ALIGN_STACK 0
	call	get_str
	UNALIGN_STACK 0

	mov		string_1, eax
	mov		dummy_string_1, eax

	ALIGN_STACK 4
	push	string_1
	call	strlen
	UNALIGN_STACK 4

	mov		len_str_1, eax

	ALIGN_STACK 0
	call	get_str
	UNALIGN_STACK 0

	mov		string_2, eax

	ALIGN_STACK 4
	push	string_2
	call	strlen
	UNALIGN_STACK 4

	mov		len_str_2, eax

	mov		flag_swap, 0

	mov		edi, len_str_2
	cmp		edi, len_str_1
	ja 		.swap
	jmp 	.continue_main

	.swap:
		mov		flag_swap, 1

		mov		ebx, len_str_1
		xchg	len_str_2, ebx
		mov		len_str_1, ebx

		mov		ebx, string_1
		xchg	string_2, ebx
		mov		string_1, ebx

		mov		ebx, string_2
		mov		dummy_string_1, ebx

		jmp		.continue_main

.continue_main:
	ALIGN_STACK 16
	push	len_str_2
	push	string_2
	push	len_str_1
	push	string_1
	call	issubstr
	UNALIGN_STACK 16

	mov		struct_issubstr, eax

	; ; debug
	; ALIGN_STACK 8
	; push	string_1
	; push	debug_str_o_format
	; call	printf
	; UNALIGN_STACK 8
	; ; debug

	mov		ebx, struct_issubstr

	cmp		dword [ebx], 1
	je		.true_substr
	jne		.false_substr

	.true_substr:
		ALIGN_STACK 4
		push	103
		call	calloc
		UNALIGN_STACK 4

		mov		res_string, eax
		mov		dummy_res_string, eax

		mov		edi, dword [ebx + 4]

		ALIGN_STACK 12
		push	edi
		push	dummy_string_1
		push	dummy_res_string
		call	strncpy
		UNALIGN_STACK 12

		add		dummy_res_string, edi
		add		dummy_string_1, edi

		mov		esi, dummy_res_string
		mov		byte [esi], LEFT_SQUARE_BRACKET

		add		dummy_res_string, 1

		mov		edi, len_str_2

		ALIGN_STACK 12
		push	edi
		push	dummy_string_1
		push	dummy_res_string
		call	strncpy
		UNALIGN_STACK 12

		add		dummy_res_string, edi
		add		dummy_string_1, edi

		mov		esi, dummy_res_string
		mov		byte [esi], RIGHT_SQUARE_BRACKET

		add		dummy_res_string, 1

		mov		edi, len_str_1
		sub		edi, len_str_2
		sub		edi, dword [ebx + 4]

		ALIGN_STACK 12
		push	edi
		push	dummy_string_1
		push	dummy_res_string
		call	strncpy
		UNALIGN_STACK 12

		add		dummy_res_string, edi
		mov		dummy_res_string, 0

		ALIGN_STACK 8
		push	res_string
		push	str_o_format
		call	printf
		UNALIGN_STACK 8

		ALIGN_STACK 4
		push	res_string
		call	free
		UNALIGN_STACK 4

		jmp		.exit_func

	.false_substr:
		cmp		flag_swap, 1
		je		.true_flag_swap
		jne		.false_flag_swap

		.true_flag_swap:
			ALIGN_STACK 8
			push	string_2
			push	str_o_format
			call	printf
			UNALIGN_STACK 8
	
			jmp		.exit_func

		.false_flag_swap:
			ALIGN_STACK 8
			push	string_1
			push	str_o_format
			call	printf
			UNALIGN_STACK 8
	
			jmp		.exit_func

.exit_func:
	ALIGN_STACK 4
	push	struct_issubstr
	call	free
	UNALIGN_STACK 4	

	pop		edi
	pop 	ebx

	FUNCTION_EPILOGUE 36

	xor		eax, eax
	ret

%undef	string_1
%undef	len_str_1
%undef	string_2
%undef	len_str_2
%undef 	struct_issubstr
%undef	flag_swap

; ------------------------endmain-------------------------

%define	dst		dword [ebp - 4]

global get_str
get_str:
	FUNCTION_PROLOGUE 4

	push	ebx
	push	edi

	ALIGN_STACK 4
	push	101
	call	malloc
	UNALIGN_STACK 4

	mov		dst, eax

	mov		ebx, dst
	mov		edi, NEWLINE

	.L:
		ALIGN_STACK 8
		push	ebx
		push	char_i_format
		call	scanf
		UNALIGN_STACK 8

		cmp		dword [ebx], edi
		je		.exit_func

		add		ebx, BYTE_SIZE

		jmp 	.L

.exit_func:
	mov		byte [ebx], 0

	mov		eax, dst

	pop		edi
	pop		ebx

	FUNCTION_EPILOGUE 4

	ret

%undef	dst

; -----------------------functions-----------------------

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
	push	edi
	push	esi

	ALIGN_STACK 4
	push	12
	call	malloc
	UNALIGN_STACK 4

	mov 	dword [eax], 0
	mov		dword [eax + 4], -1
	mov		dword [eax + 8], -1	

	mov		res_struct_data, eax

	mov		edi, len_string
	add		edi, 1

	ALIGN_STACK 4
	push	edi
	call	malloc
	UNALIGN_STACK 4

	mov		byte [eax + edi], 0

	mov		cmp_string, eax

	ALIGN_STACK 8
	push	string
	push	cmp_string
	call	strcpy
	UNALIGN_STACK 8

	mov		esi, len_string
	sub		esi, len_substring
	add		esi, 1

	mov		boundary_iterator_val, esi
	xor		esi, esi

	mov		ebx, cmp_string

	.L:
		cmp		esi, boundary_iterator_val
		jae		.exit_func

		ALIGN_STACK 12
		push	len_substring
		push	substring
		push	ebx
		call 	strncmp
		UNALIGN_STACK 12

		cmp		eax, 0
		je 		.match
		jmp		.L_continue

		.match:
			mov 	edi, res_struct_data

			mov		dword [edi], 1
			mov		dword [edi + 4], esi

			add		esi, len_substring
			sub		esi, 1

			mov		dword [edi + 8], esi

			jmp 	.exit_func

	.L_continue:
		inc		esi

		add		ebx, BYTE_SIZE

		jmp		.L

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

; section .bss
; 	string_1				resb	101
; 	string_2				resb	101	
	
section .data	
	BYTE_SIZE				equ		1
	NEWLINE					equ 		0x0A
	LEFT_SQUARE_BRACKET		equ 		0x5B
	RIGHT_SQUARE_BRACKET	equ 		0x5D
		
	char_i_format			db		`%c`, 0
	
	str_i_format			db		`%s\n`, 0
	str_o_format			db 		`%s\n`, 0
		
	int_o_format			db		`%d `, 0


section .data
	debug_message			db		`_debug_\n`, 0
	debug_str_o_format 			db		`_%s_\n`, 0
	debug_o_str_int_format	db 		`_%s_%d_\n`, 0
	debug_int_o_format		db 		`_%d_\n`, 0
	debug_char_o_format		db		`_%c_`, 0


;; debug
; ALIGN_STACK 4	
; push	debug_message
; call	printf
; UNALIGN_STACK 4
;; debug