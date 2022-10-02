.data
look: .byte 0					# direcao olhando
vida: .byte 0 					# vida mostrada na UI
hp: .byte 0 						# mudanca de cor: dano tomado 0->1->2->morte
gas: .byte 10					# gasolina / carencia

bullet: .word 0	 				# Posicao tiro
bullet_prev: .word 0	 			# Posicao prev tiro
bullet_dir : .byte 0				# Direcao tiro



.text


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# PLAYER
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 


.macro move_player() 	# Movimenta o player com base no input 

	# OBS SO TO CHECANDO COM CHAR MINUSCULO

	# para todos os movimentos salva s1 em s2 (old position)

	# colisao com as bordas imaginarias da area de jogo tecnicamente redundante
	# porem ela funciona muito bem, entao ainda existe para caso a colisao
	# por cor com a parede bugue

	li t2, 119 			# w
	beq t2, a0, UP
	li t2, 115 			# s
	beq t2, a0, DOWN
	li t2, 97			# a
	beq t2, a0, LEFT
	li t2, 100			# d
	beq t2, a0, RIGHT
	j END

UP:
	mv s2,s1 				# Salva posicao antiga

	######## COLISOES 

	li t3, 0x01 				# cor parede

	li t0, 7680 				# colisao com teto 320 x 24
	ble s1, t0, END
	
	addi t1, s1, -320 		# colisao cor parede
	add t1,t1, s3	
	
	lw t2, 0(t1)				# word da esquerda
	srli t2, t2, 24    		# byte esquerda
	beq t2, t3, END
	
	addi t1, t1, 8			# word da direita
	lw t2, 0(t1)
	andi t2, t2, 0xff  		# byte direita
	beq t2, t3, END

	######## COLISOES 

	addi s1,s1,-1280 		# "diminui" a posicao vertical em 320*4
	li t1, 0
	sb t1, look, t2
	j END
	
DOWN:
	mv s2,s1 				# Salva posicao antiga
	
	######## COLISOES 
	
	li t3, 0x01 				# cor parede

	li t0, 58880				# colisao com chao 320 x 184
	bge s1, t0, END
	
	li t4, 3840
	add t1, s1, t4 			# colisao cor parede
	add t1,t1, s3	
	
	lw t2, 0(t1)				# word da esquerda
	srli t2, t2, 24    		# byte esquerda
	beq t2, t3, END
	
	addi t1, t1, 8			# word da direita
	lw t2, 0(t1)
	andi t2, t2, 0xff  		# byte direita
	beq t2, t3, END

	
	######## COLISOES
	
	addi s1,s1,1280 			# "aumenta" a posicao vertical em 320*4
	li t1, 2
	sb t1, look, t2
	j END
	
LEFT:
	mv s2,s1 				# Salva posicao antiga
	
	######## COLISOES 
	
	li t0, 20
	li t3, 320
	rem t1, s1, t3    		# extrai a posicao horizontal da posicao total
	ble t1, t0, END			# colisao com a parede da esquerda 20
	
	li t3, 0x01 				# cor parede
	
	addi t1, s1, -4 			# colisao cor parede
	add t1,t1, s3	
	
	lw t2, 0(t1)				# word de cima
	srli t2, t2, 24    		# byte direita
	beq t2, t3, END
	
	
	li t4, 3520
	add t1, t1, t4			# word de baixo
	lw t2, 0(t1)
	srli t2, t2, 24    		# byte direita
	beq t2, t3, END	

	######## COLISOES 
	
	
	addi s1,s1,-4
	li t1, 3
	sb t1, look, t2
	j END
	
RIGHT:
	mv s2,s1 				# Salva posicao antiga
	
	######## COLISOES 
	
	li t0, 288
	li t3, 320
	rem t1, s1, t3 			# extrai a posicao horizontal da posicao total
	bge t1, t0, END			# colisao com a parede da direita 288
	
	li t3, 0x01 				# cor parede
	
	addi t1, s1, 12 			# colisao cor parede
	add t1,t1, s3	
	
	lb t2, 0(t1)				# word de cima
	lb t2, 0(t1)	    		# byte esquerda
	beq t2, t3, END
	
	
	li t4, 3520
	add t1, t1, t4			# word de baixo
	lb t2, 0(t1)				# byte esquerda
	beq t2, t3, END	

	######## COLISOES 
	
	addi s1,s1,4
	li t1, 1
	sb t1, look, t2
	j END
	
END:
.end_macro

