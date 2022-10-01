.data
.include "../game/data/background.data"
.include "../game/data/map1.data"
.include "../game/data/map0.data"

.include "../game/data/sapo_spritesheet.data"
.include "../game/data/heart.data"

.include "../game/data/viloes.data"

.text

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# BAcKGROUND
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

.macro print_bg()
	mv t1,s3	# endereco inicial da Memoria VGA
	
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
	mv t1,s3	# endereco inicial da Memoria VGA
	
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
	mv t1,s3	# endereco inicial da Memoria VGA
	
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
# PLAYER
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

.macro print_sapo()
	mv t0, s1 					# Importa a posicao
	add t0, s3, t0 				# adiciona o endereco do buffer next

	la t1, sapo_spritesheet 		# Importa endereco spritesheet
	addi t1, t1, 8 				# Pula size

	li t2, 12 					# look * width (12) ------> ajusta a posicao olhando
	lb t3, look
	mul t2, t2, t3
	add t1,t1,t2 				
	

	li t2, 48
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
	beqz t0, END
	
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
	beqz t0, END
	
	
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
.macro print_abelha(%pos)#, %vida) 		# print sprite abelha
									# todo: implementar vida(?)
	mv t0, %pos 					# Importa a posicao
	beqz t0, END
	
	add t0, s3, t0 				# adiciona o endereco do buffer next

	la t1, viloes		 		# Importa endereco spritesheet
	addi t1, t1, 8 				# Pula size

#	li t2, 48
#	lb t3, hp
#	mul t2, t2, t3
#	add t1, t1, t2

	
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
	beqz t0, END
	
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
