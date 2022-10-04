.data
flor_win: .byte 1
pos_flor: .word 0
flor_lv_0: .word 0x6a18
flor_lv_1: .word 0xcd18,0x781c

.text
.macro flor_coleta()
		lw t1, pos_flor 
		mv t2, s1

		li t3, 320			# diferenca hor
		rem t4, t2, t3
		rem t5, t1, t3		# extrair posicao hor	
	
		sub t5,t4,t5
		abs(t5)
		li t6, 10
		bgt t5, t6, NO_COL 		# | delta X |  > 10
	
	
		div t4, t2, t3	# diferenca vert
		div t5, t1, t3 	# extrair posicao vert
		sub t5,t5,t4
		abs(t5)
		li t3, 10
		bgt t5, t3,NO_COL 		# | delta Y |  > 10
	
		# PEGOU A FLOR
		lb t0, flor_win
		addi t0, t0, -1
		sb t0, flor_win, t1
		spawn_flor()
		
		NO_COL:
.end_macro

.macro spawn_flor()
	lb t0, current_level
	lb t1, flor_win
	beqz t1, NO_FLOR
	
	beqz t0, lv_0
	addi t0, t0, -1
	beqz t0, lv_1
	j END
	lv_0:
		lw t0, flor_lv_0
		sw t0, pos_flor, t1
		j END
	lv_1:
		la t2, flor_lv_1
		addi t1, t1, -1
		beqz t1, flor_1
		lw t3, 0(t2)
		j flor_0
		flor_1:
			lw t3, 4(t2)
		flor_0:
		sw t3, pos_flor, t1 
		j END
	NO_FLOR:
		sw zero, pos_flor, t1
	END:
.end_macro
