.data
.include "../game/data/background.data"
.include "../game/data/map1.data"
.include "../game/data/map0.data"

.include "../game/data/sapo_spritesheet.data"
.include "../game/data/heart.data"

.include "../game/data/viloes.data"
.include "../game/data/besouro.data"
.include "../game/data/pedra.data"

.include "../game/data/carencia.data"
.include "../game/data/vidamenu.data"
.include "../game/data/cesta.data"
.include "../game/data/numeros.data"

.include "../game/data/flores_sprite.data"

.include "../game/data/YouWon.data"
.include "../game/data/tela_info.data"
.include "../game/data/tela_menu.data"
.include "../game/data/GameOver.data"

.text

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# BACKGROUND
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

.macro print_bg()
	mv t1,s3				# endereco inicial da Memoria VGA
	
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
.end_macro

.macro print_map1()		# printa o mapa do level 1
	mv t1,s3				# endereco inicial da Memoria VGA
	
	la t4, map1
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
.end_macro

.macro print_map0()		# printa o mapa do level 0
	mv t1,s3				# endereco inicial da Memoria VGA
	
	la t4, map0
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
.end_macro

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# FLOR
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
.macro print_flor()			# printa a flor a ser coletada (ajuste de cor)
	lb t0, flor_win

	addi t0, t0, -1 			# cor = 12 * (flor_win-1 + current_level)
	lb t1, current_level
	add t0, t0, t1
	li t1, 12
	mul t0, t0, t1 			# posicao na spritesheet
	
	la t1, flores_sprite
	addi t1,t1,8 			# skip size
	add t1, t1, t0 			# posicao na spritesheet	
	
	lw t0, pos_flor
	add t0, t0, s3 			# posicao na tela
	li t4, 11 				# ctr: 12 linhas
	VERT_DRAW:
		
     	lw t3, 0(t1) # Le spritesheet
        sw t3, 0(t0) # Printa na tela
        lw t3, 4(t1) # Le spritesheet
        sw t3, 4(t0) # Printa na tela
        lw t3, 8(t1) # Le spritesheet
        sw t3, 8(t0) # Printa na tela


		addi t1, t1, 36			# avanca linha spritesheet
		addi t0, t0,320 			# avanca linha tela
		addi t4,t4,-1			# diminui ctr
		bgez t4, VERT_DRAW
	END:
.end_macro


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# BESOURO
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
.macro print_besouro() 			# printa o sprite do besouro
	lw t0, pos_besouro 			# Importa a posicao
	beqz t0, END
	add t0, s3, t0 				# adiciona o endereco do buffer next

	la t1, besouro 				# Importa endereco spritesheet
	addi t1, t1, 8 				# Pula size

	li t2, 16 					# look * width (12) ------> ajusta a posicao olhando
	lb t3, besouro_look
	mul t2, t2, t3
	add t1,t1,t2 				# posicao na spritesheet
	
	li t4, 15 					# ctr: 16 linhas
	VERT_DRAW:
		lw t3, 0(t1) 			# Le spritesheet
		sw t3, 0(t0)				# Printa na tela
		lw t3, 4(t1)				# ...
		sw t3, 4(t0)				# ...
		lw t3, 8(t1)
		sw t3, 8(t0)
		lw t3, 12(t1)
		sw t3, 12(t0)
		
		addi t1, t1, 64			# avanca linha spritesheet
		addi t0, t0,320 			# avanca linha tela
		addi t4,t4,-1			# diminui ctr
		bgez t4, VERT_DRAW
	END:
.end_macro
.macro del_besouro() 			# printa o sprite do besouro
	lw t0, pos_prev_besouro 			# Importa a posicao
	beqz t0, END
	add t0, s4, t0 				# adiciona o endereco do buffer next
	
	li t3, 0x50505050
	li t4, 15 					# ctr: 16 linhas
	VERT_DRAW:

		sw t3, 0(t0)				# Printa na tela
		sw t3, 4(t0)				# ...
		sw t3, 8(t0)
		sw t3, 12(t0)
		
		addi t0, t0,320 			# avanca linha tela
		addi t4,t4,-1			# diminui ctr
		bgez t4, VERT_DRAW
	END:
