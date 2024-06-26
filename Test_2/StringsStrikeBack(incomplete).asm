bits 32

extern	calloc, free
extern	scanf, printf, strlen, strncmp

%macro ALIGN_STACK 1.nolist
    sub		esp, %1
    and		esp, 0xfffffff0
    add		esp, %1
%endmacro

%macro UNALIGN_STACK 1.nolist
    add esp, %1
%endmacro

%macro FUNCTION_PROLOGUE 1.nolist
    enter	%1, 0
    and 	esp, 0xfffffff0
%endmacro

%macro FUNCTION_EPILOGUE 0.nolist
    leave
%endmacro	

%define	tmp_ebx	    ebp - 4
%define	tmp_esi	    ebp - 8
%define	tmp_edi	    ebp - 12
%define	tmp_edx	    ebp - 16

section .text
global main
main:
    FUNCTION_PROLOGUE 0
    mov	[tmp_ebx], ebx
    mov	[tmp_esi], esi
    mov	[tmp_edi], edi

    mov	[tmp_edx], edx
    
    ALIGN_STACK 4
    push max_size
    call calloc
    UNALIGN_STACK 4  
    
    mov dword [line_ptr], eax
    
    ALIGN_STACK 8
    push dword [line_ptr]
    push i_format_str
    call scanf
    UNALIGN_STACK 8
    
    ALIGN_STACK 4
    push dword [line_ptr]
    call strlen
    UNALIGN_STACK 4 
   
    mov dword[len], eax
    
    mov ebx, dword [line_ptr]
    mov edi, 0
    mov esi, 0 ;X cntr
    
    .L:
        cmp edi, dword [len]
        jae .continue_func
        
        ALIGN_STACK 12
        push 1
        push char_X
        push ebx
        call strncmp
        UNALIGN_STACK 12
        
        test eax, eax
        jz .eq_X
        jmp .continue_L
        
        .eq_X:
            inc esi
            jmp .continue_L
            
    .continue_L:
        add ebx, 1            
        inc edi
        jmp .L    
    
.continue_func:
    bt esi, 0
    dec dword [len]
    jnc .straight
    jc .reversed
    
    .straight:
        mov ebx, dword [line_ptr]
        mov edi, 0
        .L_1:
            cmp edi, dword [len]
            jae .exit_func
            
            mov dl, byte [ebx]
            mov byte [out_char], dl
            
            ALIGN_STACK 4
            push out_char
            call printf
            UNALIGN_STACK 4
                
        .continue_L_1:
            inc ebx     
            inc edi
            jmp .L_1
        
     .reversed:
        mov ebx, dword [line_ptr]
        add ebx, dword [len]
        dec ebx
        mov edi, 0
        .L_2:
            cmp edi, dword [len]
            jae .exit_func
            
            mov dl, byte [ebx]
            mov byte [out_char], dl
            
            ALIGN_STACK 4
            push out_char
            call printf
            UNALIGN_STACK 4
                
        .continue_L_2:
            dec ebx      
            inc edi
            jmp .L_2  
    
.exit_func:
    ALIGN_STACK 4
    push dword [line_ptr]
    call free
    UNALIGN_STACK 4

    mov	edx, [tmp_edx]

    mov	edi, [tmp_edi]
    mov	esi, [tmp_esi]
    mov	ebx, [tmp_ebx]

    FUNCTION_EPILOGUE

    xor eax, eax
    ret

%undef	tmp_ebx
%undef	tmp_esi
%undef	tmp_edi
%undef	tmp_edx
    
section .bss
    line_ptr resd 1
    len  resd 1
    flag resd 1
    out_char resb 2
    
section .data
    o_format_char db `%c`, 0
    i_format_str db `%s.`,0
    o_format_str db `%s`,0
    max_size dd 2049
    char_X db `X`, 0