.section .data
entrada:    .asciz "+99"

.section .text
.globl _start

_start:
    pushq %rbp
    movq %rsp, %rbp
   
    leaq entrada(%rip), %rdi

    # parâmetro %rdi: ponteiro da entrada
    call _string_to_int

    popq %rbp
    # resultado em %eax
    movl %eax, %edi
    movq $60, %rax
    syscall

_string_to_int:

    pushq %rbp
    movq %rsp, %rbp
    
    subq $4, %rsp  # resultado = -4(%rbp)
    subq $4, %rsp  # sinal = -8(%rbp)
    subq $4, %rsp  # digito = -12(%rbp)

    movl $0, -4(%rbp)
    movl $1, -8(%rbp)

    _if:
        movzbq (%rdi), %rax
        cmpb $'-', %al
        jne _else
        movl $-1, -8(%rbp)
        incq %rdi
        jmp _loop_func
    _else:
        cmpb $'+', %al
        jne _loop_func
        incq %rdi

    _loop_func:
        movzbq (%rdi), %rax
        cmpb $0, %al
        je _fim_func

        call _char_para_digito

        # se não for um dígito
        cmpl $-1, %eax
        je _fim_func

        # acumula valor do inteiro
        movl %eax, -12(%rbp)
        movl -4(%rbp), %eax
        imull $10, %eax, %eax
        addl -12(%rbp), %eax
        movl %eax, -4(%rbp)

        incq %rdi
        jmp _loop_func

    # aplica sinal
    _fim_func:
        movl -8(%rbp), %edx
        movl -4(%rbp), %eax
        imull %edx, %eax
        addq $12, %rsp
        popq %rbp
        ret

_char_para_digito:

    pushq %rbp
    movq %rsp, %rbp
    movzbq (%rdi), %rax

    _if_aux:
        cmpb $'0', %al
        jl _char_invalido
        cmpb $'9', %al
        jg _char_invalido

        subb $'0', %al
        movzbl %al, %eax
        jmp _fim_func_aux

    _char_invalido:
        movl $-1, %eax

    _fim_func_aux:
        popq %rbp
        ret
