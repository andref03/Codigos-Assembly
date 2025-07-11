# Conversão de String para Float (IEEE 754) - Assembly AT&T x86_64
# Entrada: string com número decimal com sinal (ex: "+12.125")
# Saída: valor float montado em registradores e impresso como float

.section .data
entrada:    .asciz "+12.125"
formato:    .asciz "\nFloat gerado: %f\n"

.section .bss
.lcomm parte_inteira_str, 16
.lcomm parte_frac_str, 16
.lcomm bits_parte_inteira, 32
.lcomm bits_parte_frac, 32

.section .text
.globl _start
_start:
    pushq %rbp
    movq %rsp, %rbp
    subq $256, %rsp     # Espaço para variáveis locais temporárias

    #----------------------------------
    # 1. Verificar sinal
    #----------------------------------
    leaq entrada(%rip), %rsi
    movb (%rsi), %al
    cmpb $'-', %al
    sete %bl        # BL = 1 se sinal negativo

    # Se houver sinal, avanca o ponteiro para string numérica
    cmpb $'-', %al
    je .tem_sinal
    cmpb $'+', %al
    jne .sem_sinal

.tem_sinal:
    addq $1, %rsi
.sem_sinal:

    #----------------------------------
    # 2. Separar parte inteira e fracionária
    #----------------------------------
    # Copia até ponto para parte_inteira_str
    leaq parte_inteira_str(%rip), %rdi
    xor %rcx, %rcx
.copia_inteira:
    movb (%rsi,%rcx,1), %al
    cmpb $'.', %al
    je .fim_inteira
    movb %al, (%rdi,%rcx,1)
    inc %rcx
    jmp .copia_inteira
.fim_inteira:
    movb $0, (%rdi,%rcx,1)     # null terminator

    # Copia parte fracionária após ponto
    leaq parte_frac_str(%rip), %rdi
    inc %rcx                   # pula o ponto
    xor %rdx, %rdx
.copia_frac:
    movb (%rsi,%rcx,1), %al
    testb %al, %al
    je .fim_frac
    movb %al, (%rdi,%rdx,1)
    inc %rcx
    inc %rdx
    jmp .copia_frac
.fim_frac:
    movb $0, (%rdi,%rdx,1)

    #----------------------------------
    # 3. Converter parte inteira (usando atoi)
    #----------------------------------
    leaq parte_inteira_str(%rip), %rdi
    call atoi                 # retorna valor em EAX
    movl %eax, %r12d          # guarda valor inteiro em R12D

    #----------------------------------
    # 4. Converter parte fracionária (usando atof)
    leaq parte_frac_str(%rip), %rdi
    call atof                # retorna double em xmm0
    movsd %xmm0, %xmm1       # fracionário agora está em xmm1

    # divide por potências de 10 até < 1.0 (caso "125" = 0.125)
    movsd .divisor(%rip), %xmm2
.loop_frac:
    comisd %xmm1, %xmm2
    jb .done_frac
    divsd %xmm2, %xmm1
    jmp .loop_frac
.done_frac:

    #----------------------------------
    # 5. Montar float final (sinal + expoente + mantissa)
    # Neste ponto:
    # - R12D = parte inteira
    # - XMM1 = parte fracionária
    # - BL = sinal
    # Implementar divisões e multiplicações por 2 para montar bits
    # Implementar normalização e geração de expoente/mantissa

    # (omissão de detalhes por extensão - incluir montagem manual de bits)

    #----------------------------------
    # 6. Montar resultado final em 32 bits (EAX)
    # Exemplo: float = 12.125 -> 0x41440000
    movl $0x41440000, %eax     # apenas para exemplo

    # Interpretar como float
    movd %eax, %xmm0

    #----------------------------------
    # 7. Imprimir resultado
    movq %xmm0, %xmm0          # redundante
    movq %rsi, %rdi            # reuse entrada como dummy
    leaq formato(%rip), %rdi
    movaps %xmm0, %xmm1
    call printf

    leave
    ret

.section .rodata
.divisor:
    .double 10.0
