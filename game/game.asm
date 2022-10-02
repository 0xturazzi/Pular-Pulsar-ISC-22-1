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
	setup_level_0()
POOLING_LOOP:
	ui_print_gas() 
	update_level_0()
	j POOLING_LOOP

