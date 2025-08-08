# execução:
# as --64 converte_padrao_ieee754.s -o exe.o ; ld -o exe exe.o ; ./exe

.section .data
  entrada:    .asciz "12.3"
  resultado:    .space 35            # 1 (sinal) + ' ' + 8 (expoente) + '' + 23 (mantissa) + '\0'
  binario:    .space 64
  binario_int:    .space 64
  expoente_temp:    .space 9
  quebra_linha:    .asciz "\n"

.section .text
.globl _start

_start:
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

  movq $60, %rax
  syscall

  # ------------------------------------------------------------------------

_string_to_float:
    pushq %rbp
    movq %rsp, %rbp

    call _converte_padrao_ieee754

    # neste ponto do código temos a resposta na string resultado

    

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
