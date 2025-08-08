# execução:
# as --64 string_to_float.s -o exe.o ; ld -o exe exe.o ; ./exe
# as --64 string_to_float.s -o exe.o ; ld -o exe exe.o ; gdb ./exe

.section .data
  entrada:    .asciz "-2.1"
  resultado:    .space 35            # 1 (sinal) + ' ' + 8 (expoente) + ' ' + 23 (mantissa) + '\0'
  binario:    .space 100
  binario_int:    .space 100
  expoente_temp:    .space 9
  quebra_linha:    .asciz "\n"

.section .text
.globl _start

_start:
    pushq %rbp
    movq %rsp, %rbp
    leaq entrada(%rip), %rdi

    call _string_to_float

    movq $1, %rax
    movq $1, %rdi
    leaq resultado(%rip), %rsi
    movq $35, %rdx
    syscall

    movq $1, %rax
    movq $1, %rdi
    leaq quebra_linha(%rip), %rsi
    movq $1, %rdx
    syscall

    popq %rbp
    movq $0, %rdi
    movq $60, %rax
    syscall

  # ------------------------------------------------------------------------

_string_to_float:
    pushq %rbp
    movq %rsp, %rbp

    call _converte_padrao_ieee754

    # neste ponto do código temos a resposta na string resultado

    leaq binario(%rip), %rdi
    movb $0, %al

    _loop7:
        cmpb $0, (%rdi)
        je _binario_limpo
        movb %al, (%rdi)
        incq %rdi
        jmp _loop7

    _binario_limpo:

        leaq binario_int(%rip), %rdi

    _loop8:
        cmpb $0, (%rdi)
        je _binario_int_limpo
        movb %al, (%rdi)
        incq %rdi
        jmp _loop8

    _binario_int_limpo:

        leaq expoente_temp(%rip), %rdi
    
    _loop9:
        cmpb $0, (%rdi)
        je _expoente_temp_limpo
        movb %al, (%rdi)
        incq %rdi
        jmp _loop9

    _expoente_temp_limpo:

    movq $11, %rcx      # posição de início da mantissa, em resultado
    movq $0, %r10
    movb $'1', binario(%r10)
    incq %r10

    _loop10:
        movb resultado(%rcx), %al
        cmpq $24, %r10
        je _mantissa_extraida
        cmpb $' ', %al
        je _remove_espaco
        jmp _sem_espaco
        _remove_espaco:
            incq %rcx
            jmp _loop10
        _sem_espaco:
        movb %al, binario(%r10)
        incq %r10
        incq %rcx
        jmp _loop10

    _mantissa_extraida:

    movq $2, %rcx       # posição de início do expoente em resultado
    movq $0, %r10

    _loop11:
        movb resultado(%rcx), %al
        cmpb $' ', %al
        je _expoente_extraido
        movb %al, expoente_temp(%r10)
        incq %r10
        incq %rcx
        jmp _loop11
    
    _expoente_extraido:
    
        movq $0, %rcx
        movq $7, %r10
        movq $1, %r13   # fator potência de 2

    _loop12:
        cmpq $0, %r10
        jl _expoente_calculado
        movb expoente_temp(%r10), %al
        subb $'0', %al
        movzbq %al, %rax
        imulq %r13, %rax
        addq %rax, %rcx
        imulq $2, %r13
        decq %r10
        jmp _loop12

    _expoente_calculado:
        subq $127, %rcx
        movq %rcx, %rbx     # rbx = expoente

    cmpq $0, %rbx
    jl _expoente_negativo_tratamento
    
    movq $0, %r10
    movb $'1', binario_int(%r10)
    incq %r10
    movq $1, %rcx

    _loop13:
        movb binario(%rcx), %al
        cmpq %rbx, %rcx
        jg _parte_inteira_extraida
        movb %al, binario_int(%r10)
        incq %r10
        incq %rcx
        jmp _loop13

    _parte_inteira_extraida:
    
    movq $0, %r9
    movq %rbx, %r10 # tamanho parte inteira
    movq $1, %r13   # fator potência de 2

    _loop14:
        cmpq $0, %r10
        jl _inteiro_calculado
        movb binario_int(%r10), %al
        subb $'0', %al
        movzbq %al, %rax
        imulq %r13, %rax
        addq %rax, %r9
        imulq $2, %r13
        decq %r10
        jmp _loop14

    _inteiro_calculado:
    jmp _calcula_mantissa_fracionaria

    _expoente_negativo_tratamento:
        movq $0, %r9
        movq $1, %rcx
        movq %rbx, %rax
        imulq $-1, %rax  # torna positivo
        decq %rax
        addq %rax, %rcx  # pula os bits necessários

    _calcula_mantissa_fracionaria:
    # de %rcx em diante, a string binario tem a mantissa fracionária

    movq $0, %rax
    cvtsi2ss %rax, %xmm3  # acumulador da mantissa
    movq $2, %rax
    cvtsi2ss %rax, %xmm2  # potências de 2 (começa com 2)
    movq $0, %r11         # contador de bits processados

    _loop15:
        cmpq $23, %r11
        jge _mantissa_calculada
        movb binario(%rcx), %al
        cmpb $0, %al
        je _mantissa_calculada
        subb $'0', %al
        movzbq %al, %rax
        cvtsi2ss %rax, %xmm0
        divss %xmm2, %xmm0      # bit * (1/2^n)
        addss %xmm0, %xmm3
        movq $2, %rax
        cvtsi2ss %rax, %xmm4
        mulss %xmm4, %xmm2      # próxima potência de 2
        incq %rcx
        incq %r11
        jmp _loop15

    _mantissa_calculada:
    # xmm3 possui a mantissa calculada, %r9 a parte inteira

    # pra expoente negativo, aplicar divisão por 2^expoentr
    cmpq $0, %rbx
    jl _aplicar_divisao_expoente
    
    cvtsi2ss %r9, %xmm0
    addss %xmm3, %xmm0
    jmp _aplicar_sinal

    _aplicar_divisao_expoente:
    movq $1, %rax
    cvtsi2ss %rax, %xmm0
    addss %xmm3, %xmm0 
    movq %rbx, %rax
    imulq $-1, %rax
    movq $2, %r10
    cvtsi2ss %r10, %xmm4    # 2
    
    _loop_divisao:
        cmpq $0, %rax
        jle _aplicar_sinal
        divss %xmm4, %xmm0    # dividir por 2
        decq %rax
        jmp _loop_divisao

    _aplicar_sinal:
    leaq resultado(%rip), %rdi
    cmpb $'1', (%rdi)
    je _negativo
    jmp _fim

    _negativo:
        movq $-1, %rax
        cvtsi2ss %rax, %xmm1
        mulss %xmm1, %xmm0

    _fim:
        leave
        ret

