.section .data
.section .text
.global _start

_start:

    pushq %rbp
    movq %rsp, %rbp     # atualiza o topo da pilha

    subq $8, %rbp       # cria uma variável local (pares) de tamanho 8 bytes
    
    # cria o vetor local de 10 posições
    subq $80, %rsp      # aloca espaço 10 posições
    movq $-8, -96(%rsp)
    movq $1, -88(%rsp)
    movq $4, -80(%rsp)
    movq $23, -72(%rsp)
    movq $12, -64(%rsp)
    movq $67, -56(%rsp)
    movq $98, -48(%rsp)
    movq $2, -40(%rsp)
    movq $5, -32(%rsp)
    movq $9, -24(%rsp)

    call quantidade_pares

    addq $80, %rsp      # exclui todo o vetor da pilha

    movq %r10, 8(%rsp) # pares = %r10

    movq %r10, %rdi     # para visualização
    addq $16, %rsp      # limpa a pilha
    movq $60, %rax
    syscall

quantidade_pares:

    pushq %rbp
    movq %rsp, %rbp         # atualiza o topo da pilha

    subq $16, %rbp          # aloca espaço para variáveis locais: i e pares
    movq $0, -8(%rbp)       # i = 0    
    movq $0, -16(%rbp)      # pares = 0

    movq -8(%rbp), %rdi     # %rdi = i

    movq 16(%rbp), %rbx    # primeira posição do vetor em %rbx
    movq $2, %r8            # denominador
    movq $0, %r9            # imediato 0 para comparação

    _loop:
        cmpq $10, %rdi      # compara 10 e i
        jge _end_loop
        
        movq (%rbx,%rdi,8), %rax    # itera cada posição do vetor

        idivq %r8          # %rax = %rax / 2, %rdx = %rax % 2

        cmpq %rdx, %r9
        jne _loop

        addq $1, 16(%rbp)   # pares++

    _end_loop:
        movq 16(%rbp), %r10 # valor que será retornado
        popq -16(%rbp)
        popq %rbp
        ret
