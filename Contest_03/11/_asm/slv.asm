bits 32

%include "io.inc"

section .text
global div3

%define	value 			dword [ebp + 8]
%define iterations_q	16

div3:
	push 	ebp
	mov 	ebp, esp

	push  	ebx		; itterator 
	push 	edx		; bit position
	push 	esi		; check sub

	xor esi, esi 
	mov ebx, 0
	mov edx, 0
	inc edx

.loop_half_even:
	cmp 	ebx, iterations_q	
	jae 	.exit_loop_half_even

	bt 		value, edx
	jc 		.bit_1_even

	jmp 	.continue_loop_half_even
	
	.bit_1_even:
		add esi, 1
		jmp .continue_loop_half_even

.continue_loop_half_even:
	inc 	ebx
	add 	edx, 2

	jmp 	.loop_half_even

.exit_loop_half_even:
	mov ebx, 0
	mov edx, 0

.loop_half_odd:
	cmp 	ebx, iterations_q
	jae 	.exit_loop_half_odd

	bt 		value, edx
	jc 		.bit_1_odd

	jmp 	.continue_loop_half_odd
	
	.bit_1_odd:
		sub 	esi, 1
		jmp 	.continue_loop_half_odd

.continue_loop_half_odd:
	inc 	ebx
	add 	edx, 2

	jmp 	.loop_half_odd

.exit_loop_half_odd:
	mov ebx, 0
	mov edx, 0

.flag_setting:
	cmp 	esi, 15
	jz 		.flag_true

	cmp 	esi, 12
	jz 		.flag_true

	cmp 	esi, 9
	jz 		.flag_true

	cmp 	esi, 6
	jz 		.flag_true	

	cmp 	esi, 3
	jz 		.flag_true	

	cmp 	esi, 0
	jz 		.flag_true	

	cmp 	esi, -3
	jz 		.flag_true

	cmp 	esi, -6
	jz 		.flag_true

	cmp 	esi, -9
	jz 		.flag_true

	cmp 	esi, -12
	jz 		.flag_true	

	cmp 	esi, -15
	jz 		.flag_true		

	jmp 	.flag_false

.flag_true:
	mov 	eax, 1
	jmp 	.exit_func

.flag_false:
	mov 	eax, 0
	jmp 	.exit_func

.exit_func:
	pop  	esi	
	pop 	edx	
	pop 	ebx	

	mov 	esp, ebp
	pop 	ebp

	ret

%undef	value
%undef iterations_q

section .text
global main
main:
	GET_DEC 4, eax

	cmp 	eax, MAX_QUANTITY
	ja 		RangeExceptionCondition

	cmp 	eax, MIN_QUANTITY
	jb 		RangeExceptionCondition

	mov 	[n], eax

	push    ebp
    mov     ebp, esp

	push  	ebx		
	push 	edx		
	push 	esi	

	mov 	ecx, 0

	jmp 	cycle

cycle:	
	cmp 	ecx, [n]
	jae 	exit_cycle

    sub     esp, 12

	GET_UDEC 4, eax

	push 	eax
	call 	div3

	cmp 	eax, 1
	jz 		div3_true
	jnz 	div3_false

	div3_true:
		mov 	dword [verdicts + ecx * 4], YES
		jmp 	continue_cycle

	div3_false:
		mov 	dword [verdicts + ecx * 4], NO
		jmp 	continue_cycle

continue_cycle:
	inc 	ecx
	jmp 	cycle

exit_cycle:
	pop     ebx
    pop     edx
    pop     esi

    add     esp, 12

    mov     esp, ebp
    pop     ebp

	mov 	ecx, 0
	jmp 	output

output:
	cmp 	ecx, [n]
	jae 	exit_program

	PRINT_STRING 	dword [verdicts + ecx * 4]
	NEWLINE

	inc 	ecx
	jmp 	output

exit_program:
	xor 	eax, eax
	ret

RangeExceptionCondition:
	PRINT_STRING 	RangeExceptionMessage
	NEWLINE

	xor 	eax, eax
	int 	0x0A

section .bss
	n: 						resd 	1

section .data
	MAX_QUANTITY			equ		100000
	MIN_QUANTITY			equ		1

	verdicts				dd 		MAX_QUANTITY	

section .rodata
	RangeExceptionMessage	db 		`Input data is out of range`, 0

	YES						db		`YES`, 0
	NO						db		`NO`, 0