# ------------------------------------------------------------------------

_converte_padrao_ieee754:
  pushq %rbp
  movq %rsp, %rbp
  movq $0, %rcx

  _identifica_sinal:
    movb (%rdi), %al
    cmpb $'-', %al
    jne _positivo
    movb $'1', resultado(%rcx)
    incq %rdi
    jmp _sinal_analisado
  _positivo:
    cmpb $'+', %al
    jne _sem_sinal
    incq %rdi

  _sem_sinal:
    movb $'0', resultado(%rcx)
  _sinal_analisado:
    incq %rcx

  movb $' ', resultado(%rcx)  # espaço só pra separar os campos
  incq %rcx

  call _transforma_em_binario

  _calcula_expoente:
    # parte inteira está em %r8
    cmpq $0, %r8
    je _parte_inteira_zero
    # a parte inteira é diferente de zero, ent expoente é o tamanho da parte inteira - 1
    movq %r15, %rax
    decq %rax
    addq $127, %rax
    jmp _exp_para_binario
    
    _parte_inteira_zero:
      _loop6:
        movb binario(%r15), %al
        cmpb $'1', %al
        je _fim_loop6
        incq %r15
        jmp _loop6

    _fim_loop6:
      incq %r15
      movq %r15, %rax
      imulq $-1, %rax
      addq $127, %rax
      movq $-1, %rbx      # rbx = -1 se torna uma flag pra saber se o expoente é negativo

  _exp_para_binario:
    call _expoente_para_binario

  movb $' ', resultado(%rcx)  # espaço só pra separar os campos
  incq %rcx

  _calcula_mantissa:
    movq $0, %r14
    movq $0, %r12

  _verifica_expoente:
    cmpq $-1, %rbx
    je _expoente_negativo
    # ignora o primeiro bit (começa no bit de index 1)
    movq $1, %rdi
    leaq binario(%rdi), %rsi # rsi agora aponta para o ponto no binário normalizado
    jmp _loop_mantissa

    _expoente_negativo:
      movq %r15, %rdi
      leaq binario(%rdi), %rsi # rsi agora aponta para o ponto no binário normalizado

  _loop_mantissa:
    cmpq $23, %r14
    jge _fim_conversao
    movb (%rsi), %al
    cmpb $0, %al           # se chegou no '\0'
    je _completa_zero
    movb %al, resultado(%rcx)
    jmp _avanca

    _completa_zero:
        movb $'0', resultado(%rcx)

    _avanca:
        incq %rsi
        incq %rcx
        incq %r14
      jmp _loop_mantissa

