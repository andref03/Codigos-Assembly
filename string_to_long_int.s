.section .data
entrada:    .asciz "102"

.section .text
.globl _start

_start:
    pushq %rbp
    movq %rsp, %rbp
   
    leaq entrada(%rip), %rdi    # ponteiro da string vai para %rdi

    # parâmetro %rdi: ponteiro da entrada
    call _string_to_long_int

    popq %rbp
    # resultado está em %rax
    movq %rax, %rdi
    movl $60, %eax
    syscall

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

        call _char_para_digito

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
        movq $-1, %rax

    _fim_char_para_digito:
        popq %rbp
        ret
