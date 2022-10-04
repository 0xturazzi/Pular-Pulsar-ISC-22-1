.text
.macro move_abelha(%pos) 	# Movimenta a abelha com base na distancia ate o player
	mv a0, %pos
	mv a1, s1
	mv a2, s3
	jal ra, move_abelha_func
	mv %pos, a0
.end_macro

### MOVE ABELHA foi movida para game.asm para garantir que compila as funcoes na ordem correta