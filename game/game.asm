# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# DATA
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
.data

# # # # # # # # # # # 
# DATA BESOURO
# # # # # # # # # # # 
pos_besouro_min: .word 0
pos_besouro_max: .word 0
pos_besouro: .word 0
pos_prev_besouro: .word 0
besouro_look: .byte 0
pedra_look: .byte 0
pos_pedra: .word 0
pos_prev_pedra: .word 0

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# DEPENDENCIAS
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
.text
.include "levels.s"
.include "player.s"
.include "artmanager.s"
.include "MACROS.s"
.include "flores.s"
.include "musicmanager.s"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# MAIN
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
.text
menu:
	li t0, 4					# lv4_menu
	sb t0, current_level, t1	# seleciona comecar no menu
main:
	sb zero, died, t0 		# restaurar flag de morte ao renascer
	setup_current_level() 	# dinamicamente da setup no nivel
	
POOLING_LOOP:
	update_ui()				# atualiza interface
	update_level()			# atualiza o runtime (todos niveis tem runtime identico)
	
	lb t0, died 				# checa flag de morte
	bnez t0, main			# re-setup no nivel atual
	
	lb t0, flor_win			# condicao de vitoria po coleta de chaves
	bnez t0, POOLING_LOOP
	
	lb t0, current_level		# Passa pro proximo nivel
	addi t0, t0, 1
	sb t0, current_level, t1
	j main

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# FUNCOES QUE PRECISAM SER ENCAPSULADAS EM MACROS
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # 
# MOVE ABELHA
# # # # # # # # # # # 

move_abelha_func:				# move a abelha
	mv t5, a0				# importa valores da macro
	mv s1, a1
	mv s3, a2
	#del_abelha(t5)			# limpa rastro
	mv t1, a0
	beqz t1, ABELHA_NO_COL 			# pula tudo se ja ta morto
	
	get_slow_count(t2) 		# counter para desacelerar a abelha
	bgtz t2, ABELHA_END
	
	beq t1, s1, abelha_col_player 	# colisao exata com player: abelha indo ate voce

	COL_PROX_PLAYER: 			# colisao por proximidade com player: voce indo ate abelha
							# precisa dos dois tipos por causa do delay slow count no movimento da abelha
							# Tecnicamente o de proximidade ja bastaria, mas ele e' significantemente mais pesado
							# entao so usamos quando extritamente nescessario
		mv t2, s1

		li t3, 320			# diferenca hor
		rem t4, t2, t3
		rem t5, t1, t3		# extrair posicao hor	
	
		sub t5,t4,t5
		abs(t5)
		li t6, 10
		bgt t5, t6, END_COL_PROX_PLAYER 		# | delta X |  > 10
	
	
		div t4, t2, t3	# diferenca vert
		div t5, t1, t3 	# extrair posicao vert
		sub t5,t5,t4
		abs(t5)
		li t3, 10
		bgt t5, t3, END_COL_PROX_PLAYER 		# | delta Y |  > 10
	
		j abelha_col_player 						# | delta X |  > 10   &&    | delta Y |  > 10
	
	END_COL_PROX_PLAYER:
	li t3, 320
	div t2,t1,t3
	div t4, s1, t3
	bgt t2,t4, ABELHA_UP 	# abelha > player: abelha em baixo 	-> move up							
	blt t2,t4, ABELHA_DOWN 	# abelha < player: abelha em cima 	-> move down

	ABELHA_left_right: 				# primeiro move no eixo y, depois pula pra ca e move no eixo x
	li t3, 320
	rem t2, t1, t3    		# extrai a posicao horizontal da posicao total abelha
	
	rem t3, s1, t3    		# extrai a posicao horizontal da posicao total player
	sub t2, t2, t3 			# > 0: abelha dir do player -> move left
							# < 0: analogo
	bgtz t2, ABELHA_LEFT
	bltz t2, ABELHA_RIGHT

	j ABELHA_END

ABELHA_UP:

	######## COLISOES 

	li t3, 0x01 				# cor parede

	li t4, -320	
	add t4, t1, t4 			# colisao cor parede
	add t4,t4, s3	
	
	lw t2, 0(t4)				# word da esquerda
	srli t2, t2, 24    		# byte esquerda
	beq t2, t3, ABELHA_left_right
	
	addi t4, t4, 4			# word da direita
	lw t2, 0(t4)
	andi t2, t2, 0xff  		# byte direita
	beq t2, t3, ABELHA_left_right

	######## COLISOES 

	addi t1,t1,-320 		# "diminui" a posicao vertical em 320*4
	j ABELHA_left_right
	
