bits 32

extern malloc, realloc, free
extern scanf
extern log, pow, exp

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

%define M_PI	3.14159265358979323846
%define M_E		2.71828182845904523536

%define afunc 		ebp + 8
%define rpn			ebp - 4
%define	size		ebp - 8
%define variable	ebp - 12

global f_subs
f_subs:
	FUNCTION_PROLOGUE 12

	push	ebx
	push	edi
	push	esi

	mov		ebx, dword [afunc]
	mov		dword [rpn], ebx

	mov		ebx, dword [afunc + 4]
	mov		dword [size], ebx

	

	pop 	esi
	pop		edi
	pop		ebx

	FUNCTION_EPILOGUE 12

	ret