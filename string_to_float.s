.section .data
entrada:    .asciz "+12.125"
tipo:       .long 0             # 0 = float, 1 = double

.section .text
.globl _start

_start:

    pushq %rbp
    movq %rsp, %rbp
   
    leaq entrada(%rip), %rdi    # ponteiro da string vai para %rdi

    call _string_to_float



    popq %rbp
    movl %eax, %edi
    movq $60, %rax
    syscall


_string_to_float:
    
    pushq %rbp
    movq %rsp, %rbp

    subq $8, %rsp   # parte_inteira = -8(%rbp)
    subq $8, %rsp   # parte_fracionaria = -16(%rbp)
    subq $4, %rsp   # resultado = -20(%rbp)
    subq $4, %rsp   # expoente = -24(%rbp)
    subq $4, %rsp   # mantissa = -28(%rbp)
    subq $4, %rsp   # expoente_bias = -32(%rbp)

    call _string_to_int     # retorna parte inteira em %eax
    movl %eax, -8(%rbp)

    movl $10, %eax
    cvtsi2sd %eax, %xmm1     # xmm1 = 10.0
    movl $0, %eax
    cvtsi2sd %eax, %xmm0     # xmm0 = 0.0

    _if_ponto:
        cmp $'.', (%rdi)
        jne _fim__func_float
        incq %rdi               # pula o ponto

    _loop_fracionario:
        movzbq (%rdi), %rax     # %al = caractere atual
        cmpb $0, %al            # compara caractere atual com 0 (semelhante a '\0')
        je _fim__loop_fracionario

        call _char_para_digito  # retorno tá no %eax
        
        cmpl $-1, %eax          # se não for um dígito
        je _fim__func_float

        cvtsi2sd %eax, %xmm2
        


    _fim__loop_fracionario:



    _fim__func_float:
        ret


_string_to_int:

    pushq %rbp
    movq %rsp, %rbp
    
    subq $4, %rsp               # int resultado = -4(%rbp)
    subq $4, %rsp               # int sinal = -8(%rbp)
    subq $4, %rsp               # int digito = -12(%rbp)

    movl $0, -4(%rbp)           # resultado = 0
    movl $1, -8(%rbp)           # sinal = 1

    _if:
        movzbq (%rdi), %rax     # %al = caractere atual
        cmpb $'-', %al          # compara caractere atual com '-'
        jne _else
        movl $-1, -8(%rbp)      # sinal = -1, pra multiplicar com resultado no final
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

        # se não for um dígito
        cmpl $-1, %eax
        je _fim_func

        movl %eax, -12(%rbp)     # dígito = %eax
        movl -4(%rbp), %eax      # %eax = resultado
        imull $10, %eax, %eax    # %eax = %eax * 10
        addl -12(%rbp), %eax     # %eax = %eax + dígito
        movl %eax, -4(%rbp)      # resultado = %eax

        incq %rdi
        jmp _loop_func

    _fim_func:
        movl -8(%rbp), %edx      # %edx = sinal
        movl -4(%rbp), %eax      # resultado
        imull %edx, %eax         # resultado = resultado * sinal
        addq $12, %rsp           # desaloca as 3 variáveis locais
        popq %rbp
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