.end_macro
.macro print_pedra()				# deleta o sprite da pedra do besouro
	lw t0, pos_pedra 			# Importa a posicao atual
	beqz t0, END
	add t0, s3, t0 				# adiciona o endereco do buffer next

	la t1, pedra 				# Importa endereco spritesheet
	addi t1, t1, 8 				# Pula size

	li t2, 8 					# look * width (12) ------> ajusta a posicao olhando
	lb t3, pedra_look
	mul t2, t2, t3
	add t1,t1,t2 				# posicao na spritesheet
	
	li t4, 7 					# ctr: 8 linhas
	VERT_DRAW:
		lw t3, 0(t1) 			# Le spritesheet
		sw t3, 0(t0)				# Printa na tela
		lw t3, 4(t1)				# ...
		sw t3, 4(t0)				# ...

		
		addi t1, t1, 32			# avanca linha spritesheet
		addi t0, t0,320 			# avanca linha tela
		addi t4,t4,-1			# diminui ctr
		bgez t4, VERT_DRAW
	END:
.end_macro
.macro del_pedra() 				# deleta o sprite da pedra do besouro
	lw t0, pos_prev_pedra 		# Importa a posicao previa
	beqz t0, END
	add t0, s4, t0 				# adiciona o endereco do buffer next

	li t3, 0x50505050
	li t4, 11 					# ctr: 12 linhas
	VERT_DRAW:
		sw t3, 0(t0)				# Printa na tela
		sw t3, 4(t0)				# ...
		sw t3, 8(t0)
		
		addi t0, t0,320 			# avanca linha tela
		addi t4,t4,-1			# diminui ctr
		bgez t4, VERT_DRAW
	END:
.end_macro

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# UI
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

.macro ui_print_vida() 		# printa vida (3 sapinhos)
	mv a0, s3
	jal ra, ui_print_vida_func

.end_macro

.macro ui_print_gas() 			# printa gasolina / carencia
	mv a0, s3
	jal ra, ui_print_gas_func
.end_macro

.macro ui_print_cesta() 		# printa cesta de flores coletadas
	lb t0, flor_win
	lb t1, current_level
	
	slli t1, t1, 1			# (64 * 8) * (nivel + (nivel - flor_win + 1)) = 512 * (2 nivel + 1 - flor_win)
	addi t1, t1, 1
	sub t0, t1, t0
	
	li t1, 512 				
	mul t0, t0, t1 			# posicao na spritesheet
	la t1, cesta
	addi t1,t1,8 			# skip size
	add t1, t1, t0 			# posicao na spritesheet	
	
	li t0, 68752
	add t0, t0, s3 			# posicao na tela 68480 (320*214) + 272
	li t4, 7 				# ctr: 8 linhas
	VERT_DRAW:
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

		addi t1, t1, 64			# avanca linha spritesheet
		addi t0, t0,320 			# avanca linha tela
		addi t4,t4,-1			# diminui ctr
		bgez t4, VERT_DRAW
	END:
		
.end_macro

.macro ui_print_score() 		# printa cesta de flores coletadas
	mv a0, s3
	jal ra, ui_print_score_func
		
.end_macro


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# PLAYER
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

.macro print_sapo() 				# printa o sprite do sapo
	mv t0, s1 					# Importa a posicao
	add t0, s3, t0 				# adiciona o endereco do buffer next

	la t1, sapo_spritesheet 		# Importa endereco spritesheet
	addi t1, t1, 8 				# Pula size

	li t2, 12 					# look * width (12) ------> ajusta a posicao olhando
	lb t3, look
	mul t2, t2, t3
	add t1,t1,t2 				# posicao na spritesheet
	

	li t2, 48 					# altera posicao na sprite sheet com base no hp (cor)
	lb t3, hp
	mul t2, t2, t3
	add t1, t1, t2

	
	li t4, 11 					# ctr: 12 linhas
	VERT_DRAW:
		lw t3, 0(t1) 			# Le spritesheet
		sw t3, 0(t0)				# Printa na tela
		lw t3, 4(t1)				# ...
		sw t3, 4(t0)				# ...
		lw t3, 8(t1)
		sw t3, 8(t0)
		
		addi t1, t1, 144			# avanca linha spritesheet
		addi t0, t0,320 			# avanca linha tela
		addi t4,t4,-1			# diminui ctr
		bgez t4, VERT_DRAW
