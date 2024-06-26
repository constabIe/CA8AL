	bits 32

%inclue "io.inc"

section .text
RangeExceptionCondition:
	PRINT_STRING RangeExceptionMessage
	NEWLINE

	xor eax, eax
	int 0x0A

global main
main:
	GET_DEC 4, eax

	cmp 	eax, MAX_SIZE
	ja 	RangeExceptionCondition

	cmp 	eax, MIN_SIZE
	jb 	RangeExceptionCondition

	mov 	[n], eax

	GET_DEC 4, eax

	cmp 	eax, MAX_SIZE
	ja 	RangeExceptionCondition

	cmp 	eax, MIN_SIZE
	jb 	RangeExceptionCondition

	mov 	[m], eax

	GET_DEC 4, eax

	cmp 	eax, MAX_SIZE
	ja 	RangeExceptionCondition

	cmp 	eax, MIN_SIZE
	jb 	RangeExceptionCondition

	mov 	[k], eax

	mov 	[ebp + 8], operand_matrix_1
	mov 	[ebp + 12], n
	mov 	[ebp + 12], m

	call 	mscanf

	mov 	[ebp + 8], operand_matrix_2
	mov 	[ebp + 12], m
	mov 	[ebp + 12], k

	call 	mscanf

global mscanf

%define src_size_j		dword [ebp + 16]
%define src_size_i		dword [ebp + 12]
%define matrix_base		dword [ebp +  8]

mscanf:
	push 	ebp
	mov 	ebp, esp

	push 	eax
	push 	ebx
	push 	ecx
	push 	edx

    	xor 	eax, eax
    	mov 	ecx, matrix_base

.rows_loop:
 	cmp 	eax, src_size_i
 	jae 	mscanf.rows_loop_exit 

 	xor 	ebx, ebx

 	.cols_loop:
 		cmp     ebx, src_size_j
        	jae     mscanf.cols_loop_exit

       GET_DEC	4, edx

       cmp 	edx, MAX_CELL_VAL
       ja 	RangeExceptionCondition
       cmp 	edx, MIN_CELL_VAL
       jb 	RangeExceptionCondition

       mov 	[ecx], edx

       add 	ecx, INT32_SIZE

       inc 	ebx
       jmp 	mscanf.cols_loop

    .cols_loop_exit:
    	inc 	eax
    	jmp 	mscanf.rows_loop

.rows_loop_exit:
	pop 	edx 	 
	pop 	ecx 	 	
	pop 	ebx 	 	
	pop 	eax 

	mov    esp, ebp
    	pop    ebp	

	ret  

global mprintf

%define src_size_j		dword [ebp + 16]
%define src_size_i		dword [ebp + 12]
%define matrix_base		dword [ebp +  8]

mprintf:
	push 	ebp
	mov 	ebp, esp

	push 	eax
	push 	ebx
	push 	ecx

    	xor 	eax, eax
    	mov 	ecx, matrix_base

 .rows_loop:
 	cmp 	eax, src_size_i
 	jae 	mprintf.rows_loop_exit 

 	xor 	ebx, ebx

 	.cols_loop:
 		cmp     ebx, src_size_j
        	jae     mprintf.cols_loop_exit

       PRINT_DEC	4, [ecx]

       add 	ecx, INT32_SIZE

       inc 	ebx
       jmp 	mprintf.cols_loop

    .cols_loop_exit:
    	inc 	eax
    	jmp 	mprintf.rows_loop

.rows_loop_exit:	 
	pop 	ecx 	 	
	pop 	ebx 	 	
	pop 	eax 

	mov    esp, ebp
    	pop    ebp	

	ret  

global matrix_product_operation

%define matrix_result_size_j		dword [ebp + 40]
%define matrix_result_size_i		dword [ebp + 36]
%define matrix_result_base			dword [ebp + 32]

%define matrix_operand_2_size_j		dword [ebp + 28]
%define matrix_operand_2_size_i		dword [ebp + 24]
%define matrix_operand_2_base		dword [ebp + 20]

%define matrix_operand_1_size_j		dword [ebp + 16]
%define matrix_operand_1_size_i		dword [ebp + 12]
%define matrix_operand_1_base		dword [ebp + 8]

%define matrix_result_index_i       	dword [ebp -  4]
%define matrix_result_index_j       	dword [ebp -  8]

; Position in matrix: matrix[y][x] = matrix + 4 * (MATRIX_SIZE * y + x)

matrix_product_operation:
	push 	ebp
	mov 	ebp, esp

	push 	eax
	push 	ebx
	push  	ecx
	push  	edx
	push  	edi
	push  	esi

	mov 	ecx, matrix_operand_1_base
	mov 	edx, matrix_operand_2_base
	mov 	esi, matrix_result_base

	xor  	eax, eax

.rows_loop:
	cmp  	eax, matrix_operand_1_size_i
	jae 	matrix_product_operation.rows_loop_exit 

	xor  	ebx, ebx

	.cols_loop:
		cmp  	ebx, matrix_operand_2_size_j
		jae 	matrix_product_operation.cols_loop_exit 

		xor  	edi, edi

		mov  	matrix_result_index_i, eax
		mov 	matrix_result_index_j, ebx
		
		.calculations_loop:
			cmp  	edi, matrix_operand_1_size_j
			jae 	matrix_product_operation.calculations_loop_exit 

			; xor  eax, eax
			; xor 	ebx, ebx

			mov 	eax, [matrix_operand_1_base + 4 * (eax * edi)]
			mov 	ebx, [matrix_operand_2_base + 4 * (ebx * edi)]
			imul 	ebx

			xchg 	matrix_result_index_i, eax

		.calculations_loop_exit:

	.cols_loop_exit:

.rows_loop_exit:


section .text


section .bss
	n: 				resd	1
	m: 				resd 	1
	k:				resd	1
	
	matrix_operand_1:		resd 	MAX_SIZE * MAX_SIZE
	matrix_operand_2:		resd 	MAX_SIZE * MAX_SIZE
	matrix_result 		resd 	MAX_SIZE * MAX_SIZE
	
section .data	
	MAX_SIZE			equ	100
	MIN_SIZE			equ	1
	MAX_CELL_VAL			equ	1000
	MIN_CELL_VAL			equ	-1000	
	INT32_SIZE			equ 	4

section .rodata
	RangeExceptionMessage	db 	`Input data is out of range`, 0