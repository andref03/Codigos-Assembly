.section .data
float_val: .float -21.174
resultado: .space 100
quebra_linha: .asciz "\n"

.section .text
.global _start

_start:
    pushq %rbp
    movq %rsp, %rbp

    movss float_val, %xmm0
    leaq resultado, %rsi

    call _float_to_string

    # imprime resultado
    leaq resultado, %rdi
    call _calcula_tamanho_str
    movq %rax, %rdx
    movq $1, %rax
    movq $1, %rdi
    leaq resultado, %rsi
    syscall

    # imprime quebra de linha
    movq $1, %rax
    movq $1, %rdi
    leaq quebra_linha, %rsi
    movq $1, %rdx
    syscall

    popq %rbp
    movl $0, %edi
    movl $60, %eax
    syscall


# -------------------------------------------------------------------

_float_to_string:
    pushq %rbp
    movq %rsp, %rbp
    movq %rsi, %r8 # string

    movl $0, %eax
    cvtsi2ss %eax, %xmm1

    # sinal
    ucomiss %xmm1, %xmm0
    jae _sinal_tratado_float_to_str

    movb $'-', (%r8)
    incq %r8
    movl $-1, %eax
    cvtsi2ss %eax, %xmm1
    mulss %xmm1, %xmm0  # xmm0 agr tem valor absoluto

    _sinal_tratado_float_to_str:

        cvttss2si %xmm0, %eax   # xmm0 arredondo para inteiro
        movl %eax, %r10d
        movl %eax, %edi
        movq %r8, %rsi

        call _int_to_string

        movq %rsi, %r9
        movq %rsi, %rdi

        call _calcula_tamanho_str

        addq %rax, %r9  # r9: fim da parte inteira
        movb $'.', (%r9)
        incq %r9

        # parte_fracionaria
        cvtsi2ss %r10d, %xmm1
        subss %xmm1, %xmm0
        movl $0, %eax
        cvtsi2ss %eax, %xmm2
        ucomiss %xmm2, %xmm0
        jne _nao_nulo_float_to_str
        movb $'0', (%r9)  # parte fracionária é zero
        incq %r9
        jmp _fim_float_to_str

    _nao_nulo_float_to_str:
        movl $10, %ebx
        movl $20, %ecx  # qtdd de casas decimais

    _loop_float_to_str:
        cmpl $0, %ecx
        je _fim_float_to_str

        cvtsi2ss %ebx, %xmm2
        mulss %xmm2, %xmm0

        cvttss2si %xmm0, %eax
        movl %eax, %r11d
        
        addb $'0', %al
        movb %al, (%r9)
        incq %r9

        cvtsi2ss %r11d, %xmm2
        subss %xmm2, %xmm0

        decl %ecx
        jmp _loop_float_to_str

    _fim_float_to_str:
        movb $0, (%r9)
        popq %rbp
        ret

# -------------------------------------------------------------------

_int_to_string:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rcx
    pushq %rbx

    movl %edi, %eax # valor
    movq %rsi, %r8  # string
    movq $0, %rcx
    movl $10, %ebx

    # número negativo
    cmpl $0, %eax
    jge _positivo_int_to_str
    movb $'-', (%r8)
    incq %r8
    neg %eax
    
    _positivo_int_to_str:
        # número zero
        cmp $0, %eax
        jne _loop_int_to_str
        movb $'0', (%r8)
        incq %r8
        movb $0, (%r8)
        jmp _fim_int_to_str

    _loop_int_to_str:
        movl $0, %edx
        idivl %ebx          # divide eax por 10, edx = resto
        addb $'0', %dl
        movb %dl, (%r8,%rcx,1)
        incq %rcx
        cmp $0, %eax
        jne _loop_int_to_str

        # inverte string
        movq %rcx, %r9
        decq %r9
        movq $0, %rax

    _inverte_str:
        cmpq %rax, %r9
        jle _fim_str
        movb (%r8,%rax,1), %dl
        movb (%r8,%r9,1), %cl
        movb %cl, (%r8,%rax,1)
        movb %dl, (%r8,%r9,1)
        incq %rax
        decq %r9
        jmp _inverte_str

    _fim_str:
        movb $0, (%r8,%rcx,1)

    _fim_int_to_str:
        popq %rbx
        popq %rcx
        leave
        ret

# -------------------------------------------------------------------

_calcula_tamanho_str:
    pushq %rbp
    movq %rsp, %rbp
    movq $0, %rax
    
    _loop_tam_str:
        movb (%rdi,%rax,1), %cl
        cmpb $0, %cl
        je _fim_loop_tam
        inc %rax
        jmp _loop_tam_str
    _fim_loop_tam:
        leave
        ret
