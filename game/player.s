.macro print_player(%reg1, %reg2, %int)
	mv t0, %reg1

	
	li t3, %int
	
	add t0, %reg2, t0
	li t4, 11
	VERT_DRAW:
		sw t3, 0(t0)
		sw t3, 4(t0)
		sw t3, 8(t0)
		
		addi t0, t0,320
		addi t4,t4,-1
		bgez t4, VERT_DRAW

.end_macro

.macro move_player()

	li t2, 119
	beq t2, a0, UP
	li t2, 115
	beq t2, a0, DOWN
	li t2, 97
	beq t2, a0, LEFT
	li t2, 100
	beq t2, a0, RIGHT
	j END
UP:
	mv s2,s1
	li t0, 7680 #320 x 24
	ble s1, t0, END
	addi s1,s1,-1280
	j END
	
DOWN:
	mv s2,s1
	li t0, 57600 # 320 x 180
	bge s1, t0, END
	addi s1,s1,1280
	j END
	
LEFT:
	mv s2,s1
	li t0, 20
	li t3, 320
	rem t1, s1, t3
	ble t1, t0, END
	addi s1,s1,-4
	j END
	
RIGHT:
	mv s2,s1
	li t0, 288
	li t3, 320
	rem t1, s1, t3
	bge t1, t0, END
	addi s1,s1,4
	j END
	
END:
.end_macro

