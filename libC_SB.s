.section .data
entrada_scanf:      .space 100
resultado_printf:   .space 100
quebra_linha:  .asciz "\n"

formato_int:      .asciz "%d"
formato_char:      .asciz "%c"
formato_float:      .asciz "%f"
formato_double:     .asciz "%lf"
formato_long_int:     .asciz "%ld"
formato_short_int:    .asciz "%hd"

prompt_escolha: .asciz "Escolha o tipo do formato \n(1: int) (2: char) (3: float) (4: double) (5: long int) (6: short int): "
prompt_entrada:  .asciz ">> Entrada: "

.section .text
.globl _start

_start:
    pushq %rbp
    movq %rsp, %rbp
    
    movq $1, %rax
    movq $1, %rdi
    leaq prompt_escolha, %rsi   # escolha
    movq $99, %rdx
    syscall

    # converte entrada pra inteiro
    movq $formato_int, %rdi
    leaq entrada_scanf, %rsi
    xor %rax, %rax
    call _scanf

    movl entrada_scanf, %eax
    cmpl $1, %eax
    je _int
    cmpl $2, %eax
    je _char
    cmpl $3, %eax
    je _float
    cmpl $4, %eax
    je _double
    jne _fim

    _int:
        movq $1, %rax
        movq $1, %rdi
        leaq prompt_entrada, %rsi
        movq $20, %rdx
        syscall

        leaq entrada_scanf, %rsi
        leaq formato_int, %rdi
        call _scanf

        leaq formato_int, %rdi
        movl entrada_scanf, %esi
        call _printf
        jmp _fim

    _char:
        movq $1, %rax
        movq $1, %rdi
        leaq prompt_entrada, %rsi
        movq $20, %rdx
        syscall

        leaq entrada_scanf, %rsi
        leaq formato_char, %rdi
        call _scanf

        leaq formato_char, %rdi
        movw entrada_scanf, %si
        call _printf
        jmp _fim

    _float:
        movq $1, %rax
        movq $1, %rdi
        leaq prompt_entrada, %rsi
        movq $20, %rdx
        syscall

        leaq entrada_scanf, %rsi
        leaq formato_float, %rdi
        call _scanf

        leaq formato_float, %rdi
        leaq entrada_scanf, %rsi
        call _printf
        jmp _fim

    _double:
        movq $1, %rax
        movq $1, %rdi
        leaq prompt_entrada, %rsi
        movq $20, %rdx
        syscall

        leaq entrada_scanf, %rsi
        leaq formato_double, %rdi
        call _scanf

        leaq formato_double, %rdi
        leaq entrada_scanf, %rsi
        call _printf
        jmp _fim

    _fim:
        # quebra de linha
        movq $1, %rax
        movq $1, %rdi
        leaq quebra_linha, %rsi
        movq $1, %rdx
        syscall

        movq $60, %rax
        movq $0, %rdi
        syscall

# ---------------------------------------------------------------------

_scanf:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rbx
    pushq %r12

    movq %rdi, %r12  # formato da string
    movq %rsi, %r13  # destino

    movq $0, %rax
    movq $0, %rdi
    leaq entrada_scanf, %rsi
    movq $120, %rdx
    syscall

    # identifica o formato
    movb (%r12), %al
    incq %r12
    cmpb $'%', %al
    jne _fim_scanf

    movb (%r12), %al
    incq %r12
    cmpb $'d', %al
    je _scanf_int
    cmpb $'c', %al
    je _scanf_char
    cmpb $'f', %al
    je _scanf_float
    cmpb $'l', %al
    jne _fim_scanf

    movb (%r12), %al
    incq %r12
    cmpb $'f', %al
    je _scanf_double

    _scanf_int:
        leaq entrada_scanf, %rdi
        call _string_to_int # resultado em eax        
        movl %eax, (%r13)
        jmp _fim_scanf

    _scanf_char:
        leaq entrada_scanf, %rdi
        call _string_to_char # resultado em ax
        movw %ax, (%r13)
        jmp _fim_scanf

    _scanf_float:
        leaq entrada_scanf, %rdi
        call _string_to_float # resultado em xmm0
        movss %xmm0, (%r13)
        jmp _fim_scanf

    _scanf_double:
        leaq entrada_scanf, %rdi
        call _string_to_double # resultado em xmm0
        movsd %xmm0, (%r13)
        jmp _fim_scanf

    _fim_scanf:
        popq %r12
        popq %rbx
        popq %rbp
        ret

# ---------------------------------------------------------------------

_printf:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rbx
    pushq %r12
    pushq %r13

    movq %rdi, %r12  # formato da string
    movq %rsi, %r13  # entrada

    movb (%r12), %al
    incq %r12
    cmpb $'%', %al
    jne _fim_printf

    movb (%r12), %al
    incq %r12
    cmpb $'d', %al
    je _printf_int
    cmpb $'c', %al
    je _printf_char
    cmpb $'f', %al
    je _printf_float
    cmpb $'l', %al
    jne _fim_printf

    movb (%r12), %al
    incq %r12
    cmpb $'f', %al
    je _printf_double

    _printf_int:
        movl %r13d, %edi    # inteiro de entrada
        leaq resultado_printf, %rsi
        call _int_to_string # retorna resultado_printf com a string com resposta
        jmp _fim_printf

    _printf_char:
        movw %r13w, %di # char de entrada
        leaq resultado_printf, %rsi
        call _char_to_string
        jmp _fim_printf

    _printf_float:
        movss (%r13), %xmm0 # float de entrada
        leaq resultado_printf, %rsi
        call _float_to_string
        jmp _fim_printf

    _printf_double:
        movsd (%r13), %xmm0 # double de entrada
        leaq resultado_printf, %rsi
        call _double_to_string
        jmp _fim_printf

    _escrever_resultado_printf:
        pushq %rbp
        movq %rsp, %rbp
        
        movq %rsi, %rdi # rdi: resultado_printf
        call _calcula_tamanho_str   # retorna tamanho em rax
        movq %rax, %rdx
        movq $1, %rax
        movq $1, %rdi
        syscall
        leave
        ret

    _fim_printf:
        leaq resultado_printf, %rsi
        movq $1, %rax
        movq $1, %rdi
        call _escrever_resultado_printf
        popq %r13
        popq %r12
        popq %rbx
        popq %rbp
        ret

# ---------------------------------------------------------------------

_string_to_short:
    pushq %rbp
    movq %rsp, %rbp
    
    subq $2, %rsp   # resultado = -2(%rbp)
    subq $2, %rsp   # sinal = -4(%rbp)
    subq $2, %rsp   # digito = -6(%rbp)

    movw $0, -2(%rbp)   # resultado = 0
    movw $1, -4(%rbp)   # sinal = 1

    movzbl (%rdi), %eax   # %al: caractere atual
    cmpb $'-', %al
    jne _else_str_to_short
    movw $-1, -4(%rbp)    # sinal = -1
    addq $1, %rdi
    jmp _loop_str_to_short

    _else_str_to_short:
        cmpb $'+', %al
        jne _loop_str_to_short
        addq $1, %rdi

    _loop_str_to_short:
        movzbl (%rdi), %eax
        cmpb $0, %al
        je _fim_str_to_short

        call _char_para_digito_short

        cmpw $-1, %ax
        je _fim_str_to_short

        movw %ax, -6(%rbp)    # digito
        movzwl -2(%rbp), %eax # resultado 
        imulw $10, %ax, %ax
        addw -6(%rbp), %ax
        movw %ax, -2(%rbp)

        addq $1, %rdi
        jmp _loop_str_to_short

    _fim_str_to_short:
        movw -4(%rbp), %dx
        movw -2(%rbp), %ax
        imulw %dx, %ax
        addq $6, %rsp
        popq %rbp
        ret

# ---------------------------------------------------------------------

_char_para_digito_short:
    pushq %rbp
    movq %rsp, %rbp
    movzbl (%rdi), %eax

    cmpb $'0', %al
    jl _char_invalido_short
    cmpb $'9', %al
    jg _char_invalido_short

    subb $'0', %al
    movzbl %al, %eax
    jmp _fim_char_para_digito_short

    _char_invalido_short:
        movw $-1, %ax

    _fim_char_para_digito_short:
        popq %rbp
        ret

# ---------------------------------------------------------------------

