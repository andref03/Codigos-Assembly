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

prompt_escolha: .asciz "Escolha o tipo do formato \n(1: int) (2: char) (3: float) (4: double) (5: long int) (6: short int) (7: arquivos): "
prompt_entrada:  .asciz ">> Entrada: "

qtdd_arquivos:         .quad 0
qtdd_limite_arquivos:  .quad 128
tabela_arquivos:       .space 400
arquivo1:   .asciz "a_teste.txt"
arquivo2:   .asciz "b_teste.txt"

tipo_r:             .asciz "r"
tipo_w:             .asciz "w"
tipo_a:             .asciz "a"
tipo_r_mais:         .asciz "r+"
tipo_w_mais:         .asciz "w+"
tipo_a_mais:         .asciz "a+"

.section .text
.globl _start

_start:
    pushq %rbp
    movq %rsp, %rbp
    
    movq $1, %rax
    movq $1, %rdi
    leaq prompt_escolha, %rsi   # escolha
    movq $113, %rdx
    syscall

    # converte entrada pra inteiro
    movq $formato_int, %rdi
    leaq entrada_scanf, %rsi
    movq $0, %rax
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
    cmpl $5, %eax
    je _long_int
    cmpl $6, %eax
    je _short_int
    cmpl $7, %eax
    je _arquivos
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

    _long_int:
        movq $1, %rax
        movq $1, %rdi
        leaq prompt_entrada, %rsi
        movq $20, %rdx
        syscall

        leaq entrada_scanf, %rsi
        leaq formato_long_int, %rdi
        call _scanf

        leaq formato_long_int, %rdi
        leaq entrada_scanf, %rsi
        call _printf
        jmp _fim

    _short_int:
        movq $1, %rax
        movq $1, %rdi
        leaq prompt_entrada, %rsi
        movq $20, %rdx
        syscall

        leaq entrada_scanf, %rsi
        leaq formato_short_int, %rdi
        call _scanf

        leaq formato_short_int, %rdi
        leaq entrada_scanf, %rsi
        call _printf
        jmp _fim

    _arquivos:
        
        leaq arquivo1, %rdi
        leaq tipo_w, %rsi  # abre pra escrita
        call _fopen
        movq %rax, %r10     # salva descritor de arquivo

        # testei somente com int mesmo
        movq %r10, %rdi
        leaq formato_int, %rsi
        movq $194783, %rdx  # valor pra escrever
        call _fprintf

        movq %r10, %rdi
        call _fclose

        leaq arquivo1, %rdi
        leaq tipo_r, %rsi   # abre pra leitura
        call _fopen
        movq %rax, %r11

        leaq entrada_scanf, %rdx

        movq %r11, %rdi
        leaq formato_int, %rsi
        call _fscanf

        movq %r11, %rdi
        call _fclose

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
    je _formato_long_scanf
    cmpb $'h', %al
    jne _fim_scanf

    movb (%r12), %al
    incq %r12
    cmpb $'d', %al
    je _scanf_short_int
    jne _fim_scanf

    _formato_long_scanf:
        movb (%r12), %al
        incq %r12
        cmpb $'f', %al
        je _scanf_double
        cmpb $'d', %al
        je _scanf_long_int
        jne _fim_scanf

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

    _scanf_long_int:
        leaq entrada_scanf, %rdi
        call _string_to_long_int # resultado em rax
        movq %rax, (%r13)
        jmp _fim_scanf

    _scanf_short_int:
        leaq entrada_scanf, %rdi
        call _string_to_short # resultado em ax
        movw %ax, (%r13)
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
    je _formato_long_printf
    cmpb $'h', %al
    jne _fim_printf

    movb (%r12), %al
    incq %r12
    cmpb $'d', %al
    je _printf_short_int
    jne _fim_printf

    _formato_long_printf:
        movb (%r12), %al
        incq %r12
        cmpb $'f', %al
        je _printf_double
        cmpb $'d', %al
        je _printf_long_int

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
    
    _printf_long_int:
        movq (%r13), %rdi # long int de entrada
        leaq resultado_printf, %rsi
        call _long_int_to_string
        jmp _fim_printf

    _printf_short_int:
        movw (%r13), %di # short int de entrada
        leaq resultado_printf, %rsi
        call _short_to_string
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


_fopen:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rbx
    pushq %r12
    pushq %r13

    movq %rdi, %r12  # arquivo
    movq %rsi, %r13  # tipo

    movq qtdd_arquivos, %rax
    cmpq qtdd_limite_arquivos, %rax
    jge _erro_abertura

    movq %r13, %rdi
    call _descobre_flags   # converte tipo para as flags corretas
    movq %rax, %rbx  # rbx: flags

    movq $2, %rax
    movq %r12, %rdi
    movq %rbx, %rsi
    movq $256, %rdx # leitura só do proprietário S_IRUSR
    orq  $128, %rdx # escrita só do proprietário S_IWUSR
    syscall

    # erro se rax menor que zero
    cmpq $0, %rax
    jl _erro_abertura

    movq qtdd_arquivos, %rbx
    movq %rax, tabela_arquivos(,%rbx,8)  # descritor de arquivo
    incq qtdd_arquivos
    jmp _fim_fopen

    _erro_abertura:
        # nulo
        movq $0, %rax

    _fim_fopen:
        popq %r13
        popq %r12
        popq %rbx
        popq %rbp
        ret

