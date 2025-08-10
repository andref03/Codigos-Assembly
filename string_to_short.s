.section .data
entrada:    .asciz "115"

.section .text
.globl _start

_start:
    pushq %rbp
    movq %rsp, %rbp
   
    leaq entrada(%rip), %rdi    # ponteiro da string vai para %rdi

    # parâmetro %rdi: ponteiro da entrada
    call _string_to_int

    popq %rbp
    # resultado está em %eax
    movl %eax, %edi
    movl $60, %eax
    syscall

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
