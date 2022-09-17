.data
.include "../game/data/background.data"
.include "../game/data/sapo_spritesheet.data"

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
		beq t0,t3,OUT	# Se for o �ltimo endere�o ent�o sai do loop
		lw t5, 0(t4) 	# le o pixel
		sw t5,0(t1)		# escreve a word na mem�ria
		addi t1,t1,4		# soma 4 ao endere�o
		addi t4,t4,4 	# avanca 4 pixels
		addi t0,t0,4 	# contador +4
		j LOOP			
	OUT:
.end_macro

	
.macro print_sapo() 	# Printa um quadrado verde que eu to fingindo ser o player  
	mv t0, s1
	
	add t0, s3, t0 	
	la t1, sapo_spritesheet
	addi t1, t1, 8
	li t2, 12
	lb t3, look
	mul t2, t2, t3
	add t1,t1,t2
	
	li t4, 11
	VERT_DRAW:
		lw t3, 0(t1)
		sw t3, 0(t0)
		lw t3, 4(t1)
		sw t3, 4(t0)
		lw t3, 8(t1)
		sw t3, 8(t0)
		
		addi t1, t1, 144
		addi t0, t0,320
		addi t4,t4,-1
		bgez t4, VERT_DRAW

.end_macro
