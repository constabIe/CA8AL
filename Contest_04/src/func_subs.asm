bits 32

; %pragma elf32 prefix _

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

%macro FUNCTION_EPILOGUE 1.nolist
	add		esp, %1
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
%define unary_func_name		ebp - 48	
%define operand				ebp - 52
%define opearnd_obj			ebp - 56	
%define variable			ebp - 60	
%define variable_obj		ebp - 64		
%define iterator			ebp - 68
%define	user_stack_ptr		ebp - 72

; ; Начальное значение регистра eax указывает на адрес func
; mov eax, [eax]            ; eax = func->obj_rpn (получаем адрес obj_rpn)
; mov eax, [eax]            ; eax = func->obj_rpn->rpn (получаем адрес rpn)
; mov eax, [eax]            ; eax = func->obj_rpn->rpn[0] (получаем адрес rpn[0])
; mov eax, [eax + type_offset] ; eax = func->obj_rpn->rpn[0]->type (получаем значение type)

; ; В этом примере предполагается, что смещение поля 'type' от начала структуры известно и хранится в type_offset.


global func_subs
func_subs:
	FUNCTION_PROLOGUE 68

	push	ebx
	push	edi
	push	esi

	mov		ebx, user_stack
	mov		[user_stack_ptr], ebx

	mov		ebx, [func] ; func

	mov		esi, [ebx]
	mov		[obj_rpn], esi

	mov		edi, [esi]
	mov		[rpn], edi

	mov		edi, [esi + DWORD_SIZE]
	mov		[rpn_size], esi

	mov		dword [iterator], 0
	mov		ebx, 0

	.L:
		mov		edi, [iterator]
		cmp		edi, [rpn_size]
		jae		.continue_func

		mov		edi, [rpn]

		mov		esi, [edi + ebx]
		mov		[rpn_el], esi

		mov		edi, [esi + DWORD_SIZE]
		mov		[rpn_el_type], edi

		; debug
		ALIGN_STACK 8
		push	edi
		push	debug_o_format_int
		call	printf
		UNALIGN_STACK 8
		; debug

		cmp		edi, OPERATOR
		je		.operator

		cmp		edi, OPERAND
		je		.operand

		cmp		edi, VARIABLE
		je		.variable

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

				cmp		esi, DIV_INSTR
				jbe		.std_operators
				jmp		.pow_instr

				.std_operators:
					mov		edi, [user_stack_ptr]

					fld		qword [edi - QWORD_SIZE]
					fld		qword [edi]

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
						jmp		.continue_std_operators

					.sub_instr:
						fsubp
						jmp		.continue_std_operators

					.mul_instr:
						fmulp
						jmp		.continue_std_operators

					.div_instr:
						fdivp
						jmp		.continue_std_operators

				.continue_std_operators:
					sub		edi, QWORD_SIZE
					fstp	qword [user_stack_ptr]

					jmp		.continue_binary

				.pow_instr:
					ALIGN_STACK 8
					lea		esi, [user_stack_ptr]
					push	esi
					lea		esi, [user_stack_ptr - QWORD_SIZE]
					push	esi
					call	pow
					UNALIGN_STACK 8

					sub		edi, QWORD_SIZE
					fstp	qword [edi]

					jmp		.continue_binary

			.continue_binary:
				mov		[user_stack_ptr], edi

				jmp		.continue_L

			.unary:
				mov		edi, [esi]
				mov		[unary], edi

				mov		esi, [edi + DWORD_SIZE]
				mov		[unary_func_name], esi

				mov		esi, [edi]
				mov		[unary_func_ptr], esi	

				ALIGN_STACK 4
				lea		esi, [user_stack_ptr]
				push	esi
				call	dword [unary_func_ptr]
				UNALIGN_STACK 4

				fstp	qword [user_stack_ptr]

				jmp 	.continue_L

		.operand:
			mov		esi, [edi]
			mov		[operand], esi		

			fld		qword [esi]

			add		dword [user_stack_ptr], QWORD_SIZE
			fstp	qword [user_stack_ptr]

			jmp 	.continue_L

		.variable:
			fld		qword [val]

			add		dword [user_stack_ptr], QWORD_SIZE
			fstp	qword [user_stack_ptr]

			jmp 	.continue_L				

	.continue_L:
		add		ebx, DWORD_SIZE
		inc		dword [iterator]

		jmp		.L

.continue_func:
	fstp 	qword [user_stack_ptr]

	pop 	esi
	pop		edi
	pop		ebx

	FUNCTION_EPILOGUE 68

	ret

section .bss
	user_stack 		resq	500

section .data
	DWORD_SIZE		equ		4
	QWORD_SIZE		equ		8

section .data
	debug_o_format_int		db		`%d\n`, 0
	debug_o_format_str		db		`%s\n`, 0
	debug_message			db 		`_debug_`, 0
