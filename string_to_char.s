.section .data
entrada:    .asciz "H"

.section .text
.globl _start

_start:
    pushq %rbp
    movq %rsp, %rbp
   
    leaq entrada, %rdi

    # parâmetro %rdi
    call _string_to_char

    popq %rbp
    # resultado está em %ax
    movzwl %ax, %edi
    movl $60, %eax
    syscall

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
