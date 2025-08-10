.section .data
entrada:    .asciz "82.132"

.section .text
.globl _start

_start:

    pushq %rbp
    movq %rsp, %rbp
   
    leaq entrada, %rdi

    call _string_to_double   # resultado está em xmm0

    popq %rbp
    movq $60, %rax
    syscall

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
    
    _loop_fracionario:
        movzbq (%rdi), %rax
        cmpb $0, %al
        je _fim_loop_fracionario_double
        call _char_para_digito_long
        cmpl $-1, %eax
        je _fim_loop_fracionario_double

        call _retorna_fracao_double
    
        incq %rdi
        jmp _loop_fracionario

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

        call _char_para_digito_long

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
        addq $12, %rsp
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
