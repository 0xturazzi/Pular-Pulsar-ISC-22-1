.text
.macro setup_level_0()
	SETUP_DATA()					# setup .data (combustivel/hp) apos morte
	SETUP_REGS() 					# Setup registradores reservados

	li t1, 1 
	sb t1, flor_win, t2				# Quantidade de chaves/flores para condicao de vitoria
	spawn_flor()

									# Printa o Background , flor e player nos 2 buffers
	print_map0()
	print_sapo()
	print_flor()
	
	NEXT_FRAME()
	
	print_map0()
	print_sapo()
	print_flor()
	
	li s0,0xFF200604					# Garantir que sempre comeca na frame 0
	li t2,0
	sw t2,0(s0)
	
									# como tem poucos inimigos, da pra usar register pra posicao
	li s7, 0x4b20  # ABELHA
	li s8, 0xcd2c  # ABELHA     
	li s9, 0x9c18  # ABELHA
	li s10, 0 						# zerado para poder utilizar o mesmo runtime que o level 1
	
	li t0, 3							# trajeto linear que o besouro pode andar e direcao de movimento inicial
	sb t0, besouro_look, t1
	li t0, 0x2914					# diagonal superior direita
	sw t0, pos_besouro, t1
	sw t0, pos_besouro_max, t1
	li t0, 0x2824					# diagonal superior esquerda
	sw t0, pos_besouro_min, t1
.end_macro

.macro setup_level_1()
	SETUP_DATA()					# setup .data (combustivel/hp) apos morte
	SETUP_REGS() 					# Setup registradores reservados

	li t0, 2
	sb t0, flor_win, t1 				# quantidade de chaves para condicao de vitoria
	spawn_flor()

									# Printa o Background, flor e player nos 2 buffers
	print_map1()
	print_sapo()
	
	NEXT_FRAME()
	
	print_map1()
	print_sapo()
	
	li s0,0xFF200604					# Garantir que sempre comeca na frame 0
	li t2,0
	sw t2,0(s0)
	
	# como tem poucos inimigos, da pra usar register pra posicao
	# caso tivesse mais, seria armazenado no .data
	li s7, 0x7380 # ABELHA
	li s8, 0xd27c # ABELHA
	li s9, 0x50ec # ABELHA
	li s10,0x6e2c # ABELHA
.end_macro

.macro update_level()
	flor_coleta()					# colisao com a flor
	print_flor()

	level_update_input()			# ler input MMIO
	
	level_update_player_actions() 	# acoes do player: mover, atirar, avancar posicao do tiro, etc
	
	move_abelha(s7)					# Abelha s7
	print_abelha(s7)
	move_abelha(s8)					# Abelha s8
	print_abelha(s8)
	move_abelha(s9)					# Abelha s9
	print_abelha(s9)
	move_abelha(s10)					# Abelha s9
	print_abelha(s10)
	
	besouro_move()					# Besouro
	besouro_move_pedra()
	del_besouro()
	print_besouro()
	del_pedra()
	print_pedra()
.end_macro
