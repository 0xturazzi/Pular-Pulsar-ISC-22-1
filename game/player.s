.data
look: .byte 0					# direcao olhando
vida: .byte 3 					# vida mostrada na UI
hp: .byte 0 						# mudanca de cor: dano tomado 0->1->2->morte
bullet_cnt: .byte 3 				# Municao
bullet: .word 0,0,0 				# Posicao tiros
bullet_dir : .byte 0,0,0 			# Direcao tiros

.macro print_player(%reg1, %int) 	# Printa um quadrado das mesmas dimensoes que o player  
	mv t0, %reg1					# Pode ser usado para debugar o  movimento
	li t3, %int					# ou para limpar o rastro do sprite
	add t0, s3, t0 				# int = cor
	li t4, 11					# reg = posicao
	VERT_DRAW:
		sw t3, 0(t0)				# escrita horizontal
		sw t3, 4(t0)
		sw t3, 8(t0)
		
		addi t0, t0,320 			# escrita vertical
		addi t4,t4,-1
		bgez t4, VERT_DRAW

.end_macro

.macro move_player() 	# Movimenta o player com base no input 

	# OBS SO TO CHECANDO COM CHAR MINUSCULO

	# para todos os movimentos salva s1 em s2 (old position)

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
	mv s2,s1
	li t0, 7680 			# colisao com teto 320 x 24
	ble s1, t0, END
	addi s1,s1,-1280 	# "diminui" a posicao vertical em 320*4
	li t1, 0
	sb t1, look, t2
	j END
	
DOWN:
	mv s2,s1
	li t0, 58880			# colisao com chao 320 x 184
	bge s1, t0, END
	addi s1,s1,1280 		# "aumenta" a posicao vertical em 320*4
	li t1, 2
	sb t1, look, t2
	j END
	
LEFT:
	mv s2,s1
	li t0, 20
	li t3, 320
	rem t1, s1, t3    	# extrai a posicao horizontal da posicao total
	ble t1, t0, END		# colisao com a parede da esquerda 20
	addi s1,s1,-4
	li t1, 3
	sb t1, look, t2
	j END
	
RIGHT:
	mv s2,s1
	li t0, 288
	li t3, 320
	rem t1, s1, t3 		# extrai a posicao horizontal da posicao total
	bge t1, t0, END		# colisao com a parede da direita 288
	addi s1,s1,4
	li t1, 1
	sb t1, look, t2
	j END
	
END:
.end_macro

.macro attack_player()
	li t2, 32
	beq t2, a0, ATK 		# barra de espaco
	j END
	ATK:
						# checa se tem municao sobrando
	END:
.end_macro
