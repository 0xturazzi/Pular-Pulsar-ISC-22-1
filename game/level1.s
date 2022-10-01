.macro setup_level_1()
	SETUP_REGS() 					# Setup registradores reservados


	# Printa o Background e player nos 2 buffers
	print_map1()
	print_sapo()
	
	NEXT_FRAME()
	
	print_map1()
	print_sapo()
	
	li s0,0xFF200604					# Garantir que sempre comeca na frame 0
	li t2,0
	sw t2,0(s0)
	
	# como tem poucos inimigos, da pra usar register pra posicao
	li s7, 0x7380                    # ABELHA
	li s8, 0x0000d27c
	li s9, 0x000050ec 
	li s10, 0x00006e2c      
.end_macro

.macro update_level_1()
	NEXT_FRAME()					# Prox frame
	#dump_regs() 						# Ignorar: DEBUG
	
	li s0, MMIO_set 					# Checar se tem input para ler
	lb t1, 0(s0)
	beqz t1, NO_INPUT				# se nao tem input, pula a movimentacao
	lw a0, MMIO_add					# Endereco Dados MMIO
	#syscall(11)						# Ignorar: DEBUG

	cheat() 						# checar input de cheat

	move_player() 					# se nao tem input, pula a movimentacao
	attack_player()					# checar input de ataque

	NO_INPUT:
		next_slow_count()
		move_bullet() 				# ataque do player
		delete_atk()
		print_atk()
	
		print_player(s2, 0x50505050) 	# apaga player antigo
		print_sapo()					# print sprite do player 

		move_abelha(s7)					# Abelha s7
		print_abelha(s7)
		move_abelha(s8)					# Abelha s8
		print_abelha(s8)
		move_abelha(s9)					# Abelha s9
		print_abelha(s9)
		move_abelha(s10)					# Abelha s10
		print_abelha(s10)
.end_macro