# ---------------------------------------------------------------------

_fclose:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rbx
    pushq %r12

    cmpq $0, %rdi
    je _erro_fechar_arquivo

    movq %rdi, %r12  # descritor de arquivo
    movq $0, %rbx

    _procura_descritor:
        cmpq qtdd_limite_arquivos, %rbx
        jge _erro_fechar_arquivo
        
        movq tabela_arquivos(,%rbx,8), %rax
        cmpq %r12, %rax
        je _encontrou_descritor
        
        incq %rbx
        jmp _procura_descritor

    _encontrou_descritor:
        movq $3, %rax    # sys_close
        movq %r12, %rdi
        syscall

        cmpq $0, %rax
        jl _erro_fechar_arquivo

        movq $-1, tabela_arquivos(,%rbx,8)  # remove da tabela
        movq $0, %rax
        jmp _fim_fclose

    _erro_fechar_arquivo:
        movq $-1, %rax

    _fim_fclose:
        popq %r12
        popq %rbx
        popq %rbp
        ret

# ---------------------------------------------------------------------

_compara_tipos:
    pushq %rbp
    movq %rsp, %rbp
    pushq %r12
    pushq %r13

    movq %rdi, %r12
    movq %rsi, %r13

    _loop_compara_tipos:
        movb (%r12), %al
        movb (%r13), %bl
        cmpb %al, %bl
        jne _tipos_diferentes
        cmpb $0, %al
        je _tipos_iguais
        incq %r12
        incq %r13
        jmp _loop_compara_tipos

    _tipos_iguais:
        movq $1, %rax
        jmp _fim_compara_tipos

    _tipos_diferentes:
        movq $-1, %rax

    _fim_compara_tipos:
        popq %r13
        popq %r12
        popq %rbp
        ret

# ---------------------------------------------------------------------

_descobre_flags:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rbx
    pushq %r12

    movq %rdi, %r12  # tipo

    movq %r12, %rdi
    leaq tipo_r, %rsi
    call _compara_tipos
    cmpq $1, %rax
    je _tipo_r

    movq %r12, %rdi
    leaq tipo_w, %rsi
    call _compara_tipos
    cmpq $1, %rax
    je _tipo_w

    movq %r12, %rdi
    leaq tipo_a, %rsi
    call _compara_tipos
    cmpq $1, %rax
    je _tipo_a

    movq %r12, %rdi
    leaq tipo_r_mais, %rsi
    call _compara_tipos
    cmpq $1, %rax
    je _tipo_r_mais

    movq %r12, %rdi
    leaq tipo_w_mais, %rsi
    call _compara_tipos
    cmpq $1, %rax
    je _tipo_w_mais

    movq %r12, %rdi
    leaq tipo_a_mais, %rsi
    call _compara_tipos
    cmpq $1, %rax
    je _tipo_a_mais

    jmp _retorna_flag

    _tipo_r:
        movq $0, %rax # flag somente leitura
        jmp _retorna_flag

    _tipo_w:
        movq $1, %rax # escrita
        orq  $64, %rax # criar
        orq  $512, %rax # truncar
        jmp _retorna_flag

    _tipo_a:
        movq $1, %rax
        orq  $64, %rax
        orq  $1024, %rax # anexar
        jmp _retorna_flag

    _tipo_r_mais:
        movq $0, %rax
        orq  $1, %rax
        jmp _retorna_flag

    _tipo_w_mais:
        movq $1, %rax
        orq  $64, %rax
        orq  $512, %rax
        orq  $0, %rax
        jmp _retorna_flag

    _tipo_a_mais:
        movq $1, %rax
        orq  $64, %rax
        orq  $1024, %rax
        orq  $0, %rax
        jmp _retorna_flag

    _retorna_flag:
        popq %r12
        popq %rbx
        popq %rbp
        ret

# ---------------------------------------------------------------------