_fim_conversao:
  leave
  ret

# ------------------------------------------------------------------------

_expoente_para_binario:
  pushq %rbp
  movq %rsp, %rbp

  movq $0, %r9
  movq $2, %r10

  _loop_exp_div:
    cmpq $0, %rax
    je _inverte_expoente
    movq $0, %rdx
    idivq %r10
    addb $'0', %dl
    movb %dl, expoente_temp(%r9)
    incq %r9
    jmp _loop_exp_div

  _inverte_expoente:
    _preenche_zeros_exp:
      cmpq $8, %r9
      jge _inverte_agora
      movb $'0', expoente_temp(%r9)
      incq %r9
      jmp _preenche_zeros_exp

  _inverte_agora:
    _loop_exp_inv:
      cmpq $0, %r9
      jl _fim_inverte_expoente
      decq %r9
      movb expoente_temp(%r9), %al
      movb %al, resultado(%rcx)
      incq %rcx
      jmp _loop_exp_inv

  _fim_inverte_expoente:
    leave
    ret

# ------------------------------------------------------------------------

_transforma_em_binario:
  pushq %rbp
  movq %rsp, %rbp
  movq $0, %r8
  movq $0, %r9
  movq $0, %r12

  _loop1:
    movb (%rdi), %al
    cmpb $'.', %al
    je _ponto_decimal
    subb $'0', %al
    imulq $10, %r8
    movzbq %al, %rax
    addq %rax, %r8
    incq %rdi
    jmp _loop1

  _ponto_decimal:
    incq %rdi
    movq $1, %r13
  _loop2:
    movb (%rdi), %al
    cmpb $0, %al
    je _divisoes_sucessivas
    subb $'0', %al
    imulq $10, %r9
    movzbq %al, %rax
    addq %rax, %r9
    incq %rdi
    imulq $10, %r13
    jmp _loop2

  _divisoes_sucessivas:
    movq %r8, %rax
    movq $2, %r10
    movq $0, %r11
  _loop3:
    cmpq $0, %rax
    je _fim_divisoes
    movq $0, %rdx
    idivq %r10
    addb $'0', %dl  # transforma em char só pra inserir na string mesmo
    movb %dl, binario_int(%r11)
    incq %r11
    jmp _loop3
  _fim_divisoes:
    call _inverte_binario_int


  _multiplicacoes_sucessivas:
    cmpq $0, %r9
    je _fim_multiplicacoes
    cvtsi2ssq %r9, %xmm0
    cvtsi2ssq %r13, %xmm1
    divss %xmm1, %xmm0
    
    movq $2, %rax
    cvtsi2ssq %rax, %xmm2
    movq $1, %rax
    cvtsi2ssq %rax, %xmm3
    
    movq $0, %r14    

  _loop5:
    cmpq $90, %r14      # loop grande o suficiente pra cobrir um expoente grande
    jge _fim_multiplicacoes
    incq %r14
    mulss %xmm2, %xmm0
    ucomiss %xmm3, %xmm0
    jb _inteiro_zero
    movb $'1', binario(%r12)
    subss %xmm3, %xmm0
    jmp _proximo_bit
  _inteiro_zero:
    movb $'0', binario(%r12)
  _proximo_bit:
    incq %r12
    jmp _loop5

_fim_multiplicacoes:
  movb $0, binario(%r12) # adiciona '\0'
  leave
  ret

# ------------------------------------------------------------------------

_inverte_binario_int:
  pushq %rbp
  movq %rsp, %rbp

  _loop4:
    cmpq $0, %r11
    je _fim_inverte_binario_int
    decq %r11
    movb binario_int(%r11), %al
    movb %al, binario(%r12)
    incq %r12
    jmp _loop4

  _fim_inverte_binario_int:
    movq %r12, %r15 # salva o tamanho da parte inteira, onde ficaria o ponto decimal
    leave
    ret
