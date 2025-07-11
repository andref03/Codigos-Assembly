.equ STDOUT, 1
.equ SYS_write, 1
.equ SYS_exit, 60
.section .data
    str: .string "Olá, mundo!"
    strLen: .quad 11
.section .bss
.section .text
.globl _start
_start:
    pushq %rbp
    movq %rsp, %rbp
    movq $SYS_write, %rax
    movq $STDOUT, %rdi
    movq $str, %rsi
    movq $strLen, %rdx
    syscall
    popq %rbp
    movq $60, %rax
    syscall