ABELHA_DOWN:
	
	######## COLISOES 

	li t3, 0x01 				# cor parede

	li t4, 2560				# 320*8
	add t4, t1, t4 			# colisao cor parede
	add t4,t4, s3	
	
	lw t2, 0(t4)				# word da esquerda
	srli t2, t2, 24    		# byte esquerda
	beq t2, t3, ABELHA_left_right
	
	addi t4, t4, 4			# word da direita
	lw t2, 0(t4)
	andi t2, t2, 0xff  		# byte direita
	beq t2, t3, ABELHA_left_right

	
	######## COLISOES
	
	addi t1,t1, 320 			# "aumenta" a posicao vertical em 320*4
	j ABELHA_left_right
	
ABELHA_LEFT:

	
	######## COLISOES 
	
	li t3, 0x01 				# cor parede
	
	addi t4, t1, -4 			# colisao cor parede
	add t4,t4, s3	
	
	lw t2, 0(t4)				# word de cima
	srli t2, t2, 24    		# byte direita
	beq t2, t3, ABELHA_END
	
	
	li t5, 2240 				# 320*7
	add t4, t5, t4			# word de baixo
	lw t2, 0(t4)
	srli t2, t2, 24    		# byte direita
	beq t2, t3, ABELHA_END	

	######## COLISOES 
	
	
	addi t1,t1,-4
	j ABELHA_END
	
ABELHA_RIGHT:

	
	######## COLISOES 
	
	li t3, 0x01 				# cor parede
	
	addi t4, t1, 8 			# colisao cor parede
	add t4,t4, s3	
	
	lb t2, 0(t4)	    		# byte esquerda
	beq t2, t3, ABELHA_END
	
	
	li t5, 2240 				# 320*7	
	add t4, t4, t5			# word de baixo
	lb t2, 0(t4)				# byte esquerda
	beq t2, t3, ABELHA_END	

	######## COLISOES 
	
	addi t1,t1,4
	j ABELHA_END

ABELHA_END:
	mv a0, t1					# posicao a ser retornada para a macro
	
col_tiro: 						# colisao com bullet: mesmo codigo da colisao por proximidade com player	
	lw t2, bullet 
	
	li t3, 320			# diferenca hor
	rem t4, t2, t3
	rem t5, t1, t3
	
	sub t5,t4,t5
	abs(t5)
	li t6, 10
	bgt t5, t6, ABELHA_NO_COL
	
	
	div t4, t2, t3	# diferenca vert
	div t5, t1, t3
	sub t5,t5,t4
	abs(t5)
	li t3, 10
	bgt t5, t3, ABELHA_NO_COL 			# | delta X |  > 10   &&    | delta Y |  > 10

	TEVE_COLISAO:
		li a0,0 		# deleta abelha

		li t0, 0
		la t4, bullet 	# deleta bullet
		sw t0, 0(t4)
		
		li t0, 0
		la t4, bullet_prev 	# deleta bullet_prev
		sw t0, 0(t4)
		
		player_refil_gas() 	# enche gasolina / carencia
		player_score(30)
	j ABELHA_NO_COL

abelha_col_player:  			# colisao com o player: deleta a abelha e causa dano ao hp (cor) do player
	li a0, 0
	player_dano()

ABELHA_NO_COL:
	jr ra

