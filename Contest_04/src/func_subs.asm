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
%define fpu_ctrl    		ebp - 76

global func_subs
func_subs:
	FUNCTION_PROLOGUE 72

	push	ebx
	push	edi
	push	esi

	fstcw   word [fpu_ctrl]
	finit
  ; Загружаем double в FPU стек

  	fld		qword [val]

    ; Подготовка аргументов для printf
    ALIGN_STACK 12
    sub esp, 8      ; Зарезервируем место для double
    fstp qword [esp]    ; Перемещаем double из FPU стека в стек
    push debug_o_format_double   ; Адрес строки формата
    call printf 
    UNALIGN_STACK 12       ; Вызов функции printf


	mov		ebx, user_stack
	mov		[user_stack_ptr], ebx

	mov		ebx, [func] ; func

	mov		esi, [ebx]
	mov		[obj_rpn], esi

	mov		edi, [esi]
	mov		[rpn], edi

	mov		edi, [esi + DWORD_SIZE]
	mov		[rpn_size], edi

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

		cmp		edi, OPERATOR
		je		.operator

		cmp		edi, OPERAND
		je		.operand		

		cmp		edi, VARIABLE
		je		.variable

		.operator:
			mov		edi, [esi]
			mov		[operator], edi

			mov		esi, [edi + DWORD_SIZE]
			mov		[operator_type], esi

			cmp		esi, BINARY
			je		.binary
			jne		.unary

			.binary:
				mov		esi, [edi]
				mov		[binary], esi

				mov		edi, dword [user_stack_ptr]
				fld		qword [edi - QWORD_SIZE]
				fld		qword [edi]

				; ; debug
				; ALIGN_STACK 20
				; sub		esp, 8
				; fstp	qword [esp]
				; sub		esp, 8
				; fstp	qword [esp]
				; push	debug_o_format_double
				; call	printf
				; UNALIGN_STACK 20
				; ; debug				

				fld		qword [edi - QWORD_SIZE]
				fld		qword [edi]

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
						jmp		.continue_binary

					.sub_instr:
						fsubrp
						jmp		.continue_binary

					.mul_instr:
						fmulp
						jmp		.continue_binary

					.div_instr:
						fdivrp
						jmp		.continue_binary

				.pow_operator:
					ALIGN_STACK 16
					sub		esp, 8
					fstp	qword [esp]
					sub		esp, 8
					fstp	qword [esp]
					call	pow
					UNALIGN_STACK 16

			.continue_binary:
				add		dword [user_stack_ptr], QWORD_SIZE
				mov		edi, dword [user_stack_ptr]
				fstp	qword [edi]

				fld		qword [edi]

				ALIGN_STACK 12
				sub		esp, 8
				fstp	qword [esp]
				push	debug_o_format_double
				call	printf
				UNALIGN_STACK 12

				jmp		.continue_L

			.unary:
				mov		esi, [edi]
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

				add		dword [user_stack_ptr], QWORD_SIZE
				mov		edi, dword [user_stack_ptr]
				fstp	qword [edi]		

				jmp		.continue_L			

		.operand:
			mov		edi, [esi]
			mov		edi, [edi]
			mov		[operand], edi

			; add		dword [user_stack_ptr], QWORD_SIZE

			; fld		qword [edi]
			; mov		esi, dword [user_stack_ptr]
			; fstp	qword [esi]

			fld		qword [edi]

			ALIGN_STACK 12
			sub		esp, 8
			fstp	qword [esp]
			push	debug_o_format_double
			call	printf
			UNALIGN_STACK 12

			jmp		.continue_L

		.variable:
			add		dword [user_stack_ptr], QWORD_SIZE

			fld		qword [val]
			mov		edi, dword [user_stack_ptr]
			fstp	qword [edi]

			; debug
			ALIGN_STACK 8
			push	debug_message
			push	debug_o_format_str
			call 	printf
			UNALIGN_STACK 8
			; debug	

			fld		qword [edi]
			; debug
			ALIGN_STACK 8
			push	debug_message
			push	debug_o_format_str
			call 	printf
			UNALIGN_STACK 8
			; debug	

			ALIGN_STACK 12
			sub		esp, 8
			fstp	qword [esp]
			push	debug_o_format_double
			call	printf
			UNALIGN_STACK 12

			jmp		.continue_L

	.continue_L:
		inc		dword [iterator]
		add		ebx, DWORD_SIZE

		jmp		.L

.continue_func:
	mov		edi, [user_stack]
	fstp	qword [edi]

	pop 	esi
	pop		edi
	pop		ebx

	FUNCTION_EPILOGUE 72

	ret

section .bss
	user_stack 		resq	500

section .data
	DWORD_SIZE		equ		4
	QWORD_SIZE		equ		8

section .data
	debug_o_format_int		db		`%u\n`, 0
	debug_o_format_double	db 		`%lf__`, 0
	debug_o_format_str		db		`%s\n`, 0
	debug_message			db 		`_debug_`, 0
	res 					dq		1.0

; ; debug
; ALIGN_STACK 8
; push	debug_message
; push	debug_o_format_str
; call 	printf
; UNALIGN_STACK 8
; ; debug	

