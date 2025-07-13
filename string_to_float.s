.section .data
entrada:    .asciz "-3.078"
tipo:       .long 0           # 0 = float, 1 = double

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
        cvtsi2ss %eax, %xmm1     # xmm1 = 10
        cvtsi2ss %ebx, %xmm0     # xmm0 = 0
        jmp _if_ponto
    _is_double:
        cvtsi2sd %eax, %xmm1     # xmm1 = 10
        cvtsi2sd %ebx, %xmm0     # xmm0 = 0

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
    # xmm0 agora ja contém a parte fracionária

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
    # finalmente finaliza o cálculo e desaloca
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

    divss %xmm1, %xmm2
    addss %xmm2, %xmm0      # acumula resultado em xmm0

    movl $10, %eax
    cvtsi2ss %eax, %xmm3     # xmm3 = 10
    mulss %xmm3, %xmm1       # xmm1 = xmm1 * 10

    popq %rbp
    ret

_retorna_fracao_double:
    pushq %rbp
    movq %rsp, %rbp

    cvtsi2sd %eax, %xmm2
    divsd %xmm1, %xmm2
    addsd %xmm2, %xmm0      # acumula resultado em xmm0
    movl $10, %eax
    cvtsi2sd %eax, %xmm3     # xmm3 = 10
    mulsd %xmm3, %xmm1       # xmm1 = xmm1 * 10

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
    
    # aqui, xmm0 contém o resultado já
    pushq %rbp
    movq %rsp, %rbp

    cmpl $0, tipo(%rip) # float
    jne _rotina_double

    _rotina_float:

        # extraindo o sinal
        pxor %xmm1, %xmm1             # sinal = 0 (positivo)
        ucomiss %xmm1, %xmm0          # compara resultado com 0
        jnb _float_positivo
        movq $1, %r8                  # sinal = 1 (negativo)

        _float_positivo:
            cmpq $0, %r8
            je _float_ja_positivo         # sinal == 0, já é positivo
            subss %xmm0, %xmm1
            movss %xmm1, %xmm0            # copia resultado absoluto para xmm0

        _float_ja_positivo:
            #  aqui vai calcularo expoente
            movq $0, %r9               # expoente = 0
            movl $2, %eax
            cvtsi2ss %eax, %xmm1

        _float_loop_maior_2:
            ucomiss %xmm1, %xmm0
            jb _float_fim_loop_maior_2
            divss %xmm1, %xmm0
            incq %r9
            jmp _float_loop_maior_2
        _float_fim_loop_maior_2:
            movl $1, %eax
            cvtsi2ss %eax, %xmm2        # xmm2 = 1
        _float_loop_menor_1:
            movl $0, %ebx
            cvtsi2ss %ebx, %xmm3
            ucomiss %xmm3, %xmm0
            jbe _float_fim_loop_menor_1
            ucomiss %xmm0, %xmm2
            jnb _float_fim_loop_menor_1
            mulss %xmm1, %xmm0
            decq %r9
            jmp _float_loop_menor_1
        _float_fim_loop_menor_1:
            subss %xmm2, %xmm0          # xmm0 = xmm0 - 1

        # lógica para calcular a mantissa
        movq $0, %r10               # mantissa = 0
        movq $0, %r11               # i = 0

        _float_loop_mantissa:
            cmpq $23, %r11              # float tem 23 bits na mantssa
            jae _float_fim_loop_mantissa
            mulss %xmm1, %xmm0          # xmm0 = xmm0 * 2
            ucomiss %xmm2, %xmm0
            jb _float_bit_mantissa_zero
            movq $22, %rcx      # rcx = 22
            subq %r11, %rcx     # 22 - i
            movq $1, %rax
            shlq %cl, %rax
            orq %rax, %r10
            subss %xmm2, %xmm0          # xmm0 = xmm0 - 1
        _float_bit_mantissa_zero:
            incq %r11
            jmp _float_loop_mantissa
        
        _float_fim_loop_mantissa:
        # montagem do resultado final sendo float
        addq $127, %r9              # bias de float
        movq %r8, %rax              # rax = sinal
        shlq $31, %rax              # sinal << 31
        movq %r9, %rcx              # rcx = expoente bias
        shlq $23, %rcx              # expoente bias << 23
        orq %rcx, %rax
        orq %r10, %rax
        jmp _fim_conversao

    # a partir daqui, a lógica é a mesma de float, mas "traduzi" ela para double
    # basicamente trocando ss para sd, e os valores de bias e bits da mantissa
        
    _rotina_double:
        
        # extraindo o sinal
        pxor %xmm1, %xmm1             # sinal = 0 (positivo)
        ucomisd %xmm1, %xmm0          # compara resultado com 0
        jnb _double_positivo
        movq $1, %r8                  # sinal = 1 (negativo)

        _double_positivo:
            cmpq $0, %r8
            je _double_ja_positivo         # sinal == 0, já é positivo
            subsd %xmm0, %xmm1
            movsd %xmm1, %xmm0            # copia resultado absoluto para xmm0
        
        _double_ja_positivo:
            # aqui vai calculanod expoente
            movq $0, %r9               # expoente = 0
            movl $2, %eax
            cvtsi2sd %eax, %xmm1
            
        _double_loop_maior_2:
            ucomisd %xmm1, %xmm0
            jb _double_fim_loop_maior_2
            divsd %xmm1, %xmm0
            incq %r9
            jmp _double_loop_maior_2
        _double_fim_loop_maior_2:
            movl $1, %eax
            cvtsi2sd %eax, %xmm2        # xmm2 = 1
        _double_loop_menor_1:
            movl $0, %ebx
            cvtsi2sd %ebx, %xmm3
            ucomisd %xmm3, %xmm0
            jbe _double_fim_loop_menor_1
            ucomisd %xmm0, %xmm2
            jnb _double_fim_loop_menor_1
            mulsd %xmm1, %xmm0
            decq %r9
            jmp _double_loop_menor_1
        _double_fim_loop_menor_1:
            subsd %xmm2, %xmm0          # xmm0 = xmm0 - 1

        _double_mantissa:
            movq $0, %r10               # mantissa = 0
            movq $0, %r11               # i = 0

            _double_loop_mantissa:
                cmpq $52, %r11              # compara i com 52 (bits da matissa de double)
                jae _double_fim_loop_mantissa
                mulsd %xmm1, %xmm0          # xmm0 = xmm0 * 2
                ucomisd %xmm2, %xmm0
                jb _double_bit_mantissa_zero
                movq $51, %rcx      # rcx = 51
                subq %r11, %rcx     # 51 - i
                movq $1, %rax
                shlq %cl, %rax
                orq %rax, %r10
                subsd %xmm2, %xmm0          # xmm0 = xmm0 - 1
            _double_bit_mantissa_zero:
                incq %r11
                jmp _double_loop_mantissa
        
        _double_fim_loop_mantissa:
            addq $1023, %r9         # bias de double

        _double_montagem:
            # montagem do resultado final sendo double
            movq %r8, %rax          # rax = sinal
            shlq $63, %rax          # sinal << 63
            movq %r9, %rcx          # rcx = expoente bias
            shlq $52, %rcx          # expoente bias << 52
            orq %rcx, %rax 
            orq %r10, %rax

    _fim_conversao:
    # nessa função de conversão, basicamente implementei para float, e depois só "traduzi" para double 
    # (mudando poucos detalhes); depende do tipo que escolhe no início (0 ou 1)
        leave
        ret