# # # # # # # # # # # 
# MOVE BESOURO
# # # # # # # # # # # 
besouro_move_func:				# move o besouro
		mv s1, a0 				# importa s1 da macro
		get_slow_count(t0)
		bnez t0, BESOURO_NO_DEL
		
		lw t1, pos_besouro			# pular se ele nao existe
		beqz t1, BESOURO_NO_DEL
		
		lb t3, besouro_look 		# direcao da pedra
		beqz t3, BESOURO_UP		# 0
		addi t3,t3,-1
		beqz t3, BESOURO_RIGHT 	# 1
		addi t3,t3,-1
		beqz t3, BESOURO_DOWN	# 2
		addi t3,t3,-1
		beqz t3, BESOURO_LEFT	# 3
		j BESOURO_NO_DEL
		BESOURO_UP:
			sw t1, pos_prev_besouro, t3 	# salva posicao antiga
			li t0, -3840
			add t1, t1, t0 				# 320x12
			j BESOURO_END_MOV 
		BESOURO_RIGHT:
			sw t1, pos_prev_besouro, t3	# salva posicao antiga
			addi t1, t1, 12
			j BESOURO_END_MOV 
		BESOURO_DOWN:
			sw t1, pos_prev_besouro, t3	# salva posicao antiga
			li t0, 3840
			add t1, t1, t0 				# 320x12
			j BESOURO_END_MOV 
		BESOURO_LEFT:
			sw t1, pos_prev_besouro, t3	# salva posicao antiga
			addi t1, t1, -12
			j BESOURO_END_MOV 
		 
		BESOURO_END_MOV: 			# checa se nao ta excedendo a tragetoria linear, e so depois salva a nova posicao
		lw t6, pos_besouro_min	# barreira horizontal
		lw t0, pos_besouro_max
		li t3, 320			# extrair hor
		rem t2, t1, t3 		# pedra
		rem t4, t6, t3		# min
		rem t5, t0, t3	 	# max
		
		bgt t2, t5, BESOURO_TURN
		blt t2, t4, BESOURO_TURN
		
		
								# barreira vertical
		div t2, t1, t3	# extrair vert
		div t4, t6, t3 	# min
		div t5, t0, t3	# max
		
		bgt t2, t5, BESOURO_TURN
		blt t2, t4, BESOURO_TURN
		
		
		# COLISAO BESOURO PLAYER por proximidade
		mv t2, s1
		li t3, 320			# diferenca hor
		rem t4, t2, t3
		rem t5, t1, t3		# extrair posicao hor	
	
		sub t5,t4,t5
		abs(t5)
		li t4, 10
		bgt t5, t4, BESOURO_NO_COL_PLAYER 		# | delta X |  > 10
	
	
		div t4, t2, t3	# diferenca vert
		div t5, t1, t3 	# extrair posicao vert
		sub t5,t5,t4
		abs(t5)
		li t3, 10
		bgt t5, t3,BESOURO_NO_COL_PLAYER 		# | delta Y |  > 10
	
		# Colidiu com player
		player_dano()
		j BESOURO_NO_COL
	BESOURO_NO_COL_PLAYER:
									# COLISAO BESOURO BULLET por proximidade
		lw t2, bullet
		li t3, 320			# diferenca hor
		rem t4, t2, t3
		rem t5, t1, t3		# extrair posicao hor	
	
		sub t5,t4,t5
		abs(t5)
		li t4, 20
		bgt t5, t4, BESOURO_NO_COL 		# | delta X |  > 20
	
	
		div t4, t2, t3	# diferenca vert
		div t5, t1, t3 	# extrair posicao vert
		sub t5,t5,t4
		abs(t5)
		li t3, 20
		bgt t5, t3,BESOURO_NO_COL 		# | delta Y |  > 20
	
		# colidiu com bullet
		sw zero, pos_besouro, t1
		del_pedra()
		sw zero, pos_pedra, t1
		player_gas()
		player_score(50)
		j BESOURO_NO_DEL
		BESOURO_TURN:
			lb t2, besouro_look
			li t4,4
			addi t2, t2, 2
			rem t2, t2, t4 		# novo look = (look antigo + 2) % 4
			sb t2, besouro_look, t0
			j BESOURO_NO_DEL
		BESOURO_NO_COL: 				# depois de todos esses checks, efetivamente salva a nova posicao da pedra
			sw t1, pos_besouro, t0	
			j BESOURO_NO_DEL
		BESOURO_NO_DEL:
			jr ra

