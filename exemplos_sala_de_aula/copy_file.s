.section .data
	copiando: .string "Copiando: "
	para: .string " para "
	error: .string "Erro ao abrir arquivo\n"
	input: .string "input.txt"
	output: .string "output.txt"
	enter: .string "\n"
	
	# Constantes
	.equ SYS_READ, 0
	.equ SYS_WRITE, 1
	.equ SYS_OPEN, 2
	.equ SYS_CLOSE, 3
	.equ SYS_EXIT, 60
	.equ STDOUT, 1	
	.equ O_RDONLY, 0000
	.equ O_CREAT, 0100
	.equ O_WRONLY, 0001
	.equ MODE, 0666 
	.equ MODE_W, 0222 

.section .bss
	.equ TAM_BUFFER, 256
	.lcomm BUFFER, TAM_BUFFER

.section .text
.globl _start
_start:
	pushq %rbp
	movq %rsp, %rbp
	addq $8, %rsp		# descritor arquivo para leitura -8(%rbp)
	addq $8, %rsp		# descritor arquivo para escrita -16(%rbp)
	addq $8, %rsp		# quantidade de caracteres lidos do imput -24(%rbp)
	addq $8, %rsp		# return -1 ERROR  -32(%rbp)
	movq $0, -32(%rbp)
	
	# Imprime mensagem de cópia
	movq $SYS_WRITE, %rax
	movq $STDOUT, %rdi
	movq $copiando, %rsi
	movq $10, %rdx
	syscall
	
	movq $SYS_WRITE, %rax
	movq $STDOUT, %rdi
	movq $input, %rsi
	movq $9, %rdx
	syscall
	
	movq $SYS_WRITE, %rax
	movq $STDOUT, %rdi
	movq $para, %rsi
	movq $6, %rdx
	syscall
	
	movq $SYS_WRITE, %rax
	movq $STDOUT, %rdi
	movq $output, %rsi
	movq $10, %rdx
	syscall

	movq $SYS_WRITE, %rax
	movq $STDOUT, %rdi
	movq $enter, %rsi
	movq $1, %rdx
	syscall

	# Cria descritor de arquivo para sys_read
	movq $SYS_OPEN, %rax	
	movq $input, %rdi
	movq $O_RDONLY, %rsi
	movq $MODE, %rdx
	syscall
	
	# verificacao if( fopen(..) != NULL )
	movq %rax, -8(%rbp)
	cmpq $0, %rax
	jge _open_output
	movq $SYS_WRITE, %rax
	movq $STDOUT, %rdi
	movq $error, %rsi
	movq $22, %rdx
	syscall
	movq $-1, -32(%rbp)
	jmp _exit

	# Cria descritor de arquivo para sys_write
_open_output:
	movq $SYS_OPEN, %rax
	movq $output, %rdi
	movq $O_CREAT, %rsi
	orq $O_WRONLY, %rsi
	movq $MODE_W, %rdx
	syscall
	
	# verificacao if( fopen(..) != NULL )
	movq %rax, -16(%rbp)
	cmpq $0, %rax
	jge _copy_file
	movq $SYS_WRITE, %rax
	movq $STDOUT, %rdi
	movq $error, %rsi
	movq $22, %rdx
	syscall
	
	movq $SYS_CLOSE, %rax
	movq -8(%rbp), %rdi
	syscall
	movq $-1, -32(%rbp)
	jmp _exit
_copy_file:
	movq $SYS_READ, %rax
	movq -8(%rbp), %rdi
	movq $BUFFER, %rsi
	movq $TAM_BUFFER, %rdx
	syscall
	
	movq %rax, -24(%rbp)
_while:
	cmpq $0, -24(%rbp)
	jle _exit
	# escrita no output.txt
	movq $SYS_WRITE, %rax
	movq -16(%rbp), %rdi
	movq $BUFFER, %rsi
	movq -24(%rbp), %rdx
	syscall
	movq %rax, -24(%rbp)
		
	movq $SYS_WRITE, %rax
	movq $STDOUT, %rdi
	movq $BUFFER, %rsi
	movq -24(%rbp), %rdx
	syscall
	
	# nova leitura
	movq $SYS_READ, %rax
	movq -8(%rbp), %rdi
	movq $BUFFER, %rsi
	movq $TAM_BUFFER, %rdx
	syscall
	movq %rax, -24(%rbp)
	jmp _while
_exit: 
	movq $SYS_CLOSE, %rax
	movq -16(%rbp), %rdi
	syscall
	
	movq $SYS_CLOSE, %rax
	movq -8(%rbp), %rdi
	syscall
	
	movq -32(%rbp), %rdi
	subq $32, %rsp
	popq %rbp
	
	movq $SYS_EXIT, %rax
	syscall
