.macro setup_level_0()
	SETUP_REGS() 					# Setup registradores reservados


	# Printa o Background e player nos 2 buffers
	print_map0()
	print_sapo()
	
	NEXT_FRAME()
	
	print_map0()
	print_sapo()
	
	li s0,0xFF200604					# Garantir que sempre comeca na frame 0
	li t2,0
	sw t2,0(s0)
	
	# como tem poucos inimigos, da pra usar register pra posicao
	li s7, 0x4b20                  # ABELHA
	li s8, 0xcd2c       
	li s9, 0x9c18         
.end_macro

.macro update_level_0()
	level_update_input()
	
	level_update_player_actions()
		
	move_abelha(s7)					# Abelha s7
	print_abelha(s7)
	move_abelha(s8)					# Abelha s8
	print_abelha(s8)
	move_abelha(s9)					# Abelha s9
	print_abelha(s9)
.end_macro
