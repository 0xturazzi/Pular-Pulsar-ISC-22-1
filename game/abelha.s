.text
.macro move_abelha(%pos) 	# Movimenta a abelha com base na distancia ate o player
	mv t5, %pos
	del_abelha(t5)			# limpa rastro
	mv t1, %pos
	beqz t1, NO_COL 			# pula tudo se ja ta morto
	
	get_slow_count(t2) 		# counter para desacelerar a abelha
	bgtz t2, END
	
	beq t1, s1, col_player 	# colisao com player

	
	bgt t1,s1, UP 	# abelha > player: abelha em baixo 	-> move up							
	blt t1,s1, DOWN 	# abelha < player: abelha em cima 	-> move down

	left_right:
	li t3, 320
	rem t2, t1, t3    		# extrai a posicao horizontal da posicao total abelha
	
	rem t3, s1, t3    		# extrai a posicao horizontal da posicao total player
	sub t2, t2, t3 			# > 0: abelha dir do player -> move left
							# < 0: analogo
	bgtz t2, LEFT
	bltz t2, RIGHT

	j END

UP:

	######## COLISOES 

	li t3, 0x01 				# cor parede

	addi t4, t1, -320 		# colisao cor parede
	add t4,t1, s3	
	
	lw t2, 0(t4)				# word da esquerda
	srli t2, t2, 24    		# byte esquerda
	beq t2, t3, left_right
	
	addi t4, t4, 8			# word da direita
	lw t2, 0(t4)
	andi t2, t2, 0xff  		# byte direita
	beq t2, t3, left_right

	######## COLISOES 

	addi t1,t1,-1280 		# "diminui" a posicao vertical em 320*4
	j left_right
	
DOWN:
	
	######## COLISOES 

	li t3, 0x01 				# cor parede

	li t4, 2560				# 320*8
	add t4, t1, t4 			# colisao cor parede
	add t4,t4, s3	
	
	lw t2, 0(t4)				# word da esquerda
	srli t2, t2, 24    		# byte esquerda
	beq t2, t3, left_right
	
	addi t4, t4, 4			# word da direita
	lw t2, 0(t4)
	andi t2, t2, 0xff  		# byte direita
	beq t2, t3, left_right

	
	######## COLISOES
	
	addi t1,t1,1280 			# "aumenta" a posicao vertical em 320*4
	j left_right
	
LEFT:

	
	######## COLISOES 
	
	li t3, 0x01 				# cor parede
	
	addi t4, t1, -4 			# colisao cor parede
	add t4,t4, s3	
	
	lw t2, 0(t4)				# word de cima
	srli t2, t2, 24    		# byte direita
	beq t2, t3, END
	
	
	li t5, 2240 				# 320*7
	add t4, t5, t4			# word de baixo
	lw t2, 0(t4)
	srli t2, t2, 24    		# byte direita
	beq t2, t3, END	

	######## COLISOES 
	
	
	addi t1,t1,-4
	j END
	
RIGHT:

	
	######## COLISOES 
	
	li t3, 0x01 				# cor parede
	
	addi t4, t1, 8 			# colisao cor parede
	add t4,t4, s3	
	
	lb t2, 0(t4)	    		# byte esquerda
	beq t2, t3, END
	
	
	li t5, 2240 				# 320*7	
	add t4, t4, t5			# word de baixo
	lb t2, 0(t4)				# byte esquerda
	beq t2, t3, END	

	######## COLISOES 
	
	addi t1,t1,4
	j END

END:
	mv %pos, t1
	
col_tiro:
	lw t2, bullet
	
	li t3, 320			# diferenca hor
	rem t4, t2, t3
	rem t5, t1, t3
	
	sub t5,t4,t5
	abs(t5)
	li t6, 5
	bgt t5, t6, NO_COL
	
	
	rem t4, t2, t3	# diferenca vert
	rem t5, t1, t3
	sub t5,t5,t4
	abs(t5)
	li t3, 5
	bgt t5, t3, NO_COL

	
	li %pos,0
		li t0, 0
		la t4, bullet 	# deleta bullet
		sw t0, 0(t4)
	j NO_COL

col_player:
	player_dano()
	li %pos, 0
NO_COL:
	
.end_macro
