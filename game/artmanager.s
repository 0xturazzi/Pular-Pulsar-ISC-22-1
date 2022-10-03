.data
.include "../game/data/background.data"
.include "../game/data/map1.data"
.include "../game/data/map0.data"

.include "../game/data/sapo_spritesheet.data"
.include "../game/data/heart.data"

.include "../game/data/viloes.data"

.include "../game/data/carencia.data"
.include "../game/data/vidamenu.data"

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

.macro print_map1()
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

.macro print_map0()
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
# UI
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

.macro ui_print_vida() 		# printa vida (3 sapinhos)
	lb t0, vida

	li t1, 480 				# 40 * 12
	mul t0, t0, t1 			# posicao na spritesheet
	
	la t1, vidamenu
	addi t1,t1,8 			# skip size
	add t1, t1, t0 			# posicao na spritesheet	
	
	li t0, 67420
	add t0, t0, s3 			# posicao na tela 67200 (320*210) + 220
	li t4, 11 				# ctr: 11 linhas
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
        lw t3, 32(t1) # Le spritesheet
        sw t3, 32(t0) # Printa na tela
        lw t3, 36(t1) # Le spritesheet
        sw t3, 36(t0) # Printa na tela

		addi t1, t1, 40			# avanca linha spritesheet
		addi t0, t0,320 			# avanca linha tela
		addi t4,t4,-1			# diminui ctr
		bgez t4, VERT_DRAW
	END:
		
.end_macro

.macro ui_print_gas() 			# printa gasolina
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
	VERT_DRAW:
	
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
		bgez t4, VERT_DRAW
	END:
	
	
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


