.section .data
entrada:    .word 199
resultado:  .space 100
quebra_linha:  .asciz "\n"

.section .text
.global _start

_start:
    pushq %rbp
    movq %rsp, %rbp

    # parâmetros
    movswl entrada, %edi
    leaq resultado, %rsi

    call _short_to_string

    leaq resultado, %rdi
    call _calcula_tamanho_str_short
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

_short_to_string:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rcx
    pushq %rbx

    movw %di, %ax   # valor
    movq %rsi, %r8  # string
    movq $0, %rcx
    movw $10, %bx

    # número negativo
    cmpw $0, %ax
    jge _positivo_short_to_str
    movb $'-', (%r8)
    incq %r8
    negw %ax
    
    _positivo_short_to_str:
        # número zero
        cmpw $0, %ax
        jne _loop_short_to_str
        movb $'0', (%r8)
        incq %r8
        movb $0, (%r8)
        jmp _fim_short_to_str

    _loop_short_to_str:
        movw $0, %dx
        idivw %bx           # divide ax por 10, dx = resto
        addb $'0', %dl
        movb %dl, (%r8,%rcx,1)
        incq %rcx
        cmpw $0, %ax
        jne _loop_short_to_str

        # inverte string
        movq %rcx, %r9
        decq %r9
        movq $0, %rax

        _inverte_str_short:
            cmpq %rax, %r9
            jle _fim_str_short
            movb (%r8,%rax,1), %dl
            movb (%r8,%r9,1), %cl
            movb %cl, (%r8,%rax,1)
            movb %dl, (%r8,%r9,1)
            incq %rax
            decq %r9
            jmp _inverte_str_short

    _fim_str_short:
        movb $0, (%r8,%rcx,1)

    _fim_short_to_str:
        popq %rbx
        popq %rcx
        leave
        ret

# ---------------------------------------------------------------------

_calcula_tamanho_str_short:
    pushq %rbp
    movq %rsp, %rbp
    movq $0, %rax
    
    _loop_tam_str_short:
        movb (%rdi,%rax,1), %cl
        cmpb $0, %cl
        je _fim_loop_tam_short
        inc %rax
        jmp _loop_tam_str_short
    _fim_loop_tam_short:
        leave
        ret
