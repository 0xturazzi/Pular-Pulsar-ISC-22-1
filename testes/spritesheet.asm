.data
.include "../art/data/sapo_spritesheet.data"
.text
		mv t1,s3	# endereco inicial da Memoria VGA
	
	la t4, sapo_spritesheet
	li t5, 4 		# num linhas
	
	addi t4,t4, 8 		# primeiro pixel
	LOOP: 	
		beqz t5,OUT	# Se for o último endereço então sai do loop
		lw t6, 0(t4) 	# le o pixel
		sw t6, 0(t1)		# escreve a word na memória
		lw t6, 4(t4) 	# le o pixel
		sw t6, 4(t1)		# escreve a word na memória		
		lw t6, 8(t4) 	# le o pixel
		sw t6, 8(t1)		# escreve a word na memória		

		
		
		addi t1,t1,4		# soma 4 ao endereço
		addi t4,t4,4 	# avanca 4 pixels
		addi t5, t5, -1
		j LOOP			
	OUT: