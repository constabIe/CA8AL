.operator:
			; debug
			ALIGN_STACK 8
			push	debug_message
			push	debug_o_format_str
			call 	printf
			UNALIGN_STACK 8
			; debug
			
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

				mov		edi, [esi]
				mov		[bin_func_name], edi

				cmp		edi, DIV_INSTR
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
				mov		esi, [edi]
				mov		[unary], esi

				mov		edi, [esi + DWORD_SIZE]
				mov		[unary_func_name], edi

				mov		edi, [esi]
				mov		[unary_func_ptr], edi	

				ALIGN_STACK 4
				lea		esi, [user_stack_ptr]
				push	esi
				call	dword [unary_func_ptr]
				UNALIGN_STACK 4

				fstp	qword [user_stack_ptr]

				jmp 	.continue_L

		.operand:
			; debug
			ALIGN_STACK 8
			push	debug_message
			push	debug_o_format_str
			call 	printf
			UNALIGN_STACK 8
			; debug

			mov		edi, [esi]
			mov		[operand], edi		

			fld		qword [edi]

			add		dword [user_stack_ptr], QWORD_SIZE
			fstp	qword [user_stack_ptr]

			jmp 	.continue_L

		.variable:
		; debug
		ALIGN_STACK 8
		push	debug_message
		push	debug_o_format_str
		call 	printf
		UNALIGN_STACK 8
		; debug	
			fld		qword [val]

			add		dword [user_stack_ptr], QWORD_SIZE
			fstp	qword [user_stack_ptr]

			jmp 	.continue_L				

	.continue_L:
		add		ebx, DWORD_SIZE
		dec		dword [iterator]

		; ; debug
		; ALIGN_STACK 8
		; push	debug_message
		; push	debug_o_format_str
		; call 	printf
		; UNALIGN_STACK 8
		; ; debug	

		jmp		.L