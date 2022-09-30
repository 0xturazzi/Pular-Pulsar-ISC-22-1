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

.text
MAIN:
	setup_level_1()
POOLING_LOOP:
	update_level_1()
	j POOLING_LOOP
	exit()

