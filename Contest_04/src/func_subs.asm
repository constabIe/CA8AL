bits 32

extern printf
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

%macro FUNCTION_EPILOGUE 0.nolist
	leave
%endmacro	

section .text

%define OPERATOR			0
%define OPERAND				1
%define VARIABLE			2
		
%define BINARY				0
%define UNARY				1
		
%define ADD_INSTR			7
%define SUB_INSTR			8
%define MUL_INSTR			9
%define DIV_INSTR 			10
%define POW_INSTR			11

%define val					ebp + 12
%define func 				ebp + 8
%define obj_rpn				ebp - 4
%define rpn 				ebp - 8
%define rpn_size			ebp - 12				
%define rpn_el				ebp - 16
%define rpn_el_type			ebp - 20
%define operator			ebp - 24
%define operator_type		ebp - 28
%define binary				ebp - 32
%define bin_func_name		ebp - 36		
%define unary				ebp - 40
%define unary_func_ptr		ebp - 44	
%define operand				ebp - 48
%define variable			ebp - 52		
%define iterator			ebp - 56
%define	user_stack_ptr		ebp - 60
%define fpu_ctrl    		ebp - 64
%define tmp_ebx				ebp - 68
%define tmp_edi				ebp - 72
%define tmp_esi				ebp - 76

global func_subs
func_subs:
	FUNCTION_PROLOGUE 72

	mov		dword [tmp_ebx], ebx
	mov		dword [tmp_edi], edi
	mov		dword [tmp_esi], esi

	mov		ebx, user_stack
	mov		[user_stack_ptr], ebx

	mov		ebx, [func] 

	mov		esi, [ebx]

	mov		edi, [esi]
	mov		[rpn], edi

	mov		edi, [esi + DWORD_SIZE]
	mov		[rpn_size], edi

	mov		dword [iterator], 0
	mov		ebx, 0
	fstcw   word [fpu_ctrl]
	finit

	.L:
		mov		edi, [iterator]
		cmp		edi, [rpn_size]
		jae		.continue_func

		mov		edi, [rpn]

		mov		esi, [edi + ebx]
		mov		[rpn_el], esi

		mov		edi, [esi + DWORD_SIZE]
		mov		[rpn_el_type], edi

		cmp		edi, OPERATOR
		je		.operator

		cmp		edi, OPERAND
		je		.operand		

		cmp		edi, VARIABLE
		je		.variable

		.operator:
			mov		edi, [esi]
			mov		edi, [edi]
			mov		[operator], edi

			mov		esi, [edi + DWORD_SIZE]
			mov		[operator_type], esi

			cmp		esi, BINARY
			je		.binary
			jne		.unary

			.binary:
				mov		esi, [edi]
				mov		esi, [esi]
				mov		[binary], esi

				mov		edi, dword [user_stack_ptr]
				fld		qword [edi]
				fld		qword [edi - QWORD_SIZE]

				sub		dword [user_stack_ptr], QWORD_SIZE
				sub		dword [user_stack_ptr], QWORD_SIZE

				mov		edi, [esi]
				mov		[bin_func_name], edi

				cmp		edi, POW_INSTR
				ja		.std_operator
				je		.pow_operator

				.std_operator:
					cmp		edi, ADD_INSTR
					je		.add_instr

					cmp		edi, SUB_INSTR
					je		.sub_instr

					cmp		edi, MUL_INSTR
					je		.mul_instr

					cmp		edi, DIV_INSTR
					je		.div_instr

					.add_instr:
						faddp
						jmp		.continue_operator

					.sub_instr:
						fsubrp
						jmp		.continue_operator

					.mul_instr:
						fmulp
						jmp		.continue_operator

					.div_instr:
						fdivrp
						jmp		.continue_operator

				.pow_operator:
					ALIGN_STACK 16
					sub		esp, 8
					fstp	qword [esp]
					sub		esp, 8
					fstp	qword [esp]
					call	pow
					UNALIGN_STACK 16

					jmp		.continue_operator

			.unary:
				mov		esi, [edi]
				mov		esi, [esi]
				mov		[unary], esi

				mov		edi, [esi]
				mov		[unary_func_ptr], edi

				mov		edi, dword [user_stack_ptr]
				fld		qword [edi]
				sub		dword [user_stack_ptr], QWORD_SIZE

				ALIGN_STACK 8
				sub		esp, 8
				fstp	qword [esp]
				call	dword [unary_func_ptr]
				UNALIGN_STACK 8

				jmp		.continue_operator	

		.continue_operator:
			add		dword [user_stack_ptr], QWORD_SIZE
			mov		edi, dword [user_stack_ptr]
			fstp	qword [edi]		

			jmp		.continue_L

		.operand:
			mov		edi, [esi]
			mov		edi, [edi]
			mov		[operand], edi

			fld		qword [edi]
			add		dword [user_stack_ptr], QWORD_SIZE
			mov		esi, dword [user_stack_ptr]
			fstp	qword [esi]

			fld		qword [esi]

			jmp		.continue_L

		.variable:
			fld		qword [val]
			add		dword [user_stack_ptr], QWORD_SIZE
			mov		edi, dword [user_stack_ptr]
			fstp	qword [edi]

			jmp		.continue_L

	.continue_L:
		inc		dword [iterator]
		add		ebx, DWORD_SIZE

		jmp		.L

.continue_func:
	fldcw   word [fpu_ctrl]

	finit
	mov		edi, [user_stack_ptr]
	fld		qword [edi]

	mov		ebx, dword [tmp_ebx]
	mov		edi, dword [tmp_edi]
	mov		esi, dword [tmp_esi]

	FUNCTION_EPILOGUE

	ret

%undef	OPERATOR
%undef	OPERAND
%undef	VARIABLE

%undef	BINARY
%undef	UNARY

%undef	ADD_INSTR
%undef	SUB_INSTR
%undef	MUL_INSTR
%undef	DIV_INSTR
%undef	POW_INSTR

%undef	val
%undef	func
%undef	obj_rpn
%undef	rpn
%undef	rpn_size
%undef	rpn_el
%undef	rpn_el_type
%undef	operator
%undef	operator_type
%undef	binary
%undef	bin_func_name
%undef	unary
%undef	unary_func_ptr
%undef	operand
%undef	variable
%undef	iterator
%undef	user_stack_ptr
%undef	fpu_ctrl
%undef	tmp_ebx
%undef	tmp_edi
%undef	tmp_esi

section .bss
	user_stack 		resq	500

section .data
	DWORD_SIZE		equ		4
	QWORD_SIZE		equ		8