_string_to_long_int:
    pushq %rbp
    movq %rsp, %rbp
    
    subq $8, %rsp   # resultado = -8(%rbp)
    subq $8, %rsp   # sinal = -16(%rbp)
    subq $8, %rsp   # digito = -24(%rbp)

    movq $0, -8(%rbp)   # resultado = 0
    movq $1, -16(%rbp)  # sinal = 1

    movzbl (%rdi), %eax   # %al: caractere atual
    cmpb $'-', %al
    jne _else_str_to_long_int
    movq $-1, -16(%rbp)   # sinal = -1
    addq $1, %rdi
    jmp _loop_str_to_long_int

    _else_str_to_long_int:
        cmpb $'+', %al
        jne _loop_str_to_long_int
        addq $1, %rdi

    _loop_str_to_long_int:
        movzbl (%rdi), %eax
        cmpb $0, %al
        je _fim_str_to_long_int

        call _char_para_digito_long

        cmpq $-1, %rax
        je _fim_str_to_long_int

        movq %rax, -24(%rbp)  # digito
        movq -8(%rbp), %rax   # resultado
        imulq $10, %rax, %rax
        addq -24(%rbp), %rax
        movq %rax, -8(%rbp)

        addq $1, %rdi
        jmp _loop_str_to_long_int

    _fim_str_to_long_int:
        movq -16(%rbp), %rdx
        movq -8(%rbp), %rax
        imulq %rdx, %rax
        addq $24, %rsp
        popq %rbp
        ret

# ---------------------------------------------------------------------

_char_para_digito_long:
    pushq %rbp
    movq %rsp, %rbp
    movzbl (%rdi), %eax

    cmpb $'0', %al
    jl _char_invalido_long
    cmpb $'9', %al
    jg _char_invalido_long

    subb $'0', %al
    movzbl %al, %eax
    jmp _fim_char_para_digito_long

    _char_invalido_long:
        movq $-1, %rax

    _fim_char_para_digito_long:
        popq %rbp
        ret


# ---------------------------------------------------------------------

_string_to_int:
    pushq %rbp
    movq %rsp, %rbp
    
    subq $4, %rsp   # resultado = -4(%rbp)
    subq $4, %rsp   # sinal = -8(%rbp)
    subq $4, %rsp   # digito = -12(%rbp)

    movl $0, -4(%rbp)   # resultado = 0
    movl $1, -8(%rbp)   # sinal = 1

    movzbl (%rdi), %eax   # %al: caractere atual
    cmpb $'-', %al
    jne _else_str_to_int
    movl $-1, -8(%rbp)    # sinal = -1
    addq $1, %rdi
    jmp _loop_str_to_int

    _else_str_to_int:
        cmpb $'+', %al
        jne _loop_str_to_int
        addq $1, %rdi

    _loop_str_to_int:
        movzbl (%rdi), %eax
        cmpb $0, %al
        je _fim_str_to_int

        call _char_para_digito

        cmpl $-1, %eax
        je _fim_str_to_int

        movl %eax, -12(%rbp)  # digito
        movl -4(%rbp), %eax   # resultado
        imull $10, %eax, %eax
        addl -12(%rbp), %eax
        movl %eax, -4(%rbp)

        addq $1, %rdi
        jmp _loop_str_to_int

    _fim_str_to_int:
        movl -8(%rbp), %edx
        movl -4(%rbp), %eax
        imull %edx, %eax
        addq $12, %rsp
        popq %rbp
        ret

# ---------------------------------------------------------------------

_char_para_digito:
    pushq %rbp
    movq %rsp, %rbp
    movzbl (%rdi), %eax

    cmpb $'0', %al
    jl _char_invalido
    cmpb $'9', %al
    jg _char_invalido

    subb $'0', %al
    movzbl %al, %eax
    jmp _fim_char_para_digito

    _char_invalido:
        movl $-1, %eax

    _fim_char_para_digito:
        popq %rbp
        ret


# ---------------------------------------------------------------------

_string_to_float:
    pushq %rbp
    movq %rsp, %rbp

    subq $8, %rsp   # parte_inteira = -8(%rbp)
    subq $4, %rsp   # sinal = -12(%rbp)

    call _string_to_int

    movl %eax, -8(%rbp)
    movl %edx, -12(%rbp)

    movl $10, %eax
    movl $0, %ebx

    cvtsi2ss %eax, %xmm1     # xmm1 = 10
    cvtsi2ss %ebx, %xmm0     # xmm0 = 0
    
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

        call _retorna_fracao_float
    
        incq %rdi
        jmp _loop_fracionario

    _fim_loop_fracionario:

    movl -8(%rbp), %eax    
    cvtsi2ss %eax, %xmm2    # soma a parte fracionária e inteira
    addss %xmm2, %xmm0

    cmpl $-1, -12(%rbp)  # verifica sinal
    jne _fim_str_to_float
    movl $-1, %edx
    cvtsi2ss %edx, %xmm1
    mulss %xmm1, %xmm0

    _fim_str_to_float:
        addq $12, %rsp
        popq %rbp
        ret

