bits 32

extern scanf
extern pow

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

%define OPERATOR	0
%define OPERAND		1
%define VARIABLE	2

%define BINARY		0
%define UNARY		1

%define SQRT_INSTR
%define ADD_INSTR	7
%define SUB_INSTR	8
%define MUL_INSTR	9
%define DIV_INSTR 	10
%define POW_INSTR	11

%define val					ebp + 12
%define func 				ebp + 8
%define rpn					ebp - 4
%define rpn_size			ebp - 12				
%define rpn_el				ebp - 16
%define rpn_el_type			ebp - 20
%define operator			ebp - 24
%define operator_type		ebp - 28
%define binary				ebp - 32
%define bin_func_name		ebp - 36		
%define unary				ebp - 40
%define unary_func_ptr		ebp - 44	
%define unary_func_name		ebp - 48	
%define operand				ebp - 52
%define opearnd_obj			ebp - 56	
%define variable			ebp - 60	
%define variable_obj		ebp - 64		
%define iterator			ebp - 68

global f_subs
f_subs:
	FUNCTION_PROLOGUE ???????

	push	ebx
	push	edi
	push	esi

	push	edx
	push	ecx

	mov		ebx, [func]

	mov 	edi, [ebx]
	mov	 	[rpn], edi

	add		ebx, DWORD_SIZE
	mov 	edi, [ebx]
	mov	 	[rpn_size], edi

	mov		[iterator], 0
	mov		ebx, DWORD_SIZE

	.L:
		mov		edi, [iterator]
		cmp		edi, [rpn_size]
		jae		.continue_func

		mov		edi, [rpn]
		add		edi, ebx
		mov		[rpn_el], edi

		mov		esi, [edi + DWORD_SIZE]
		mov		[rpn_el_type], esi

		cmp		esi, OPERATOR
		je		.operator

		cmp		esi, OPERAND
		je		.operand

		cmp		esi, VARIABLE
		je		.variable

		; jmp		.continue_L

		.operator:
			mov		esi, [edi]
			mov		[operator], esi

			mov		edi, [esi + DWORD_SIZE]
			mov		[operator_type], edi

			cmp		edi, BINARY
			je		.binary
			jne		.unary	

			.binary:
				mov		edi, [esi]
				mov		[binary], edi

				mov		esi, [edi]
				mov		[bin_func_name], esi

				mov		edi, [user_stack_ptr - DWORD_SIZE]	
				fld		qword [edi]

				mov		edi, [user_stack_ptr]	
				fld		qword [edi]

				sub 	dword user_stack_ptr, DWORD_SIZE
				sub 	dword user_stack_ptr, DWORD_SIZE

				cmp		esi, ADD_INSTR
				je		.add_instr

				cmp		esi, SUB_INSTR
				je		.sub_instr

				cmp		esi, MUL_INSTR
				je		.mul_instr

				cmp		esi, DIV_INSTR
				je		.div_instr

				.add_instr:
					faddp
					jmp		.continue_binary

				.sub_instr:
					fsubp
					jmp		.continue_binary

				.mul_instr:
					fmulp
					jmp		.continue_binary

				.div_instr:
					fdivp
					jmp		.continue_binary

			.continue_binary:
				fstp	dword [user_stack_ptr]

				jmp .continue_L

			.unary:
				mov		edi, [esi]
				mov		[unary], edi

				mov		esi, [edi + DWORD_SIZE]
				mov		[unary_func_name], esi

				cmp		esi, POW_INSTR
				je		.

				mov		esi, [edi]
				mov		[unary_func_ptr], esi

				mov		edi, [user_stack_ptr]	
				fld		qword [edi]
				sub		dword user_stack_ptr, DWORD_SIZE



				ALIGN_STACK 4
				push	qword [edi]
				call	dword [unary_func_ptr]
				UNALIGN_STACK 4

				mov		[user_stack_ptr], eax

				jmp 	.continue_L

		.operand:
			mov		esi, [edi]
			mov		[operand], esi		

			mov		edi, [esi]
			mov		[opearnd_obj], edi

			mov		[user_stack_ptr], edi
			add		dword user_stack_ptr, DWORD_SIZE

			jmp 	.continue_L

		.variable:
			mov		edi, [val]
			mov		[user_stack_ptr], edi
			add		dword user_stack_ptr, DWORD_SIZE

			jmp 	.continue_L				


	.continue_L:
		add		ebx, DWORD_SIZE
		inc		dword [iterator]

		jmp		.L


	
	pop		ecx
	pop		edx

	pop 	esi
	pop		edi
	pop		ebx

	FUNCTION_EPILOGUE ???????

	ret

; %define	val 	ebp + 8

; global user_push
; user_push:
; 	FUNCTION_PROLOGUE 0

; 	push	ebx

; 	mov		ebx, [val]
; 	mov		[user_stack_ptr], ebx

; 	add		phony_stack_ptr, DWORD_SIZE

; 	pop		ebx

; 	FUNCTION_EPILOGUE 0

; 	ret

; %undef	val

section .bss
	user_stack 		resd	500

section .data
	DWORD_SIZE			equ		4

	user_stack_ptr		dd 		stack
