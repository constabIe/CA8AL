bits 32

%inclue "io.inc"

N equ 3
M equ 4
k equ 5

MAX_SIZE		equ	100
MIN_SIZE		equ	1
MAX_CELL_VAL	equ	1000
MIN_CELL_VAL	equ	-1000	
INT32_SIZE		equ 4


global	mscanf

%define	src_size_y			dword [ebp + 16]
%define src_size_x			dword [ebp + 12]
%define matrix_base			dword [ebp +  8]

mscanf:
	push 	ebp
	mov 	esp, ebp

	push 	eax
	push 	ebx
	push 	ecx
	push 	edx

    xor 	eax, eax
    mov 	ecx, matrix_base

.rows_loop:
 	cmp 	eax, src_size_y
 	jae 	mscanf.rows_loop_exit 

 	xor 	ebx, ebx

 	.cols_loop:
 		cmp     ebx, src_size_x
        jae     mscanf.cols_loop_exit

        GET_DEC	4, edx

        cmp 	edx, MAX_CELL_VAL
        ja 		RangeExceptionCondition

        cmp 	edx, MIN_CELL_VAL
        jb 		RangeExceptionCondition

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

	mov     esp, ebp
    pop     ebp	

	ret  

global mprintf

%define	src_size_y			dword [ebp + 16]
%define src_size_x			dword [ebp + 12]
%define matrix_base			dword [ebp +  8]

mprintf:
	push 	ebp
	mov 	esp, ebp

	push 	eax
	push 	ebx
	push 	ecx

    xor 	eax, eax
    mov 	ecx, matrix_base

 .rows_loop:
 	cmp 	eax, src_size_y
 	jae 	mprintf.rows_loop_exit 

 	xor 	ebx, ebx

 	.cols_loop:
 		cmp     ebx, src_size_x
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

	mov     esp, ebp
    pop     ebp	

	ret  

global matrix_product_operation
%define dest_size_x
%define matrix_operand_2_base
%define matrix_operand_1_base



section .text
global main
main:
	GET_DEC 4, eax

	cmp 	eax, MAX_SIZE
	ja RangeExceptionCondition

	cmp 	eax, MIN_SIZE
	jb 		RangeExceptionCondition

	mov 	[n], eax

	GET_DEC 4, eax

	cmp 	eax, MAX_SIZE
	ja 		RangeExceptionCondition

	cmp 	eax, MIN_SIZE
	jb 		RangeExceptionCondition

	mov 	[m], eax

	GET_DEC 4, eax

	cmp 	eax, MAX_SIZE
	ja 		RangeExceptionCondition

	cmp 	eax, MIN_SIZE
	jb 		RangeExceptionCondition

	mov 	[k], eax

	mov 	ecx, N * M

	mov 	eax, operand_matrix_1
	mov 	ecx, N * M

	call 	scanf_matrix

	mov 	eax, operand_matrix_2
	mov 	ecx, M * K
	xor 	edx, edx

	mov 	eax, M
	mov 	ebx, N
	imul 	ebx

	mov 	[ebp + 8], operand_matrix_1
	mov 	[ebp + 12], eax
	call 	mscanf





	
	

RangeExceptionCondition:
	PRINT_STRING RangeExceptionMessage
	NEWLINE

	xor eax, eax
	int 0x0A

section .bss
	n: 					resd	1
	m: 					resd 	1
	k:					resd	1

	operand_matrix_1:	resd 	N * M
	operand_matrix_2:	resd 	M * K

section .rodata
	RangeExceptionMessage	db `Input data is out of range`, 0