.data
    tolerance: .float 0.1                    				        # Tolerância definida como 0.1
    max_iterations_msg: .asciiz "Digite o numero maximo de iteracoes: "         # Mensagem solicitando o número máximo de iterações
    root_not_found_msg: .asciiz "Nao foi possivel encontrar a raiz!"            # Mensagem exibida quando a raiz não é encontrada
    root_found_msg: .asciiz "Raiz encontrada: "                                 # Mensagem exibida quando a raiz é encontrada
    iterations_msg: .asciiz "\nNumero de iteracoes: "                           # Mensagem exibindo o número de iterações
    enter_interval_start_msg: .asciiz "Digite o valor inicial do intervalo: "   # Mensagem solicitando o valor inicial do intervalo
    enter_interval_end_msg: .asciiz "Digite o valor final do intervalo: "       # Mensagem solicitando o valor final do intervalo

.text
main:
    # Solicita o valor inicial do intervalo
    li $v0, 4
    la $a0, enter_interval_start_msg
    syscall
    li $v0, 6
    syscall
    mov.s $f4, $f0

    # Solicita o valor final do intervalo
    li $v0, 4
    la $a0, enter_interval_end_msg
    syscall
    li $v0, 6
    syscall
    mov.s $f8, $f0

    # Solicita o número máximo de iterações
    li $v0, 4
    la $a0, max_iterations_msg
    syscall
    li $v0, 5
    syscall
    move $t0, $v0

    # Chama a função para encontrar a raiz
    jal find_root

    # Finaliza o programa
    li $v0, 10
    syscall

find_root:
    # Chama a função para calcular o valor da função para o valor inicial do intervalo
    jal calculate_function
    mov.s $f6, $f0
    li $t1, 0
    mov.s $f7, $f4
    lwc1 $f9, tolerance

bisection_method:
    # Incrementa o contador de iterações
    add $t1, $t1, 1

    # Calcula o valor intermediário
    sub.s $f10, $f8, $f7
    li $t2, 2
    mtc1 $t2, $f11
    cvt.s.w $f11, $f11
    div.s $f10, $f10, $f11
    add.s $f4, $f7, $f10

    # Chama a função para calcular o valor da função para o valor intermediário
    jal calculate_function
    mtc1 $zero, $f11
    cvt.s.w $f11, $f11
    c.eq.s $f0, $f11
    bc1f check_tolerance

converged:
    # Exibe a mensagem de raiz encontrada
    li $v0, 4
    la $a0, root_found_msg
    syscall

    # Exibe o valor da raiz encontrada
    li $v0, 2
    mov.s $f12, $f4
    syscall

    # Exibe o número de iterações realizadas
    li $v0, 4
    la $a0, iterations_msg
    syscall

    # Exibe o contador de iterações
    li $v0, 1
    move $a0, $t1
    syscall

    # Pula para o final do programa
    j end_program

check_tolerance:
    c.lt.s $f10, $f9
    bc1t converged

    mul.s $f10, $f6, $f0
    c.lt.s $f11, $f10

    movt.s $f7, $f4
    movt.s $f6, $f0

    movf.s $f8, $f4

    bne $t0, $t1, bisection_method

    # Exibe a mensagem de raiz não encontrada
    la $a0, root_not_found_msg
    li $v0, 4
    syscall

    # Pula para o final do programa
    j end_program

calculate_function:
    addi $sp, $sp, -8
    swc1 $f6, 0($sp)
    sw $t2, 4($sp)

    # Calcula o valor da função para o valor atual do intervalo
    mul.s $f0, $f4, $f4
    mul.s $f0, $f0, $f4

    li $t2, 10
    mtc1 $t2, $f6
    cvt.s.w $f6, $f6

    sub.s $f0, $f0, $f6

    lwc1 $f6, 0($sp)
    lw $t2, 4($sp)
    addi $sp, $sp, 8
    jr $ra

end_program:
    # Finaliza o programa
    li $v0, 10
    syscall
