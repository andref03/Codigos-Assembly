.section .data
entrada:    .asciz "761.0"
tipo:       .long 1           # 0 = float, 1 = double

.section .text
.globl _start

_start:

    pushq %rbp
    movq %rsp, %rbp
   
    leaq entrada(%rip), %rdi    # ponteiro da string vai para %rdi

    call _string_to_float   # resultado está em xmm0

    call _converte_padrao_ieee754

    popq %rbp
    movq $60, %rax
    syscall

_string_to_float:
    pushq %rbp
    movq %rsp, %rbp

    subq $8, %rsp   # parte_inteira = -8(%rbp)
    subq $4, %rsp   # sinal = -12(%rbp)

    call _string_to_int
    movl %eax, -8(%rbp)      # parte_inteira sempre positiva
    movl %edx, -12(%rbp)     # sinal

    # para calcular a parte fracionária
    movl $10, %eax
    movl $0, %ebx

    _is_float:
        cmpl $0, tipo(%rip)
        jne _is_double
        cvtsi2ss %eax, %xmm1     # xmm1 = 10.0
        cvtsi2ss %ebx, %xmm0     # xmm0 = 0.0
        jmp _if_ponto
    _is_double:
        cvtsi2sd %eax, %xmm1     # xmm1 = 10.0
        cvtsi2sd %ebx, %xmm0     # xmm0 = 0.0

    _if_ponto:
        cmpb $'.', (%rdi)
        jne _fim_loop_fracionario
        incq %rdi
    
    _loop_fracionario:
        movzbq (%rdi), %rax
        cmpb $0, %al
        je _fim_loop_fracionario
        call _char_para_digito
        cmpl $-1, %eax
        je _fim_loop_fracionario

        _if_float:
            cmpl $0, tipo(%rip)
            jne _if_double
            call _retorna_fracao_float
            jmp _fim_if_float_ou_double
        _if_double:
            call _retorna_fracao_double

        _fim_if_float_ou_double:
            incq %rdi
            jmp _loop_fracionario

    _fim_loop_fracionario:
    # xmm0 agora contém a parte fracionária (ex: 0.5)

    # pega a parte inteira positiva
    movl -8(%rbp), %eax

    # soma a parte fracionária e inteira
    _soma:
        cmpl $0, tipo(%rip)
        jne _soma_double
        # converte a parte inteira positiva para float
        cvtsi2ss %eax, %xmm2
        addss %xmm2, %xmm0
        jmp _fim_soma
    _soma_double:
        cvtsi2sd %eax, %xmm2
        addsd %xmm2, %xmm0

    _fim_soma:
    # xmm0 agora tem o valor absoluto do número

    _aplica_sinal:
        cmpl $-1, -12(%rbp)  # verifica sinal
        jne _fim_func_float

        # se tá aqui, então o sinal é negativo
        movl $-1, %edx
        cmpl $0, tipo(%rip) # float
        jne _aplica_sinal_double
        
        cvtsi2ss %edx, %xmm1
        mulss %xmm1, %xmm0
        jmp _fim_func_float

    _aplica_sinal_double:
        cvtsi2sd %edx, %xmm1
        mulsd %xmm1, %xmm0

    _fim_func_float:
    a:
        addq $12, %rsp
        popq %rbp
        ret

_string_to_int:
    pushq %rbp
    movq %rsp, %rbp
    
    subq $4, %rsp               # int resultado = -4(%rbp)
    subq $4, %rsp               # int sinal = -8(%rbp)
    subq $4, %rsp               # int digito = -12(%rbp)

    movl $0, -4(%rbp)           # resultado = 0
    movl $1, -8(%rbp)           # sinal = 1 (padrão)

    _if:
        movzbq (%rdi), %rax
        cmpb $'-', %al
        jne _else
        movl $-1, -8(%rbp)      # sinal = -1
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
        movl $0, %ecx
        call _char_para_digito
        cmpl $-1, %ecx          # se for ponto ".", para a leitura da parte inteira
        je _fim_func
        cmpl $-1, %eax
        je _fim_func
        movl %eax, -12(%rbp)
        movl -4(%rbp), %eax
        imull $10, %eax, %eax
        addl -12(%rbp), %eax
        movl %eax, -4(%rbp)
        incq %rdi
        jmp _loop_func

    _fim_func:
        movl -8(%rbp), %edx      # retorna sinal %edx
        movl -4(%rbp), %eax      # retorna o valor absoluto %eax

        addq $12, %rsp  # desaloca
        popq %rbp
    ret


_retorna_fracao_float:

    pushq %rbp
    movq %rsp, %rbp

    cvtsi2ss %eax, %xmm2
    divss %xmm1, %xmm2      # xmm2 = xmm2 / xmm1
    addss %xmm2, %xmm0      # xmm0 = xmm0 + xmm2 (acumulando)

    movl $10, %eax
    cvtsi2ss %eax, %xmm3     # xmm3 = 10.0
    mulss %xmm3, %xmm1       # xmm1 = xmm1 * 10.0

    popq %rbp
    ret

_retorna_fracao_double:

    pushq %rbp
    movq %rsp, %rbp

    cvtsi2sd %eax, %xmm2
    divsd %xmm1, %xmm2      # xmm2 = xmm2 / xmm1
    addsd %xmm2, %xmm0      # xmm0 = xmm0 + xmm2 (acumulando)

    movl $10, %eax
    cvtsi2sd %eax, %xmm3     # xmm3 = 10.0
    mulsd %xmm3, %xmm1       # xmm1 = xmm1 * 10.0

    popq %rbp
    ret
_char_para_digito:

    pushq %rbp
    movq %rsp, %rbp
    movzbq (%rdi), %rax         # %al = caractere atual

    _if_aux:
        cmpb $'.', %al
        je _ponto_encontrado
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
        jmp _fim_func_aux

    _ponto_encontrado:
        movl $-1, %ecx

    _fim_func_aux:
        popq %rbp
        ret

_converte_padrao_ieee754:

    pushq %rbp
    movq %rsp, %rbp

    subq $4, %rsp   # expoente = -4(%rbp)
    subq $16, %rsp   # mantissa = -20(%rbp)
    subq $16, %rsp   # expoente_bias = -36(%rbp)
    
    addq $36, %rsp
    popq %rbp
    ret