# # # # # # # # # # # 
# MOVE PEDRA
# # # # # # # # # # # 
besouro_move_pedra:				# move a posicao da pedra do besouro
		mv s1, a0 				# importa s1 da macro
		
		lw t0, pos_besouro
		beqz t0, PEDRA_NO_DEL # parar com as pedras se o besouro ta morto
		
		get_slow_count(t0)
		li t1, 10 				# acelerar levemente o slow count
		rem t0, t0, t1
		bnez t0, PEDRA_NO_DEL
		
		lw t1, pos_pedra			# spawnar nova pedra se ela nao existe
		beqz t1, PEDRA_END
		
		lb t3, pedra_look 		# direcao da pedra
		beqz t3, PEDRA_UP		# 0
		addi t3,t3,-1
		beqz t3, PEDRA_RIGHT 	# 1
		addi t3,t3,-1
		beqz t3, PEDRA_DOWN	# 2
		addi t3,t3,-1
		beqz t3, PEDRA_LEFT	# 3
		j PEDRA_END
		PEDRA_UP:
			sw t1, pos_prev_pedra, t3 	# salva posicao antiga
			li t0, -3840
			add t1, t1, t0 				# 320x12
			j PEDRA_END_MOV 
		PEDRA_RIGHT:
			sw t1, pos_prev_pedra, t3	# salva posicao antiga
			addi t1, t1, 12
			j PEDRA_END_MOV 
		PEDRA_DOWN:
			sw t1, pos_prev_pedra, t3	# salva posicao antiga
			li t0, 3840
			add t1, t1, t0 				# 320x12
			j PEDRA_END_MOV 
		PEDRA_LEFT:
			sw t1, pos_prev_pedra, t3	# salva posicao antiga
			addi t1, t1, -12
			j PEDRA_END_MOV 
		 
		PEDRA_END_MOV: 			# checa se nao ta excedendo a tragetoria linear, e so depois salva a nova posicao
		lw t6, pos_besouro_min	# barreira horizontal
		lw t0, pos_besouro_max
		li t3, 320			# extrair hor
		rem t2, t1, t3 		# pedra
		rem t4, t6, t3		# min
		rem t5, t0, t3	 	# max
		
		bgt t2, t5, DEL_PEDRA
		blt t2, t4, DEL_PEDRA
		
		
								# barreira vertical
		div t2, t1, t3	# extrair vert
		div t4, t6, t3 	# min
		div t5, t0, t3	# max
		
		bgt t2, t5, DEL_PEDRA
		blt t2, t4, DEL_PEDRA
		
		
		# COLISAO PEDRA PLAYER por proximidade
		mv t2, s1
		li t3, 320			# diferenca hor
		rem t4, t2, t3
		rem t5, t1, t3		# extrair posicao hor	
	
		sub t5,t4,t5
		abs(t5)
		li t4, 10
		bgt t5, t4, PEDRA_NO_COL 		# | delta X |  > 10
	
	
		div t4, t2, t3	# diferenca vert
		div t5, t1, t3 	# extrair posicao vert
		sub t5,t5,t4
		abs(t5)
		li t3, 10
		bgt t5, t3,PEDRA_NO_COL 		# | delta Y |  > 10
	
		# Colidiu com player
		player_dano()
		DEL_PEDRA:				 	# Deleta pedra
			mv t1, zero
		PEDRA_NO_COL: 				# depois de todos esses checks, efetivamente salva a nova posicao da pedra
			sw t1, pos_pedra, t0	
			j PEDRA_NO_DEL
		PEDRA_END:
									# SPAWN NOVA PEDRA
			lw t0, pos_besouro
			sw t0, pos_pedra, t1	  	# pos_pedra = pos_besouro
			lb t0, besouro_look
			sb t0, pedra_look, t1	# pedra_look = besouro_look
		PEDRA_NO_DEL:
			jr ra

	
# # # # # # # # # # # 
# UI PRINT GAS 
# # # # # # # # # # # 

