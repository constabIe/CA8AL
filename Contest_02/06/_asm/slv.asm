; bits 32

; extern io_get_dec, io_get_udec, io_get_hex 
; extern io_get_char, io_get_string

; extern io_print_dec, io_print_udec, io_print_hex 
; extern io_print_char, io_print_string, io_newline

; UINT32_LEN	equ	32
; UINT32_MAX	equ	0xFFFFFFFF

; section	.text
; global main
; main:
; 	; get and check input
; 	call io_get_udec
; 	mov [n], eax

; 	call io_get_dec
; 	mov [k], eax

; 	cmp eax, 31
; 	jns RangeException

; 	cmp eax, 1
; 	js RangeException

; 	; [template] and itterator preparing
; 	mov ecx, UINT32_MAX
; 	sub ecx, [k]

; 	mov eax, [template]
; 	shl dword [template], cl

; 	; cycle to find [max_value] 
; find_max_loop:
; 	mov eax, [template]
; 	and eax, [n]

; 	shr eax, cl

; 	cmp [max_value], eax
; 	jns if
; 	js continue_loop

; if:							; val > max_val
; 	mov [max_value], eax
; 	jmp continue_loop

; continue_loop:
; 	shr dword [template], 1

; 	dec ecx

; 	cmp ecx, 0
; 	jns find_max_loop
; 	js exit_program

; exit_program:
; 	mov eax, [max_value]
; 	call io_print_udec
; 	call io_newline

; 	xor eax, eax
; 	ret

; RangeException:
; 	mov eax, RangeExceptionMessage
; 	call io_print_string
; 	call io_newline

; 	xor eax, eax
; 	int 0x0A 

; section .bss
; 	n:	resd	1
; 	k:	resd	1

; section .data
; 	template	dd 	UINT32_MAX
; 	max_value	dd 	0

; section .rodata
; 	RangeExceptionMessage	db `Input data is out of range`, 0


bits 32

%include "io.inc"

UINT32_LEN	equ	32
UINT32_MAX	equ	0xFFFFFFFF

section	.text
global main
main:
	; get and verify input
	GET_UDEC 4, eax
	mov [n], eax

	GET_UDEC 4, eax

	cmp eax, 31
	jns RangeExceptionCondition

	cmp eax, 1
	js RangeExceptionCondition

	mov [k], eax


	; prepare template and itterator
	mov ebx, UINT32_LEN
	sub ebx, eax

	mov ecx, ebx

	shl dword [template], cl

	mov edx, 0 ; result -- max_value

find_max_loop:
	mov eax, [template]
	and eax, [n]
	shr eax, cl

	cmp eax, edx
	jns if_max
	js continue_find_max_loop

if_max:
	mov edx, eax
	jmp continue_find_max_loop

continue_find_max_loop:
	shr dword [template], 1

	dec ecx

	cmp ecx, -1
	jz exit_program
	jnz find_max_loop

exit_program:
	PRINT_UDEC 4, edx
	NEWLINE

	xor eax, eax
	ret

RangeExceptionCondition:
	PRINT_STRING RangeExceptionMessage
	NEWLINE

	xor eax, eax
	int 0x0A

section .bss
	n:	resd	1
	k:	resd	1

section .data
	template	dd 	UINT32_MAX

section .rodata
	RangeExceptionMessage	db `Input data is out of range`, 0
