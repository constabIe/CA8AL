; days_in_year += (i_months - 1) / 2 * (even + odd) 
; days_in_year += ((i_months - 1) % 2) * even 
; days_in_year += i_days 

bits 32

extern io_get_dec, io_get_udec, io_get_hex 
extern io_get_char, io_get_string

extern io_print_dec, io_print_udec, io_print_hex 
extern io_print_char, o_print_string, io_newline


section .text
global main
main:
	call io_get_dec
	mov  dword [i_months], eax

	call io_get_dec
	mov  dword [i_days], eax

	; preps for arith ops
	sub  dword [i_months], 1
	add  eax, even_month
	add  eax, odd_month

	mov  dword [sum_even_odd], eax

	; (i_months - 1) / 2
	mov  eax, dword [i_months]
	mov  ecx, 2
	div  ecx

	; save the values after div
	mov  dword [quotient], eax
	mov  dword [remainder], edx

	; days_in_year += (i_months - 1) / 2 * (even + odd)
	; mov  eax, dword [quotient]
	mul  dword [sum_even_odd]

	add  dword [days_in_year], eax

	; days_in_year += ((i_months - 1) % 2) * even
	mov  eax, dword [remainder]
	mul  even_month

	add  dword [days_in_year], eax

	; days_in_year += i_days
	mov  eax, i_days
	add  dword [days_in_year], eax

	mov  eax, dword [days_in_year]

	call io_print_dec

	xor  eax, eax
	ret


section .bss
	i_months: 			resd  1
	i_days:				resd  1
	days_in_year:		resd  1

	quotient:			resd  1
	remainder:			resd  1
	sum_even_odd:		resd  1

section .rodata
	even_month:			dd    41 ; in days
	odd_month:			dd    42 ; in days