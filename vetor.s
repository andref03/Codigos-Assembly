.section .text
.globl _start

_quantidade_pares:
	pushq %rbp
	movq %rsp, %rbp
	# alocando a variavel i -4(%rbp)
	subq $4, %rsp
	# alocando a variavel pares -8(%rbp)
	subq $4, %rsp

	# salva o registrador %rbx
	pushq %rbx

	movl $0, -8(%rbp)   # pares
	movl $0, -4(%rbp)   # i
_for:
	movl -4(%rbp), %ebx
	cmpl %ebx, %esi  # i  %esi =  tam =  10
     jle _end_for
	# %rdi = &vetor[0]
	movl -4(%rbp), %edx
	movslq %edx, %rdx
	movl  (%rdi,%rdx,4), %eax
	movl $2, %ebx
	movl $0, %edx  # necessario para calcular o resto da divisao
	idivl %ebx
      cmpl $0, %edx
	jne _end_if
	incl -8(%rbp)	# pares++
     _end_if: 
	incl -4(%rbp)	# i++
	jmp _for

_end_for:
	# restaura o valor do registrador %rbx
	popq %rbx
	movl -8(%rbp), %eax
	# desalocando as variaveis i e pares
	addq $8, %rsp
	popq %rbp
	ret

_start:
	pushq %rbp
	movq %rsp, %rbp
	# int pares = -4(%rbp)
	subq $4, %rsp
	# int vetor [10] = -44(%rbp)
	subq $40, %rsp
	movq $2, -44(%rbp)
	movq $4, -40(%rbp)
	movq $7, -36(%rbp)
	movq $4, -32(%rbp)
	movq $9, -28(%rbp)
	movq $12, -24(%rbp)
	movq $32, -20(%rbp)
	movq $50, -16(%rbp)
	movq $90, -12(%rbp)
	movq $23, -8(%rbp)

	# passagem de parametros por registradores:
	#    %rdi, %rsi, %rdx, %rcx, %r8, %r9

	# protótipo da função: _quantidade_pares(int * vetor, int tam)
	# vamos fazer: _quantidade_pares(%rdi, %esi)

	movl $10, %esi   # 2° parametro tam        
	movq %rbp, %rax
	subq $44, %rax   # $vetor[0]
	movq %rax, %rdi  # 1° parametro &vetor[0]
	
	call _quantidade_pares
	
	movl %eax, -4(%rbp)
	movl -4(%rbp), %edi
	addq $44, %rsp
	popq %rbp
	movq $60, %rax
	syscall
