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

%define	string_1		dword [ebp -  4]
%define	len_str_1		dword [ebp -  8]
%define	string_2		dword [ebp - 12]
%define	len_str_2		dword [ebp - 16]
%define struct_issubstr	dword [ebp - 20]

global main
main:
	FUNCTION_PROLOGUE 20

	push	ebx
	push	edi

	ALIGN_STACK 0
	call	get_str
	UNALIGN_STACK 0

	mov		string_1, eax

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

	mov		edi, len_str_2
	cmp		edi, len_str_1
	ja 		.swap
	jmp 	.continue_main

	.swap:
		mov		ebx, len_str_1
		xchg	len_str_2, ebx
		mov		len_str_1, ebx

		mov		ebx, string_1
		xchg	string_2, ebx
		mov		string_1, ebx

		jmp		.continue_main

.continue_main:


	; ;_debug_
	; ALIGN_STACK 12
	; push	len_str_1
	; push	string_1
	; push	debug_o_str_int_format
	; call	printf
	; UNALIGN_STACK 12
	; ;_debug_

	; ;_debug_
	; ALIGN_STACK 12
	; push	len_str_2
	; push	string_2
	; push	debug_o_str_int_format
	; call	printf
	; UNALIGN_STACK 12
	; ;_debug_

	; ;_debug_
	; ALIGN_STACK 4
	; push	debug_message
	; call	printf
	; UNALIGN_STACK 4
	; ;_debug_

	ALIGN_STACK 16
	push	len_str_2
	push	string_2
	push	len_str_1
	push	string_1
	call	issubstr
	UNALIGN_STACK 16

	mov		struct_issubstr, eax

	mov		ebx, struct_issubstr

	ALIGN_STACK 8
	push	dword [ebx]
	push	debug_int_o_format
	call 	printf
	UNALIGN_STACK 8

	ALIGN_STACK 8
	push	dword [ebx + 4]
	push	debug_int_o_format
	call 	printf
	UNALIGN_STACK 8

	ALIGN_STACK 8
	push	dword [ebx + 8]
	push	debug_int_o_format
	call 	printf
	UNALIGN_STACK 8

	pop		edi
	pop 	ebx

	FUNCTION_EPILOGUE 20

	xor		eax, eax
	ret

%undef	string_1
%undef	len_str_1
%undef	string_2
%undef	len_str_2
%undef struct_issubstr

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
	mov		edi, [newline]

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
	mov		dword [ebx], 0

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

	mov		dword [eax + edi], 0

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
	newline					dd 		0x0000000A		
		
	char_i_format			db		`%c`, 0
	
	str_i_format			db		`%s\n`, 0
	str_o_format			db 		`%s\n`, 0
		
	int_o_format			db		`%d `, 0


section .data
	debug_message			db		`_debug_\n`, 0
	debug_o_format 			db		`_%s_\n`, 0
	debug_o_str_int_format	db 		`_%s_%d_\n`, 0
	debug_int_o_format		db 		`_%d_\n`, 0
	debug_char_o_format		db		`_%c_`, 0



; ALIGN_STACK 4			;
; push	debug_message	;
; call	printf			;
; UNALIGN_STACK 4			;
