.data
pos_besouro_min: .word 0
pos_besouro_max: .word 0
pos_besouro: .word 0
pos_prev_besouro: .word 0
besouro_look: .byte 0
pedra_look: .byte 0
pos_pedra: .word 0
pos_prev_pedra: .word 0
.text
.macro besouro_move_pedra()
	mv a0, s1
	jal ra, besouro_move_pedra
.end_macro

.macro besouro_move()
	mv a0, s1
	jal ra, besouro_move_func
.end_macro