ui_print_gas_func: 				# printa gasolina / carencia
	mv s3, a0
	lb t0, gas
	li t1, 736 					# 92 * 8
	mul t0, t0, t1 				# posicao na spritesheet
	
	la t2, carencia
	addi t1,t2,8 				# skip size
	add t1, t1, t0 				# posicao na spritesheet	
	
	addi t0, s3,  340 			# posicao na tela
	li t4, 720
	add t0, t0, t4
	li t4, 7 					# ctr: 7 linhas
	UI_PRINT_GAS_VERT_DRAW:
	
		####################################### UNROLL DO FOR LOOP HORIZONTAL: MAIS EFICIENTE
		
        lw t3, 0(t1) # Le spritesheet
        sw t3, 0(t0) # Printa na tela
        lw t3, 4(t1) # Le spritesheet
        sw t3, 4(t0) # Printa na tela
        lw t3, 8(t1) # Le spritesheet
        sw t3, 8(t0) # Printa na tela
        lw t3, 12(t1) # Le spritesheet
        sw t3, 12(t0) # Printa na tela
        lw t3, 16(t1) # Le spritesheet
        sw t3, 16(t0) # Printa na tela
        lw t3, 20(t1) # Le spritesheet
        sw t3, 20(t0) # Printa na tela
        lw t3, 24(t1) # Le spritesheet
        sw t3, 24(t0) # Printa na tela
        lw t3, 28(t1) # Le spritesheet
        sw t3, 28(t0) # Printa na tela
        lw t3, 32(t1) # Le spritesheet
        sw t3, 32(t0) # Printa na tela
        lw t3, 36(t1) # Le spritesheet
        sw t3, 36(t0) # Printa na tela
        lw t3, 40(t1) # Le spritesheet
        sw t3, 40(t0) # Printa na tela
        lw t3, 44(t1) # Le spritesheet
        sw t3, 44(t0) # Printa na tela
        lw t3, 48(t1) # Le spritesheet
        sw t3, 48(t0) # Printa na tela
        lw t3, 52(t1) # Le spritesheet
        sw t3, 52(t0) # Printa na tela
        lw t3, 56(t1) # Le spritesheet
        sw t3, 56(t0) # Printa na tela
        lw t3, 60(t1) # Le spritesheet
        sw t3, 60(t0) # Printa na tela
        lw t3, 64(t1) # Le spritesheet
        sw t3, 64(t0) # Printa na tela
        lw t3, 68(t1) # Le spritesheet
        sw t3, 68(t0) # Printa na tela
        lw t3, 72(t1) # Le spritesheet
        sw t3, 72(t0) # Printa na tela
        lw t3, 76(t1) # Le spritesheet
        sw t3, 76(t0) # Printa na tela
        lw t3, 80(t1) # Le spritesheet
        sw t3, 80(t0) # Printa na tela
        lw t3, 84(t1) # Le spritesheet
        sw t3, 84(t0) # Printa na tela
        lw t3, 88(t1) # Le spritesheet
        sw t3, 88(t0) # Printa na tela
        	
       ####################################### UNROLL DO FOR LOOP HORIZONTAL: MAIS EFICIENTE 	
       
		addi t1, t1, 92			# avanca linha spritesheet
		addi t0, t0,320 			# avanca linha tela
		addi t4,t4,-1			# diminui ctr
		bgez t4, UI_PRINT_GAS_VERT_DRAW
		jr ra

	
# # # # # # # # # # # 
# UI PRINT SCORE 
# # # # # # # # # # # 
ui_print_score_func:			# printa score na posicao fornecida pela macro via a0
	mv s3, a0
	
	lw t2, score
	
	la t1, numeros
	addi t1,t1,8 			# skip size
	
	mv t0, a1
	add t0, t0, s3 			# posicao na tela 68480 (320*214) + 84
	
	
	### extrair digitos inteiro positivo base N 	###
	###										###
	### while x > 0:							###
	###		print(x % N)						###
	### 		x /= 10							###
	### ####################################### 	###
	
	li t4, 10				# extrai unidade
	rem t6, t2, t4
	div t2, t2, t4
	slli t6, t6, 3
	add t6,t6,t1				# escolhe na spritesheet
	addi t5, t0, 16			# ajusta posicao na tela
	li t4, 7 				# ctr: 8 linhas
	DIGITO_U:
        lw t3, 0(t6) # Le spritesheet
        sw t3, 0(t5) # Printa na tela
        lw t3, 4(t6) # Le spritesheet
        sw t3, 4(t5) # Printa na tela

		addi t6, t6, 80			# avanca linha spritesheet
		addi t5, t5,320 			# avanca linha tela
		addi t4,t4,-1			# diminui ctr
		bgez t4, DIGITO_U
	
	li t4, 10				# extrair dezena
	rem t6, t2, t4
	div t2, t2, t4
	slli t6, t6, 3
	add t6,t6,t1				# escolhe na spritesheet
	addi t5, t0, 8			# ajusta posicao na tela
	li t4, 7 				# ctr: 8 linhas
	DIGITO_D:
        lw t3, 0(t6) # Le spritesheet
        sw t3, 0(t5) # Printa na tela
        lw t3, 4(t6) # Le spritesheet
        sw t3, 4(t5) # Printa na tela

		addi t6, t6, 80			# avanca linha spritesheet
		addi t5, t5,320 			# avanca linha tela
		addi t4,t4,-1			# diminui ctr
		bgez t4, DIGITO_D
	
	li t4, 10 				# extrair centena
	rem t6, t2, t4
	div t2, t2, t4
	slli t6, t6, 3
	add t6,t6,t1				# escolhe na spritesheet
	mv t5, t0				# ajusta posicao na tela
	li t4, 7 				# ctr: 8 linhas
	DIGITO_C:
        lw t3, 0(t6) # Le spritesheet
        sw t3, 0(t5) # Printa na tela
        lw t3, 4(t6) # Le spritesheet
        sw t3, 4(t5) # Printa na tela

		addi t6, t6, 80			# avanca linha spritesheet
		addi t5, t5,320 			# avanca linha tela
		addi t4,t4,-1			# diminui ctr
		bgez t4, DIGITO_C
	jr ra

