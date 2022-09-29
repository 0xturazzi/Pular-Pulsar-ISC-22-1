#### RESERVADOS
# s1 posicao player
# s2 posicao passada
# s3 next write buffer
# s4 last write buffer

.text
.include "player.s"
.include "artmanager.s"
.include "MACROS.s"

.text
MAIN:
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

POOLING_LOOP:
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
		move_bullet() 				# ataque do player
		delete_atk()
		print_atk()

	
		print_player(s2, 0x50505050) 	# apaga player antigo
		print_sapo()					# print sprite do player 


	j POOLING_LOOP
	exit()