.macro player_dano() 	# dano no hp (cor)
	lb t0, hp
	addi t0, t0, 1
	sb t0, hp, t1
.end_macro


.macro player_die() 		# dano na vida (interface)
	exit()
.end_macro

.macro player_gas()
	next_gas_count(t0)
	bnez t0, END 		# pula se nao ta na hora de diminuir
	lb t0, gas 
	addi t0, t0, -1
	sb t0, gas, t1
	bgtz t0, END 		# pula se gas > 0
	player_die() 		# morre
	END:
.end_macro

.macro player_refil_gas()
	li t0, 10
	sb t0, gas, t1
.end_macro

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# ATAQUE
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 



.macro attack_player()
	li t2, 32
	beq t2, a0, ATK 		# barra de espaco 
	j END
	ATK:
	lw t0, bullet 
	bnez t0, END 		# se tem municao
	
	spawn_bullet()
	END:
.end_macro

.macro spawn_bullet()
	mv t0, s1			# Importa a posicao

	lw t1, look			# direcao
	la t4, bullet_dir
	sb t1, 0(t4)

	addi t0, t0,  1924 	# opcional: spawna o tiro mais bonitinho, mas torna mirar mais dificil

	la t4, bullet
	sw t0, 0(t4) 		# salva posicao tiro
	la t4, bullet_prev
	sw t0, 0(t4)

	
.end_macro


.macro move_bullet()
	lb t0, bullet_dir
	lw t1, bullet
	
	la t2, bullet_prev 	# armazena o valor atual (que vai ser alterado) no valor anterior
	sw t1, 0(t2)
	
	beqz t1, NO_DRAW 	# se nao tem bullet para ser desenhada (excluida: posicao=0) 
	
	beqz t0, UP 			# bullet_dir == 0
	addi t0, t0, -1
	
	beqz t0, RIGHT 		# bullet_dir == 1
	addi t0, t0, -1
	
	beqz t0, DOWN 		# bullet_dir == 2
	addi t0, t0, -1
	
	beqz t0, LEFT 		# bullet_dir == 3
	
	j END
	UP:	
		li t3, 0x01 				# cor parede

		addi t5, t1, -320 		# colisao cor parede
		add t5,t5, s3	
	
		lw t2, 0(t5)				# word da esquerda
		srli t6, t2, 24    		# byte esquerda
		beq t6, t3, COL

		andi t2, t2, 0xff  		# byte direita
		beq t2, t3, COL

		######## COLISOES 

		addi t1, t1, -320
		j END
	DOWN:
		li t3, 0x01 				# cor parede

		addi t5, t1, 1280 		# colisao cor parede
		add t5,t5, s3	
	
		lw t2, 0(t5)				# word da esquerda
		srli t6, t2, 24    		# byte esquerda
		beq t6, t3, COL

		andi t2, t2, 0xff  		# byte direita
		beq t2, t3, COL

		######## COLISOES 
		addi t1, t1, 320
		j END

	LEFT:
		li t3, 0x01 				# cor parede
	
		addi t5, t1, -4 			# colisao cor parede
		add t5,t5, s3	
	
		lw t2, 0(t5)				# word de cima
		srli t2, t2, 24    		# byte direita
		beq t2, t3, COL
	
	
		li t4, 960
		add t5, t5, t4			# word de baixo
		lw t2, 0(t5)
		srli t2, t2, 24    		# byte direita
		beq t2, t3, COL	
	
		######## COLISOES 
	
		addi t1, t1, -4
		j END

	RIGHT:
		li t3, 0x01 				# cor parede
	
		addi t5, t1, 4 			# colisao cor parede
		add t5,t5, s3	
	
		lb t2, 0(t5)				# word de cima e byte esquerda
		beq t2, t3, COL
	
	
		li t4, 960
		add t5, t5, t4			# word de baixo
		lb t2, 0(t5)				# byte esquerda
		beq t2, t3, COL	
	
		######## COLISOES 
	
		addi t1, t1, 4
		j END
	END:
		la t0, bullet 			# salva a posicao da bullet
		sw t1, 0(t0)
		j END_DRAW
	NO_DRAW: 					# apagar a ultima iteracao da bullet que colidiu
		li t0, 0
		la t4, bullet_prev 		# delete bullet_prev
		sw t0, 0(t4)
		j END_DRAW
	COL:							# excluir a bullet que colidiu
		li t0, 0
		la t4, bullet 			# deleta bullet
		sw t0, 0(t4)
		
	END_DRAW:
.end_macro