_fprintf:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rbx
    pushq %r12
    pushq %r13

    movq %rdi, %rbx
    movq %rsi, %r12 # tipo
    movq %rdx, %r13 # valor

    # tipo
    movb (%r12), %al
    incq %r12
    cmpb $'%', %al
    jne _fim_fprintf

    movb (%r12), %al
    incq %r12
    cmpb $'d', %al
    je _fprintf_int
    cmpb $'c', %al
    je _fprintf_char
    cmpb $'f', %al
    je _fprintf_float
    cmpb $'l', %al
    je _fprintf_long
    cmpb $'h', %al
    je _fprintf_short
    jmp _fim_fprintf

    _fprintf_long:
        movb (%r12), %al
        incq %r12
        cmpb $'f', %al
        je _fprintf_double
        cmpb $'d', %al
        je _fprintf_long_int
        jmp _fim_fprintf

    _fprintf_short:
        movb (%r12), %al
        incq %r12
        cmpb $'d', %al
        je _fprintf_short_int
        jmp _fim_fprintf

    _fprintf_int:
        movl %r13d, %edi
        leaq resultado_printf, %rsi
        call _int_to_string
        jmp _escrever_resultado_fprintf

    _fprintf_char:
        movw %r13w, %di
        leaq resultado_printf, %rsi
        call _char_to_string
        jmp _escrever_resultado_fprintf

    _fprintf_float:
        movss (%r13), %xmm0
        leaq resultado_printf, %rsi
        call _float_to_string
        jmp _escrever_resultado_fprintf

    _fprintf_double:
        movsd (%r13), %xmm0
        leaq resultado_printf, %rsi
        call _double_to_string
        jmp _escrever_resultado_fprintf

    _fprintf_long_int:
        movq (%r13), %rdi
        leaq resultado_printf, %rsi
        call _long_int_to_string
        jmp _escrever_resultado_fprintf

    _fprintf_short_int:
        movw (%r13), %di
        leaq resultado_printf, %rsi
        call _short_to_string
        jmp _escrever_resultado_fprintf

    _escrever_resultado_fprintf:
        leaq resultado_printf, %rdi
        call _calcula_tamanho_str   # rax: tamanho da string
        movq %rax, %rdx

        movq $1, %rax
        movq %rbx, %rdi
        leaq resultado_printf, %rsi
        syscall

    _fim_fprintf:
        popq %r13
        popq %r12
        popq %rbx
        popq %rbp
        ret

# ---------------------------------------------------------------------

_fscanf:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rbx
    pushq %r12
    pushq %r13

    movq %rdi, %rbx
    movq %rsi, %r12 # tipo
    movq %rdx, %r13 # valor

    # tipo
    movb (%r12), %al
    incq %r12
    cmpb $'%', %al
    jne _fim_fscanf

    movb (%r12), %al
    incq %r12
    cmpb $'d', %al
    je _fscanf_int
    cmpb $'c', %al
    je _fscanf_char
    cmpb $'f', %al
    je _fscanf_float
    cmpb $'l', %al
    je _fscanf_long
    cmpb $'h', %al
    je _fscanf_short
    jmp _fim_fscanf

    _fscanf_long:
        movb (%r12), %al
        incq %r12
        cmpb $'f', %al
        je _fscanf_double
        cmpb $'d', %al
        je _fscanf_long_int
        jmp _fim_fscanf

    _fscanf_short:
        movb (%r12), %al
        incq %r12
        cmpb $'d', %al
        je _fscanf_short_int
        jmp _fim_fscanf

    _fscanf_read:
        movq $0, %rax
        movq %rbx, %rdi
        leaq entrada_scanf, %rsi
        movq $32, %rdx
        syscall
        
        cmpq $0, %rax
        jle _fim_fscanf
        ret

    _fscanf_int:
        call _fscanf_read
        leaq entrada_scanf, %rdi
        call _string_to_int
        movl %eax, (%r13)
        jmp _fim_fscanf

    _fscanf_char:
        call _fscanf_read
        leaq entrada_scanf, %rdi
        call _string_to_char
        movw %ax, (%r13)
        jmp _fim_fscanf

    _fscanf_float:
        call _fscanf_read
        leaq entrada_scanf, %rdi
        call _string_to_float
        movss %xmm0, (%r13)
        jmp _fim_fscanf

    _fscanf_double:
        call _fscanf_read
        leaq entrada_scanf, %rdi
        call _string_to_double
        movsd %xmm0, (%r13)
        jmp _fim_fscanf

    _fscanf_long_int:
        call _fscanf_read
        leaq entrada_scanf, %rdi
        call _string_to_long_int
        movq %rax, (%r13)
        jmp _fim_fscanf

    _fscanf_short_int:
        call _fscanf_read
        leaq entrada_scanf, %rdi
        call _string_to_short
        movw %ax, (%r13)
        jmp _fim_fscanf

    _fim_fscanf:
        popq %r13
        popq %r12
        popq %rbx
        popq %rbp
        ret
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
    cmpl $0, %eax
    jge _parte_inteira_positiva_float
    negl %eax
    
    _parte_inteira_positiva_float:
    cvtsi2ss %eax, %xmm2
    addss %xmm2, %xmm0

    # aplica o sinal
    cmpl $-1, -12(%rbp)
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
    cmpl $0, %eax
    jge _parte_inteira_positiva_double
    negl %eax
    
    _parte_inteira_positiva_double:
    cvtsi2sd %eax, %xmm2 
    addsd %xmm2, %xmm0

    # aplica o sinal
    cmpl $-1, -12(%rbp)
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