# ---------------------------------------------------------------------

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


# ---------------------------------------------------------------------

_string_to_double:
    pushq %rbp
    movq %rsp, %rbp

    subq $8, %rsp   # parte_inteira = -8(%rbp)
    subq $4, %rsp   # sinal = -12(%rbp)

    call _string_to_int

    movl %eax, -8(%rbp)
    movl %edx, -12(%rbp)

    movl $10, %eax
    movl $0, %ebx

    cvtsi2sd %eax, %xmm1     # xmm1 = 10
    cvtsi2sd %ebx, %xmm0     # xmm0 = 0
    
    cmpb $'.', (%rdi)
    jne _fim_loop_fracionario_double
    incq %rdi
    
    _loop_fracionario_double:
        movzbq (%rdi), %rax
        cmpb $0, %al
        je _fim_loop_fracionario_double
        call _char_para_digito_long
        cmpl $-1, %eax
        je _fim_loop_fracionario_double

        call _retorna_fracao_double
    
        incq %rdi
        jmp _loop_fracionario_double

    _fim_loop_fracionario_double:

    movl -8(%rbp), %eax    
    cvtsi2sd %eax, %xmm2    # soma a parte fracionária e inteira
    addsd %xmm2, %xmm0

    cmpl $-1, -12(%rbp)  # verifica sinal
    jne _fim_str_to_double
    movl $-1, %edx
    cvtsi2sd %edx, %xmm1
    mulsd %xmm1, %xmm0

    _fim_str_to_double:
        addq $12, %rsp
        popq %rbp
        ret

# ---------------------------------------------------------------------

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


# ---------------------------------------------------------------------

_string_to_char:
    pushq %rbp
    movq %rsp, %rbp
    
    subq $2, %rsp   # resultado = -2(%rbp)

    movw $0, -2(%rbp)   # resultado = 0

    movzbl (%rdi), %eax   # %al: primeiro caractere
    cmpb $0, %al
    je _string_vazia      # string vazia
    
    movzbl %al, %eax
    movw %ax, -2(%rbp)
    jmp _fim_str_to_char

    _string_vazia:
        movw $0, -2(%rbp)
        jmp _fim_str_to_char

    _fim_str_to_char:
        movw -2(%rbp), %ax
        addq $2, %rsp
        popq %rbp
        ret


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
        idivw %bx   # divide ax por 10, dx = resto
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
        idivq %rbx # resto em rdx
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


# ---------------------------------------------------------------------

_int_to_string:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rcx
    pushq %rbx

    movl %edi, %eax # valor
    movq %rsi, %r8  # string
    movq $0, %rcx
    movl $10, %ebx

    # número negativo
    cmpl $0, %eax
    jge _positivo_int_to_str
    movb $'-', (%r8)
    incq %r8
    neg %eax
    
    _positivo_int_to_str:
        # número zero
        cmpl $0, %eax
        jne _loop_int_to_str
        movb $'0', (%r8)
        incq %r8
        movb $0, (%r8)
        jmp _fim_int_to_str

    _loop_int_to_str:
        movl $0, %edx
        idivl %ebx  # edx = resto
        addb $'0', %dl
        movb %dl, (%r8,%rcx,1)
        incq %rcx
        cmpl $0, %eax
        jne _loop_int_to_str

        # inverte string
        movq %rcx, %r9
        decq %r9
        movq $0, %rax

        _inverte_str:
            cmpq %rax, %r9
            jle _fim_str
            movb (%r8,%rax,1), %dl  # 1 byte
            movb (%r8,%r9,1), %cl
            movb %cl, (%r8,%rax,1)
            movb %dl, (%r8,%r9,1)
            incq %rax
            decq %r9
            jmp _inverte_str

    _fim_str:
        movb $0, (%r8,%rcx,1)

    _fim_int_to_str:
        popq %rbx
        popq %rcx
        leave
        ret

# ---------------------------------------------------------------------

_calcula_tamanho_str:
    pushq %rbp
    movq %rsp, %rbp
    movq $0, %rax
    
    _loop_tam_str:
        movb (%rdi,%rax,1), %cl
        cmpb $0, %cl
        je _fim_loop_tam
        inc %rax
        jmp _loop_tam_str
    _fim_loop_tam:
        leave
        ret