# # # # # # # # # # # 
# UI PRINT VIDA 
# # # # # # # # # # # 
ui_print_vida_func:			# printa UI da vida (3 sapinhos na direita)
	mv s3, a0 
	lb t0, vida

	li t1, 480 				# 40 * 12
	mul t0, t0, t1 			# posicao na spritesheet
	
	la t1, vidamenu
	addi t1,t1,8 			# skip size
	add t1, t1, t0 			# posicao na spritesheet	
	
	li t0, 67420
	add t0, t0, s3 			# posicao na tela 67200 (320*210) + 220
	li t4, 11 				# ctr: 11 linhas
	UI_VIDA_DRAW:
		
     	lw t3, 0(t1) # Le spritesheet
        sw t3, 0(t0) # Printa na tela
        lw t3, 4(t1) # Le spritesheet
        sw t3, 4(t0) # Printa na tela
        lw t3, 8(t1) # Le spritesheet
        sw t3, 8(t0) # Printa na tela
        lw t3, 12(t1) # Le spritesheet
        sw t3, 12(t0) # Printa na tela
        lw t3, 16(t1) # Le spritesheet
        sw t3, 16(t0) # Printa na tela
        lw t3, 20(t1) # Le spritesheet
        sw t3, 20(t0) # Printa na tela
        lw t3, 24(t1) # Le spritesheet
        sw t3, 24(t0) # Printa na tela
        lw t3, 28(t1) # Le spritesheet
        sw t3, 28(t0) # Printa na tela
        lw t3, 32(t1) # Le spritesheet
        sw t3, 32(t0) # Printa na tela
        lw t3, 36(t1) # Le spritesheet
        sw t3, 36(t0) # Printa na tela

		addi t1, t1, 40			# avanca linha spritesheet
		addi t0, t0,320 			# avanca linha tela
		addi t4,t4,-1			# diminui ctr
		bgez t4, UI_VIDA_DRAW
	jr ra

# # # # # # # # # # # 
# SETUP CURRENT LEVEL 
# # # # # # # # # # # 

setup_current_level_func:			# dinamicamente seleciona que nivel carregar
	lb t0, current_level			# baseado no conteudo da variavel current_level
	beqz t0, lv0
	addi t0, t0, -1				# Isso nao e' nescessario para o update_levl
	beqz t0, lv1					# visto que todos leveis tem runtime igual
	addi t0, t0, -1
	beqz t0, lv2_win 			# considerar menu, win, etc como levels simplifica o sistema
	addi t0, t0, -1
	beqz t0, lv3_game_over
	addi t0, t0, -1
	beqz t0, lv4_menu
	j END
	
	lv0: 
		setup_level_0()
		j END
	lv1:
		setup_level_1()
		j END
	lv2_win:
		setup_level_win()
	lv3_game_over:
		setup_level_game_over()
	lv4_menu:
		setup_level_menu()
	END:
	jr ra


# # # # # # # # # # # 
# SFX ataque
# # # # # # # # # # # 


sfx_ataque:
	li a0,80		# define a nota
	li a1,200		# define a duração da nota em ms
	li a2,127		# define o instrumento
	li a3,127		# define o volume
	li a7,31		# define o syscall
	ecall			# toca a nota
	jr ra
