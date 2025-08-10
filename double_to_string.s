.section .data
double_val: .double -21.174
resultado: .space 100
quebra_linha: .asciz "\n"

.section .text
.global _start

_start:
    pushq %rbp
    movq %rsp, %rbp

    movsd double_val, %xmm0
    leaq resultado, %rsi

    call _double_to_string

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

_double_to_string:
    pushq %rbp
    movq %rsp, %rbp
    movq %rsi, %r8 # string

    movq $0, %rax
    cvtsi2sd %rax, %xmm1

    # sinal
    ucomisd %xmm1, %xmm0
    jae _sinal_tratado_double_to_str

    movb $'-', (%r8)
    incq %r8
    movq $-1, %rax
    cvtsi2sd %rax, %xmm1
    mulsd %xmm1, %xmm0  # xmm0 agr tem valor absoluto

    _sinal_tratado_double_to_str:

        cvttsd2si %xmm0, %rax   # xmm0 arredondo para inteiro (64 bits)
        movq %rax, %r10
        movq %rax, %rdi
        movq %r8, %rsi

        call _long_int_to_string

        movq %rsi, %r9
        movq %rsi, %rdi

        call _calcula_tamanho_str

        addq %rax, %r9  # r9: fim da parte inteira
        movb $'.', (%r9)
        incq %r9

        # parte_fracionaria
        cvtsi2sd %r10, %xmm1
        subsd %xmm1, %xmm0
        movq $0, %rax
        cvtsi2sd %rax, %xmm2
        ucomisd %xmm2, %xmm0
        jne _nao_nulo_double_to_str
        movb $'0', (%r9)  # parte fracionária é zero
        incq %r9
        jmp _fim_double_to_str

    _nao_nulo_double_to_str:
        movq $10, %rbx
        movq $20, %rcx

    _loop_double_to_str:
        cmpq $0, %rcx
        je _fim_double_to_str

        cvtsi2sd %rbx, %xmm2
        mulsd %xmm2, %xmm0

        cvttsd2si %xmm0, %rax
        movq %rax, %r11
        
        addb $'0', %al
        movb %al, (%r9)
        incq %r9

        cvtsi2sd %r11, %xmm2
        subsd %xmm2, %xmm0

        decq %rcx
        jmp _loop_double_to_str

    _fim_double_to_str:
        movb $0, (%r9)
        popq %rbp
        ret

# -------------------------------------------------------------------

_long_int_to_string:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rcx
    pushq %rbx

    movq %rdi, %rax # valor
    movq %rsi, %r8  # string
    movq $0, %rcx
    movq $10, %rbx

    # número negativo
    cmp $0, %rax
    jge _positivo_long_int_to_str
    movb $'-', (%r8)
    incq %r8
    neg %rax
    
    _positivo_long_int_to_str:
        # número zero
        cmp $0, %rax
        jne _loop_long_int_to_str
        movb $'0', (%r8)
        incq %r8
        movb $0, (%r8)
        jmp _fim_long_int_to_str

    _loop_long_int_to_str:
        movq $0, %rdx
        idivq %rbx          # divide rax por 10, rdx = resto
        addb $'0', %dl
        movb %dl, (%r8,%rcx,1)
        incq %rcx
        cmp $0, %rax
        jne _loop_long_int_to_str

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

    _fim_long_int_to_str:
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
