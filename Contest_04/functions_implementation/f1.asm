bits 32
extern exp, log, sin, cos, tan, cot, sqrt, pow
%macro ALIGN_STACK 1.nolist
    sub     esp, %1
    and     esp, 0xfffffff0
    add     esp, %1
%endmacro
%macro UNALIGN_STACK 1.nolist
    add     esp, %1
%endmacro
%macro FUNCTION_PROLOGUE 1.nolist
    enter   %1, 0
    and     esp, 0xfffffff0
%endmacro
%macro FUNCTION_EPILOGUE 0.nolist
    leave
%endmacro
%define val             ebp + 8
%define tmp_ebx         ebp - 4
%define tmp_edi         ebp - 12
%define tmp_esi         ebp - 16
%define fpu_ctrl        ebp - 20
global f1
f1:
    FUNCTION_PROLOGUE 20
    mov     [tmp_ebx], ebx
    mov     [tmp_edi], edi
    mov     [tmp_esi], esi
    mov     ebx, fpus
    finit
    fstcw   word [fpu_ctrl]
    mov     edi, [ebx]
    fld     qword [edi]
    add     ebx, QWORD_SIZE
    fld1
    fcompp
    fstsw   ax
    sahf
    je      .operand_1
    jne      .val_1
    .operand_1:
        mov     edi, [ebx]
        fld     qword [edi]
        add     ebx, QWORD_SIZE
        jmp    .cont_1:
    .val_1:
        fld     qword [val]
        jmp    .cont_1:
.cont_1:
    mov     edi, [ebx]
    fld     qword [edi]
    add     ebx, QWORD_SIZE
    fld1
    fcompp
    fstsw   ax
    sahf
    je      .operand_2
    jne      .val_2
    .operand_2:
        mov     edi, [ebx]
        fld     qword [edi]
        add     ebx, QWORD_SIZE
        jmp    .cont_2:
    .val_2:
        fld     qword [val]
        jmp    .cont_2:
.cont_2:
    fdivrp
    sub     ebx, QWORD_SIZE
    fstp    qword [ebx]
    fldcw   word [fpu_ctrl]
    fstcw   word [fpu_ctrl]
    finit
    mov     edi, [ebx]
    fld     qword [edi]
    fldcw   word [fpu_ctrl]
    mov     ebx, [tmp_ebx]
    mov     edi, [tmp_edi]
    mov     esi, [tmp_esi]
    FUNCTION_EPILOGUE
    ret
section .data
    DWORD_SIZE      equ     4
    QWORD_SIZE      equ     8
section .data
    fpus       dq      1.000000, 2.000000, 1.000000, 3.000000
