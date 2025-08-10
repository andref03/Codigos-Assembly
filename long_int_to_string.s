.section .data
entrada:    .long 214
resultado:  .space 100
quebra_linha:  .asciz "\n"

.section .text
.global _start

_start:
    pushq %rbp
    movq %rsp, %rbp

    # parâmetros
    movl entrada, %edi
    leaq resultado, %rsi

    call _int_to_string

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
    cmp $0, %eax
    jge _positivo_int_to_str
    movb $'-', (%r8)
    incq %r8
    neg %eax
    
    _positivo_int_to_str:
        # número zero
        cmp $0, %eax
        jne _loop_int_to_str
        movb $'0', (%r8)
        incq %r8
        movb $0, (%r8)
        jmp _fim_int_to_str

    _loop_int_to_str:
        movl $0, %edx
        idivl %ebx          # divide eax por 10, edx = resto
        addb $'0', %dl
        movb %dl, (%r8,%rcx,1)
        incq %rcx
        cmp $0, %eax
        jne _loop_int_to_str

        # inverte string
        movq %rcx, %r9
        decq %r9
        movq $0, %rax

        _inverte_str:
            cmpq %rax, %r9
            jle _fim_str
            movb (%r8,%rax,1), %dl
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