# -------------------------------------------------------------------

_float_to_string:
    pushq %rbp
    movq %rsp, %rbp
    movq %rsi, %r8 # string

    movl $0, %eax
    cvtsi2ss %eax, %xmm1

    # sinal
    ucomiss %xmm1, %xmm0
    jae _sinal_tratado_float_to_str

    movb $'-', (%r8)
    incq %r8
    movl $-1, %eax
    cvtsi2ss %eax, %xmm1
    mulss %xmm1, %xmm0  # xmm0 agr tem valor absoluto

    _sinal_tratado_float_to_str:

        cvttss2si %xmm0, %eax   # xmm0 arredondo para inteiro
        movl %eax, %r10d
        movl %eax, %edi
        movq %r8, %rsi

        call _int_to_string

        movq %rsi, %r9
        movq %rsi, %rdi

        call _calcula_tamanho_str

        addq %rax, %r9  # r9: fim da parte inteira
        movb $'.', (%r9)
        incq %r9

        # parte_fracionaria
        cvtsi2ss %r10d, %xmm1
        subss %xmm1, %xmm0
        movl $0, %eax
        cvtsi2ss %eax, %xmm2
        ucomiss %xmm2, %xmm0
        jne _nao_nulo_float_to_str
        movb $'0', (%r9)  # parte fracionária é zero
        incq %r9
        jmp _fim_float_to_str

    _nao_nulo_float_to_str:
        movl $10, %ebx
        movl $20, %ecx  # qtdd de casas decimais

    _loop_float_to_str:
        cmpl $0, %ecx
        je _fim_float_to_str

        cvtsi2ss %ebx, %xmm2
        mulss %xmm2, %xmm0

        cvttss2si %xmm0, %eax
        movl %eax, %r11d
        
        addb $'0', %al
        movb %al, (%r9)
        incq %r9

        cvtsi2ss %r11d, %xmm2
        subss %xmm2, %xmm0

        decl %ecx
        jmp _loop_float_to_str

    _fim_float_to_str:
        movb $0, (%r9)
        popq %rbp
        ret


_double_to_string:
    pushq %rbp
    movq %rsp, %rbp
    movq %rsi, %r8 # string

    movq $0, %rax
    cvtsi2sd %rax, %xmm1

    # sinal
    ucomisd %xmm1, %xmm0
    jae _sinal_tratado_double_to_str

    movb $'-', (%r8)
    incq %r8
    movq $-1, %rax
    cvtsi2sd %rax, %xmm1
    mulsd %xmm1, %xmm0  # xmm0 agr tem valor absoluto

    _sinal_tratado_double_to_str:

        cvttsd2si %xmm0, %rax   # xmm0 arredondo para inteiro
        movq %rax, %r10
        movq %rax, %rdi
        movq %r8, %rsi

        call _long_int_to_string

        movq %rsi, %r9
        movq %rsi, %rdi

        call _calcula_tamanho_str

        addq %rax, %r9  # r9: fim da parte inteira
        movb $'.', (%r9)
        incq %r9

        # parte_fracionaria
        cvtsi2sd %r10, %xmm1
        subsd %xmm1, %xmm0
        movq $0, %rax
        cvtsi2sd %rax, %xmm2
        ucomisd %xmm2, %xmm0
        jne _nao_nulo_double_to_str
        movb $'0', (%r9)  # parte fracionária é zero
        incq %r9
        jmp _fim_double_to_str

    _nao_nulo_double_to_str:
        movq $10, %rbx
        movq $20, %rcx

    _loop_double_to_str:
        cmpq $0, %rcx
        je _fim_double_to_str

        cvtsi2sd %rbx, %xmm2
        mulsd %xmm2, %xmm0

        cvttsd2si %xmm0, %rax
        movq %rax, %r11
        
        addb $'0', %al
        movb %al, (%r9)
        incq %r9

        cvtsi2sd %r11, %xmm2
        subsd %xmm2, %xmm0

        decq %rcx
        jmp _loop_double_to_str

    _fim_double_to_str:
        movb $0, (%r9)
        popq %rbp
        ret


# ---------------------------------------------------------------------

_char_to_string:
    pushq %rbp
    movq %rsp, %rbp

    movb %dil, %al  # caractere
    movq %rsi, %r8  # string

    movb %al, (%r8)
    incq %r8
    movb $0, (%r8)

    _fim_char_to_str:
        popq %rbp
        ret