.end_macro

.macro print_player(%reg1, %int) 	# Printa um quadrado das mesmas dimensoes que o player  
	mv t0, %reg1					# Pode ser usado para debugar o  movimento
	li t3, %int					# ou para limpar o rastro do sprite
	add t0, s3, t0 				# 		int = cor
	li t4, 11					# 		reg = posicao
	VERT_DRAW:
		sw t3, 0(t0)				# escrita horizontal
		sw t3, 4(t0)
		sw t3, 8(t0)
		
		addi t0, t0,320 			# escrita vertical
		addi t4,t4,-1
		bgez t4, VERT_DRAW

.end_macro

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# ATAQUE PLAYER
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 


.macro print_atk()				# printa ataque coracao
	lw t0, bullet				# Importa a posicao
	beqz t0, END					# pula tudo se o tiro nao existe
	
	add t0, s3, t0 				# adiciona o endereco do buffer next

	la t1, heart 				# Importa endereco spritesheet
	addi t1, t1, 8 				# Pula size
	
	li t4, 3 					# ctr: 4 linhas
	VERT_DRAW:
		lw t3, 0(t1) 			# Le spritesheet
		sw t3, 0(t0)				# Printa na tela
		
		addi t1, t1, 4			# avanca linha spritesheet
		addi t0, t0,320 			# avanca linha tela
		addi t4,t4,-1			# diminui ctr
		bgez t4, VERT_DRAW
	END:
.end_macro

.macro delete_atk() 				# delete rastro coracao
	lw t0, bullet_prev
	beqz t0, END					# pula tudo se o tiro nao existe
	
	
	li t3, 0x50505050			# limpar o rastro do sprite
	add t0, s4, t0 				# int = cor
	li t4, 3
	VERT_DRAW:
		sw t3, 0(t0)				# escrita horizontal
		
		addi t0, t0,320 			# escrita vertical
		addi t4,t4,-1
		bgez t4, VERT_DRAW
	END:
.end_macro

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# ABELHA
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
.macro print_abelha(%pos) 		# print sprite abelha
								# todo: implementar vida(?)
	mv t0, %pos 					# Importa a posicao
	beqz t0, END					# pula se a abelha nao existe
	
	add t0, s3, t0 				# adiciona o endereco do buffer next

	la t1, viloes		 		# Importa endereco spritesheet
	addi t1, t1, 8 				# Pula size

	
	li t4, 7 					# ctr: 12 linhas
	VERT_DRAW:
		lw t3, 0(t1) 			# Le spritesheet
		sw t3, 0(t0)				# Printa na tela
		lw t3, 4(t1)				# ...
		sw t3, 4(t0)				# ...

		
		addi t1, t1, 32			# avanca linha spritesheet
		addi t0, t0,320 			# avanca linha tela
		addi t4,t4,-1			# diminui ctr
		bgez t4, VERT_DRAW
	END:
.end_macro

.macro del_abelha(%pos)			# limpar rastro abelha
	mv t0, %pos 					# Importa a posicao
	beqz t0, END					# pula se a abelha nao existe
	
	add t0, s4, t0 				# adiciona o endereco do buffer next


	li t3, 0x50505050			# limpar o rastro do sprite
	li t4, 7 					# ctr: 12 linhas
	VERT_DRAW:
		sw t3, 0(t0)				# Printa na tela
		sw t3, 4(t0)				# ...

		addi t0, t0,320 			# avanca linha tela
		addi t4,t4,-1			# diminui ctr
		bgez t4, VERT_DRAW
	END:
.end_macro

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# MENU
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
.macro print_win()
	mv t1,s3				# endereco inicial da Memoria VGA
	
	la t4, YouWon
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
.end_macro

.macro print_menu()
	mv t1,s3				# endereco inicial da Memoria VGA
	
	la t4, tela_menu
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
.end_macro

.macro print_game_over()
	mv t1,s3				# endereco inicial da Memoria VGA
	
	la t4, GameOver
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
.end_macro


.macro print_info()
	mv t1,s3				# endereco inicial da Memoria VGA
	
	la t4, tela_info
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
.end_macro
