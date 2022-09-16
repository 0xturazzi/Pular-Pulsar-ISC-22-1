

#### RESERVADOS
# s1 posicao 
# s2 posicao passada
# s3 next write
# s4 last write

.include "player.s"
.include "MACROS.s"
.text
MAIN:
	SETUP_REGS()
	SCREEN_PURPLE_0()
	SCREEN_PURPLE_1()
	print_player(s1,s3, 0x71717171)
	NEXT_FRAME()
	print_player(s1,s3, 0x71717171)

POOLING_LOOP:
	NEXT_FRAME()

	
	li s0, MMIO_set
	lb t1, 0(s0)
	beqz t1, NO_INPUT	# ready bit == 0
	lw a0, MMIO_add		# Dados MMIO
	#syscall(11)

	move_player()
	NO_INPUT:
	print_player(s2,s3, 0x82828282)
	print_player(s1,s3, 0x71717171)



	j POOLING_LOOP
	exit()

