.section .data
entrada:    .quad  2872818712
resultado:  .space 100
quebra_linha:  .asciz "\n"

.section .text
.global _start

_start:
    pushq %rbp
    movq %rsp, %rbp

    # parâmetros
    movq entrada, %rdi
    leaq resultado, %rsi

    call _long_int_to_string

    leaq resultado, %rdi
    call _calcula_tamanho_str_long_int
    movq %rax, %rdx # tamanho da string
    movq $1, %rax  
    movq $1, %rdi  
    leaq resultado, %rsi
    syscall

    movq $1, %rax
    movq $1, %rdi
    leaq quebra_linha, %rsi
    movq $1, %rdx
    syscall

    popq %rbp
    movl $0, %edi
    movl $60, %eax
    syscall

# ---------------------------------------------------------------------

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

        _inverte_str_long_int:
            cmpq %rax, %r9
            jle _fim_str_long_int
            movb (%r8,%rax,1), %dl
            movb (%r8,%r9,1), %cl
            movb %cl, (%r8,%rax,1)
            movb %dl, (%r8,%r9,1)
            incq %rax
            decq %r9
            jmp _inverte_str_long_int

    _fim_str_long_int:
        movb $0, (%r8,%rcx,1)

    _fim_long_int_to_str:
        popq %rbx
        popq %rcx
        leave
        ret

# ---------------------------------------------------------------------

_calcula_tamanho_str_long_int:
    pushq %rbp
    movq %rsp, %rbp
    movq $0, %rax
    
    _loop_tam_str_long_int:
        movb (%rdi,%rax,1), %cl
        cmpb $0, %cl
        je _fim_loop_tam_long_int
        inc %rax
        jmp _loop_tam_str_long_int
    _fim_loop_tam_long_int:
        leave
        ret
