#### RESERVADOS
# s1 posicao player
# s2 posicao passada
# s3 next write buffer
# s4 last write buffer

.text
.include "player.s"
.include "artmanager.s"
.include "MACROS.s"
.include "abelha.s"
.include "level1.s"
.include "level0.s"

.text
MAIN:
	sb zero, died, t0
	setup_current_level()
	
POOLING_LOOP:
	update_ui()
	update_level_0()
	#update_current_level()
	
	lb t0, died
	bnez t0, MAIN
	
	lb t0, flor_win
	bnez t0, POOLING_LOOP
	lb t0, current_level
	addi t0, t0, 1
	sb t0, current_level, t1
	j MAIN