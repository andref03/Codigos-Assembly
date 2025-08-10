.section .data
entrada:    .byte 'M'
resultado:  .space 100
quebra_linha:  .asciz "\n"

.section .text
.global _start

_start:
    pushq %rbp
    movq %rsp, %rbp

    # parâmetros
    movzbl entrada, %edi
    leaq resultado, %rsi

    call _char_to_string

    leaq resultado, %rdi
    call _calcula_tamanho_str
    movq %rax, %rdx # tamanho da string
    movq $1, %rax  
    movq $1, %rdi  
    leaq resultado, %rsi
    syscall

    movq $1, %rax
    movq $1, %rdi
    leaq quebra_linha, %rsi
    movq $1, %rdx
    syscall

    popq %rbp
    movl $0, %edi
    movl $60, %eax
    syscall

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
