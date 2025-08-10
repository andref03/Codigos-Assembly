.section .data
entrada:    .asciz "135"

.section .text
.globl _start

_start:
    pushq %rbp
    movq %rsp, %rbp
   
    leaq entrada(%rip), %rdi    # ponteiro da string vai para %rdi

    # parâmetro %rdi: ponteiro da entrada
    call _string_to_short

    popq %rbp
    # resultado está em %ax
    movzwl %ax, %edi
    movl $60, %eax
    syscall

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
