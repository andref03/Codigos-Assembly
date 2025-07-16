.section .data
.section .text
.globl _start

_start:

    pushq %rbp
    movq %rsp, %rbp

    # alocando variáveis locais
    subq $4, %rsp   # pares_main  = -4(%rbp)
    subq $4, %rsp   # tam = -8(%rbp)
    subq $40, %rsp  # vetor_main

    movl $-8, -48(%rbp)      # vetor[0] = -8
    movl $1, -40(%rbp)       # vetor[1] = 1
    movl $4, -36(%rbp)       # vetor[2] = 4
    movl $23, -32(%rbp)      # vetor[3] = 23
    movl $12, -28(%rbp)      # vetor[4] = 12
    movl $67, -24(%rbp)      # vetor[5] = 67
    movl $98, -20(%rbp)      # vetor[6] = 98
    movl $2, -16(%rbp)       # vetor[7] = 2
    movl $5, -12(%rbp)       # vetor[8] = 5
    movl $9, -8(%rbp)        # vetor[9] = 9

    movl $10, -8(%rbp)       # tam = 10
    movl -8(%rbp), %rdi      # vetor = -8(%rbp), pois rdi é o primeiro parâmetro

    call quantidade_pares

    
    mov %eax, %rdi
    addq $48, %rsp
    popq %rbp
    movq $60, %rax
    syscall

quantidade_pares:

    pushq %rbp
    movq %rsp, %rbp

    # alocando variáveis locais
    subq $4, %rsp   # i (contador) = -4(%rbp)
    subq $4, %rsp   # pares = -8(%rbp)

    movq $0, -4(%rbp)   # i = 0
    movq $0, -8(%rbp)   # pares = 0

    _loop:
        cmpl %rdi, -4(%rbp)
        jge _end_loop
        _if:

            cmpl

    popq %rbp
    ret
