.section .data
    str1: .string "Digite dois numeros: "
    str2: .string "%d %d"
    str3: .string "Os numeros digitados foram %d %d\n"

.section .text
.globl main
main:
    pushq %rbp
    movq %rsp, %rbp

    subq $16, %rsp              # reserva 16 bytes para 2 ints (4 bytes cada + alinhamento)

    # Imprime mensagem
    movq $str1, %rdi
    xor %rax, %rax              # printf é variadic, limpar %rax
    call printf

    # Prepara parâmetros para scanf
    leaq -16(%rbp), %rsi       # endereço da 1ª variável local (int)
    leaq -12(%rbp), %rdx       # endereço da 2ª variável local (int)
    movq $str2, %rdi           # formato "%d %d"
    xor %rax, %rax             # scanf variadic, limpar %rax
    call scanf

    # Prepara parâmetros para printf mostrar os números
    movl -16(%rbp), %esi       # 1º número (int) no %esi (2º arg)
    movl -12(%rbp), %edx       # 2º número (int) no %edx (3º arg)
    movq $str3, %rdi           # string de formato em %rdi (1º arg)
    xor %rax, %rax             # printf variadic, limpar %rax
    call printf

    addq $16, %rsp             # desaloca as variáveis locais
    popq %rbp
    movl $0, %eax              # retorno 0 para main
    ret
