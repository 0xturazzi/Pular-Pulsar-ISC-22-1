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
#print_player(s2,s3,0xbfbfbfbf)

.end_macro



#### RESERVADOS
# s1 posicao 
# s2 posicao passada
# s3 next write
# s4 last write

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

