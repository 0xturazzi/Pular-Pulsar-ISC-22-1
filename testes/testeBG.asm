.data
.include "../game/data/background.data"

.text
	li s0,0xFF200604		# Escolhe o Frame 0 ou 1
	li t2,0				# inicio Frame 0
	sw t2,0(s0)			# seleciona a Frame
	li t1,0xFF000000		# endereco inicial da Memoria VGA
	
	la t4, background
	lw t5, 0(t4) 		# num linhas
	lw t6, 4(t4) 		# num colunas
	li t0, 0 			# count
	mul t3, t5, t6		# num pixels 
	
	addi t4,t4, 8 		# primeiro pixel
	LOOP: 	
		beq t0,t3,OUT	# Se for o último endereço então sai do loop
		lw t5, 0(t4) 	# le o pixel
		sw t5,0(t1)		# escreve a word na memória
		addi t1,t1,4		# soma 4 ao endereço
		addi t4,t4,4 	# avanca 4 pixels
		addi t0,t0,4 	# contador +4
		j LOOP			
	OUT: