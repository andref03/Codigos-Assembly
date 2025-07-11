.section .data
entrada:    .asciz "+12.125"

.section .text
.globl _start

_start:

    pushq %rbp
    movq %rsp, %rbp
   
    leaq entrada(%rip), %rdi    # ponteiro da string vai para %rdi

    

    popq %rbp
    movl %eax, %edi
    movq $60, %rax
    syscall


_string_to_float:
    
    pushq %rbp
    movq %rsp, %rbp




    
    subq $4, %rsp               # int sinal = -4(%rbp)
    movl $0, -4(%rbp)           # sinal = 0

    _if:
        movzbq (%rdi), %rax     # %al = caractere atual
        cmpb $'-', %al          # compara caractere atual com '-'
        jne _else
        movl $1, -8(%rbp)      # sinal = 1
        incq %rdi
        jmp _loop_func
    _else:
        cmpb $'+', %al
        jne _loop_func
        incq %rdi

    _loop_func:
        movzbq (%rdi), %rax     # %al = caractere atual
        cmpb $0, %al            # compara caractere atual com 0 (semelhatne a '\0')
        je _fim_func

        call _char_para_digito

        # se não for um dígito # precisa quebrar a execução do programa inteiro
        cmpl $-1, %eax
        je _fim_func

        movl %eax, -12(%rbp)     # dígito = %eax
        movl -4(%rbp), %eax      # %eax = resultado
        imull $10, %eax, %eax    # %eax = %eax * 10
        addl -12(%rbp), %eax     # %eax = %eax + dígito
        movl %eax, -4(%rbp)      # resultado = %eax

        incq %rdi
        jmp _loop_func

ret

_char_para_digito:

    pushq %rbp
    movq %rsp, %rbp
    movzbq (%rdi), %rax         # %al = caractere atual

    _if_aux:
        cmpb $'0', %al          # compara caractere atual com char '0'
        jl _char_invalido
        cmpb $'9', %al          # compara caractere atual com char '9'
        jg _char_invalido

        subb $'0', %al          # converte caractere para dígito inteiro de verdade
        movzbl %al, %eax
        jmp _fim_func_aux

    # se (%al < '0') ou (%al > '9'), não se trata de dígito
    _char_invalido:
        movl $-1, %eax

    _fim_func_aux:
        popq %rbp
        ret
