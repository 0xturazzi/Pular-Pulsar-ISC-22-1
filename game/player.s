.data
look: .byte 0

.macro print_player(%reg1, %int) 	# Printa um quadrado verde que eu to fingindo ser o player  
	mv t0, %reg1
	li t3, %int
	add t0, s3, t0 	
	li t4, 11
	VERT_DRAW:
		sw t3, 0(t0)
		sw t3, 4(t0)
		sw t3, 8(t0)
		
		addi t0, t0,320
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
	sw t1, look, t2
	j END
	
DOWN:
	mv s2,s1
	li t0, 58880		# colisao com chao 320 x 184
	bge s1, t0, END
	addi s1,s1,1280 		# "aumenta" a posicao vertical em 320*4
	li t1, 2
	sw t1, look, t2
	j END
	
LEFT:
	mv s2,s1
	li t0, 20
	li t3, 320
	rem t1, s1, t3    	# extrai a posicao horizontal da posicao total
	ble t1, t0, END		# colisao com a parede da esquerda 20
	addi s1,s1,-4
	li t1, 3
	sw t1, look, t2
	j END
	
RIGHT:
	mv s2,s1
	li t0, 288
	li t3, 320
	rem t1, s1, t3 		# extrai a posicao horizontal da posicao total
	bge t1, t0, END		# colisao com a parede da direita 288
	addi s1,s1,4
	li t1, 1
	sw t1, look, t2
	j END
	
END:
.end_macro

