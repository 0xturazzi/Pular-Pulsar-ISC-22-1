.data
.include "../game/data/background.data"
.include "../game/data/map1.data"

.include "../game/data/sapo_spritesheet.data"
.include "../game/data/heart.data"

.text
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

.macro print_atk()
	mv t0, s1 					# Importa a posicao
	add t0, s3, t0 				# adiciona o endereco do buffer next

	lb t1, look 					# centralize bullet
	li t2, 2
	rem t1, t1, t2 
	bnez t1, leftright
	addi t0,t0 4
	 j end_center
	leftright:
		addi t0, t0, 1280
	end_center:

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
.end_macro
